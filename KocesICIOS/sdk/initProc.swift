//
//  initProc.swift
//  osxapp
//
//  Created by 金載龍 on 2021/01/09.
//

import UIKit
import DeviceCheck
import CryptoKit
import CommonCrypto
import Siren

class initProc {
    static let shared = initProc()

    struct MobileProvision: Decodable {
        var name: String
        var appIDName: String
        var platform: [String]
        var isXcodeManaged: Bool? = false
        var creationDate: Date
        var expirationDate: Date
        var entitlements: Entitlements
        
        private enum CodingKeys : String, CodingKey {
            case name = "Name"
            case appIDName = "AppIDName"
            case platform = "Platform"
            case isXcodeManaged = "IsXcodeManaged"
            case creationDate = "CreationDate"
            case expirationDate = "ExpirationDate"
            case entitlements = "Entitlements"
        }
        
        // Sublevel: decode entitlements informations
        struct Entitlements: Decodable {
            let keychainAccessGroups: [String]
            let getTaskAllow: Bool
            let apsEnvironment: Environment
            
            private enum CodingKeys: String, CodingKey {
                case keychainAccessGroups = "keychain-access-groups"
                case getTaskAllow = "get-task-allow"
                case apsEnvironment = "aps-environment"
            }
            
            enum Environment: String, Decodable {
                case development, production, disabled
            }
            
            init(keychainAccessGroups: Array<String>, getTaskAllow: Bool, apsEnvironment: Environment) {
                self.keychainAccessGroups = keychainAccessGroups
                self.getTaskAllow = getTaskAllow
                self.apsEnvironment = apsEnvironment
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let keychainAccessGroups: [String] = (try? container.decode([String].self, forKey: .keychainAccessGroups)) ?? []
                let getTaskAllow: Bool = (try? container.decode(Bool.self, forKey: .getTaskAllow)) ?? false
                let apsEnvironment: Environment = (try? container.decode(Environment.self, forKey: .apsEnvironment)) ?? .disabled
                
                self.init(keychainAccessGroups: keychainAccessGroups, getTaskAllow: getTaskAllow, apsEnvironment: apsEnvironment)
            }
        }
    }
    
    /// 앱 무결성 검사
    /// - Returns: 성공,실패
    func AppVerity() -> String {
        let profilePath:String? = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision")
        guard let path = profilePath else {
            let bundleIdentifier =  Bundle.main.bundleIdentifier ?? ""
            if bundleIdentifier.contains("com.jam.KocesICIOS") ||
                bundleIdentifier.contains("com.KOCES.KocesICIOS") ||
                bundleIdentifier.contains("com.koces.KocesICIOSPay") {
                return ""
            }
            return "앱 번들ID 불일치(Error = 1). 앱 무결성 검사에 실패하였습니다"
        }
        
        guard let plistDataString = try? NSString.init(contentsOfFile: path,
                                                               encoding: String.Encoding.isoLatin1.rawValue) else { return "앱 프로필 경로 불일치(Error = 1). 앱 무결성 검사에 실패하였습니다" }
                        
                // Skip binary part at the start of the mobile provisionning profile
                let scanner = Scanner(string: plistDataString as String)
                guard scanner.scanUpTo("<plist", into: nil) != false else { return "앱 프로필 경로 불일치(Error = 2). 앱 무결성 검사에 실패하였습니다" }
                
                // ... and extract plist until end of plist payload (skip the end binary part.
                var extractedPlist: NSString?
                guard scanner.scanUpTo("</plist>", into: &extractedPlist) != false else { return "앱 프로필 경로 불일치(Error = 3). 앱 무결성 검사에 실패하였습니다" }
                
                guard let plist = extractedPlist?.appending("</plist>").data(using: .isoLatin1) else { return "앱 프로필 경로 불일치(Error = 4). 앱 무결성 검사에 실패하였습니다" }
                let decoder = PropertyListDecoder()
                do {
                    let provision = try decoder.decode(MobileProvision.self, from: plist)

                    if provision.name.contains("com.KOCES.KocesICIOS")
                        ||  provision.name.contains("com.jam.KocesICIOS")
                        ||  provision.name.contains("com.koces.KocesICIOSPay")
                    {
                        return ""
                    }
                    else
                    {
                        return "앱 번들ID 불일치(Error = 2). 앱 무결성 검사에 실패하였습니다"
                    }
                    
                } catch {
                    // TODO: log / handle error
                    return "앱 번들ID 불일치(Error = 3). 앱 무결성 검사에 실패하였습니다"
                }
        
        return ""
    }
    
