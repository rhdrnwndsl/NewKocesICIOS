//
//  Aes.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2023/11/28.
//

import Foundation
import CryptoSwift
 
//라이브러리 : https://github.com/krzyzanowskim/CryptoSwift
//pod 'CryptoSwift', '~> 1.3.8'
class Aes {
    //키값 32바이트: AES256(24bytes: AES192, 16bytes: AES128)
    private static let SECRET_KEY = "01234567890123450123456789012345"
    private static let IV = "0123456789012345"
 
    static func encrypt(string: String) -> String {
        guard !string.isEmpty else { return "" }
        return try! getAESObject().encrypt(string.bytes).toBase64() ?? ""
    }
 
    static func decrypt(_key : [UInt8], encoded: [UInt8]) -> [UInt8] {
//        let datas = Data(base64Encoded: encoded)
//
//        guard datas != nil else {
//            return ""
//        }
        let iv: Array<UInt8> = [0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f]
        do {
            let decrypted = try AES(key: _key, blockMode: CFB(iv: iv), padding: .noPadding).decrypt(encoded)
            let decryptedData = Data(decrypted)
            
            return decrypted
//            let bytes = datas!.bytes
//            let decode = try! getAESObject().decrypt(bytes)
        }  catch {
            print(error)
            return []
        }
    }

 
    private static func getAESObject() -> AES{
        let keyDecodes : Array<UInt8> = Array(SECRET_KEY.utf8)
        let ivDecodes : Array<UInt8> = Array(IV.utf8)
        let aesObject = try! AES(key: keyDecodes, blockMode: CBC(iv: ivDecodes), padding: .pkcs5)
 
        return aesObject
    }
}