    /** 번들ID 를 sha1 로 해시값을 뜨고 해당 값을 기록한 후 향후 해당값을 비교하면 앱이 바뀌었는지를 확인 할 수 있다 */
    func sha1(_msg:String) -> String {
        let data = Data(_msg.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
    /**
     애플서버에 요청하여 현재의 앱의 서명키가 변경되었는지 체크
     */
    func AppAttestDeviceCheck(Listener _listener:AppAttestResultDelegate) {

        let service = DCAppAttestService.shared
        
        if !Setting.shared.getDefaultUserData(_key: "APPVERITY").isEmpty && Setting.shared.getDefaultUserData(_key: "APPVERITY") == "성공" {
            let bundleIdentifier =  Bundle.main.bundleIdentifier ?? ""

            //만일 SHA 해시한 값이 기존과 변경되어 있다면 이 앱은 손상된 버전이다.
            if !Setting.shared.getDefaultUserData(_key: "SHA").isEmpty && Setting.shared.getDefaultUserData(_key: "SHA") != self.sha1(_msg: bundleIdentifier) {
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "SHA1 해시 값 손상"
                Setting.shared.setDefaultUserData(_data: "실패", _key: "APPVERITY")
                Setting.shared.setDefaultUserData(_data: "", _key: "APPATTEST")
                Setting.shared.setDefaultUserData(_data: "", _key: "SHA")
                _listener.onAppAttestResult(AppAttest: .FAIL, Result: resDataDic)
                return
            }
            let challenge = self.sha1(_msg: bundleIdentifier).data(using: .utf8)!


            let hash = Data(SHA256.hash(data: challenge))
            service.attestKey(Setting.shared.getDefaultUserData(_key: "APPATTEST"), clientDataHash: hash) { attestation, error in
                guard error == nil else {
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "애플서버와 키일치 실패." + "\n" + error!.localizedDescription
                    Setting.shared.setDefaultUserData(_data: "실패", _key: "APPVERITY")
                    Setting.shared.setDefaultUserData(_data: "", _key: "APPATTEST")
                    Setting.shared.setDefaultUserData(_data: "", _key: "SHA")
                    _listener.onAppAttestResult(AppAttest: .FAIL, Result: resDataDic)
                    return
                }
//                let attestationString = attestation?.base64EncodedString()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "정상"
                _listener.onAppAttestResult(AppAttest: .SUCCESS, Result: resDataDic)
                return
                // Send the attestation to the server. It now has access to the public key!
                // If it fails, throw the identifier away and start over.
            }
            return
        }
     
        service.generateKey { (keyIdentifier, error) in
            guard error == nil else {
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "키 생성 실패." + "\n" + error!.localizedDescription
                Setting.shared.setDefaultUserData(_data: "실패", _key: "APPVERITY")
                Setting.shared.setDefaultUserData(_data: "", _key: "APPATTEST")
                Setting.shared.setDefaultUserData(_data: "", _key: "SHA")
                _listener.onAppAttestResult(AppAttest: .FAIL, Result: resDataDic)
                return
            }
            //IOS 기기는 반드시 서포트 하기 때문에 체크 할 필요없다. 간혹 맥OS 에서는 서포트 DCAppAttestService 를 지원하지 않는 경우가 있다.(아주 오래된 버전)
            if service.isSupported {  }
 
      
            
            let bundleIdentifier =  Bundle.main.bundleIdentifier ?? ""

            //만일 SHA 해시한 값이 기존과 변경되어 있다면 이 앱은 손상된 버전이다.
//            if !Setting.shared.getDefaultUserData(_key: "SHA").isEmpty && Setting.shared.getDefaultUserData(_key: "SHA") != self.sha1(_msg: bundleIdentifier) {
//                var resDataDic:[String:String] = [:]
//                resDataDic["Message"] = "SHA1 해시 값 손상"
//                _listener.onAppAttestResult(AppAttest: .FAIL, Result: resDataDic)
//                return
//            }
            
  
            
            let challenge = self.sha1(_msg: bundleIdentifier).data(using: .utf8)!
          
           
            let hash = Data(SHA256.hash(data: challenge))
            service.attestKey(keyIdentifier!, clientDataHash: hash) { attestation, error in
                guard error == nil else {
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "애플서버와 키일치 실패." + "\n" + error!.localizedDescription
                    Setting.shared.setDefaultUserData(_data: "실패", _key: "APPVERITY")
                    Setting.shared.setDefaultUserData(_data: "", _key: "APPATTEST")
                    Setting.shared.setDefaultUserData(_data: "", _key: "SHA")
                    _listener.onAppAttestResult(AppAttest: .FAIL, Result: resDataDic)
                    return
                }
//                let attestationString = attestation?.base64EncodedString()
                Setting.shared.setDefaultUserData(_data: keyIdentifier.unsafelyUnwrapped, _key: "APPATTEST")
                Setting.shared.setDefaultUserData(_data: self.sha1(_msg: bundleIdentifier), _key: "SHA")
                Setting.shared.setDefaultUserData(_data: "성공", _key: "APPVERITY")
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "정상"
                _listener.onAppAttestResult(AppAttest: .SUCCESS, Result: resDataDic)
                return
                // Send the attestation to the server. It now has access to the public key!
                // If it fails, throw the identifier away and start over.
            }
        }
    }
    
    /**
     탈옥 폰인지 아닌지 체크
     */
    func hasJailbreak() -> Bool {
            
        guard let cydiaUrlScheme = NSURL(string: "cydia://package/com.example.package") else{
                return false
            }
        
            if UIApplication.shared.canOpenURL(cydiaUrlScheme as URL) {
                return true
            }
            #if arch(i386) || arch(x86_64)
            return false
            #endif
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
                fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
                fileManager.fileExists(atPath: "/bin/bash") ||
                fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
                fileManager.fileExists(atPath: "/etc/apt") ||
                fileManager.fileExists(atPath: "/usr/bin/ssh") ||
                fileManager.fileExists(atPath: "/private/var/lib/apt") {
                return true
            }
            if canOpen(path: "/Applications/Cydia.app") ||
                canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
                canOpen(path: "/bin/bash") ||
                canOpen(path: "/usr/sbin/sshd") ||
                canOpen(path: "/etc/apt") ||
                canOpen(path: "/usr/bin/ssh") {
                return true
            }
            let path = "/private/" + NSUUID().uuidString
            do {
                try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                try fileManager.removeItem(atPath: path)
                return true
            } catch {
                return false
            }
        }
        func canOpen(path: String) -> Bool {
            let file = fopen(path, "r")
            guard file != nil else { return false }
            fclose(file)
            return true
        }
    
    
    /**
     현재 버전이 최신버전인지를 체크하고 업데이트 메세지를 보여준다
     */
    func IsNewVersionUpdated(Listener _listener:AppVersionUpdateDelegate){
        
        let siren = Siren.shared
//        siren.apiManager = APIManager(country: .korea) //기준 위치 대한민국 앱스토어로 변경
//        siren.presentationManager = PresentationManager(forceLanguageLocalization: .korean) //알림 메시지 한국어로
        siren.rulesManager = RulesManager(majorUpdateRules: .critical,
                                          minorUpdateRules: .annoying,
                                          patchUpdateRules: .default,
                                          revisionUpdateRules: .relaxed)
         let us = siren.wail { results in
            switch results {
            case .success(let updateResults):
                debugPrint("AlertAction -> ", updateResults.alertAction)
                debugPrint("Localization -> ", updateResults.localization)
                debugPrint("Model -> ", updateResults.model)
                debugPrint("UpdateType -> ", updateResults.updateType)
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "업데이트 성공"
                _listener.onAppUpdateResult(UpdateState: .SUCCESS, Result: resDataDic)
            case .failure(let error):
                debugPrint("error -> ", error.localizedDescription)
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "앱을 다시 시작하여 업데이트를 재시작하거나 앱 제거 후 다시 설치해 주십시오." + "\n" + error.localizedDescription
                _listener.onAppUpdateResult(UpdateState: .FAIL, Result: resDataDic)
            }
            
        }
    }
}
