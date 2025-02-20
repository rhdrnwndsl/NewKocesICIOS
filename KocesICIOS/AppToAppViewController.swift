//
//  AppToAppViewController.swift
//  osxapp
//
//  Created by 신진우 on 2021/01/20.
//

import Foundation
import UIKit
import SystemConfiguration
import SafariServices

class AppToAppViewController: UIViewController, AppAttestResultDelegate, AppVersionUpdateDelegate {
    
 
//    func mPaymentResultListener(Message _message: String) {
//        //PaySdk 에 등록한 델리게이트를 통해 이곳으로 결과값을 전달한다
//    }
    
    let mKocesSdk:KocesSdk = KocesSdk.instance
    let mSqlite:sqlite = sqlite.instance
    
    var mpaySdk:PaySdk = PaySdk.instance
    var mCatSdk:CatSdk = CatSdk.instance
    var mKakaoSdk:KaKaoPaySdk = KaKaoPaySdk.instance
    
    var listener: TcpResult?
    var paylistener: payResult?
    var printlistener: PrintResult?
    var catlistener:CatResult?
    
    var veritylistener:AppAttestResult?
    var updatelistener:AppUpdateResult?
    
    var alert = UIAlertController()
    var devices:[[String: Any]] = [[String: Any]]()

    var ViewStart:Bool = false  //해당 뷰를 연속으로 실행하는 것을 방지한다
    
    var WebORApp:Int = 0 // 웹에서 호출한건지 엡에서 호출한건지를 체크한다 0=웹 1=엡 디폴트=웹
    
    var scanTimeout:Timer? //프린트시 타임아웃설정
    
    var keyUpdateResultFail:Int = 0
    
    var tmpTid = ""
    var tmpBsn = ""
    var tmpSerial = ""
    
    var tmpTrdType = ""
    var tmpBillNo = ""
    var tmpresDicData:[String:String] = [:]
    var printMsg = ""
    
    var WebToAppSendDataFail:Int = 0    //0은 정상. 1은 실패
    var keyUpdateCount:Int = 0
    var countAck: Int = 0
    var _keyDownloadResult:[String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        mpaySdk.Clear()
//        mpaySdk = PaySdk.instance
//        mCatSdk.Clear()
//        mCatSdk = CatSdk.instance
//        mKakaoSdk.Clear()
//        mKakaoSdk = KaKaoPaySdk.instance
//        listener = TcpResult()
//        listener?.delegate = self
//        paylistener = payResult()
//        paylistener?.delegate = self
//        printlistener = PrintResult()
//        printlistener?.delegate = self
//        catlistener = CatResult()
//        catlistener?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(didActivate), name: UIScene.willEnterForegroundNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        //등록된 노티 전체 제거
        NotificationCenter.default.removeObserver(self)
        //등록된 노티 개별 제거
//        NotificationCenter.default.removeObserver ( self, name : UIScene.didActivateNotification , object : nil )
//        NotificationCenter.default.removeObserver ( self, name : NSNotification.Name(rawValue: "BLEStatus") , object : nil )
    }
    
    /**
     루팅 체크 함수
     - returns  false -> 정상. true -> 루팅
     */
    func checkAppVerity() -> Bool {
        
        #if DEBUG
        return false
        #endif
//        let _appVerity:String = initProc.shared.AppVerity()
//        if(_appVerity != ""){
////            let dialog = UIAlertController(title: nil, message: _appVerity, preferredStyle: .alert)
////            let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){
////                        (action:UIAlertAction!) in
////                DispatchQueue.main.async {
////                    self.ViewStart = false
////                    UIApplication.shared.perform (#selector (NSXPCConnection.suspend))
////                }
////
////            }
////            dialog.addAction(action)
////            self.present(dialog, animated: true, completion: nil)
//
//            return false
//        }
        
        if(initProc.shared.hasJailbreak()){
            let dialog = UIAlertController(title: nil, message: "탈옥, 루팅 의심되는 기기입니다.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){
                        (action:UIAlertAction!) in
                DispatchQueue.main.async {
                    self.ViewStart = false
                    UIApplication.shared.perform (#selector (NSXPCConnection.suspend))
                }

            }
            dialog.addAction(action)
            self.present(dialog, animated: true, completion: nil)

        }
        
        return false
    }

    func BleStatus(ble bleStatus:String) {
        switch bleStatus {
        case define.ScanSuccess:
            print("BLE_Status :", bleStatus)
            self.ViewStart = false
            var message:String = "연결 가능한 목록입니다"
            if self.mKocesSdk.manager.devices.count == 0 {
                message = "연결 가능한 디바이스가 존재하지 않습니다"
            }
            
            let blealert = UIAlertController(title: "리더기연결", message: message, preferredStyle: .alert)
            
            if self.mKocesSdk.manager.devices.count == 0 {
                let button = UIAlertAction(title: "확인", style: .default){ (Action) in
                    //목록이 없으면 앱투앱을 실행시킨다
//                    exit(0)
//                    self.AppToAppCommand()
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = message
                    self.onResult(tcpStatus: .fail, Result: recDicData)
                }
                blealert.addAction(button)
            }
            else {
                for i in 0 ..< self.mKocesSdk.manager.devices.count {
                    let device = self.mKocesSdk.devices[i]
                    let TempDeviceName:String = String(describing: device["device"].unsafelyUnwrapped)
                    var deviceName:String = ""
                    if TempDeviceName != "" {
                        let temp = TempDeviceName.components(separatedBy: ":")
                        if temp.count > 0 {
                            deviceName = String(temp[0])
                        }

                    }
//                    blealert.addAction(UIAlertAction(title: String(describing: device["device"].unsafelyUnwrapped) , style: .default, handler: { (Action) in
//                        let uuid = device["uuid"] as! UUID
//                        self.mKocesSdk.manager.connect(uuid: uuid)
//
//                    }))
                    blealert.addAction(UIAlertAction(title: deviceName , style: .default, handler: { (Action) in
                        let uuid = device["uuid"] as! UUID
                        self.mKocesSdk.manager.connect(uuid: uuid)

                    }))
                }
                let button = UIAlertAction(title: "취소", style: .default, handler: {(action) in
                    //연결을 하지 않고 넘어간다
//                    self.AppToAppCommand()
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "장치연결을 취소하였습니다"
                    self.onResult(tcpStatus: .fail, Result: recDicData)
                })
                blealert.addAction(button)
            }
            alert.dismiss(animated: false) {
                self.present(blealert, animated: true, completion: nil)
            }
         
            
            break
        case define.ConnectStart:
            print("BLE_Status :", bleStatus)
            break
        case define.ConnectSuccess:
            print("BLE_Status :", bleStatus)
            
            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
            
//            alert.dismiss(animated: true, completion: nil)
//            mKocesSdk.GetVerity()   //연결에 성공하면 자동으로 무결성검사 시작
            mKocesSdk.GetVerity()
//            mKocesSdk.GetDeviceInfo(Date: Utils.getDate(format: "yyyyMMddHHmmss") )
            break
        case define.ConnectFail:
            print("BLE_Status :", bleStatus)
            let alertFail = UIAlertController(title: "연결에 실패하였습니다", message: "다시 연결 가능 목록을 검색하시겠습니까", preferredStyle: .alert)
            let failOK = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                self.mKocesSdk.bleConnect()
            })
          
            let failCancel = UIAlertAction(title: "취소", style: .default, handler: {(action) in
                UserDefaults.standard.setValue("", forKey: define.LAST_CONNECT_DEVICE)
//                self.AppToAppCommand()
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "장치연결에 실패하였습니다"
                self.onResult(tcpStatus: .fail, Result: recDicData)
            })
            alertFail.addAction(failCancel)
            alertFail.addAction(failOK)
            alert.dismiss(animated: false) {
                self.present(alertFail, animated: true, completion: nil)
            }
            break
        case define.ConnectTimeOut:
            print("BLE_Status :", bleStatus)
            let alertFail = UIAlertController(title: "연결에 실패하였습니다", message: "장치연결에 실패하였습니다. 아이폰설정으로 이동하여 등록된 블루투스 리더기를 제거해 주십시오", preferredStyle: .alert)
            let failOK = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
          
            let failCancel = UIAlertAction(title: "취소", style: .default, handler: {(action) in
                UserDefaults.standard.setValue("", forKey: define.LAST_CONNECT_DEVICE)
//                self.AppToAppCommand()
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "장치연결에 실패하였습니다"
                self.onResult(tcpStatus: .fail, Result: recDicData)
            })
            alertFail.addAction(failCancel)
            alertFail.addAction(failOK)
            alert.dismiss(animated: false) {
                self.present(alertFail, animated: true, completion: nil)
            }
            break
        case define.Disconnect:
            print("BLE_Status :", bleStatus)
            self.ViewStart = false
            let alertDisconnect = UIAlertController(title: "Disconnect", message: "다시 연결 가능 목록을 검색하시겠습니까", preferredStyle: .alert)
            let disconnectOK = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                self.mKocesSdk.bleConnect()
            })
            
            let disconnectCancel = UIAlertAction(title: "취소", style: .default, handler: {(action) in
                UserDefaults.standard.setValue("", forKey: define.LAST_CONNECT_DEVICE)
//                self.AppToAppCommand()
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "장치연결에 실패하였습니다"
                self.onResult(tcpStatus: .fail, Result: recDicData)
            })
            alertDisconnect.addAction(disconnectCancel)
            alertDisconnect.addAction(disconnectOK)
            alert.dismiss(animated: false) {
                self.present(alertDisconnect, animated: true, completion: nil)
            }
            break
        case define.SendComplete:
            //정상적으로 모두 보냄
//            print("BLE_Status :", bleStatus)
            break
        case define.Receive:
            print("BLE_Status :", bleStatus)
            print("receive_data :", Utils.UInt8ArrayToHexCode(_value: self.mKocesSdk.mReceivedData,_option: true))
            if self.mKocesSdk.mReceivedData.isEmpty {
                return
            }
            
            if self.mKocesSdk.mReceivedData[3] == Command.ACK && countAck == 0 {
                if (mKocesSdk.mBleConnectedName.contains(define.bleName) || mKocesSdk.mBleConnectedName.contains(define.bleNameNew)) {
                    debugPrint("ACK 데이터 버림")
                    countAck += 1
                    return
                } else {
 
                }
            }
            
            countAck = 0
            
            if(self.mKocesSdk.mReceivedData[3] == Command.CMD_VERITY_RES)
            {
                var resTitle:String = "무결성검증실패"
                switch mKocesSdk.mReceivedData[4...5] {
                case [0x30,0x30]:
                    mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "0", Result: "0")
                    //정상
                    resTitle = "무결성검증성공"
                    mKocesSdk.mVerityCheck = define.VerityMethod.Success.rawValue
                    break
                case [0x30,0x31]:
                    mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "0", Result: "1")
                    //실패
                    mKocesSdk.mVerityCheck = define.VerityMethod.Fail.rawValue
                    break
                case [0x30,0x32]:
                    mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "0", Result: "1")
                    //FK검증실패
                    resTitle = "FK검증실패"
                    mKocesSdk.mVerityCheck = define.VerityMethod.Fail.rawValue
                    break
                default:
                    break
                }
                mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                
                mKocesSdk.GetDeviceInfo(Date: Utils.getDate(format: "yyyyMMddHHmmss") )
                
            } else if(self.mKocesSdk.mReceivedData[3] == Command.CMD_POSINFO_RES){
                var spt:Int = 4
                let TmIcNo = Utils.UInt8ArrayToStr(UInt8Array: Array(self.mKocesSdk.mReceivedData[spt...spt + 15]))
                spt += 16
                let UniqueCode = Utils.UInt8ArrayToStr(UInt8Array: Array(self.mKocesSdk.mReceivedData[spt...spt + 15]))
                spt += 16
                let serialNumber = Utils.UInt8ArrayToStr(UInt8Array: Array(self.mKocesSdk.mReceivedData[spt...spt + 9]))
                spt += 10
                let version = Utils.UInt8ArrayToStr(UInt8Array: Array(self.mKocesSdk.mReceivedData[spt...spt + 4]))
                spt += 5
                let key = Utils.UInt8ArrayToStr(UInt8Array: Array(self.mKocesSdk.mReceivedData[spt...spt + 1]))
                

                mKocesSdk.mKocesCode = define.KOCES_ID
                mKocesSdk.mAppCode = define.KOCES_APP_ID
                mKocesSdk.mModelNumber = TmIcNo
                mKocesSdk.mSerialNumber = serialNumber
                mKocesSdk.mModelVersion = version // version
                
                if keyUpdateCount != 0 {
                    mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                    
//                    keyUpdateCount = 0
                    mKocesSdk.KeyDownload_Ready()
                    return
                }
                
//                alert.dismiss(animated: true, completion: nil)
//                mKocesSdk.GetVerity()   //연결에 성공하면 자동으로 무결성검사 시작
                if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                    let alertReceive = UIAlertController(title: "무결성검증실패", message: "리더기 무결성 검증실패 제조사A/S요망", preferredStyle: .alert)
                    let receiveBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in

                        self.AppToAppCommand()
                    })
                    alertReceive.addAction(receiveBtn)
                    alert.dismiss(animated: false) {
                        self.present(alertReceive, animated: true, completion: nil)
                    }
    
                    return
                }
                if key != "00" {
                    let alertReceive = UIAlertController(title: "장치정보", message: "키 갱신이 필요합니다", preferredStyle: .alert)
                    let receiveBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                        self.mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                        
                        self.mKocesSdk.KeyDownload_Ready()
//                        self.AppToAppCommand()
                    })
                    alertReceive.addAction(receiveBtn)
                    alert.dismiss(animated: false) {
                        self.present(alertReceive, animated: true, completion: nil)
                    }
                    
                } else {
                    self.AppToAppCommand()
                }
                
            } else if(self.mKocesSdk.mReceivedData[3] == Command.CMD_KEYUPDATE_READY_RES){
                var spt:Int = 4
                var authNumber = Utils.UInt8ArrayToStr(UInt8Array: Array(self.mKocesSdk.mReceivedData[spt...spt + 31]))
                spt += 32
                var keydata:[UInt8] = Array(self.mKocesSdk.mReceivedData[spt...spt+127])
                spt += 128
                var result = Utils.UInt8ArrayToStr(UInt8Array: Array(self.mKocesSdk.mReceivedData[spt...spt + 1]))
                debugPrint(authNumber)
                debugPrint(keydata)
                debugPrint(result)
                if keyUpdateCount != 0 {
                    if result == "00" {
//                        keyUpdateCount = 0
                        KeyDownload(KeyCheckData: keydata)
                    } else {
                        keyUpdateResultFail += 1
                        if keyUpdateResultFail == 2 {
                            keyUpdateCount = 0
                            keyUpdateResultFail = 0
                            let alertReceive = UIAlertController(title: "키갱신", message: "보안키 갱신 생성 결과 비정상", preferredStyle: .alert)
                            let receiveBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                                self.AppToAppCommand()
                            })
                            alertReceive.addAction(receiveBtn)
                            alert.dismiss(animated: false) {
                                self.present(alertReceive, animated: true, completion: nil)
                            }
                            
                            
                        } else {
                            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                            
                            mKocesSdk.KeyDownload_Ready()
                        }
                   
                    }
                    return
                }
                //서버에 키 요청
                if result == "00" {
//                    AlertLoadingBox(title: "서버에 키를 요청중입니다")
//                    KeyDownload(KeyCheckData: keydata)
                    self.AppToAppCommand()
                } else {
                    keyUpdateResultFail += 1
                    if keyUpdateResultFail == 2 {
                        keyUpdateResultFail = 0
                        let alertReceive = UIAlertController(title: "키갱신", message: "보안키 갱신 생성 결과 비정상", preferredStyle: .alert)
                        let receiveBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                            self.AppToAppCommand()
                        })
                        alertReceive.addAction(receiveBtn)
                        alert.dismiss(animated: false) {
                            self.present(alertReceive, animated: true, completion: nil)
                        }
                        
                        
                    } else {
                        mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                        
                        mKocesSdk.KeyDownload_Ready()
                    }
               
                }
                
            } else if(self.mKocesSdk.mReceivedData[3] == Command.NAK){
//                keyUpdateResultFail += 1
//                if keyUpdateResultFail == 2 {
//                    keyUpdateResultFail = 0
//                    let alertReceive = UIAlertController(title: "키갱신", message: "보안키 갱신 생성 결과 비정상", preferredStyle: .alert)
//                    let receiveBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
//                        self.AppToAppCommand()
//                    })
//                    alertReceive.addAction(receiveBtn)
//                    present(alertReceive, animated: true, completion: nil)
//                } else {
//                    mKocesSdk.KeyDownload_Ready()
//                }
                
                if keyUpdateCount != 0 {
                    keyUpdateCount = 0
                    var recDicData:[String:String] = [:]
                    recDicData = _keyDownloadResult
                    recDicData["Message"] = "키다운로드 실패"
                    recDicData["TrdType"] = "D25"
                    self.onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
                self.AppToAppCommand()
            } else if(self.mKocesSdk.mReceivedData[3] == Command.ACK){
                if keyUpdateCount != 0 {
                    keyUpdateCount = 0
                    var recDicData:[String:String] = [:]
                    recDicData = _keyDownloadResult
                    recDicData["TrdType"] = "D25"
                    recDicData["Message"] = "키다운로드 완료"
                    self.onResult(tcpStatus: .sucess, Result: recDicData)
                }
            }
            break
        case define.IsPaired:
            print("BLE_Status :", bleStatus)
            self.ViewStart = false
            //장치 이름만 추출 하기 2020-03-08 kim.jy
            let TempDeviceName:String = String(describing: self.mKocesSdk.isPairedDevice[0]["device"].unsafelyUnwrapped)
            var deviceName:String = ""
            if TempDeviceName != "" {
                let temp = TempDeviceName.components(separatedBy: ":")
                if temp.count > 0 {
                    deviceName = String(temp[0])
                }

            }

            mKocesSdk.manager.connect(uuid: mKocesSdk.isPaireduuid)
            break
        case define.IsConnected:
            print("BLE_Status :", bleStatus)
            self.ViewStart = false
            let temp:[UInt8] = Command.GetVerity()

            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
            if false == self.mKocesSdk.bleManagerWrite(Data: temp) {
                // 쓰기 실패 시 처리
                print("bleManagerWrite :", false)
            }
     
            break
        case define.ScanFail:
            print("BLE_Status :", bleStatus)
            self.ViewStart = false
            self.AppToAppCommand()
//            let alertScanFail = UIAlertController(title: "주변에 연결 가능한 장치가 없습니다", message: "", preferredStyle: .alert)
//            let ScanFailBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
//                self.AppToAppCommand()
//            })
//            alertScanFail.addAction(ScanFailBtn)
//            present(alertScanFail, animated: true, completion: nil)
            break
        case define.PairingKeyFail:
            print("BLE_Status :", bleStatus)
            self.ViewStart = false
            self.AppToAppCommand()
            break
        case define.PowerOff:
            print("BLE_Status :", bleStatus)
            self.ViewStart = false
            self.AppToAppCommand()
//            let alertPowerOff = UIAlertController(title: "블루투스를 사용할 수 없는 기기입니다", message: "", preferredStyle: .alert)
//            let PowerOffBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
//                self.AppToAppCommand()
//            })
//            alertPowerOff.addAction(PowerOffBtn)
//            present(alertPowerOff, animated: true, completion: nil)
            break
        case define.Send:
//            print("BLE_Status :", bleStatus)
            break
        case define.UpdateDevices:
            print("BLE_Status :", bleStatus)
            break
        default:
            break
        }
    }
    
    @objc func didBle(_ notification: Notification) {
        guard let bleStatus: String = notification.userInfo?["Status"] as? String else { return }
        
        if bleStatus == define.ScanSuccess ||
            bleStatus == define.ConnectSuccess ||
            bleStatus == define.ScanFail ||
            bleStatus == define.PowerOff ||
            bleStatus == define.Disconnect ||
            bleStatus == define.PairingKeyFail ||
            bleStatus == define.Receive ||
            bleStatus == define.ConnectFail ||
            bleStatus == define.ConnectTimeOut ||
            bleStatus == define.IsConnected {
            if alert.isViewLoaded {
                self.BleStatus(ble: bleStatus)
            } else {
                BleStatus(ble: bleStatus)
            }
        } else {
            BleStatus(ble: bleStatus)
        }
    }

    //앱루팅체크 네트워크 연결체크등을 한다
    @objc func didActivate() {
        Setting.shared.mWebAPPReturnAddr = ""
        if ViewStart == false {
            ViewStart = true
        } else {
            return
        }
        //checkAppVerity() true -> 루팅 false -> 정상

        if checkAppVerity() {
            let alert = UIAlertController(title: "루팅검사", message: "루팅,탈옥이 의심됩니다.", preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "루팅,탈옥이 의심됩니다. 장비를 체크해주세요."
                if Setting.shared.ApptoApp.isEmpty && Setting.shared.WebtoApp.isEmpty {
                    self.ViewStart = false
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                } else {
                    if Setting.shared.WebtoApp.isEmpty {
                        Setting.shared.ApptoApp = ""
                        self.WebORApp = 1
                    } else {
                        Setting.shared.WebtoApp = ""
                        self.WebORApp = 0
                    }
                    self.ViewStart = false
                    self.onResult(tcpStatus: .fail, Result: recDicData)
                }
             
            })
            alert.addAction(okBtn)
            self.alert.dismiss(animated: false) {
                self.present(alert, animated: true, completion: nil)
            }
           
            return
        }
        
        if !Utils.isInternetAvailable() {
            let alert = UIAlertController(title: "네트워크검사", message: "네트워크 상태가 불량입니다.", preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "네트워크 상태가 불량입니다. 인터넷을 확인해 주세요."
                if Setting.shared.ApptoApp.isEmpty && Setting.shared.WebtoApp.isEmpty {
                    self.ViewStart = false
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                } else {
                    if Setting.shared.WebtoApp.isEmpty {
                        Setting.shared.ApptoApp = ""
                        self.WebORApp = 1
                    } else {
                        Setting.shared.WebtoApp = ""
                        self.WebORApp = 0
                    }
                    self.ViewStart = false
                    self.onResult(tcpStatus: .fail, Result: recDicData)
                }
            })
            alert.addAction(okBtn)
            self.alert.dismiss(animated: false) {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        
//        #if DEBUG
        CompleteCheck()
//        return
//        #endif
//        veritylistener = AppAttestResult()
//        veritylistener?.delegate = self
//        initProc.shared.AppAttestDeviceCheck(Listener: veritylistener?.delegate as! AppAttestResultDelegate)
        return
    }
    
    //앱 업데이트 후 결과값
    func onAppUpdateResult(UpdateState _state: updateStatus, Result _result: Dictionary<String, String>) {
        if _state == .SUCCESS {
            DispatchQueue.main.async {[self] in

                CompleteCheck()
            }
           
            return
        }
        
        DispatchQueue.main.async {[self] in
            let alert = UIAlertController(title: "앱업데이트", message: "앱 업데이트에 실패하였습니다." + "\n" + (_result["Message"] ?? ""), preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "앱 업데이트에 실패하였습니다." + "\n" + (_result["Message"] ?? "")
                if Setting.shared.ApptoApp.isEmpty && Setting.shared.WebtoApp.isEmpty {
                    self.ViewStart = false
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                } else {
                    if Setting.shared.WebtoApp.isEmpty {
                        Setting.shared.ApptoApp = ""
                        self.WebORApp = 1
                    } else {
                        Setting.shared.WebtoApp = ""
                        self.WebORApp = 0
                    }
                    self.ViewStart = false
                    self.onResult(tcpStatus: .fail, Result: recDicData)
                }
            })
            alert.addAction(okBtn)
            self.alert.dismiss(animated: false) {
                self.present(alert, animated: true, completion: nil)
            }
        }
       
        return
    }
    
    //AppAttest 를 통해 키값을 애플서버와 비교후 결과처리
    func onAppAttestResult(AppAttest _status: verityStatus, Result _result: Dictionary<String, String>) {
        if _status == .SUCCESS {
            DispatchQueue.main.async {[self] in
                //앱버전을 여기서 체크해서 업데이트 한다. 할 때 리스너를 등록해줘서 처리한다.
//                updatelistener = AppUpdateResult()
//                updatelistener?.delegate = self
//                initProc.shared.IsNewVersionUpdated(Listener: updatelistener?.delegate as! AppVersionUpdateDelegate)
                CompleteCheck()
            }
           
            return
        }
        DispatchQueue.main.async {[self] in
            let alert = UIAlertController(title: "앱무결성검사", message: "앱 제거 후 다시 설치해 주십시오." + "\n" + (_result["Message"] ?? ""), preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "앱 제거 후 다시 설치해 주십시오." + "\n" + (_result["Message"] ?? "")
                if Setting.shared.ApptoApp.isEmpty && Setting.shared.WebtoApp.isEmpty {
                    self.ViewStart = false
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                } else {
                    if Setting.shared.WebtoApp.isEmpty {
                        Setting.shared.ApptoApp = ""
                        self.WebORApp = 1
                    } else {
                        Setting.shared.WebtoApp = ""
                        self.WebORApp = 0
                    }
                    self.ViewStart = false
                    self.onResult(tcpStatus: .fail, Result: recDicData)
                }
            })
            alert.addAction(okBtn)
            self.alert.dismiss(animated: false) {
                self.present(alert, animated: true, completion: nil)
            }
        }
       
        return
     
    }
    
    
    //네트워크 탈옥 루팅 앱무결성 등을 정상적으로 마무리 지었다면 정상적인 프로세스를 진행한다
    func CompleteCheck() {
        keyUpdateCount = 0
        //어플에 저장 되어 있는 결제 장비가 어떤 장비 인지 읽어서 확인한다.
        var devicesTemp1 = Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE)
        if devicesTemp1.isEmpty {
            Setting.shared.setDefaultUserData(_data: define.TAGETBLE, _key: define.TARGETDEVICE)    //어플 기동 할 때 타겟 대상을 결정
            devicesTemp1 = Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE)
        }
        
        switch devicesTemp1 {
        case define.TAGETBLE:
            //20200507 kim.jy mainViewController 에서 ble가 연결 되고 나중에 app to app이 호출 되어 있을때 이미 연결된 상태가 끊어진 상태로 표현될 문제가 있어서
            //ble상태를 먼저 확인 한다.
            if mKocesSdk.bleState != define.TargetDeviceState.BLECONNECTED {
                mKocesSdk.bleState = define.TargetDeviceState.BLENOCONNECT
            }
        

            // 만일 앱투앱/웹투엡일 경우 ble 연결 없이 다이렉트로 서버와 통신해야 하는 경우들이 있다. 이럴때 ble 연결 없이 진행할 수 있도록 여기서 체크한다
            if !Setting.shared.ApptoApp.isEmpty || !Setting.shared.WebtoApp.isEmpty {
                if Setting.shared.WebtoApp.isEmpty {
                    let apptoapp:String = Setting.shared.ApptoApp

                    if self.DirectServerCheck(apptoapp) {
                        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)

                    } else {
                        self.ViewStart = false
                        AppToAppCommand()
                        return
                    }
                } else {
                    let webtoapp:String = Setting.shared.WebtoApp

                    if self.DirectServerCheck(webtoapp) {
                        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)

                    } else {
                        self.ViewStart = false
                        AppToAppCommand()
                        return
                    }
                }
                //페어링 중에 실패하여 재시도한다면 커넥트를 연달아 날린다.(화면을 다시불러오는 것이기 때문에) 이를 방지하기 위해 여기서 리턴시켜서 다시 커넥트를 하려는 것을 방지한다.
                if mKocesSdk.manager.pairingCount != 0 {
                    return
                }
        
                // 여기서 연결할 장비의 이름의 일부(이걸로 장비를 찾음) 서비스 시리얼 을 설정한다.
                if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                    if self.ViewStart {
                        /**
                         메세지창에 로딩화면을 추가한다
                         */
                        AlertLoadingBox(title: "잠시만 기다려 주세요")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                            self.mKocesSdk.bleConnect()
                        }
                    }
        
                } else {
                    self.ViewStart = false
                    AppToAppCommand()
                }
            } else {
                /** log : 본앱 기록 시작 */
                if Setting.shared.getDefaultUserData(_key: define.STORE_TID) != "" {
                    LogFile.instance.InsertLog("********** OriginalApp Service **********", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID), TimeStamp: true)
                }

    //            NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)
                self.ViewStart = false
                AppToAppCommand()
            }
            
            
            break
        case define.TAGETCAT:
            mKocesSdk.bleState = define.TargetDeviceState.CATCONNECTED
            self.ViewStart = false
            AppToAppCommand()
            break
        default:
            mKocesSdk.bleState = define.TargetDeviceState.BLENOCONNECT
            self.ViewStart = false
            AppToAppCommand()
            break
        }
        

    }
    
    //다이렉트로 서버로 가야하는 건지 아닌지를 체크 true=ble연결시도 false=ble연결없음
    func DirectServerCheck(_ rec: String) -> Bool {
        if rec.isEmpty {
            //데이터도 없이 앱투앱/웹투앱에서 보내진경우다
            return false
        }
        
        let res = rec.split(separator: "&", omittingEmptySubsequences: false)
        
        var trdCode = ""
        var cashNum = ""
        var trdType = ""
        var print = ""
        for i in 0 ..< res.count {
            switch String(res[i].split(separator: "=",omittingEmptySubsequences: false)[0]) {
            case "TrdCode": //거래구분(T:거래고유키취소, C:해외은련, A:App카드결제 U:BC(은련) 또는 QR결제 (일반신용일경우 미설정)
                trdCode = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "CashNum": //고객번호(신용X) 현금영수증 거래 시: 신분확인 번호
                cashNum = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "TrdType":  //가맹점등록tid 사업자번호 시리얼번호 체크
                trdType = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "Print"://프린트
                print = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
            default:
                break
            }
        }
        
        if (print != "" || trdType == "P10") {
            if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
                return false
            }
        }
        
        
        if trdCode == "T" || !cashNum.isEmpty || trdType == Command.CMD_REGISTERED_SHOP_DOWNLOAD_REQ  ||
            trdType == Command.CMD_EASY_APPTOAPP_REQ || trdType == Command.CMD_EASY_APPTOAPP_CANCEL_REQ ||
            trdType == Command.CMD_RECOMMAND_REQ {
            //거래구분자가 거래고유키취소 인경우거나 현금신분확인번호가 입력받았을 경우, 가맹점등록인경우, 간편결제요청인경우 ble연결없이 다이렉트로 서버로 보낸다
            return false
        }
        
        return true
    }
    
    
    func AppToAppCommand() {
        if Setting.shared.ApptoApp.isEmpty && Setting.shared.WebtoApp.isEmpty {
            /**
            2020-01-21 kim.jy TabBar로 이동 시키기 전에 Setting 필요한 정보를 읽어와서 설정하는 부분이 필요하다.
            예를 들어 세금 저장되어 있는 부분 서버 주소 기타 필요한 사항들에 대한 로컬 정보를 읽어와서 설정한다.
            */
            
            /**
             UI 가 모두 로딩되고 난 후 탭바컨트롤러(tabbar)에 붙어있는 메인씬으로 이동한다 "Main" 은 기본적으로 우리가 사용하는 UIStoryboard 를 뜻하는거지 뷰컨트롤러와는 관계없다
             */
            var storyboard:UIStoryboard?
            if UIDevice.current.userInterfaceIdiom == .phone {
                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            } else {
                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
            }
            //이용약관을 체크하지 않았다면 약관으로 이동
            let APP_TERMS_CHECK:String = Setting.shared.getDefaultUserData(_key: define.APP_TERMS_CHECK)
            if APP_TERMS_CHECK.isEmpty {
                let controller = (storyboard?.instantiateViewController(identifier: "TermsViewController"))! as TermsViewController
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: false)
                return
            } else {
                //권한설정을 완료하지 않았다면 권한설정으로 이동
                let APP_PERMISSION_CHECK:String = Setting.shared.getDefaultUserData(_key: define.APP_PERMISSION_CHECK)
                if APP_PERMISSION_CHECK.isEmpty {
                    let controller = (storyboard?.instantiateViewController(identifier: "TermsViewController"))! as TermsViewController
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: false)
                    return
                }

            }

            let mainTabBarController = storyboard!.instantiateViewController(identifier: "TabBar")
            mainTabBarController.modalPresentationStyle = .fullScreen
            self.alert.dismiss(animated: false) {
                self.present(mainTabBarController, animated: true, completion: nil)
            }
            
            
            return
        }
        
        /**
         메세지창에 로딩화면을 추가한다
         */
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        
        
        //헨들러의 포스트딜레이와 같다. 3은 3초뒤 실행
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            if Setting.shared.WebtoApp.isEmpty {
                let apptoapp:String = Setting.shared.ApptoApp
                Setting.shared.ApptoApp = ""
                self.WebORApp = 1
                self.CommandPlay(apptoapp)
            } else {
                let webtoapp:String = Setting.shared.WebtoApp
                Setting.shared.WebtoApp = ""
                self.WebORApp = 0
                self.CommandPlay(webtoapp)
            }


        }
    }
    
    
    //로딩 박스
    func AlertLoadingBox(title _title:String) {
        self.alert.dismiss(animated: false) { [self] in
            alert = UIAlertController(title: "잠시만 기다려 주세요", message: nil, preferredStyle: .alert)
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.isUserInteractionEnabled = false
            activityIndicator.startAnimating()

            alert.view.addSubview(activityIndicator)
            alert.view.heightAnchor.constraint(equalToConstant: 95).isActive = true

            activityIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor, constant: 0).isActive = true
            activityIndicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20).isActive = true

            present(alert, animated: true, completion: nil)
        }
    }
    
}

extension AppToAppViewController: TcpResultDelegate, PayResultDelegate, PrintResultDelegate, CustomAlertDelegate, CatResultDelegate {

    
    
    func OkButtonTapped() {
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){[self] in
            mKocesSdk.manager.connect(uuid: mKocesSdk.isPaireduuid)
        }
    }
    
    func CancelButtonTapped() {
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){[self] in
            UserDefaults.standard.setValue("", forKey: define.LAST_CONNECT_DEVICE)
            mKocesSdk.manager.scan()
        }
    }

    func CommandPlay(_ rec: String){
        if rec.isEmpty {
//            var recDicData:[String:String] = [:]
//            recDicData["Message"] = "받은 데이터가 없습니다. 데이터를 보내주세요"
//            onResult(tcpStatus: .fail, Result: recDicData)
            return
        }
        listener = TcpResult()
        listener?.delegate = self
        paylistener = payResult()
        paylistener?.delegate = self
        printlistener = PrintResult()
        printlistener?.delegate = self
        catlistener = CatResult()
        catlistener?.delegate = self
        Setting.shared.tmpTid = ""
        WebToAppSendDataFail = 0 ;
        self.printMsg = ""
        
        let res = rec.split(separator: "&", omittingEmptySubsequences: false)
        
        var resDicData:[String:String] = [:]
        
        for i in 0 ..< res.count {
            switch String(res[i].split(separator: "=",omittingEmptySubsequences: false)[0]) {
//            case "termId":  //가맹점등록tid 사업자번호 시리얼번호 체크
//                resDicData["termId"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
//                break
            case "BsnNo":   //가맹점등록tid 사업자번호 시리얼번호 체크
                resDicData["BsnNo"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1]).replacingOccurrences(of: " ", with: "")
                break
            case "Serial":  //가맹점등록tid 사업자번호 시리얼번호 체크
                resDicData["Serial"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1]).replacingOccurrences(of: " ", with: "")
//                Setting.shared.setDefaultUserData(_data: resDicData["Serial"]!, _key: define.STORE_SERIAL)
                break
                //여기부터 아래는 신용/현금 거래
            case "TrdType": //전문명령어
                resDicData["TrdType"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                tmpTrdType = resDicData["TrdType"] ?? ""
                break
            case "TermID":  //단말기 ID
                resDicData["TermID"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1]).replacingOccurrences(of: " ", with: "")
                break
            case "AuDate":  //원거래일자 YYMMDD
                resDicData["AuDate"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1]).replacingOccurrences(of: " ", with: "")
                break
            case "AuNo":    //원승인번호
                resDicData["AuNo"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1]).replacingOccurrences(of: " ", with: "")
                break
            case "KeyYn":   //입력방법 K=keyin, S-swipe, I=ic
                resDicData["KeyYn"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "TrdAmt":  //거래금액 승인:공급가액, 취소:원승인거래총액
                resDicData["TrdAmt"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                Setting.shared.tmpMoney = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "TaxAmt":  //세금
                resDicData["TaxAmt"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                Setting.shared.tmpTax = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "SvcAmt":  //봉사료
                resDicData["SvcAmt"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                Setting.shared.tmpSvc = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "TaxFreeAmt":  //비과세
                resDicData["TaxFreeAmt"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                Setting.shared.tmpTxf = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "Month":   //할부개월(현금은 X)
                resDicData["Month"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                Setting.shared.tmpInstallment = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "MchData": //가맹점데이터
                resDicData["MchData"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "TrdCode": //거래구분(T:거래고유키취소, C:해외은련, A:App카드결제 U:BC(은련) 또는 QR결제 (일반신용일경우 미설정)
                resDicData["TrdCode"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "TradeNo": //Koces거래고유번호(거래고유키 취소 시 사용)
                resDicData["TradeNo"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1]).replacingOccurrences(of: " ", with: "")
                break
            case "CompCode":    //업체코드(koces에서 부여한 업체코드)
                resDicData["CompCode"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "DgTmout": //카드입력대기시간 10~99, 거래요청 후 카드입력 대기시간
                resDicData["DgTmout"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                Setting.shared.mDgTmout = resDicData["DgTmout"] ?? "30"
                break
            case "DscYn":   //전자서명사용여부(현금X) 0:무서명 1:전자서명 2:bmp data 3:bmp(base64)
                resDicData["DscYn"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "DscData":   //위의 dscyn 이 2 혹은 3일 경우 아래로 데이터를 체크하여 서명에 실어서 보낸다
//                resDicData["DscData"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                let tmp = res[i].split(separator: "=", omittingEmptySubsequences: false)
                let _t1 = tmp[1].replacingOccurrences(of: "%2F", with: "/")
                let _t2 = _t1.replacingOccurrences(of: "%3A", with: ":")
                resDicData["DscData"] = String(_t2)
                Setting.shared.mDscData = resDicData["DscData"] ?? ""
                break
            case "FBYn":    //fallback 사용 0:fallback 사용 1: fallback 미사용
                resDicData["FBYn"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "InsYn":   //개인/법인 구분(신용X) 1:개인 2:법인 3:자진발급 4:원천
                resDicData["InsYn"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                Setting.shared.tmpInsYn = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "CancelReason":    //취소사유(신용X) 현금영수증 취소 시 필수 1:거래취소 2:오류발급 3:기타
                resDicData["CancelReason"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "CashNum": //고객번호(신용X) 현금영수증 거래 시: 신분확인 번호
                resDicData["CashNum"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "Print": //프린트일때 사용
                resDicData["Print"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "returnAddr":  //웹투엡일 경우 해당 웹의 주소도 함께 보내주어야 이곳으로 값을 전달 할 수 있다
                resDicData["returnAddr"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                if resDicData["returnAddr"] != ""
                {
                    Setting.shared.mWebAPPReturnAddr = resDicData["returnAddr"]!
                }
                break
                //다중사업자 0: 일반, 1: 다중사업자(가맹점 등록 포함) 0 일경우 일반거래로 처리. 1일 경우 가맹점등록 후 정상일 때 일반거래를 처리하며 만일 시리얼번호 사업자번호가 없다면 해당 정보 미확인으로 인한 가맹점 등록 실패를 리턴한다
            case "MtidYn":
                resDicData["MtidYn"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "QrNo":    //QR, 바코드번호 QR, 바코드 거래 시 사용(App 카드, BC QR 등)
                resDicData["QrNo"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "QrKind":  //QR종류 .
                resDicData["QrKind"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "HostMchData":  //호스트가맹점데이터(제로페이) .
                resDicData["HostMchData"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "BillNo":  //전표번호 .
                resDicData["BillNo"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                tmpBillNo = resDicData["BillNo"] ?? ""
                break
                
            case "ShpNm":  //P10 프린트시 사용.
                resDicData["ShpNm"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "PreNm":   //P10 프린트시 사용.
                resDicData["PreNm"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "ShpTno": //P10 프린트시 사용.
                resDicData["ShpTno"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
            case "ShpAr":  //P10 프린트시 사용.
                resDicData["ShpAr"] = String(res[i].split(separator: "=",omittingEmptySubsequences: false)[1])
                break
                
            default:
                break
            }
        }
        
        tmpresDicData = resDicData
        
        /** log : 앱투앱 기록 시작 */
        var _tmpTermID = resDicData["TermID"] ?? ""
        if _tmpTermID != "" {
            if WebORApp == 0 {
                LogFile.instance.InsertLog("********** WebToApp Service 시작 **********", Tid: resDicData["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("WebToApp Data -> " + rec, Tid: resDicData["TermID"] ?? "", TimeStamp: true)
            } else if WebORApp == 1 {
                LogFile.instance.InsertLog("********** AppToApp Service 시작 **********", Tid: resDicData["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("AppToApp Data -> " + rec, Tid: resDicData["TermID"] ?? "", TimeStamp: true)
            }
        } else {
            if WebORApp == 0 {
                LogFile.instance.InsertLog("********** WebToApp Service 시작 **********", Tid: resDicData["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("WebToApp Data -> 웹투앱으로 TermId 가져오지 못함" + rec, Tid: resDicData["TermID"] ?? "", TimeStamp: true)
            } else if WebORApp == 1 {
                LogFile.instance.InsertLog("********** AppToApp Service 시작 **********", Tid: resDicData["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("AppToApp Data -> 앱투앱으로 TermId 가져오지 못함" + rec, Tid: resDicData["TermID"] ?? "", TimeStamp: true)
            }
        }
        
        //전표번호 길이값 체크
        if !tmpBillNo.isEmpty && tmpBillNo.count != 12 {
            
            var recDicData:[String:String] = [:]
            recDicData["Message"] = "전표번호 길이 값은 12자리여야 합니다"
            onResult(tcpStatus: .fail, Result: recDicData)
            return
        }
                
        //만일 프린트라면
        let _print = resDicData["Print"] ?? ""
        if !_print.isEmpty {
            if mKocesSdk.blePrintState == define.PrintDeviceState.BLENOPRINT {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            //cat 연동일 경우
            if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
                if Utils.CheckPrintCatPortIP() != "" {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = Utils.CheckPrintCatPortIP()
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }

            if !printParserCheck().isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = printParserCheck()
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            printTimeOut()
            
//            guard var message = _print.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
            let message = NSString(string: _print) as String
           
            Utils.printAlertBox(Title: "프린트 중입니다.", LoadingBar: true, GetButton: "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                if mKocesSdk.blePrintState == define.PrintDeviceState.BLEUSEPRINT {
                    mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                    
                    let prtStr = mKocesSdk.PrintParser(파싱할프린트내용: message)
                    mKocesSdk.BlePrinter(내용: prtStr, CallbackListener: printlistener?.delegate as! PrintResultDelegate)
                } else if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
                    mCatSdk.Print(파싱할프린트내용: message, CompletionCallback: catlistener?.delegate! as! CatResultDelegate)
                } else {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "프린트 가능한 장비를 연결해 주십시오"
                    onResult(tcpStatus: .fail, Result: recDicData)
                }
          
            }
           
            return
        }
        
        
        /** 거래금액을 받아오면 거래금액+비과세한다. 이것은 cat은 제외한다 */
        if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
            let _command = resDicData["TrdType"] ?? ""
            if _command == Command.CMD_ICTRADE_REQ || _command == Command.CMD_CASH_RECEIPT_REQ ||
                _command == Command.CMD_ICTRADE_CANCEL_REQ || _command == Command.CMD_CASH_RECEIPT_CANCEL_REQ ||
                _command == Command.CMD_EASY_APPTOAPP_REQ || _command == Command.CMD_EASY_APPTOAPP_CANCEL_REQ{
                let _trdAmt:Int = Int(resDicData["TrdAmt"] ?? "0")! + Int(resDicData["TaxFreeAmt"] ?? "0")!
                resDicData["TrdAmt"] = String(_trdAmt)
            }
            
        }
       
        
        let _command = resDicData["TrdType"] ?? ""
        if _command.isEmpty {
            var recDicData:[String:String] = [:]
            recDicData["Message"] = "커맨드가 정상적이지 않습니다. 커맨드를 확인해 주세요"
            onResult(tcpStatus: .fail, Result: recDicData)
            return
        }
        
        //다중사업자 0: 일반, 1: 다중사업자(가맹점 등록 포함) 0 일경우 일반거래로 처리. 1일 경우 가맹점등록 후 정상일 때 일반거래를 처리하며 만일 시리얼번호 사업자번호가 없다면 해당 정보 미확인으로 인한 가맹점 등록 실패를 리턴한다
        if (resDicData["MtidYn"] ?? "") == "1" && mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
            
            //기존 정보들을 일단 다 제거 한다.
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key.contains(define.APPTOAPP_TID) {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                    KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                }
                if key.contains(define.APPTOAPP_BSN) {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
                if key.contains(define.APPTOAPP_SERIAL) {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
                if key.contains(define.APPTOAPP_ADDR) {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
            }
            
            //다중사업자 가맹점 등록다운로드를 시도한다. 그리고 결과가 나오면 거기서 신용/현금 등을 처리해 본다
            let _storeParserCheck = storeParserCheck(Tid: String(resDicData["TermID"] ?? ""), BSN: String(resDicData["BsnNo"] ?? ""), Serial: String(resDicData["Serial"] ?? ""))
            if !_storeParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _storeParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            tmpTid = String(resDicData["TermID"] ?? "")
            tmpBsn = String(resDicData["BsnNo"] ?? "")
            tmpSerial = String(resDicData["Serial"] ?? "")
//            Setting.shared.setDefaultUserData(_data: String(resDicData["TermID"] ?? ""), _key: define.APPTOAPP_TID)
//            Setting.shared.setDefaultUserData(_data: String(resDicData["BsnNo"] ?? ""), _key: define.APPTOAPP_BSN)
//            Setting.shared.setDefaultUserData(_data: String(resDicData["Serial"] ?? ""), _key: define.APPTOAPP_SERIAL)
            var _mchData = String(resDicData["MchData"] ?? "")
            if _mchData.isEmpty {
//                _mchData = ""
                _mchData = "MDO"
            }
            mKocesSdk.StoreDownload(Command: Command.CMD_REGISTERED_SHOP_DOWNLOAD_REQ, Tid: String(resDicData["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", Length: "0003", PosCheckData: "MDO", BSN: String(resDicData["BsnNo"]!), Serial: String(resDicData["Serial"]!), PosData: "", MacAddr: Utils.getKeyChainUUID(), DirectData: resDicData, CallbackListener: listener?.delegate as! TcpResultDelegate)
            return
        }
        
        var _Command:String = resDicData["TrdType"]!
        //간편결제 중 캣이 아닌 간편결제로 서버측과 통신을 할 때에는 아래의 조건문에서 수정하여 해당 명령어를 주입한다
        if (resDicData["QrKind"] != nil && resDicData["QrKind"] == "ZP")
        {
            if(_Command == "A10")
            {
                _Command = "Z10";
            }
            else if(_Command == "A20")
            {
                _Command = "Z20";
            }
            else if(_Command == "E10")
            {
                _Command = "Z10";
            }
            else if(_Command == "E20")
            {
                _Command = "Z20";
            }
        }

        if (_Command == "A10")
        {
            _Command = "K21";
        }
        else if (_Command == "A20")
        {
            _Command = "K22";
        }
        else if(_Command == "E10")
        {
            _Command = "K21";
        }
        else if(_Command == "E20")
        {
            _Command = "K22";
        }
        

        
        switch resDicData["TrdType"] {
        case "Print":
            //위에서 프린트 메세지가 아무것도 없이 전문명령어만 달랑 온 경우를 처리한다.
            var recDicData:[String:String] = [:]
            recDicData["Message"] = "출력할 내용이 없습니다. 내용을 확인 해 주세요"
            onResult(tcpStatus: .fail, Result: recDicData)
            return
        case "P10":
            //위에서 프린트 메세지가 아무것도 없이 전문명령어만 달랑 온 경우를 처리한다.
            var _tid = tmpresDicData["TermID"] ?? "";
            var _date = tmpresDicData["AuDate"] ?? "";
            if(tmpBillNo.count > 0 && !sqlite.instance.checkAppToAppList(TermID: _tid, BillNo: tmpBillNo, AuDate: _date))
            {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "해당 데이터가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            if mKocesSdk.blePrintState == define.PrintDeviceState.BLENOPRINT {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            //cat 연동일 경우
            if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
                if Utils.CheckPrintCatPortIP() != "" {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = Utils.CheckPrintCatPortIP()
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }

            if !printParserCheck().isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = printParserCheck()
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            //가맹점명
            let _ShpNm:String = resDicData["ShpNm"] ?? "";
                        //사업자번호
            let _BsnNo:String = resDicData["BsnNo"] ?? "";
                        //단말기TID
            let _TermID:String = resDicData["TermID"] ?? "";
                        //대표자명
            let _PreNm:String = resDicData["PreNm"] ?? "";
                        //연락처
            let _ShpTno:String = resDicData["ShpTno"] ?? "";
                        //주소
            let _ShpAr:String = resDicData["ShpAr"] ?? "";

            if ( _ShpNm == "")
            {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "가맹점 정보가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            } else if ( _BsnNo == "")
            {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "가맹점 정보가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            } else if ( _TermID == "")
            {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "가맹점 정보가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            } else if ( _PreNm == "")
            {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "가맹점 정보가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            } else if ( _ShpTno == "")
            {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "가맹점 정보가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            } else if ( _ShpAr == "")
            {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "가맹점 정보가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            printTimeOut()
            var reHash:[String:String] = [:]
            reHash = sqlite.instance.getAppToAppTrade(TermId: resDicData["TermID"] ?? "", AuDate: resDicData["AuDate"] ?? "", BillNo: tmpBillNo);
            reHash["ShpNm"] = _ShpNm
            reHash["BsnNo"] = _BsnNo
            reHash["PreNm"] = _PreNm
            reHash["ShpTno"] = _ShpTno
            reHash["ShpAr"] = _ShpAr
            let message = PrintReceiptInit(HashMap: reHash);

            let prtStr = mKocesSdk.PrintParser(파싱할프린트내용: message)
            Utils.printAlertBox(Title: "프린트 중입니다.", LoadingBar: true, GetButton: "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                if mKocesSdk.blePrintState == define.PrintDeviceState.BLEUSEPRINT {
                    mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                    
    
                    mKocesSdk.BlePrinter(내용: prtStr, CallbackListener: printlistener?.delegate as! PrintResultDelegate)
                } else if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
                    mCatSdk.Print(파싱할프린트내용: prtStr, CompletionCallback: catlistener?.delegate! as! CatResultDelegate)
                }
          
            }
            return
        case "R10":
            //ble 버전정보 전달 ble 연결안되어있다면 앱정보만 전달
            var recDicData:[String:String] = [:]
            recDicData["Message"] = "출력할 내용이 없습니다. 내용을 확인 해 주세요"
            onResult(tcpStatus: .fail, Result: recDicData)
            return
        case "R20":
            //ble 버전정보 전달 ble 연결안되어있다면 ble 연결을 요청하고 ble 정보를 가져와서 전달한다
            var recDicData:[String:String] = [:]
            recDicData["Message"] = "출력할 내용이 없습니다. 내용을 확인 해 주세요"
            onResult(tcpStatus: .fail, Result: recDicData)
            return
        case "F10":
            //지난 데이터를 전달한다
            if(tmpBillNo == "")
            {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "해당 전표번호의 거래가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            

            if (resDicData["TermID"] == nil || resDicData["TermID"] == "") {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "TID가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            if (resDicData["AuDate"] == nil || resDicData["AuDate"] == "") {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "거래일자가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            if (resDicData["BillNo"] == nil || resDicData["BillNo"] == "") {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "해당 전표번호의 거래가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            var reHash:[String:String] = sqlite.instance.getAppToAppTrade(TermId: resDicData["TermID"] ?? "", AuDate: resDicData["AuDate"] ?? "", BillNo: resDicData["BillNo"] ?? "");
            
            if reHash.count > 2 {
                reHash.removeValue(forKey: "OriAuNo")
                reHash.removeValue(forKey: "OriAuDate")
                reHash.removeValue(forKey: "TrdAmt")
                reHash.removeValue(forKey: "TaxAmt")
                reHash.removeValue(forKey: "SvcAmt")
                reHash.removeValue(forKey: "TaxFreeAmt")
                reHash.removeValue(forKey: "Month")
                onResult(tcpStatus: .sucess, Result: reHash)
                
            } else {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "데이터가 없습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                
            }
            
            
            return
        case Command.CMD_KEY_UPDATE_REQ:
            //cat 연동일 경우
            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "CAT 연동은 지원하지않습니다"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            let _storeParserCheck = storeParserCheck(Tid: String(resDicData["TermID"] ?? ""), BSN: String(resDicData["BsnNo"] ?? ""), Serial: String(resDicData["Serial"] ?? ""))
            if !_storeParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _storeParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            tmpTid = String(resDicData["TermID"] ?? "")
            tmpBsn = String(resDicData["BsnNo"] ?? "")
            tmpSerial = String(resDicData["Serial"] ?? "")
            
            var _mchData = String(resDicData["MchData"] ?? "")
            if _mchData.isEmpty {
//                _mchData = ""
                _mchData = "MDO"
            }
            
            /** D10 가맹점다운로드 D20 키갱신시 사용 */
            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
            
            //장치정보에서 시리얼정보를 가져와서 하지 않고 그냥 여기서 시리얼정보를 요청해서 한다. 따로 장치정보버튼누르고 키업데이트버튼 누를 필요 없다
            keyUpdateCount = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){ [self] in
                mKocesSdk.GetDeviceInfo(Date: Utils.getDate(format: "yyyyMMddHHmmss"))
            }
//            mKocesSdk.KeyDownload(Command: String(resDicData["TrdType"]!), Tid: String(resDicData["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", Length: "0128", PosCheckData: _mchData, BSN: String(resDicData["BsnNo"]!), Serial: String(resDicData["Serial"]!), PosData: "", MacAddr: Utils.getKeyChainUUID(),CallbackListener: listener?.delegate as! TcpResultDelegate)
            
            break
        case Command.CMD_REGISTERED_SHOP_DOWNLOAD_REQ:
            
            //기존 정보들을 일단 다 제거 한다.
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key.contains(define.APPTOAPP_TID) {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                    KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                }
                if key.contains(define.APPTOAPP_BSN) {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
                if key.contains(define.APPTOAPP_SERIAL) {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
                if key.contains(define.APPTOAPP_ADDR) {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
            }
            
            let _storeParserCheck = storeParserCheck(Tid: String(resDicData["TermID"] ?? ""), BSN: String(resDicData["BsnNo"] ?? ""), Serial: String(resDicData["Serial"] ?? ""))
            if !_storeParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _storeParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            tmpTid = String(resDicData["TermID"] ?? "")
            tmpBsn = String(resDicData["BsnNo"] ?? "")
            tmpSerial = String(resDicData["Serial"] ?? "")
//            Setting.shared.setDefaultUserData(_data: String(resDicData["TermID"] ?? ""), _key: define.APPTOAPP_TID)
//            Setting.shared.setDefaultUserData(_data: String(resDicData["BsnNo"] ?? ""), _key: define.APPTOAPP_BSN)
//            Setting.shared.setDefaultUserData(_data: String(resDicData["Serial"] ?? ""), _key: define.APPTOAPP_SERIAL)
            
            var _mchData = String(resDicData["MchData"] ?? "")
            if _mchData.isEmpty {
//                _mchData = ""
                _mchData = "MDO"
            }
//            mKocesSdk.KeyDownload(Command: String(resDicData["TrdType"]!), Tid: String(resDicData["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", Length: "0003", PosCheckData: [UInt8]("MDO".utf8), BSN: String(resDicData["BsnNo"]!), Serial: String(resDicData["Serial"]!), PosData: "", MacAddr: Utils.getKeyChainUUID(), CallbackListener: listener?.delegate as! TcpResultDelegate)
            mKocesSdk.StoreDownload(Command: String(resDicData["TrdType"]!), Tid: String(resDicData["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", Length: "0003", PosCheckData: "MDO", BSN: String(resDicData["BsnNo"]!), Serial: String(resDicData["Serial"]!), PosData: "", MacAddr: Utils.getKeyChainUUID(), CallbackListener: listener?.delegate as! TcpResultDelegate)
            break
        case Command.CMD_ICTRADE_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _creditParserCheck = creditParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InstallMent: String(resDicData["Month"] ?? ""), DscYn: String(resDicData["DscYn"] ?? ""), DscData: String(resDicData["DscData"] ?? ""))
            if !_creditParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _creditParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            //cat 연동일 경우
            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = Utils.CheckCatPortIP()
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            
            
            if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "리더기 무결성 검증실패 제조사A/S요망."
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                mCatSdk.PayCredit(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: resDicData["Month"]!, 취소: false, 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])
            }
            else if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
                mpaySdk.CreditIC(Tid: String(resDicData["TermID"]!), Money: String(resDicData["TrdAmt"]!), Tax: Int(resDicData["TaxAmt"]!)!, ServiceCharge: Int(resDicData["SvcAmt"]!)!, TaxFree: Int(resDicData["TaxFreeAmt"]!)!, InstallMent: String(resDicData["Month"]!), OriDate: "", CancenInfo: "", mchData: String(resDicData["MchData"]!), KocesTreadeCode: String(resDicData["TradeNo"]!), CompCode: String(resDicData["CompCode"]!), SignDraw: String(resDicData["DscYn"] ?? "1"), FallBackUse: String(resDicData["FBYn"] ?? "0"),payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
            }
            break
        case Command.CMD_ICTRADE_CANCEL_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _creditCancelParserCheck = creditCancelParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InstallMent: String(resDicData["Month"] ?? ""), AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"] ?? ""), TradeNo: String(resDicData["TradeNo"] ?? ""), TrdCode: String(resDicData["TrdCode"] ?? ""), DscYn: String(resDicData["DscYn"] ?? ""), DscData: String(resDicData["DscData"] ?? ""))
            if !_creditCancelParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _creditCancelParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            //cat 연동일 경우
            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = Utils.CheckCatPortIP()
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            
            if resDicData["TrdCode"] == "T" {
                let _resonCancel = "a" + String(resDicData["AuDate"]?.prefix(6) ?? "") + (resDicData["AuNo"] ?? "")
                if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.PayCredit(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"] ?? ""), 코세스거래고유번호: String(resDicData["TradeNo"]!), 할부: resDicData["Month"]!, 취소: true, 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])
                }
                else {
                    mpaySdk.CreditDirectCancel(Command: Command.CMD_ICTRADE_CANCEL_REQ, Tid: String(resDicData["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), OriDate: String(resDicData["AuDate"] ?? ""), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: _resonCancel, InputType: "K", CardNumber: "", EncryptInfo: [UInt8](), Money: String(resDicData["TrdAmt"]!), Tax: String(resDicData["TaxAmt"]!), ServiceCharge: String(resDicData["SvcAmt"]!), TaxFree: String(resDicData["TaxFreeAmt"]!), Currency: "", InstallMent: String(resDicData["Month"]!), PosCertificationNumber: Utils.AppTmlcNo(), TradeType: "", EmvData: "", ResonFallBack: "", ICreqData: [UInt8](), WorkingKeyIndex: "", Password: "", OilSurpport: "", OilTaxFree: "", DccFlag: "", DccReqInfo: "", PointCardCode: "", PointCardNumber: "", PointCardEncprytInfo: [UInt8](), SignInfo: Setting.shared.g_sDigSignInfo, SignPadSerial: "", SignData: [UInt8](), Certification: "", PosData: String(resDicData["MchData"]!), KocesUid: String(resDicData["TradeNo"]!), UniqueCode: resDicData["CompCode"]!, payLinstener: paylistener?.delegate as! PayResultDelegate)
                }
            } else {
                if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
                
                //cat 연동일 경우
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    if Utils.CheckCatPortIP() != "" {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = Utils.CheckCatPortIP()
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
                
                if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                    if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = "리더기 무결성 검증실패 제조사A/S요망."
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
                
                let _resonCancel = "0" +  String(resDicData["AuDate"]?.prefix(6) ?? "") + (resDicData["AuNo"] ?? "")
                if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.PayCredit(TID:  String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"] ?? ""), 코세스거래고유번호: String(resDicData["TradeNo"]!), 할부: resDicData["Month"]!, 취소: true, 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])
                }
                else if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
                    mpaySdk.CreditIC(Tid: String(resDicData["TermID"]!), Money: String(resDicData["TrdAmt"]!), Tax: Int(resDicData["TaxAmt"]!)!, ServiceCharge: Int(resDicData["SvcAmt"]!)!, TaxFree: Int(resDicData["TaxFreeAmt"]!)!, InstallMent: String(resDicData["Month"]!), OriDate: String(resDicData["AuDate"] ?? ""), CancenInfo: _resonCancel, mchData: String(resDicData["MchData"]!), KocesTreadeCode: String(resDicData["TradeNo"]!), CompCode: String(resDicData["CompCode"]!), SignDraw: String(resDicData["DscYn"] ?? "1"), FallBackUse: String(resDicData["FBYn"] ?? "0"),payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                }
            }

            break
        case Command.CMD_CASH_RECEIPT_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _cashParserCheck = cashParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InsYn: String(resDicData["InsYn"] ?? ""), KeyYn: String(resDicData["KeyYn"] ?? ""), CashNum: String(resDicData["CashNum"] ?? ""))
            if !_cashParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _cashParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            var cashNum = resDicData["CashNum"] ?? ""
            //만일 현금영수증 자진발급(3)일 경우 자진발급번호로 즉시 거래를 진행한다.결제방법을 카드리더기 선택이거나 입력된 번호가 있더라도 모두 무시하고
                   //자진발급번호(고객번호) "0100001234" 로 진행한다. 신분확인번호(CashNum)"0100001234" 입력방법(KeyYn)"K" 개인/법인(InsYn) 구분:3
            if resDicData["InsYn"] == "3" {
                cashNum = "0100001234"
            }
            
            if cashNum.isEmpty {
                if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
                
                //cat 연동일 경우
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    if Utils.CheckCatPortIP() != "" {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = Utils.CheckCatPortIP()
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
                if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                    if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = "리더기 무결성 검증실패 제조사A/S요망."
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
               
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.CashRecipt(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: "", 고객번호: "", 개인법인구분: resDicData["InsYn"]!, 취소: false, 최소사유: "", 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate as! CatResultDelegate, Products: [])
                }
                else {
                    mpaySdk.CashRecipt(Tid: String(resDicData["TermID"]!), Money: String(resDicData["TrdAmt"]!), Tax: Int(resDicData["TaxAmt"]!)!, ServiceCharge: Int(resDicData["SvcAmt"]!)!, TaxFree: Int(resDicData["TaxFreeAmt"]!)!, PrivateOrBusiness: Int(resDicData["InsYn"]!)!, ReciptIndex: "0000", CancelInfo: "", OriDate: "", InputMethod: String(resDicData["KeyYn"] ?? ""), CancelReason: "", ptCardCode: "", ptAcceptNum: "", BusinessData: String(resDicData["MchData"]!), Bangi: String(resDicData["CompCode"]!), KocesTradeUnique: String(resDicData["TradeNo"] ?? ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                }
            } else {
                //cat 연동일 경우
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    if Utils.CheckCatPortIP() != "" {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = Utils.CheckCatPortIP()
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.CashRecipt(TID:  String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: "", 고객번호: cashNum, 개인법인구분: resDicData["InsYn"]!, 취소: false, 최소사유: "", 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate as! CatResultDelegate, Products: [])
                }
                else {
                    mpaySdk.CashReciptDirectInput(CancelReason: "", Tid: String(resDicData["TermID"]!), AuDate: "", AuNo: "", Num: cashNum, Command: String(resDicData["TrdType"]!), MchData: String(resDicData["MchData"]!), TrdAmt: String(resDicData["TrdAmt"]!), TaxAmt: String(resDicData["TaxAmt"]!), SvcAmt: String(resDicData["SvcAmt"]!), TaxFreeAmt: String(resDicData["TaxFreeAmt"]!), InsYn: String(resDicData["InsYn"]!), kocesNumber: String(resDicData["TradeNo"] ?? ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                }
            }

            break
        case Command.CMD_CASH_RECEIPT_CANCEL_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _cashCancelParserCheck = cashCancelParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InsYn: String(resDicData["InsYn"] ?? ""), KeyYn: String(resDicData["KeyYn"] ?? ""), CashNum: String(resDicData["CashNum"] ?? ""), CancelReason: String(resDicData["CancelReason"] ?? ""), AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"] ?? ""), TradeNo: String(resDicData["TradeNo"] ?? ""), TrdCode: String(resDicData["TrdCode"] ?? ""))
            if !_cashCancelParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _cashCancelParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            var cashNum = resDicData["CashNum"] ?? ""
            var cancelInfo = "0" + String(resDicData["AuDate"]?.prefix(6) ?? "") + (resDicData["AuNo"] ?? "")
            //만일 현금영수증 자진발급(3)일 경우 자진발급번호로 즉시 거래를 진행한다.결제방법을 카드리더기 선택이거나 입력된 번호가 있더라도 모두 무시하고
                   //자진발급번호(고객번호) "0100001234" 로 진행한다. 신분확인번호(CashNum)"0100001234" 입력방법(KeyYn)"K" 개인/법인(InsYn) 구분:3
            if resDicData["InsYn"] == "3" {
                cashNum = "0100001234"
                resDicData["KeyYn"] = "K"
            }
            
            if resDicData["TrdCode"] == "T" {   //거래고유키취소
                //cat 연동일 경우
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    if Utils.CheckCatPortIP() != "" {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = Utils.CheckCatPortIP()
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.CashRecipt(TID:  String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"]!), 코세스거래고유번호: String(resDicData["TradeNo"] ?? ""), 할부: "", 고객번호: cashNum, 개인법인구분: resDicData["InsYn"]!, 취소: true, 최소사유: String(resDicData["CancelReason"]!), 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate as! CatResultDelegate, Products: [])
                }
                else {
                    mpaySdk.CashReciptDirectInput(CancelReason: String(resDicData["CancelReason"]!), Tid: String(resDicData["TermID"]!), AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"]!), Num: cashNum, Command: String(resDicData["TrdType"]!), MchData: String(resDicData["MchData"]!), TrdAmt: String(resDicData["TrdAmt"]!), TaxAmt: String(resDicData["TaxAmt"]!), SvcAmt: String(resDicData["SvcAmt"]!), TaxFreeAmt: String(resDicData["TaxFreeAmt"]!), InsYn: String(resDicData["InsYn"]!), kocesNumber: String(resDicData["TradeNo"] ?? ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                }
            } else {
                resDicData["TradeNo"] = ""
                if cashNum.isEmpty {    //일반취소
                    if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                    
                    //cat 연동일 경우
                    if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                        if Utils.CheckCatPortIP() != "" {
                            var recDicData:[String:String] = [:]
                            recDicData["Message"] = Utils.CheckCatPortIP()
                            onResult(tcpStatus: .fail, Result: recDicData)
                            return
                        }
                    }
                    
                    if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                        if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                            var recDicData:[String:String] = [:]
                            recDicData["Message"] = "리더기 무결성 검증실패 제조사A/S요망."
                            onResult(tcpStatus: .fail, Result: recDicData)
                            return
                        }
                    }
                    if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                        mCatSdk.CashRecipt(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"]!), 코세스거래고유번호: String(resDicData["TradeNo"] ?? ""), 할부: "", 고객번호: "", 개인법인구분: resDicData["InsYn"]!, 취소: true, 최소사유: String(resDicData["CancelReason"]!), 가맹점데이터: resDicData["MchData"]!, 여유필드: "",StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate, Products: [])
                    }
                    else {
                        mpaySdk.CashRecipt(Tid: String(resDicData["TermID"]!), Money: String(resDicData["TrdAmt"]!), Tax: Int(resDicData["TaxAmt"]!)!, ServiceCharge: Int(resDicData["SvcAmt"]!)!, TaxFree: Int(resDicData["TaxFreeAmt"]!)!, PrivateOrBusiness: Int(resDicData["InsYn"]!)!, ReciptIndex: "0000", CancelInfo: cancelInfo, OriDate: String(resDicData["AuDate"] ?? ""), InputMethod: String(resDicData["KeyYn"]!), CancelReason: String(resDicData["CancelReason"]!), ptCardCode: "", ptAcceptNum: "", BusinessData: String(resDicData["MchData"]!), Bangi: String(resDicData["CompCode"]!), KocesTradeUnique: String(resDicData["TradeNo"] ?? ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                    }
                } else {    //다이렉트일반취소
                    //cat 연동일 경우
                    if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                        if Utils.CheckCatPortIP() != "" {
                            var recDicData:[String:String] = [:]
                            recDicData["Message"] = Utils.CheckCatPortIP()
                            onResult(tcpStatus: .fail, Result: recDicData)
                            return
                        }
                    }
                    if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                        mCatSdk.CashRecipt(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"]!), 코세스거래고유번호: "", 할부: "", 고객번호: cashNum, 개인법인구분: resDicData["InsYn"]!, 취소: true, 최소사유: String(resDicData["CancelReason"]!), 가맹점데이터: resDicData["MchData"]!, 여유필드: "",StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate, Products: [])
                    }
                    else {
                        mpaySdk.CashReciptDirectInput(CancelReason: String(resDicData["CancelReason"]!), Tid: String(resDicData["TermID"]!), AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"]!), Num: cashNum, Command: String(resDicData["TrdType"]!), MchData: String(resDicData["MchData"]!), TrdAmt: String(resDicData["TrdAmt"]!), TaxAmt: String(resDicData["TaxAmt"]!), SvcAmt: String(resDicData["SvcAmt"]!), TaxFreeAmt: String(resDicData["TaxFreeAmt"]!), InsYn: String(resDicData["InsYn"]!), kocesNumber: "", payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                    }
                }
            }
            break
        case Command.CMD_EASY_APPTOAPP_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _easyParserCheck = easyParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InstallMent: String(resDicData["Month"] ?? ""), DscYn: String(resDicData["DscYn"] ?? ""), DscData: String(resDicData["DscData"] ?? ""), QrKind: String(resDicData["QrKind"] ?? ""))
            if !_easyParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _easyParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
//            if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
//                var recDicData:[String:String] = [:]
//                recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
//                onResult(tcpStatus: .fail, Result: recDicData)
//                return
//            }
            
            //만일 페이코거래일 경우 캣단말기인지를 체크한다
            var isQrKind : String = String(resDicData["QrKind"] ?? "")
            if isQrKind == "PC" {
                if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "페이코 거래는 CAT 단말기로만 거래 가능합니다"
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            
            //cat 연동일 경우
            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = Utils.CheckCatPortIP()
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            
            
//            if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
//                if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
//                    var recDicData:[String:String] = [:]
//                    recDicData["Message"] = "리더기 무결성 검증실패 제조사A/S요망."
//                    onResult(tcpStatus: .fail, Result: recDicData)
//                    return
//                }
//            }
                        
            if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                mCatSdk.EasyRecipt(TrdType: Command.CMD_EASY_APPTOAPP_REQ, TID: resDicData["TermID"]!, Qr: resDicData["QrNo"]!, 거래금액: resDicData["TrdAmt"]!, 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, EasyKind: resDicData["QrKind"]!, 원거래일자: "", 원승인번호: "", 서브승인번호: "", 할부: resDicData["Month"] ?? "0", 가맹점데이터: resDicData["MchData"] ?? "", 호스트가맹점데이터: resDicData["HostMchData"] ?? "", 코세스거래고유번호: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "", CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])
            }
            else {
                var mTrdAmt:Int = (Int(resDicData["TrdAmt"]!)! + Int(resDicData["TaxFreeAmt"]!)!)
                resDicData["TrdAmt"] = String(mTrdAmt)
                
                mKakaoSdk.EasyPay(Command: _Command, Tid: resDicData["TermID"]!, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelDevine: "", AuDate: "", AuNo: "", InputType: "B", BarCode: resDicData["QrNo"] ?? "", OTCCardCode: [UInt8](), Money: resDicData["TrdAmt"]!, Tax: resDicData["TaxAmt"]!, ServiceCharge: resDicData["SvcAmt"]!, TaxFree: resDicData["TaxFreeAmt"]!, Currency: "", Installment: resDicData["Month"] ?? "0", PayType: "", CancelMethod: "", CancelType: "", StoreCode: "", PEM: "", trid: "", CardBIN: "", SearchNumber: "", WorkingKeyIndex: "", SignUse: resDicData["DscYn"] ?? "1", SignPadSerial: "", SignData: [UInt8](Setting.shared.mDscData.utf8), StoreData: resDicData["MchData"] ?? "", StoreInfo: resDicData["HostMchData"] ?? "", KocesUniNum: resDicData["TradeNo"] ?? "", payLinstener: paylistener?.delegate! as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", QrKind: resDicData["QrKind"] ?? "", Products: [])

            }
            break
        case Command.CMD_EASY_APPTOAPP_CANCEL_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _easyCancelParserCheck = easyCancelParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InstallMent: String(resDicData["Month"] ?? ""), AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"] ?? ""), TradeNo: String(resDicData["TradeNo"] ?? ""), TrdCode: String(resDicData["TrdCode"] ?? ""), DscYn: String(resDicData["DscYn"] ?? ""), DscData: String(resDicData["DscData"] ?? ""), QrKind: String(resDicData["QrKind"] ?? ""))
            if !_easyCancelParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _easyCancelParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            //만일 페이코거래일 경우 캣단말기인지를 체크한다
            var isQrKind : String = String(resDicData["QrKind"] ?? "")
            if isQrKind == "PC" {
                if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "페이코 거래는 CAT 단말기로만 거래 가능합니다"
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            
            //cat 연동일 경우
            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = Utils.CheckCatPortIP()
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            
            //취소시에는 UN통합 사용 불가
            if resDicData["QrKind"] == "UN" {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "취소시에는 UN 통합 사용 불가"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            if resDicData["AuDate"] != nil || resDicData["AuDate"] != "" {
                resDicData["AuDate"] = String(resDicData["AuDate"]!.prefix(6))
            }
            if resDicData["AuNo"] != nil || resDicData["AuNo"] != "" {
                resDicData["AuNo"] = resDicData["AuNo"]?.replacingOccurrences(of: " ", with: "")
            }
            
            if resDicData["TrdCode"] == "T" {
                if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.EasyRecipt(TrdType: Command.CMD_EASY_APPTOAPP_CANCEL_REQ, TID: resDicData["TermID"]!, Qr: resDicData["QrNo"]!, 거래금액: resDicData["TrdAmt"]!, 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, EasyKind: resDicData["QrKind"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"] ?? ""), 서브승인번호: "", 할부: resDicData["Month"] ?? "0", 가맹점데이터: resDicData["MchData"] ?? "", 호스트가맹점데이터: resDicData["HostMchData"] ?? "", 코세스거래고유번호: String(resDicData["TradeNo"] ?? ""), StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "", CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])

                }
                else {
                    var mTrdAmt:Int = (Int(resDicData["TrdAmt"]!)! + Int(resDicData["TaxFreeAmt"]!)! + Int(resDicData["SvcAmt"]!)! + Int(resDicData["TaxAmt"]!)!)
                    resDicData["TrdAmt"] = String(mTrdAmt)
                    
                    mKakaoSdk.EasyPay(Command: _Command, Tid: resDicData["TermID"]!, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelDevine: "a", AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"] ?? ""), InputType: "B", BarCode: resDicData["QrNo"] ?? "", OTCCardCode: [UInt8](), Money: resDicData["TrdAmt"]!, Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", Installment: resDicData["Month"] ?? "0", PayType: "", CancelMethod: "0", CancelType: "B", StoreCode: "", PEM: "", trid: "", CardBIN: "", SearchNumber: String(resDicData["TradeNo"] ?? ""), WorkingKeyIndex: "", SignUse: resDicData["DscYn"] ?? "1", SignPadSerial: "", SignData: [UInt8](Setting.shared.mDscData.utf8), StoreData: resDicData["MchData"] ?? "", StoreInfo: resDicData["HostMchData"] ?? "", KocesUniNum: resDicData["TradeNo"] ?? "", payLinstener: paylistener?.delegate! as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", QrKind: resDicData["QrKind"] ?? "", Products: [])

                }
            } else {
                if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.EasyRecipt(TrdType: Command.CMD_EASY_APPTOAPP_CANCEL_REQ, TID: resDicData["TermID"]!, Qr: resDicData["QrNo"]!, 거래금액: resDicData["TrdAmt"]!, 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, EasyKind: resDicData["QrKind"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"] ?? ""), 서브승인번호: "", 할부: resDicData["Month"] ?? "0", 가맹점데이터: resDicData["MchData"] ?? "", 호스트가맹점데이터: resDicData["HostMchData"] ?? "", 코세스거래고유번호: String(resDicData["TradeNo"] ?? ""), StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "", CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])
                    
                }
                else {
                    var mTrdAmt:Int = (Int(resDicData["TrdAmt"]!)! + Int(resDicData["TaxFreeAmt"]!)! + Int(resDicData["SvcAmt"]!)! + Int(resDicData["TaxAmt"]!)!)
                    resDicData["TrdAmt"] = String(mTrdAmt)
                    
                    mKakaoSdk.EasyPay(Command: _Command, Tid: resDicData["TermID"]!, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelDevine: "0", AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"] ?? ""), InputType: "B", BarCode: resDicData["QrNo"] ?? "", OTCCardCode: [UInt8](), Money: resDicData["TrdAmt"]!, Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", Installment: resDicData["Month"] ?? "0", PayType: "", CancelMethod: "0", CancelType: "B", StoreCode: "", PEM: "", trid: "", CardBIN: "", SearchNumber: String(resDicData["TradeNo"] ?? ""), WorkingKeyIndex: "", SignUse: resDicData["DscYn"] ?? "1", SignPadSerial: "", SignData: [UInt8](Setting.shared.mDscData.utf8), StoreData: resDicData["MchData"] ?? "", StoreInfo: resDicData["HostMchData"] ?? "", KocesUniNum: resDicData["TradeNo"] ?? "", payLinstener: paylistener?.delegate! as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", QrKind: resDicData["QrKind"] ?? "", Products: [])
                    
                }
            }
            break
        default:
            break
        }
    }
    
    func KeyDownload(KeyCheckData _data:[UInt8])
    {
        listener = TcpResult()
        listener?.delegate = self

        /** D10 가맹점다운로드 D20 키갱신시 사용 */
        mKocesSdk.KeyDownload(Command: "D20", Tid: tmpTid, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", Length: "0128", PosCheckData: _data, BSN: tmpBsn, Serial: tmpSerial, PosData: "", MacAddr: Utils.getKeyChainUUID(),CallbackListener: listener?.delegate as! TcpResultDelegate)
        
    }
    
    /** 키갱신시 사용 */
    func onKeyResult(tcpStatus _status: tcpStatus, Result _result: [UInt8], DicResult _dicresult: Dictionary<String, String>) {
        print(_result)
        mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        _keyDownloadResult = _dicresult
        mKocesSdk.KeyDownload_Update(Time: "20" + _dicresult["TrdDate"]!, Data: _result)
//        mKocesSdk.KeyDownload_Update(Time: Utils.getDate(format: "yyyyMMddHHmmss"), Data: _result)
    }

    /** 가맹점등록다운로드 결과 페이지. 만일 데이터 전송을 앱/웹으로 전송에 실패에 따른 처리완료 */
    func onResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>) {
        alert.dismiss(animated: true, completion: nil)
        if Setting.shared.WebtoApp != "" {
            WebORApp = 0
        } else if Setting.shared.ApptoApp != "" {
            WebORApp = 1
        }
        /** log : 앱투앱 기록 시작 */
        let _tmpTermID = _result["TermID"] ?? ""
        if _tmpTermID != "" {
            if WebORApp == 0 {
                LogFile.instance.InsertLog("********** WebToApp Service **********", Tid: _result["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("WebToApp onResult -> " + _result.description, Tid: _result["TermID"] ?? "", TimeStamp: true)
            } else if WebORApp == 1 {
                LogFile.instance.InsertLog("********** AppToApp Service **********", Tid: _result["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("AppToApp onResult -> " + _result.description, Tid: _result["TermID"] ?? "", TimeStamp: true)
            }
        } else {
            if WebORApp == 0 {
                LogFile.instance.InsertLog("********** WebToApp Service **********", Tid: _result["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("WebToApp onResult TermID 없음-> " + _result.description, Tid: _result["TermID"] ?? "", TimeStamp: true)
            } else if WebORApp == 1 {
                LogFile.instance.InsertLog("********** AppToApp Service **********", Tid: _result["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("AppToApp onResult TermID 없음-> " + _result.description, Tid: _result["TermID"] ?? "", TimeStamp: true)
            }
        }
        

        let _trdType = _result["TrdType"] ?? ""
        let _code = _result["AnsCode"] ?? ""
        var tmpResult = _result;
        if (tmpTrdType != "R10" && tmpTrdType != "R20" && tmpTrdType != "F10" && tmpTrdType != "P10" && tmpTrdType != "" && _trdType != "") {
//            if(_result["TrdType"]!.contains("20"))
//            {
//                tmpResult["OriAuDate"] = tmpresDicData["AuDate"];
//                tmpResult["OriAuNo"] = tmpresDicData["AuNo"];
//            }
            if(tmpTrdType.contains("20"))
            {
                tmpResult["OriAuDate"] = tmpresDicData["AuDate"];
                tmpResult["OriAuNo"] = tmpresDicData["AuNo"];
            }

            tmpResult["BillNo"] =  tmpBillNo;
            tmpResult["TrdAmt"] = tmpresDicData["TrdAmt"];
            tmpResult["TaxAmt"] = tmpresDicData["TaxAmt"];
            tmpResult["SvcAmt"] = tmpresDicData["SvcAmt"];
            tmpResult["TaxFreeAmt"] = tmpresDicData["TaxFreeAmt"];
            tmpResult["Month"] = tmpresDicData["Month"];
            
//            tmpResult["PcKind"] = tmpresDicData["PcKind"];
//            tmpResult["PcCoupon"] = tmpresDicData["PcCoupon"];
//            tmpResult["PcPoint"] = tmpresDicData["PcPoint"];
//            tmpResult["PcCard"] = tmpresDicData["PcCard"];
            if (!tmpBillNo.isEmpty && tmpBillNo.count == 12) {
                sqlite.instance.insertAppToAppData(resultData: tmpResult)
            }
        }
        
        tmpBillNo = ""
        tmpTrdType = ""
        tmpresDicData = [:]
                                              
                                              
                                              
        
        //여기는 가맹점데이터처리일 경우만 처리하는 곳이라 따로 분류를 하지 않는다
        var _totalString:String = ""
        var keyCount:Int = 0
        var WebPostParamameter:[String:Any] = [:]
        if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
            //가맹점다운로드일경우
            if _code == "0000" {
                Setting.shared.setDefaultUserData(_data: tmpTid, _key: define.APPTOAPP_TID)
                Setting.shared.setDefaultUserData(_data: tmpBsn, _key: define.APPTOAPP_BSN)
                Setting.shared.setDefaultUserData(_data: tmpSerial, _key: define.APPTOAPP_SERIAL)
                if _trdType == "D16" || _trdType == "D17" {
                    var TermIDCount:Int = 0    //총 몇개의 키를 저장해야 하는지 체크
                    for (key,value) in _result {
                        if key.contains("TermID") {
                            TermIDCount += 1
                        }
                    }
                    //이게 1개란 소리는 복수가맹점으로 했지만 실제로 복수가맹점데이터 필드에는 데이터가 없었다는 소리다.
                    if TermIDCount == 1 {
                        Setting.shared.setDefaultUserData(_data: _result["TermID"]!, _key: define.APPTOAPP_TID)
                        Setting.shared.setDefaultUserData(_data: _result["BsnNo"]!, _key: define.APPTOAPP_BSN)
                        Setting.shared.setDefaultUserData(_data: tmpSerial, _key: define.APPTOAPP_SERIAL)
                   

                    } else {
                        var _key:String = ""
                        for i in 0 ..< (TermIDCount - 1) {
                            Setting.shared.setDefaultUserData(_data: _result["TermID" + String(i)]!, _key: define.APPTOAPP_TID + String(i))
                            Setting.shared.setDefaultUserData(_data: _result["BsnNo" + String(i)]!, _key: define.APPTOAPP_BSN + String(i))
                            Setting.shared.setDefaultUserData(_data: tmpSerial, _key: define.APPTOAPP_SERIAL + String(i))
              
                        }
                    }
                }
            } else {
                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                tmpTid = ""
                tmpBsn = ""
                tmpSerial = ""
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key.contains(define.APPTOAPP_TID) {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                        KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                    }
                    if key.contains(define.APPTOAPP_BSN) {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                    if key.contains(define.APPTOAPP_SERIAL) {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                   
                }

            }
            
            if _trdType == "D16" || _trdType == "D17" {
                for (key,value) in _result {
                    if _result.count - 1 == keyCount {
                        _totalString += key + "=" + value
                    }
                    else{
                        _totalString += key + "=" + value + "&"
                    }
                    keyCount += 1
                    WebPostParamameter.updateValue(value, forKey: key)
                }
            } else {
                for (key,value) in _result {
                    if key == "TrdType" || key == "TermID" || key == "TrdDate" || key == "AnsCode" ||
                        key == "Message" || key == "AsNum" || key == "ShpNm" || key == "BsnNo" ||
                        key == "PreNm" || key == "ShpAdr" || key == "ShpTel" || key == "MchData" {
                        if 12 - 1 == keyCount {
                            //실제 보내는 키는 12개라서 12 - 1 을 했다
                            _totalString += key + "=" + value
                        }
                        else{
                            _totalString += key + "=" + value + "&"
                        }
                        keyCount += 1
                        WebPostParamameter.updateValue(value, forKey: key)
                    }
                }
            }
        } else {
            //일반 앱투앱/웹투앱으로 오류메세지 보낼때
            for (key,value) in _result {
                if _result.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "&"
                }
                keyCount += 1
                WebPostParamameter.updateValue(value, forKey: key)
            }
 
            
        }

        var message = ""
        if _totalString.isEmpty {
            message = "Message=" +  (_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
        } else {
            let _t1 = _totalString.replacingOccurrences(of: "/", with: "%2F")
            let _t2 = _t1.replacingOccurrences(of: ":", with: "%3A")
            message = _t2.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        }
        debugPrint(" res StringCode = \(message)")

        var cusomUrl = ""
        if WebORApp == 0 {  //webToApp
            cusomUrl = Setting.shared.mWebAPPReturnAddr //웹페이지랑 연동시 처리 해당페이지 주소입력 이부분은 환경설정이나 이런곳에서 셋팅하는 방향?
        } else {    //AppToApp
            cusomUrl = define.APPTOAPP_ADDR + "?" + "\(message)"  //앱투앱으로 처리시
        }
        
        guard let url = URL(string: cusomUrl) else {
            if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                //가맹점다운로드일경우
                if _code != "0000" {
                    Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                    Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                    Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                    tmpTid = ""
                    tmpBsn = ""
                    tmpSerial = ""
                    for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                        if key.contains(define.APPTOAPP_TID) {
                            Setting.shared.setDefaultUserData(_data: "", _key: key)
                            KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                        }
                        if key.contains(define.APPTOAPP_BSN) {
                            Setting.shared.setDefaultUserData(_data: "", _key: key)
                        }
                        if key.contains(define.APPTOAPP_SERIAL) {
                            Setting.shared.setDefaultUserData(_data: "", _key: key)
                        }
                       
                    }
                }
            }
            
            var _error:Dictionary<String,String> = [:]
            _error["Message"] = (_trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17") ? "가맹점데이터 전송 실패":(_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
            _error["TrdType"] = _trdType
            self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
            return
        }

        guard UIApplication.shared.canOpenURL(url) else {
            if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                //가맹점다운로드일경우
                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                tmpTid = ""
                tmpBsn = ""
                tmpSerial = ""
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key.contains(define.APPTOAPP_TID) {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                        KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                    }
                    if key.contains(define.APPTOAPP_BSN) {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                    if key.contains(define.APPTOAPP_SERIAL) {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                   
                }
            }
            var _error:Dictionary<String,String> = [:]
            _error["Message"] = (_trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17") ? "가맹점데이터 전송 실패":(_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
            _error["TrdType"] = _trdType
            self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
            return
        }

        if WebORApp == 0 {

            //2020.05.20 kim.jy
            let url = URL(string: cusomUrl)!
            var request = URLRequest(url: url)
            //2020-06-25 json 데이터가 정상적으로 전달 되지 않는 문제 수정
            //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept-Type")
            request.httpMethod = "POST"
            let postData = (try? JSONSerialization.data(withJSONObject: WebPostParamameter, options: []))
            request.httpBody = postData
 
            let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {   // check for fundamental networking error
                    if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                        //가맹점다운로드일경우
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                        tmpTid = ""
                        tmpBsn = ""
                        tmpSerial = ""
                        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                            if key.contains(define.APPTOAPP_TID) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                                KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                            }
                            if key.contains(define.APPTOAPP_BSN) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                            }
                            if key.contains(define.APPTOAPP_SERIAL) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                            }
                           
                        }
                    }
                    var _error:Dictionary<String,String> = [:]
                    _error["Message"] = (_trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17") ? "가맹점데이터 전송 실패":(_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
                    _error["TrdType"] = _trdType
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _result.count > 0 ? _result:_error, resultCheck: false)
                    return
                }

                guard (200 ... 299) ~= response.statusCode else {  // check for http errors
                    if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                        //가맹점다운로드일경우
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                        tmpTid = ""
                        tmpBsn = ""
                        tmpSerial = ""
                        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                            if key.contains(define.APPTOAPP_TID) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                                KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                            }
                            if key.contains(define.APPTOAPP_BSN) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                            }
                            if key.contains(define.APPTOAPP_SERIAL) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                            }
                           
                        }
                    }
                    var _error:Dictionary<String,String> = [:]
                    _error["Message"] = (_trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17") ? "가맹점데이터 전송 실패":(_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
                    _error["TrdType"] = _trdType
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _result.count > 0 ? _result:_error, resultCheck: false)
                    return
                }

                
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
 
                self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _result)
            }

            task.resume()

//            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)

      
        }
        else {
 
            UIApplication.shared.open(url, options: [:], completionHandler: { [self](success) in
                if success {
                
                } else {
                    if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                        //가맹점다운로드일경우
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                        tmpTid = ""
                        tmpBsn = ""
                        tmpSerial = ""
                        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                            if key.contains(define.APPTOAPP_TID) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                                KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                            }
                            if key.contains(define.APPTOAPP_BSN) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                            }
                            if key.contains(define.APPTOAPP_SERIAL) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                            }
                           
                        }
                    }
                    var _error:Dictionary<String,String> = [:]
                    _error["Message"] = (_trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17") ? "가맹점데이터 전송 실패":(_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
                    _error["TrdType"] = _trdType
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
                    return
                   
                }
            })
        }

    }
    
    /** 앱투앱/웹투앱 으로 가맹점다운로드와 거래요청을 같이 보내는 경우 처리한다 */
    func onDirectResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>, DirectData _directData: Dictionary<String, String>)
    {
        alert.dismiss(animated: true, completion: nil)
        
        /** log : 앱투앱 기록 시작 */
        let _tmpTermID = _result["TermID"] ?? ""
        if _tmpTermID != "" {
            if WebORApp == 0 {
                LogFile.instance.InsertLog("********** WebToApp Service **********", Tid: _result["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("WebToApp onDirectResult _result -> " + _result.description, Tid: _result["TermID"] ?? "", TimeStamp: true)
                LogFile.instance.InsertLog("WebToApp onDirectResult _directData -> " + _directData.description, Tid: _result["TermID"] ?? "", TimeStamp: true)
            } else if WebORApp == 1 {
                LogFile.instance.InsertLog("********** AppToApp Service **********", Tid: _result["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("AppToApp onDirectResult _result -> " + _result.description, Tid: _result["TermID"] ?? "", TimeStamp: true)
                LogFile.instance.InsertLog("AppToApp onDirectResult _directData -> " + _directData.description, Tid: _directData["TermID"] ?? "", TimeStamp: true)
            }
        } else {
            if WebORApp == 0 {
                LogFile.instance.InsertLog("********** WebToApp Service **********", Tid: _directData["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("WebToApp onDirectResult _result -> " + _result.description, Tid: _directData["TermID"] ?? "", TimeStamp: true)
                LogFile.instance.InsertLog("WebToApp onDirectResult _directData -> " + _directData.description, Tid: _directData["TermID"] ?? "", TimeStamp: true)
            } else if WebORApp == 1 {
                LogFile.instance.InsertLog("********** AppToApp Service **********", Tid: _result["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("AppToApp onDirectResult _result -> " + _result.description, Tid: _directData["TermID"] ?? "", TimeStamp: true)
                LogFile.instance.InsertLog("AppToApp onDirectResult _directData -> " + _directData.description, Tid: _directData["TermID"] ?? "", TimeStamp: true)
            }
        }


        var resDicData = _directData
        let _trdType = _result["TrdType"] ?? ""
        let _code = _result["AnsCode"] ?? ""
        
        var tmpResult = _result;
        if (tmpTrdType != "R10" && tmpTrdType != "R20" && tmpTrdType != "F10" && tmpTrdType != "P10" && tmpTrdType != "" && _trdType != "") {
//            if(_result["TrdType"]!.contains("20"))
//            {
//                tmpResult["OriAuDate"] = tmpresDicData["AuDate"];
//                tmpResult["OriAuNo"] = tmpresDicData["AuNo"];
//            }
            if(tmpTrdType.contains("20"))
            {
                tmpResult["OriAuDate"] = tmpresDicData["AuDate"];
                tmpResult["OriAuNo"] = tmpresDicData["AuNo"];
            }

            tmpResult["BillNo"] =  tmpBillNo;
            tmpResult["TrdAmt"] = tmpresDicData["TrdAmt"];
            tmpResult["TaxAmt"] = tmpresDicData["TaxAmt"];
            tmpResult["SvcAmt"] = tmpresDicData["SvcAmt"];
            tmpResult["TaxFreeAmt"] = tmpresDicData["TaxFreeAmt"];
            tmpResult["Month"] = tmpresDicData["Month"];
            if (!tmpBillNo.isEmpty && tmpBillNo.count == 12) {
                sqlite.instance.insertAppToAppData(resultData: tmpResult)
            }
        }
        
        tmpBillNo = ""
        tmpTrdType = ""
        tmpresDicData = [:]
        
        
        if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
            //가맹점다운로드일경우
            if _code == "0000" {
                Setting.shared.setDefaultUserData(_data: tmpTid, _key: define.APPTOAPP_TID)
                Setting.shared.setDefaultUserData(_data: tmpBsn, _key: define.APPTOAPP_BSN)
                Setting.shared.setDefaultUserData(_data: tmpSerial, _key: define.APPTOAPP_SERIAL)
                Setting.shared.tmpTid = tmpTid
                if _trdType == "D16" || _trdType == "D17" {
                    var TermIDCount:Int = 0    //총 몇개의 키를 저장해야 하는지 체크
                    for (key,value) in _result {
                        if key.contains("TermID") {
                            TermIDCount += 1
                        }
                    }
                    //이게 1개란 소리는 복수가맹점으로 했지만 실제로 복수가맹점데이터 필드에는 데이터가 없었다는 소리다.
                    if TermIDCount == 1 {
                        Setting.shared.setDefaultUserData(_data: _result["TermID"]!, _key: define.APPTOAPP_TID)
                        Setting.shared.setDefaultUserData(_data: _result["BsnNo"]!, _key: define.APPTOAPP_BSN)
                        Setting.shared.setDefaultUserData(_data: tmpSerial, _key: define.APPTOAPP_SERIAL)
                

                    } else {
                        var _key:String = ""
                        for i in 0 ..< (TermIDCount - 1) {
                            Setting.shared.setDefaultUserData(_data: _result["TermID" + String(i)]!, _key: define.APPTOAPP_TID + String(i))
                            Setting.shared.setDefaultUserData(_data: _result["BsnNo" + String(i)]!, _key: define.APPTOAPP_BSN + String(i))
                            Setting.shared.setDefaultUserData(_data: tmpSerial, _key: define.APPTOAPP_SERIAL + String(i))
                
                        }
                    }
                }
            } else {
                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                tmpTid = ""
                tmpBsn = ""
                tmpSerial = ""
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key.contains(define.APPTOAPP_TID) {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                        KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                    }
                    if key.contains(define.APPTOAPP_BSN) {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                    if key.contains(define.APPTOAPP_SERIAL) {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                   
                }
            }
        }
        if _code != "0000" && (_trdType == "D15" || _trdType == "D16" || _trdType == "D25" || _trdType == "D17") {
            //여기는 가맹점데이터처리일 경우만 처리하는 곳이라 따로 분류를 하지 않는다
            var _totalString:String = ""
            var keyCount:Int = 0
            var WebPostParamameter:[String:Any] = [:]
            if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                //가맹점다운로드일경우
                if _code == "0000" {
                    Setting.shared.setDefaultUserData(_data: tmpTid, _key: define.APPTOAPP_TID)
                    Setting.shared.setDefaultUserData(_data: tmpBsn, _key: define.APPTOAPP_BSN)
                    Setting.shared.setDefaultUserData(_data: tmpSerial, _key: define.APPTOAPP_SERIAL)
                    if _trdType == "D16" || _trdType == "D17" {
                        var TermIDCount:Int = 0    //총 몇개의 키를 저장해야 하는지 체크
                        for (key,value) in _result {
                            if key.contains("TermID") {
                                TermIDCount += 1
                            }
                        }
                        //이게 1개란 소리는 복수가맹점으로 했지만 실제로 복수가맹점데이터 필드에는 데이터가 없었다는 소리다.
                        if TermIDCount == 1 {
                            Setting.shared.setDefaultUserData(_data: _result["TermID"]!, _key: define.APPTOAPP_TID)
                            Setting.shared.setDefaultUserData(_data: _result["BsnNo"]!, _key: define.APPTOAPP_BSN)
                            Setting.shared.setDefaultUserData(_data: tmpSerial, _key: define.APPTOAPP_SERIAL)
                          
                        } else {
                            var _key:String = ""
                            for i in 0 ..< (TermIDCount - 1) {
                                Setting.shared.setDefaultUserData(_data: _result["TermID" + String(i)]!, _key: define.APPTOAPP_TID + String(i))
                                Setting.shared.setDefaultUserData(_data: _result["BsnNo" + String(i)]!, _key: define.APPTOAPP_BSN + String(i))
                                Setting.shared.setDefaultUserData(_data: tmpSerial, _key: define.APPTOAPP_SERIAL + String(i))
                            
                            }
                        }
                    }
                } else {
                    Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                    Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                    Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                    tmpTid = ""
                    tmpBsn = ""
                    tmpSerial = ""
                    for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                        if key.contains(define.APPTOAPP_TID) {
                            Setting.shared.setDefaultUserData(_data: "", _key: key)
                            KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                        }
                        if key.contains(define.APPTOAPP_BSN) {
                            Setting.shared.setDefaultUserData(_data: "", _key: key)
                        }
                        if key.contains(define.APPTOAPP_SERIAL) {
                            Setting.shared.setDefaultUserData(_data: "", _key: key)
                        }
                       
                    }
                }
                if _trdType == "D16" || _trdType == "D17" {
                    for (key,value) in _result {
                        if _result.count - 1 == keyCount {
                            _totalString += key + "=" + value
                        }
                        else{
                            _totalString += key + "=" + value + "&"
                        }
                        keyCount += 1
                        WebPostParamameter.updateValue(value, forKey: key)
                    }
                } else {
                    for (key,value) in _result {
                        if key == "TrdType" || key == "TermID" || key == "TrdDate" || key == "AnsCode" ||
                            key == "Message" || key == "AsNum" || key == "ShpNm" || key == "BsnNo" ||
                            key == "PreNm" || key == "ShpAdr" || key == "ShpTel" || key == "MchData" {
                            if 12 - 1 == keyCount {
                                //실제 보내는 키는 12개라서 12 - 1 을 했다
                                _totalString += key + "=" + value
                            }
                            else{
                                _totalString += key + "=" + value + "&"
                            }
                            keyCount += 1
                            WebPostParamameter.updateValue(value, forKey: key)
                        }
                    }
                }
            } else {
                //일반 앱투앱/웹투앱으로 오류메세지 보낼때
                for (key,value) in _result {
                    if _result.count - 1 == keyCount {
                        _totalString += key + "=" + value
                    }
                    else{
                        _totalString += key + "=" + value + "&"
                    }
                    keyCount += 1
                    WebPostParamameter.updateValue(value, forKey: key)
                }

            }

            var message = ""
            if _totalString.isEmpty {
                message = "Message=" +  (_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
            } else {
                let _t1 = _totalString.replacingOccurrences(of: "/", with: "%2F")
                let _t2 = _t1.replacingOccurrences(of: ":", with: "%3A")
                message = _t2.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
            }
            debugPrint(" res StringCode = \(message)")

            var cusomUrl = ""
            if WebORApp == 0 {  //webToApp
                cusomUrl = Setting.shared.mWebAPPReturnAddr //웹페이지랑 연동시 처리 해당페이지 주소입력 이부분은 환경설정이나 이런곳에서 셋팅하는 방향?
            } else {    //AppToApp
                cusomUrl = define.APPTOAPP_ADDR + "?" + "\(message)"  //앱투앱으로 처리시
            }
            
            guard let url = URL(string: cusomUrl) else {
                if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                    //가맹점다운로드일경우
                    if _code != "0000" {
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                        tmpTid = ""
                        tmpBsn = ""
                        tmpSerial = ""
                        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                            if key.contains(define.APPTOAPP_TID) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                                KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                            }
                            if key.contains(define.APPTOAPP_BSN) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                            }
                            if key.contains(define.APPTOAPP_SERIAL) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                            }
                           
                        }
                    }
                }
                var _error:Dictionary<String,String> = [:]
                _error["Message"] = (_trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17") ? "가맹점데이터 전송 실패":(_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
                _error["TrdType"] = _trdType
                self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
                return
            }

            guard UIApplication.shared.canOpenURL(url) else {
                if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                    //가맹점다운로드일경우
                    if _code != "0000" {
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                        Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                        tmpTid = ""
                        tmpBsn = ""
                        tmpSerial = ""
                        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                            if key.contains(define.APPTOAPP_TID) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                                KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                            }
                            if key.contains(define.APPTOAPP_BSN) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                            }
                            if key.contains(define.APPTOAPP_SERIAL) {
                                Setting.shared.setDefaultUserData(_data: "", _key: key)
                            }
                           
                        }
                    }
                }
                var _error:Dictionary<String,String> = [:]
                _error["Message"] = (_trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17") ? "가맹점데이터 전송 실패":(_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
                _error["TrdType"] = _trdType
                self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
                return
            }

            if WebORApp == 0 {
                //2020.05.20 kim.jy
                let url = URL(string: cusomUrl)!
                var request = URLRequest(url: url)
                //2020-06-25 json 데이터가 정상적으로 전달 되지 않는 문제 수정
                //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept-Type")
                request.httpMethod = "POST"
                let postData = (try? JSONSerialization.data(withJSONObject: WebPostParamameter, options: []))
                request.httpBody = postData
             
                
                let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
                    guard let data = data,
                          let response = response as? HTTPURLResponse,
                          error == nil else {   // check for fundamental networking error
                        if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                            //가맹점다운로드일경우
                            if _code != "0000" {
                                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                                tmpTid = ""
                                tmpBsn = ""
                                tmpSerial = ""
                                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                                    if key.contains(define.APPTOAPP_TID) {
                                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                                        KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                                    }
                                    if key.contains(define.APPTOAPP_BSN) {
                                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                                    }
                                    if key.contains(define.APPTOAPP_SERIAL) {
                                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                                    }
                                   
                                }
                            }
                        }
                        var _error:Dictionary<String,String> = [:]
                        _error["Message"] = (_trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17") ? "가맹점데이터 전송 실패":(_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
                        _error["TrdType"] = _trdType
                        self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _result.count > 0 ? _result:_error, resultCheck: false)
                        return
                    }

                    guard (200 ... 299) ~= response.statusCode else {  // check for http errors
                        if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                            //가맹점다운로드일경우
                            if _code != "0000" {
                                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                                Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                                tmpTid = ""
                                tmpBsn = ""
                                tmpSerial = ""
                                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                                    if key.contains(define.APPTOAPP_TID) {
                                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                                        KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                                    }
                                    if key.contains(define.APPTOAPP_BSN) {
                                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                                    }
                                    if key.contains(define.APPTOAPP_SERIAL) {
                                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                                    }
                                   
                                }
                            }
                        }
                        var _error:Dictionary<String,String> = [:]
                        _error["Message"] = (_trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17") ? "가맹점데이터 전송 실패":(_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
                        _error["TrdType"] = _trdType
                        self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _result.count > 0 ? _result:_error, resultCheck: false)
                        return
                    }

                    
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(String(describing: responseString))")
                
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _result)
                }

                task.resume()
    //            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }
            else {
         
                UIApplication.shared.open(url, options: [:], completionHandler: { [self](success) in
                    if success {
                    
                    } else {
                        if _trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17" {
                            //가맹점다운로드일경우
                            Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_TID)
                            Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_BSN)
                            Setting.shared.setDefaultUserData(_data: "", _key: define.APPTOAPP_SERIAL)
                            tmpTid = ""
                            tmpBsn = ""
                            tmpSerial = ""
                            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                                if key.contains(define.APPTOAPP_TID) {
                                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                                    KeychainWrapper.standard.removeObject(forKey: keyChainTarget.AppToApp.rawValue + (value as! String))
                                }
                                if key.contains(define.APPTOAPP_BSN) {
                                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                                }
                                if key.contains(define.APPTOAPP_SERIAL) {
                                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                                }
                               
                            }
                        }
                        var _error:Dictionary<String,String> = [:]
                        _error["Message"] = (_trdType == "D15" || _trdType == "D25" || _trdType == "D16" || _trdType == "D17") ? "가맹점데이터 전송 실패":(_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
                        _error["TrdType"] = _trdType
                        self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
                        return
                       
                    }
                })
            }
            return
        }
        
        //에러일 경우 위에서 처리
        
        switch resDicData["TrdType"] {
        case Command.CMD_REGISTERED_SHOP_DOWNLOAD_REQ:
            let _storeParserCheck = storeParserCheck(Tid: String(resDicData["TermID"] ?? ""), BSN: String(resDicData["BsnNo"] ?? ""), Serial: String(resDicData["Serial"] ?? ""))
            if !_storeParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _storeParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            tmpTid = String(resDicData["TermID"] ?? "")
            tmpBsn = String(resDicData["BsnNo"] ?? "")
            tmpSerial = String(resDicData["Serial"] ?? "")

            var _mchData = String(resDicData["MchData"] ?? "")
            if _mchData.isEmpty {
//                _mchData = ""
                _mchData = "MDO"
            }

            mKocesSdk.StoreDownload(Command: String(resDicData["TrdType"]!), Tid: String(resDicData["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", Length: "0003", PosCheckData: "MDO", BSN: String(resDicData["BsnNo"]!), Serial: String(resDicData["Serial"]!), PosData: "", MacAddr: Utils.getKeyChainUUID(), CallbackListener: listener?.delegate as! TcpResultDelegate)
            break
        case Command.CMD_ICTRADE_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _creditParserCheck = creditParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InstallMent: String(resDicData["Month"] ?? ""), DscYn: String(resDicData["DscYn"] ?? ""), DscData: String(resDicData["DscData"] ?? ""))
            if !_creditParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _creditParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            //cat 연동일 경우
            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = Utils.CheckCatPortIP()
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            
            if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "리더기 무결성 검증실패 제조사A/S요망."
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }

            if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                mCatSdk.PayCredit(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: resDicData["Month"]!, 취소: false, 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])
            }
            else if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
                mpaySdk.CreditIC(Tid: String(resDicData["TermID"]!), Money: String(resDicData["TrdAmt"]!), Tax: Int(resDicData["TaxAmt"]!)!, ServiceCharge: Int(resDicData["SvcAmt"]!)!, TaxFree: Int(resDicData["TaxFreeAmt"]!)!, InstallMent: String(resDicData["Month"]!), OriDate: "", CancenInfo: "", mchData: String(resDicData["MchData"]!), KocesTreadeCode: String(resDicData["TradeNo"]!), CompCode: String(resDicData["CompCode"]!), SignDraw: String(resDicData["DscYn"] ?? "1"), FallBackUse: String(resDicData["FBYn"] ?? "0"),payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
            }
 
            break
        case Command.CMD_ICTRADE_CANCEL_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _creditCancelParserCheck = creditCancelParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InstallMent: String(resDicData["Month"] ?? ""), AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"] ?? ""), TradeNo: String(resDicData["TradeNo"] ?? ""), TrdCode: String(resDicData["TrdCode"] ?? ""), DscYn: String(resDicData["DscYn"] ?? ""), DscData: String(resDicData["DscData"] ?? ""))
            if !_creditCancelParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _creditCancelParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            if resDicData["TrdCode"] == "T" {
                //cat 연동일 경우
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    if Utils.CheckCatPortIP() != "" {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = Utils.CheckCatPortIP()
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
                
                let _resonCancel = "a" + String(resDicData["AuDate"]?.prefix(6) ?? "") + (resDicData["AuNo"] ?? "")
                if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.PayCredit(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"] ?? ""), 코세스거래고유번호: String(resDicData["TradeNo"]!), 할부: resDicData["Month"]!, 취소: true, 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])
                }
                else {
                    mpaySdk.CreditDirectCancel(Command: Command.CMD_ICTRADE_CANCEL_REQ, Tid: String(resDicData["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), OriDate: String(resDicData["AuDate"] ?? ""), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: _resonCancel, InputType: "K", CardNumber: "", EncryptInfo: [UInt8](), Money: String(resDicData["TrdAmt"]!), Tax: String(resDicData["TaxAmt"]!), ServiceCharge: String(resDicData["SvcAmt"]!), TaxFree: String(resDicData["TaxFreeAmt"]!), Currency: "", InstallMent: String(resDicData["Month"]!), PosCertificationNumber: Utils.AppTmlcNo(), TradeType: "", EmvData: "", ResonFallBack: "", ICreqData: [UInt8](), WorkingKeyIndex: "", Password: "", OilSurpport: "", OilTaxFree: "", DccFlag: "", DccReqInfo: "", PointCardCode: "", PointCardNumber: "", PointCardEncprytInfo: [UInt8](), SignInfo: Setting.shared.g_sDigSignInfo, SignPadSerial: "", SignData: [UInt8](), Certification: "", PosData: String(resDicData["MchData"]!), KocesUid: String(resDicData["TradeNo"]!), UniqueCode: resDicData["CompCode"]!, payLinstener: paylistener?.delegate as! PayResultDelegate)
                }
            } else {
                if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
                
                //cat 연동일 경우
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    if Utils.CheckCatPortIP() != "" {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = Utils.CheckCatPortIP()
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
                
                if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                    if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = "리더기 무결성 검증실패 제조사A/S요망."
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
                
                let _resonCancel = "0" +  String(resDicData["AuDate"]?.prefix(6) ?? "") + (resDicData["AuNo"] ?? "")
                if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.PayCredit(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"] ?? ""), 코세스거래고유번호: String(resDicData["TradeNo"]!), 할부: resDicData["Month"]!, 취소: true, 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])
                }
                else if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
                    mpaySdk.CreditIC(Tid: String(resDicData["TermID"]!), Money: String(resDicData["TrdAmt"]!), Tax: Int(resDicData["TaxAmt"]!)!, ServiceCharge: Int(resDicData["SvcAmt"]!)!, TaxFree: Int(resDicData["TaxFreeAmt"]!)!, InstallMent: String(resDicData["Month"]!), OriDate: String(resDicData["AuDate"] ?? ""), CancenInfo: _resonCancel, mchData: String(resDicData["MchData"]!), KocesTreadeCode: String(resDicData["TradeNo"]!), CompCode: String(resDicData["CompCode"]!), SignDraw: String(resDicData["DscYn"] ?? "1"), FallBackUse: String(resDicData["FBYn"] ?? "0"),payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                }
            }

            break
        case Command.CMD_CASH_RECEIPT_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _cashParserCheck = cashParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InsYn: String(resDicData["InsYn"] ?? ""), KeyYn: String(resDicData["KeyYn"] ?? ""), CashNum: String(resDicData["CashNum"] ?? ""))
            if !_cashParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _cashParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            var cashNum = resDicData["CashNum"] ?? ""
            //만일 현금영수증 자진발급(3)일 경우 자진발급번호로 즉시 거래를 진행한다.결제방법을 카드리더기 선택이거나 입력된 번호가 있더라도 모두 무시하고
                   //자진발급번호(고객번호) "0100001234" 로 진행한다. 신분확인번호(CashNum)"0100001234" 입력방법(KeyYn)"K" 개인/법인(InsYn) 구분:3
            if resDicData["InsYn"] == "3" {
                cashNum = "0100001234"
            }
            
            if cashNum.isEmpty {
                if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
                
                //cat 연동일 경우
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    if Utils.CheckCatPortIP() != "" {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = Utils.CheckCatPortIP()
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
                
                if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                    if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = "리더기 무결성 검증실패 제조사A/S요망."
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                }
                
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.CashRecipt(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: "", 고객번호: "", 개인법인구분: resDicData["InsYn"]!, 취소: false, 최소사유: "", 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate as! CatResultDelegate, Products: [])
                }
                else if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                    mpaySdk.CashRecipt(Tid: String(resDicData["TermID"]!), Money: String(resDicData["TrdAmt"]!), Tax: Int(resDicData["TaxAmt"]!)!, ServiceCharge: Int(resDicData["SvcAmt"]!)!, TaxFree: Int(resDicData["TaxFreeAmt"]!)!, PrivateOrBusiness: Int(resDicData["InsYn"]!)!, ReciptIndex: "0000", CancelInfo: "", OriDate: "", InputMethod: String(resDicData["KeyYn"] ?? ""), CancelReason: "", ptCardCode: "", ptAcceptNum: "", BusinessData: String(resDicData["MchData"]!), Bangi: String(resDicData["CompCode"]!), KocesTradeUnique: String(resDicData["TradeNo"] ?? ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                }
            } else {
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.CashRecipt(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: "", 고객번호: cashNum, 개인법인구분: resDicData["InsYn"]!, 취소: false, 최소사유: "", 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate as! CatResultDelegate, Products: [])
                }
                else {
                    mpaySdk.CashReciptDirectInput(CancelReason: "", Tid: String(resDicData["TermID"]!), AuDate: "", AuNo: "", Num: cashNum, Command: String(resDicData["TrdType"]!), MchData: String(resDicData["MchData"]!), TrdAmt: String(resDicData["TrdAmt"]!), TaxAmt: String(resDicData["TaxAmt"]!), SvcAmt: String(resDicData["SvcAmt"]!), TaxFreeAmt: String(resDicData["TaxFreeAmt"]!), InsYn: String(resDicData["InsYn"]!), kocesNumber: String(resDicData["TradeNo"] ?? ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                }
            }

            break
        case Command.CMD_CASH_RECEIPT_CANCEL_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _cashCancelParserCheck = cashCancelParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InsYn: String(resDicData["InsYn"] ?? ""), KeyYn: String(resDicData["KeyYn"] ?? ""), CashNum: String(resDicData["CashNum"] ?? ""), CancelReason: String(resDicData["CancelReason"] ?? ""), AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"] ?? ""), TradeNo: String(resDicData["TradeNo"] ?? ""), TrdCode: String(resDicData["TrdCode"] ?? ""))
            if !_cashCancelParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _cashCancelParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            var cashNum = resDicData["CashNum"] ?? ""
            var cancelInfo = "0" + String(resDicData["AuDate"]?.prefix(6) ?? "") + (resDicData["AuNo"] ?? "")
            //만일 현금영수증 자진발급(3)일 경우 자진발급번호로 즉시 거래를 진행한다.결제방법을 카드리더기 선택이거나 입력된 번호가 있더라도 모두 무시하고
                   //자진발급번호(고객번호) "0100001234" 로 진행한다. 신분확인번호(CashNum)"0100001234" 입력방법(KeyYn)"K" 개인/법인(InsYn) 구분:3
            if resDicData["InsYn"] == "3" {
                cashNum = "0100001234"
                resDicData["KeyYn"] = "K"
            }
            
            if resDicData["TrdCode"] == "T" {   //거래고유키취소
                if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.CashRecipt(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"]!), 코세스거래고유번호: String(resDicData["TradeNo"] ?? ""), 할부: "", 고객번호: cashNum, 개인법인구분: resDicData["InsYn"]!, 취소: true, 최소사유: String(resDicData["CancelReason"]!), 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate as! CatResultDelegate, Products: [])
                }
                else {
                    mpaySdk.CashReciptDirectInput(CancelReason: String(resDicData["CancelReason"]!), Tid: String(resDicData["TermID"]!), AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"]!), Num: cashNum, Command: String(resDicData["TrdType"]!), MchData: String(resDicData["MchData"]!), TrdAmt: String(resDicData["TrdAmt"]!), TaxAmt: String(resDicData["TaxAmt"]!), SvcAmt: String(resDicData["SvcAmt"]!), TaxFreeAmt: String(resDicData["TaxFreeAmt"]!), InsYn: String(resDicData["InsYn"]!), kocesNumber: String(resDicData["TradeNo"] ?? ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                }
            } else {
                resDicData["TradeNo"] = ""
                if cashNum.isEmpty {    //일반취소
                    if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                        var recDicData:[String:String] = [:]
                        recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
                        onResult(tcpStatus: .fail, Result: recDicData)
                        return
                    }
                    
                    //cat 연동일 경우
                    if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                        if Utils.CheckCatPortIP() != "" {
                            var recDicData:[String:String] = [:]
                            recDicData["Message"] = Utils.CheckCatPortIP()
                            onResult(tcpStatus: .fail, Result: recDicData)
                            return
                        }
                    }
                    
                    if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                        if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                            var recDicData:[String:String] = [:]
                            recDicData["Message"] = "리더기 무결성 검증실패 제조사A/S요망."
                            onResult(tcpStatus: .fail, Result: recDicData)
                            return
                        }
                    }
                    if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                        mCatSdk.CashRecipt(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"]!), 코세스거래고유번호: String(resDicData["TradeNo"] ?? ""), 할부: "", 고객번호: "", 개인법인구분: resDicData["InsYn"]!, 취소: true, 최소사유: String(resDicData["CancelReason"]!), 가맹점데이터: resDicData["MchData"]!, 여유필드: "",StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate, Products: [])
                    }
                    else {
                        mpaySdk.CashRecipt(Tid: String(resDicData["TermID"]!), Money: String(resDicData["TrdAmt"]!), Tax: Int(resDicData["TaxAmt"]!)!, ServiceCharge: Int(resDicData["SvcAmt"]!)!, TaxFree: Int(resDicData["TaxFreeAmt"]!)!, PrivateOrBusiness: Int(resDicData["InsYn"]!)!, ReciptIndex: "0000", CancelInfo: cancelInfo, OriDate: String(resDicData["AuDate"] ?? ""), InputMethod: String(resDicData["KeyYn"]!), CancelReason: String(resDicData["CancelReason"]!), ptCardCode: "", ptAcceptNum: "", BusinessData: String(resDicData["MchData"]!), Bangi: String(resDicData["CompCode"]!), KocesTradeUnique: String(resDicData["TradeNo"] ?? ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                    }
                } else {    //다이렉트일반취소
                    if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                        mCatSdk.CashRecipt(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"]!), 코세스거래고유번호: "", 할부: "", 고객번호: cashNum, 개인법인구분: resDicData["InsYn"]!, 취소: true, 최소사유: String(resDicData["CancelReason"]!), 가맹점데이터: resDicData["MchData"]!, 여유필드: "",StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate, Products: [])
                    }
                    else {
                        mpaySdk.CashReciptDirectInput(CancelReason: String(resDicData["CancelReason"]!), Tid: String(resDicData["TermID"]!), AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"]!), Num: cashNum, Command: String(resDicData["TrdType"]!), MchData: String(resDicData["MchData"]!), TrdAmt: String(resDicData["TrdAmt"]!), TaxAmt: String(resDicData["TaxAmt"]!), SvcAmt: String(resDicData["SvcAmt"]!), TaxFreeAmt: String(resDicData["TaxFreeAmt"]!), InsYn: String(resDicData["InsYn"]!), kocesNumber: "", payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                    }
                }
            }
            break
        case Command.CMD_EASY_APPTOAPP_REQ:
            alert.dismiss(animated: true, completion: nil)
            let _easyParserCheck = easyParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InstallMent: String(resDicData["Month"] ?? ""), DscYn: String(resDicData["DscYn"] ?? ""), DscData: String(resDicData["DscData"] ?? ""), QrKind: String(resDicData["QrKind"] ?? ""))
            if !_easyParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _easyParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
//            if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
//                var recDicData:[String:String] = [:]
//                recDicData["Message"] = "연결된 장비가 없습니다. BLE 장비를 연결해 주세요"
//                onResult(tcpStatus: .fail, Result: recDicData)
//                return
//            }
            
            //cat 연동일 경우
            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = Utils.CheckCatPortIP()
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            
//            if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
//                if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
//                    var recDicData:[String:String] = [:]
//                    recDicData["Message"] = "리더기 무결성 검증실패 제조사A/S요망."
//                    onResult(tcpStatus: .fail, Result: recDicData)
//                    return
//                }
//            }

            if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                mCatSdk.PayCredit(TID: String(resDicData["TermID"]!), 거래금액: String(resDicData["TrdAmt"]!), 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: resDicData["Month"]!, 취소: false, 가맹점데이터: resDicData["MchData"]!, 여유필드: "", StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "",CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])
            }
            else {
                mpaySdk.CreditIC(Tid: String(resDicData["TermID"]!), Money: String(resDicData["TrdAmt"]!), Tax: Int(resDicData["TaxAmt"]!)!, ServiceCharge: Int(resDicData["SvcAmt"]!)!, TaxFree: Int(resDicData["TaxFreeAmt"]!)!, InstallMent: String(resDicData["Month"]!), OriDate: "", CancenInfo: "", mchData: String(resDicData["MchData"]!), KocesTreadeCode: String(resDicData["TradeNo"]!), CompCode: String(resDicData["CompCode"]!), SignDraw: String(resDicData["DscYn"] ?? "1"), FallBackUse: String(resDicData["FBYn"] ?? "0"),payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
            }
 
            break
        case Command.CMD_EASY_APPTOAPP_CANCEL_REQ:
            var _Command:String = resDicData["TrdType"]!
            //간편결제 중 캣이 아닌 간편결제로 서버측과 통신을 할 때에는 아래의 조건문에서 수정하여 해당 명령어를 주입한다
            if (resDicData["QrKind"] != nil && resDicData["QrKind"] == "ZP")
            {
                if(_Command == "A10")
                {
                    _Command = "Z10";
                }
                else if(_Command == "A20")
                {
                    _Command = "Z20";
                }
                else if(_Command == "E10")
                {
                    _Command = "Z10";
                }
                else if(_Command == "E20")
                {
                    _Command = "Z20";
                }
            }

            if (_Command == "A10")
            {
                _Command = "K21";
            }
            else if (_Command == "A20")
            {
                _Command = "K22";
            }
            else if(_Command == "E10")
            {
                _Command = "K21";
            }
            else if(_Command == "E20")
            {
                _Command = "K22";
            }
            
            alert.dismiss(animated: true, completion: nil)
            let _easyCancelParserCheck = easyCancelParserCheck(Tid: String(resDicData["TermID"] ?? ""), Money: String(resDicData["TrdAmt"] ?? ""), Tax: String(resDicData["TaxAmt"] ?? ""), ServiceCharge: String(resDicData["SvcAmt"] ?? ""), TaxFree: String(resDicData["TaxFreeAmt"] ?? ""), InstallMent: String(resDicData["Month"] ?? ""), AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"] ?? ""), TradeNo: String(resDicData["TradeNo"] ?? ""), TrdCode: String(resDicData["TrdCode"] ?? ""), DscYn: String(resDicData["DscYn"] ?? ""), DscData: String(resDicData["DscData"] ?? ""), QrKind: String(resDicData["QrKind"] ?? ""))
            if !_easyCancelParserCheck.isEmpty {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = _easyCancelParserCheck + " 확인해 주세요"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            //만일 페이코거래일 경우 캣단말기인지를 체크한다
            var isQrKind : String = String(resDicData["QrKind"] ?? "")
            if isQrKind == "PC" {
                if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = "페이코 거래는 CAT 단말기로만 거래 가능합니다"
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            
            //cat 연동일 경우
            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    var recDicData:[String:String] = [:]
                    recDicData["Message"] = Utils.CheckCatPortIP()
                    onResult(tcpStatus: .fail, Result: recDicData)
                    return
                }
            }
            
            //취소시에는 UN통합 사용 불가
            if resDicData["QrKind"] == "UN" {
                var recDicData:[String:String] = [:]
                recDicData["Message"] = "취소시에는 UN 통합 사용 불가"
                onResult(tcpStatus: .fail, Result: recDicData)
                return
            }
            
            if resDicData["AuDate"] != nil || resDicData["AuDate"] != "" {
                resDicData["AuDate"] = String(resDicData["AuDate"]!.prefix(6))
            }
            if resDicData["AuNo"] != nil || resDicData["AuNo"] != "" {
                resDicData["AuNo"] = resDicData["AuNo"]?.replacingOccurrences(of: " ", with: "")
            }
            
            if resDicData["TrdCode"] == "T" {
                if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.EasyRecipt(TrdType: Command.CMD_EASY_APPTOAPP_CANCEL_REQ, TID: resDicData["TermID"]!, Qr: resDicData["QrNo"]!, 거래금액: resDicData["TrdAmt"]!, 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, EasyKind: resDicData["QrKind"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"] ?? ""), 서브승인번호: "", 할부: resDicData["Month"] ?? "0", 가맹점데이터: resDicData["MchData"] ?? "", 호스트가맹점데이터: resDicData["HostMchData"] ?? "", 코세스거래고유번호: String(resDicData["TradeNo"] ?? ""), StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "", CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])

                }
                else {
                    var mTrdAmt:Int = (Int(resDicData["TrdAmt"]!)! + Int(resDicData["TaxFreeAmt"]!)! + Int(resDicData["SvcAmt"]!)! + Int(resDicData["TaxAmt"]!)!)
                    resDicData["TrdAmt"] = String(mTrdAmt)
                    
                    mKakaoSdk.EasyPay(Command: _Command, Tid: resDicData["TermID"]!, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelDevine: "a", AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"] ?? ""), InputType: "B", BarCode: resDicData["QrNo"] ?? "", OTCCardCode: [UInt8](), Money: resDicData["TrdAmt"]!, Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", Installment: resDicData["Month"] ?? "0", PayType: "", CancelMethod: "0", CancelType: "B", StoreCode: "", PEM: "", trid: "", CardBIN: "", SearchNumber: String(resDicData["TradeNo"] ?? ""), WorkingKeyIndex: "", SignUse: resDicData["DscYn"] ?? "1", SignPadSerial: "", SignData: [UInt8](Setting.shared.mDscData.utf8), StoreData: resDicData["MchData"] ?? "", StoreInfo: resDicData["HostMchData"] ?? "", KocesUniNum: resDicData["TradeNo"] ?? "", payLinstener: paylistener?.delegate! as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", QrKind: resDicData["QrKind"] ?? "", Products: [])

                }
            } else {
                if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.EasyRecipt(TrdType: Command.CMD_EASY_APPTOAPP_CANCEL_REQ, TID: resDicData["TermID"]!, Qr: resDicData["QrNo"]!, 거래금액: resDicData["TrdAmt"]!, 세금: resDicData["TaxAmt"]!, 봉사료: resDicData["SvcAmt"]!, 비과세: resDicData["TaxFreeAmt"]!, EasyKind: resDicData["QrKind"]!, 원거래일자: String(resDicData["AuDate"] ?? ""), 원승인번호: String(resDicData["AuNo"] ?? ""), 서브승인번호: "", 할부: resDicData["Month"] ?? "0", 가맹점데이터: resDicData["MchData"] ?? "", 호스트가맹점데이터: resDicData["HostMchData"] ?? "", 코세스거래고유번호: String(resDicData["TradeNo"] ?? ""), StoreName: "", StoreAddr: "", StoreNumber: "", StorePhone: "", StoreOwner: "", CompletionCallback: catlistener?.delegate! as! CatResultDelegate, Products: [])
                    
                }
                else {
                    var mTrdAmt:Int = (Int(resDicData["TrdAmt"]!)! + Int(resDicData["TaxFreeAmt"]!)! + Int(resDicData["SvcAmt"]!)! + Int(resDicData["TaxAmt"]!)!)
                    resDicData["TrdAmt"] = String(mTrdAmt)
                    
                    mKakaoSdk.EasyPay(Command: _Command, Tid: resDicData["TermID"]!, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", CancelDevine: "0", AuDate: String(resDicData["AuDate"] ?? ""), AuNo: String(resDicData["AuNo"] ?? ""), InputType: "B", BarCode: resDicData["QrNo"] ?? "", OTCCardCode: [UInt8](), Money: resDicData["TrdAmt"]!, Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", Installment: resDicData["Month"] ?? "0", PayType: "", CancelMethod: "0", CancelType: "B", StoreCode: "", PEM: "", trid: "", CardBIN: "", SearchNumber: String(resDicData["TradeNo"] ?? ""), WorkingKeyIndex: "", SignUse: resDicData["DscYn"] ?? "1", SignPadSerial: "", SignData: [UInt8](Setting.shared.mDscData.utf8), StoreData: resDicData["MchData"] ?? "", StoreInfo: resDicData["HostMchData"] ?? "", KocesUniNum: resDicData["TradeNo"] ?? "", payLinstener: paylistener?.delegate! as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", QrKind: resDicData["QrKind"] ?? "", Products: [])
                    
                }
            }

            break
        default:
            break
        }
        
        
    }
    
    /** BLE 프린트 결과창  */
    func onPrintResult(printStatus _status: printStatus, printResult _result: Dictionary<String, String>) {
        mpaySdk.Clear()
        mpaySdk = PaySdk.instance
        mCatSdk.Clear()
        mCatSdk = CatSdk.instance
        mKakaoSdk.Clear()
        mKakaoSdk = KaKaoPaySdk.instance
        listener = TcpResult()
        listener?.delegate = self
        paylistener = payResult()
        paylistener?.delegate = self
        printlistener = PrintResult()
        printlistener?.delegate = self
        catlistener = CatResult()
        catlistener?.delegate = self
        
        self.scanTimeout?.invalidate()
        self.scanTimeout = nil
        alert.dismiss(animated: true){
            Utils.customAlertBoxClear()
        }
        
        //여기는 가맹점데이터처리일 경우만 처리하는 곳이라 따로 분류를 하지 않는다
        var _totalString:String = ""
        var keyCount:Int = 0
        var WebPostParamameter:[String:Any] = [:]
        for (key,value) in _result {
            if _result.count - 1 == keyCount {
                _totalString += key + "=" + value
            }
            else{
                _totalString += key + "=" + value + "&"
            }
            keyCount += 1
            WebPostParamameter.updateValue(value, forKey: key)
        }

        var message = ""
        if _totalString.isEmpty {
            message = "Message=" +  (_result["Message"] ?? _result["ERROR"] ?? "통신장애발생")
        } else {
            let _t1 = _totalString.replacingOccurrences(of: "/", with: "%2F")
            let _t2 = _t1.replacingOccurrences(of: ":", with: "%3A")
            message = _t2.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        }
        debugPrint(" res StringCode = \(message)")

        var cusomUrl = ""
        if WebORApp == 0 {  //webToApp
            cusomUrl = Setting.shared.mWebAPPReturnAddr  //웹페이지랑 연동시 처리 해당페이지 주소입력 이부분은 환경설정이나 이런곳에서 셋팅하는 방향?
        } else {    //AppToApp
            cusomUrl = define.APPTOAPP_ADDR + "?" + "\(message)"  //앱투앱으로 처리시
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[self] in
            guard let url = URL(string: cusomUrl) else {
                var _error:Dictionary<String,String> = [:]
                _error["Message"] = "출력확인데이터 전송 실패"
              
                self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
                return
            }

            guard UIApplication.shared.canOpenURL(url) else {
                var _error:Dictionary<String,String> = [:]
                _error["Message"] = "출력확인데이터 전송 실패"
    
                self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
                return
            }
            
            
            if WebORApp == 0{
                let url = URL(string: cusomUrl)!
                var request = URLRequest(url: url)
                //2020-06-25 json 데이터가 정상적으로 전달 되지 않는 문제 수정
                //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept-Type")
                request.httpMethod = "POST"
                let postData = (try? JSONSerialization.data(withJSONObject: WebPostParamameter, options: []))
                request.httpBody = postData
          
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data,
                          let response = response as? HTTPURLResponse,
                          error == nil else {   // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                        var _error:Dictionary<String,String> = [:]
                        _error["Message"] = "출력확인데이터 전송 실패"
              
                        self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _result.count > 0 ? _result:_error, resultCheck: false)
                        return
                    }

                    guard (200 ... 299) ~= response.statusCode else {  // check for http errors
                        print("statusCode should be 2xx, but is \(response.statusCode)")
                        print("response = \(response)")
                        var _error:Dictionary<String,String> = [:]
                        _error["Message"] = "출력확인데이터 전송 실패"
                
                        self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _result.count > 0 ? _result:_error, resultCheck: false)
                        return
                    }

                    
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(String(describing: responseString))")
 
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _result)
                }

                task.resume()
    //            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }
            else{
            
                UIApplication.shared.open(url, options: [:], completionHandler: {(success) in
                    if success {
                      
                    } else {
                        var _error:Dictionary<String,String> = [:]
                        _error["Message"] = "출력확인데이터 전송 실패"
                    
                        self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
                        return
                    }
                })
            }
        }
    }
    
    func onPaymentResult(payTitle _status: payStatus, payResult _message: Dictionary<String, String>) {
        mpaySdk.Clear()
        mpaySdk = PaySdk.instance
        mCatSdk.Clear()
        mCatSdk = CatSdk.instance
        mKakaoSdk.Clear()
        mKakaoSdk = KaKaoPaySdk.instance
        listener = TcpResult()
        listener?.delegate = self
        paylistener = payResult()
        paylistener?.delegate = self
        printlistener = PrintResult()
        printlistener?.delegate = self
        catlistener = CatResult()
        catlistener?.delegate = self
        
        var _totalString:String = ""
        var keyCount:Int = 0
        var WebPostParamameter:[String:Any] = [:]
        //2021-08-24 망취소를 테스트 위한 코드 shin.jw
//        Setting.shared.mWebAPPReturnAddr = "apptoap://"
        
        /** log : 앱투앱 기록 시작 */
        let _tmpTermID = _message["TermID"] ?? ""
        if _tmpTermID != "" {
            if WebORApp == 0 {
                LogFile.instance.InsertLog("********** WebToApp Service **********", Tid: _message["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("WebToApp onPaymentResult -> " + _message.description, Tid: _message["TermID"] ?? "", TimeStamp: true)
            } else if WebORApp == 1 {
                LogFile.instance.InsertLog("********** AppToApp Service **********", Tid: _message["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("AppToApp onPaymentResult -> " + _message.description, Tid: _message["TermID"] ?? "", TimeStamp: true)
            }
        } else {
            if WebORApp == 0 {
                LogFile.instance.InsertLog("********** WebToApp Service **********", Tid: _message["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("WebToApp onPaymentResult -> TermID 가 없음", Tid: _message["TermID"] ?? "", TimeStamp: true)
            } else if WebORApp == 1 {
                LogFile.instance.InsertLog("********** AppToApp Service **********", Tid: _message["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("AppToApp onPaymentResult ->  TermID 가 없음", Tid: _message["TermID"] ?? "", TimeStamp: true)
            }
        }
        
        
        var tmpResult = _message;
        var _trdType = _message["TrdType"] ?? ""
        if (tmpTrdType != "R10" && tmpTrdType != "R20" && tmpTrdType != "F10" && tmpTrdType != "P10" && tmpTrdType != "" && _trdType != "") {
//            if(_message["TrdType"]!.contains("20"))
//            {
//                tmpResult["OriAuDate"] = tmpresDicData["AuDate"];
//                tmpResult["OriAuNo"] = tmpresDicData["AuNo"];
//            }
            if(tmpTrdType.contains("20"))
            {
                tmpResult["OriAuDate"] = tmpresDicData["AuDate"];
                tmpResult["OriAuNo"] = tmpresDicData["AuNo"];
            }

            tmpResult["BillNo"] =  tmpBillNo;
            tmpResult["TrdAmt"] = tmpresDicData["TrdAmt"];
            tmpResult["TaxAmt"] = tmpresDicData["TaxAmt"];
            tmpResult["SvcAmt"] = tmpresDicData["SvcAmt"];
            tmpResult["TaxFreeAmt"] = tmpresDicData["TaxFreeAmt"];
            tmpResult["Month"] = tmpresDicData["Month"];
            if (!tmpBillNo.isEmpty && tmpBillNo.count == 12) {
                sqlite.instance.insertAppToAppData(resultData: tmpResult)
            }
        }
        
        tmpBillNo = ""
        tmpTrdType = ""
        tmpresDicData = [:]
        
        var money:Int = 0
        switch _message["TrdType"] {
        case Command.CMD_IC_OK_RES:
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "&"
                }
                keyCount += 1
                WebPostParamameter.updateValue(value, forKey: key)
            }
            break
        case Command.CMD_IC_CANCEL_RES:
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "&"
                }
                keyCount += 1
                WebPostParamameter.updateValue(value, forKey: key)
            }
            break
        case Command.CMD_CASH_RECEIPT_RES:
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "&"
                }
                keyCount += 1
                WebPostParamameter.updateValue(value, forKey: key)
            }
            break
        case Command.CMD_CASH_RECEIPT_CANCEL_RES:
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "&"
                }
                keyCount += 1
                WebPostParamameter.updateValue(value, forKey: key)
            }
            break
        default:
            //오류로 인한 데이터들이 왔다면 여기서 처리를 한다
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "&"
                }
                keyCount += 1
                WebPostParamameter.updateValue(value, forKey: key)
            }
            break
        }
        Utils.customAlertBoxClear()
        // 카드애니메이션뷰 컨트롤러가 여전히 떠있으니 해당 뷰를 지운다
        Utils.CardAnimationViewControllerClear()

        var message = ""
        if _totalString.isEmpty {
            message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
        } else {
            if WebToAppSendDataFail == 1 {
                if (_message["AnsCode"] ?? "") == "0000" {
                    _totalString = "Message=" + "거래 승인 오류 망취소 발생&" + "AnsCode=9999&" + "TrdType=" + (_message["TrdType"] ?? "")
                } else if (_message["AnsCode"] ?? "") == "9999" {
                    _totalString = "Message=" + "거래 승인 오류 망취소 발생&" + "AnsCode=9999&" + "TrdType=" + (_message["TrdType"] ?? "")
                } else {
                    _totalString = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생") + " 거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요" + "AnsCode=" + (_message["AnsCode"] ?? "") + "&TrdType=" + (_message["TrdType"] ?? "")
                }
            } else {
                if (_message["AnsCode"] ?? "") == "9999" {
                    _totalString = "Message=" + "거래 승인 오류 망취소 발생&" + "AnsCode=9999&" + "TrdType=" + (_message["TrdType"] ?? "")
                }
            }
            let _t1 = _totalString.replacingOccurrences(of: "/", with: "%2F")
            let _t2 = _t1.replacingOccurrences(of: ":", with: "%3A")
            message = _t2.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        }
    
        debugPrint(" res StringCode = \(message)")
        

        
        var cusomUrl = ""
        if WebORApp == 0 {  //webToApp
            cusomUrl = Setting.shared.mWebAPPReturnAddr //웹페이지랑 연동시 처리 해당페이지 주소입력 이부분은 환경설정이나 이런곳에서 셋팅하는 방향?
        } else {    //AppToApp
//            cusomUrl = define.APPTOAPP_ADDR + "\(message)"  //앱투앱으로 처리시
            cusomUrl = define.APPTOAPP_ADDR + "?" + "\(message)"  //앱투앱으로 처리시
        }

        guard let url = URL(string: cusomUrl) else {
            
            /** log : 앱투앱 기록 시작 */
            let _tmpTermID = _message["TermID"] ?? ""
            if _tmpTermID != "" {
                if WebORApp == 0 {
                    /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                    LogFile.instance.InsertLog("WebToApp url 읽기 실패 -> guard let url = URL(string: cusomUrl) -> " + cusomUrl, Tid: _message["TermID"] ?? "", TimeStamp: true)
                } else if WebORApp == 1 {
                    /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                    LogFile.instance.InsertLog("AppToApp url 읽기 실패 -> guard let url = URL(string: cusomUrl) -> " + cusomUrl, Tid: _message["TermID"] ?? "", TimeStamp: true)
                }
            } else {
                if WebORApp == 0 {
                    /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                    LogFile.instance.InsertLog("WebToApp onPaymentResult -> TermID 가 없음 & url 읽기 실패 -> guard let url = URL(string: cusomUrl) -> " + cusomUrl, Tid: _message["TermID"] ?? "", TimeStamp: true)
                } else if WebORApp == 1 {
                    /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                    LogFile.instance.InsertLog("AppToApp onPaymentResult ->  TermID 가 없음 & url 읽기 실패 -> guard let url = URL(string: cusomUrl) -> " + cusomUrl, Tid: _message["TermID"] ?? "", TimeStamp: true)
                }
            }
            
            
            money = Int(Setting.shared.tmpMoney)! + Int(Setting.shared.tmpTax)! + Int(Setting.shared.tmpSvc)!
            switch _message["TrdType"] {
            case Command.CMD_IC_OK_RES:
                if _message["AnsCode"] == "0000" {
                    //거래고유키 취소 진행
                    WebToAppSendDataFail = 1
                    let _resonCancel = "a" + String(_message["TrdDate"]?.prefix(6) ?? "") + (_message["AuNo"] ?? "")
                    mpaySdk.CreditDirectCancel(Command: Command.CMD_ICTRADE_CANCEL_REQ, Tid: String(_message["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), OriDate: String(_message["TrdDate"] ?? ""), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: _resonCancel, InputType: "K", CardNumber: "", EncryptInfo: [UInt8](), Money: String(money), Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", InstallMent: Setting.shared.tmpInstallment, PosCertificationNumber: Utils.AppTmlcNo(), TradeType: "", EmvData: "", ResonFallBack: "", ICreqData: [UInt8](), WorkingKeyIndex: "", Password: "", OilSurpport: "", OilTaxFree: "", DccFlag: "", DccReqInfo: "", PointCardCode: "", PointCardNumber: "", PointCardEncprytInfo: [UInt8](), SignInfo: Setting.shared.g_sDigSignInfo, SignPadSerial: "", SignData: [UInt8](), Certification: "", PosData: String(_message["MchData"]!), KocesUid: String(_message["TradeNo"] ?? ""), UniqueCode: _message["CompCode"] ?? "", payLinstener: paylistener?.delegate as! PayResultDelegate)
                    return
                }
                break
            case Command.CMD_CASH_RECEIPT_RES:
                if _message["AnsCode"] == "0000" {
                    //거래고유키 취소 진행
                    WebToAppSendDataFail = 1
                    mpaySdk.CashReciptDirectInput(CancelReason: "1", Tid: String(_message["TermID"]!), AuDate: String(_message["TrdDate"] ?? ""), AuNo: String(_message["AuNo"]!), Num: String(_message["CardNo"]!), Command: Command.CMD_CASH_RECEIPT_CANCEL_REQ, MchData: String(_message["MchData"]!), TrdAmt: String(money), TaxAmt: "0", SvcAmt: "0", TaxFreeAmt: "0", InsYn: Setting.shared.tmpInsYn, kocesNumber: String(_message["TradeNo"]!).replacingOccurrences(of:  " ", with: ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                    return
                }
                break
            case Command.CMD_ZEROPAY_RES:
                if _message["AnsCode"] == "0000" {
                    //거래고유키 취소 진행
                    WebToAppSendDataFail = 1
                    
                    return
                }
                break
            case Command.CMD_KAKAOPAY_RES:
                if _message["AnsCode"] == "0000" {
                    //거래고유키 취소 진행
                    WebToAppSendDataFail = 1
                    
                    return
                }
                break
            case Command.CMD_WECHAT_ALIPAY_RES:
                if _message["AnsCode"] == "0000" {
                    //거래고유키 취소 진행
                    WebToAppSendDataFail = 1
                    
                    return
                }
                break
            default:
                break
            }
            
            message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
            var _error:Dictionary<String,String> = [:]
            if (_message["AnsCode"] ?? "") == "0000" {
                _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                _error["AnsCode"] = WebToAppSendDataFail == 1 ? "9999":(_message["AnsCode"] ?? "")
                _error["TrdType"] = (_message["TrdType"] ?? "")
            } else if (_message["AnsCode"] ?? "") == "9999" {
                _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                _error["AnsCode"] = "9999"
                _error["TrdType"] = (_message["TrdType"] ?? "")
            } else {
                _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                _error["AnsCode"] = (_message["AnsCode"] ?? "")
                _error["TrdType"] = (_message["TrdType"] ?? "")
            }
            
//            _error["Message"] = ((_message["AnsCode"] ?? "") != "0000") ? ("사용할 수 없는 URL" + "\n" + message):"사용할 수 없는 URL로 인한 거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요"
//            _error["TrdType"] = _message["TrdType"] ?? ""
            self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
            return
        }

        guard UIApplication.shared.canOpenURL(url) else {
            /** log : 앱투앱 기록 시작 */
            let _tmpTermID = _message["TermID"] ?? ""
            if _tmpTermID != "" {
                if WebORApp == 0 {
                    /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                    LogFile.instance.InsertLog("WebToApp url 읽기 실패 -> UIApplication.shared.canOpenURL(url) -> " + url.absoluteString, Tid: _message["TermID"] ?? "", TimeStamp: true)
                } else if WebORApp == 1 {
                    /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                    LogFile.instance.InsertLog("AppToApp url 읽기 실패 -> UIApplication.shared.canOpenURL(url) -> " + url.absoluteString, Tid: _message["TermID"] ?? "", TimeStamp: true)
                }
            } else {
                if WebORApp == 0 {
                    /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                    LogFile.instance.InsertLog("WebToApp onPaymentResult -> TermID 가 없음 & url 읽기 실패 -> UIApplication.shared.canOpenURL(url) -> " + url.absoluteString, Tid: _message["TermID"] ?? "", TimeStamp: true)
                } else if WebORApp == 1 {
                    /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                    LogFile.instance.InsertLog("AppToApp onPaymentResult ->  TermID 가 없음 & url 읽기 실패 -> UIApplication.shared.canOpenURL(url) -> " + url.absoluteString, Tid: _message["TermID"] ?? "", TimeStamp: true)
                }
            }
            
            money = Int(Setting.shared.tmpMoney)! + Int(Setting.shared.tmpTax)! + Int(Setting.shared.tmpSvc)!
            switch _message["TrdType"] {
            case Command.CMD_IC_OK_RES:
                if _message["AnsCode"] == "0000" {
                    //거래고유키 취소 진행
                    WebToAppSendDataFail = 1
                    let _resonCancel = "a" + String(_message["TrdDate"]?.prefix(6) ?? "") + (_message["AuNo"] ?? "")
                    mpaySdk.CreditDirectCancel(Command: Command.CMD_ICTRADE_CANCEL_REQ, Tid: String(_message["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), OriDate: String(_message["TrdDate"] ?? ""), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: _resonCancel, InputType: "K", CardNumber: "", EncryptInfo: [UInt8](), Money: String(money), Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", InstallMent: Setting.shared.tmpInstallment, PosCertificationNumber: Utils.AppTmlcNo(), TradeType: "", EmvData: "", ResonFallBack: "", ICreqData: [UInt8](), WorkingKeyIndex: "", Password: "", OilSurpport: "", OilTaxFree: "", DccFlag: "", DccReqInfo: "", PointCardCode: "", PointCardNumber: "", PointCardEncprytInfo: [UInt8](), SignInfo: Setting.shared.g_sDigSignInfo, SignPadSerial: "", SignData: [UInt8](), Certification: "", PosData: String(_message["MchData"]!), KocesUid: String(_message["TradeNo"] ?? ""), UniqueCode: _message["CompCode"] ?? "", payLinstener: paylistener?.delegate as! PayResultDelegate)
                    return
                }
                break
            case Command.CMD_CASH_RECEIPT_RES:
                if _message["AnsCode"] == "0000" {
                    //거래고유키 취소 진행
                    WebToAppSendDataFail = 1
                    mpaySdk.CashReciptDirectInput(CancelReason: "1", Tid: String(_message["TermID"]!), AuDate: String(_message["TrdDate"] ?? ""), AuNo: String(_message["AuNo"]!), Num: String(_message["CardNo"]!), Command: Command.CMD_CASH_RECEIPT_CANCEL_REQ, MchData: String(_message["MchData"]!), TrdAmt: String(money), TaxAmt: "0", SvcAmt: "0", TaxFreeAmt: "0", InsYn: Setting.shared.tmpInsYn, kocesNumber: String(_message["TradeNo"]!).replacingOccurrences(of:  " ", with: ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                    return
                }
                break
            case Command.CMD_ZEROPAY_RES:
                if _message["AnsCode"] == "0000" {
                    //거래고유키 취소 진행
                    WebToAppSendDataFail = 1
                    
                    return
                }
                break
            case Command.CMD_KAKAOPAY_RES:
                if _message["AnsCode"] == "0000" {
                    //거래고유키 취소 진행
                    WebToAppSendDataFail = 1
                    
                    return
                }
                break
            case Command.CMD_WECHAT_ALIPAY_RES:
                if _message["AnsCode"] == "0000" {
                    //거래고유키 취소 진행
                    WebToAppSendDataFail = 1
                    
                    return
                }
                break
            default:
                break
            }
            
            message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
            var _error:Dictionary<String,String> = [:]
            if (_message["AnsCode"] ?? "") == "0000" {
                _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                _error["AnsCode"] = WebToAppSendDataFail == 1 ? "9999":(_message["AnsCode"] ?? "")
                _error["TrdType"] = (_message["TrdType"] ?? "")
            } else if (_message["AnsCode"] ?? "") == "9999" {
                _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                _error["AnsCode"] = "9999"
                _error["TrdType"] = (_message["TrdType"] ?? "")
            } else {
                _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                _error["AnsCode"] = (_message["AnsCode"] ?? "")
                _error["TrdType"] = (_message["TrdType"] ?? "")
            }
//            _error["Message"] = ((_message["AnsCode"] ?? "") != "0000") ? ("사용할 수 없는 스키마(URL Scheme)" + "\n" + message):"사용할 수 없는 스키마(URL Scheme)로 인한 거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요"
//            _error["TrdType"] = _message["TrdType"] ?? ""
            self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
            return
        }
        
        if WebORApp == 0{
            let url = URL(string: cusomUrl)!
            var request = URLRequest(url: url)
            //2020-06-25 json 데이터가 정상적으로 전달 되지 않는 문제 수정
            //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept-Type")
            request.httpMethod = "POST"
            let postData = (try? JSONSerialization.data(withJSONObject: WebPostParamameter, options: []))
            request.httpBody = postData
    
            let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {   // check for fundamental networking error
                    
                    /** log : 앱투앱 기록 시작 */
                    let _tmpTermID = _message["TermID"] ?? ""
                    if _tmpTermID != "" {
                        if WebORApp == 0 {
                            /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                            LogFile.instance.InsertLog("WebToApp 거래내역 전송이 실패되었습니다 -> URLSession.shared.dataTask(with: request) -> " + request.description, Tid: _message["TermID"] ?? "", TimeStamp: true)
                        }
                    } else {
                        if WebORApp == 0 {
                            /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                            LogFile.instance.InsertLog("WebToApp -> TermID 가 없음 & 거래내역 전송이 실패되었습니다 -> URLSession.shared.dataTask(with: request) -> " + request.description, Tid: _message["TermID"] ?? "", TimeStamp: true)
                        }
                    }
                    
                    money = Int(Setting.shared.tmpMoney)! + Int(Setting.shared.tmpTax)! + Int(Setting.shared.tmpSvc)!
                    switch _message["TrdType"] {
                    case Command.CMD_IC_OK_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            let _resonCancel = "a" + String(_message["TrdDate"]?.prefix(6) ?? "") + (_message["AuNo"] ?? "")
                            mpaySdk.CreditDirectCancel(Command: Command.CMD_ICTRADE_CANCEL_REQ, Tid: String(_message["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), OriDate: String(_message["TrdDate"] ?? ""), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: _resonCancel, InputType: "K", CardNumber: "", EncryptInfo: [UInt8](), Money: String(money), Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", InstallMent: Setting.shared.tmpInstallment, PosCertificationNumber: Utils.AppTmlcNo(), TradeType: "", EmvData: "", ResonFallBack: "", ICreqData: [UInt8](), WorkingKeyIndex: "", Password: "", OilSurpport: "", OilTaxFree: "", DccFlag: "", DccReqInfo: "", PointCardCode: "", PointCardNumber: "", PointCardEncprytInfo: [UInt8](), SignInfo: Setting.shared.g_sDigSignInfo, SignPadSerial: "", SignData: [UInt8](), Certification: "", PosData: String(_message["MchData"]!), KocesUid: String(_message["TradeNo"] ?? ""), UniqueCode: _message["CompCode"] ?? "", payLinstener: paylistener?.delegate as! PayResultDelegate)
                            return
                        }
                        break
                    case Command.CMD_CASH_RECEIPT_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            mpaySdk.CashReciptDirectInput(CancelReason: "1", Tid: String(_message["TermID"]!), AuDate: String(_message["TrdDate"] ?? ""), AuNo: String(_message["AuNo"]!), Num: String(_message["CardNo"]!), Command: Command.CMD_CASH_RECEIPT_CANCEL_REQ, MchData: String(_message["MchData"]!), TrdAmt: String(money), TaxAmt: "0", SvcAmt: "0", TaxFreeAmt: "0", InsYn: Setting.shared.tmpInsYn, kocesNumber: String(_message["TradeNo"]!).replacingOccurrences(of:  " ", with: ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                            return
                        }
                        break
                    case Command.CMD_ZEROPAY_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            
                            return
                        }
                        break
                    case Command.CMD_KAKAOPAY_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            
                            return
                        }
                        break
                    case Command.CMD_WECHAT_ALIPAY_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            
                            return
                        }
                        break
                    default:
                        break
                    }
                    message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
                    var _error:Dictionary<String,String> = [:]
                    if (_message["AnsCode"] ?? "") == "0000" {
                        _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                        _error["AnsCode"] = WebToAppSendDataFail == 1 ? "9999":(_message["AnsCode"] ?? "")
                        _error["TrdType"] = (_message["TrdType"] ?? "")
                    } else if (_message["AnsCode"] ?? "") == "9999" {
                        _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                        _error["AnsCode"] = "9999"
                        _error["TrdType"] = (_message["TrdType"] ?? "")
                    } else {
                        _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                        _error["AnsCode"] = (_message["AnsCode"] ?? "")
                        _error["TrdType"] = (_message["TrdType"] ?? "")
                    }
//                    _error["Message"] = ((_message["AnsCode"] ?? "") != "0000") ? ("http error : " + error.unsafelyUnwrapped.localizedDescription + "\n" + message):"http error : " + error.unsafelyUnwrapped.localizedDescription + " 로 인한 거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요"
//                    _error["TrdType"] = _message["TrdType"] ?? ""
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _message.count > 0 ? _message:_error, resultCheck: false)
                    return
                }

                guard (200 ... 299) ~= response.statusCode else {  // check for http errors
                    /** log : 앱투앱 기록 시작 */
                    let _tmpTermID = _message["TermID"] ?? ""
                    if _tmpTermID != "" {
                        if WebORApp == 0 {
                            /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                            LogFile.instance.InsertLog("WebToApp 거래내역 전송이 실패되었습니다 -> guard (200 ... 299) ~= response.statusCode -> " + response.description, Tid: _message["TermID"] ?? "", TimeStamp: true)
                        }
                    } else {
                        if WebORApp == 0 {
                            /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                            LogFile.instance.InsertLog("WebToApp -> TermID 가 없음 & 거래내역 전송이 실패되었습니다 -> guard (200 ... 299) ~= response.statusCode -> " + response.description, Tid: _message["TermID"] ?? "", TimeStamp: true)
                        }
                    }
                    
                    money = Int(Setting.shared.tmpMoney)! + Int(Setting.shared.tmpTax)! + Int(Setting.shared.tmpSvc)!
                    switch _message["TrdType"] {
                    case Command.CMD_IC_OK_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            let _resonCancel = "a" + String(_message["TrdDate"]?.prefix(6) ?? "") + (_message["AuNo"] ?? "")
                            mpaySdk.CreditDirectCancel(Command: Command.CMD_ICTRADE_CANCEL_REQ, Tid: String(_message["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), OriDate: String(_message["TrdDate"] ?? ""), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: _resonCancel, InputType: "K", CardNumber: "", EncryptInfo: [UInt8](), Money: String(money), Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", InstallMent: Setting.shared.tmpInstallment, PosCertificationNumber: Utils.AppTmlcNo(), TradeType: "", EmvData: "", ResonFallBack: "", ICreqData: [UInt8](), WorkingKeyIndex: "", Password: "", OilSurpport: "", OilTaxFree: "", DccFlag: "", DccReqInfo: "", PointCardCode: "", PointCardNumber: "", PointCardEncprytInfo: [UInt8](), SignInfo: Setting.shared.g_sDigSignInfo, SignPadSerial: "", SignData: [UInt8](), Certification: "", PosData: String(_message["MchData"]!), KocesUid: String(_message["TradeNo"] ?? ""), UniqueCode: _message["CompCode"] ?? "", payLinstener: paylistener?.delegate as! PayResultDelegate)
                            return
                        }
                        break
                    case Command.CMD_CASH_RECEIPT_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            mpaySdk.CashReciptDirectInput(CancelReason: "1", Tid: String(_message["TermID"]!), AuDate: String(_message["TrdDate"] ?? ""), AuNo: String(_message["AuNo"]!), Num: String(_message["CardNo"]!), Command: Command.CMD_CASH_RECEIPT_CANCEL_REQ, MchData: String(_message["MchData"]!), TrdAmt: String(money), TaxAmt: "0", SvcAmt: "0", TaxFreeAmt: "0", InsYn: Setting.shared.tmpInsYn, kocesNumber: String(_message["TradeNo"]!).replacingOccurrences(of:  " ", with: ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                            return
                        }
                        break
                    case Command.CMD_ZEROPAY_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            
                            return
                        }
                        break
                    case Command.CMD_KAKAOPAY_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            
                            return
                        }
                        break
                    case Command.CMD_WECHAT_ALIPAY_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            
                            return
                        }
                        break
                    default:
                        break
                    }
                    message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
                    var _error:Dictionary<String,String> = [:]
                    if (_message["AnsCode"] ?? "") == "0000" {
                        _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                        _error["AnsCode"] = WebToAppSendDataFail == 1 ? "9999":(_message["AnsCode"] ?? "")
                        _error["TrdType"] = (_message["TrdType"] ?? "")
                    } else if (_message["AnsCode"] ?? "") == "9999" {
                        _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                        _error["AnsCode"] = "9999"
                        _error["TrdType"] = (_message["TrdType"] ?? "")
                    } else {
                        _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                        _error["AnsCode"] = (_message["AnsCode"] ?? "")
                        _error["TrdType"] = (_message["TrdType"] ?? "")
                    }
//                    _error["Message"] = ((_message["AnsCode"] ?? "") != "0000") ? ("http error : statusCode is \(response.statusCode)" + "\n" + message):"http error : statusCode is \(response.statusCode)" + " 로 인한 거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요"
//                    _error["TrdType"] = _message["TrdType"] ?? ""
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _message.count > 0 ? _message:_error, resultCheck: false)
                    return
                }

                
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
       
                self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _message, resultCheck: _status == .OK ? true:false)
            }

            task.resume()
        }
        else{
    
            UIApplication.shared.open(url, options: [:], completionHandler: { [self](success) in
                if success {
             
                    WebToAppSendDataFail = 0
                } else {
                    money = Int(Setting.shared.tmpMoney)! + Int(Setting.shared.tmpTax)! + Int(Setting.shared.tmpSvc)!
                    switch _message["TrdType"] {
                    case Command.CMD_IC_OK_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            let _resonCancel = "a" + String(_message["TrdDate"]?.prefix(6) ?? "") + (_message["AuNo"] ?? "")
                            mpaySdk.CreditDirectCancel(Command: Command.CMD_ICTRADE_CANCEL_REQ, Tid: String(_message["TermID"]!), Date: Utils.getDate(format: "yyMMddHHmmss"), OriDate: String(_message["TrdDate"] ?? ""), PosVer: define.TEST_SOREWAREVERSION, Etc: "", ResonCancel: _resonCancel, InputType: "K", CardNumber: "", EncryptInfo: [UInt8](), Money: String(money), Tax: "0", ServiceCharge: "0", TaxFree: "0", Currency: "", InstallMent: Setting.shared.tmpInstallment, PosCertificationNumber: Utils.AppTmlcNo(), TradeType: "", EmvData: "", ResonFallBack: "", ICreqData: [UInt8](), WorkingKeyIndex: "", Password: "", OilSurpport: "", OilTaxFree: "", DccFlag: "", DccReqInfo: "", PointCardCode: "", PointCardNumber: "", PointCardEncprytInfo: [UInt8](), SignInfo: Setting.shared.g_sDigSignInfo, SignPadSerial: "", SignData: [UInt8](), Certification: "", PosData: String(_message["MchData"]!), KocesUid: String(_message["TradeNo"] ?? ""), UniqueCode: _message["CompCode"] ?? "", payLinstener: paylistener?.delegate as! PayResultDelegate)
                            return
                        }
                        break
                    case Command.CMD_CASH_RECEIPT_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            mpaySdk.CashReciptDirectInput(CancelReason: "1", Tid: String(_message["TermID"]!), AuDate: String(_message["TrdDate"] ?? ""), AuNo: String(_message["AuNo"]!), Num: String(_message["CardNo"]!), Command: Command.CMD_CASH_RECEIPT_CANCEL_REQ, MchData: String(_message["MchData"]!), TrdAmt: String(money), TaxAmt: "0", SvcAmt: "0", TaxFreeAmt: "0", InsYn: Setting.shared.tmpInsYn, kocesNumber: String(_message["TradeNo"]!).replacingOccurrences(of:  " ", with: ""), payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: "",StoreAddr: "",StoreNumber: "",StorePhone: "",StoreOwner: "", Products: [])
                            return
                        }
                        break
                    case Command.CMD_ZEROPAY_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            
                            return
                        }
                        break
                    case Command.CMD_KAKAOPAY_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            
                            return
                        }
                        break
                    case Command.CMD_WECHAT_ALIPAY_RES:
                        if _message["AnsCode"] == "0000" {
                            //거래고유키 취소 진행
                            WebToAppSendDataFail = 1
                            
                            return
                        }
                        break
                    default:
                        break
                    }
                    message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
                    var _error:Dictionary<String,String> = [:]
                    if (_message["AnsCode"] ?? "") == "0000" {
                        _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                        _error["AnsCode"] = WebToAppSendDataFail == 1 ? "9999":(_message["AnsCode"] ?? "")
                        _error["TrdType"] = (_message["TrdType"] ?? "")
                    } else if (_message["AnsCode"] ?? "") == "9999" {
                        _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                        _error["AnsCode"] = "9999"
                        _error["TrdType"] = (_message["TrdType"] ?? "")
                    } else {
                        _error["Message"] = "거래내역 전송이 실패되었습니다. \n 결제 내역을 확인하세요"
                        _error["AnsCode"] = (_message["AnsCode"] ?? "")
                        _error["TrdType"] = (_message["TrdType"] ?? "")
                    }
//                    _error["Message"] = ((_message["AnsCode"] ?? "") != "0000") ? ("앱투앱 오픈 실패" + "\n" + message):"앱투앱 오픈 실패로 인한 거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요"
//                    _error["TrdType"] = _message["TrdType"] ?? ""
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: false)
                    return
                   
                }
            })
        }

    }
    
    /** CAT 거래 완료(CAT 프린트도 포함) */
    func onResult(CatState _state: payStatus, Result _message: Dictionary<String, String>) {
        
        mpaySdk.Clear()
        mpaySdk = PaySdk.instance
        mCatSdk.Clear()
        mCatSdk = CatSdk.instance
        mKakaoSdk.Clear()
        mKakaoSdk = KaKaoPaySdk.instance
        listener = TcpResult()
        listener?.delegate = self
        paylistener = payResult()
        paylistener?.delegate = self
        printlistener = PrintResult()
        printlistener?.delegate = self
        catlistener = CatResult()
        catlistener?.delegate = self
        
        var _totalString:String = ""
        var keyCount:Int = 0
        var WebPostParamameter:[String:Any] = [:]
//        Setting.shared.mWebAPPReturnAddr = "apptoap://"
        
        /** log : 앱투앱 기록 시작 */
        let _tmpTermID = _message["TermID"] ?? ""
        if _tmpTermID != "" {
            if WebORApp == 0 {
                LogFile.instance.InsertLog("********** WebToApp Service **********", Tid: _message["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("WebToApp CAT onResult -> " + _message.description, Tid: _message["TermID"] ?? "", TimeStamp: true)
            } else if WebORApp == 1 {
                LogFile.instance.InsertLog("********** AppToApp Service **********", Tid: _message["TermID"] ?? "", TimeStamp: true)
                /** log : 처음 웹투앱/앱투앱으로 받은데이터가 어떤 건지 기록 */
                LogFile.instance.InsertLog("AppToApp CAT onResult -> " + _message.description, Tid: _message["TermID"] ?? "", TimeStamp: true)
            }
        }
        
        
        var tmpResult = _message;
        var _trdType = _message["TrdType"] ?? ""
        if (tmpTrdType != "R10" && tmpTrdType != "R20" && tmpTrdType != "F10" && tmpTrdType != "P10" && tmpTrdType != "" && _trdType != "") {
//            if(_message["TrdType"]!.contains("20"))
//            {
//                tmpResult["OriAuDate"] = tmpresDicData["AuDate"];
//                tmpResult["OriAuNo"] = tmpresDicData["AuNo"];
//            }
            if(tmpTrdType.contains("20"))
            {
                tmpResult["OriAuDate"] = tmpresDicData["AuDate"];
                tmpResult["OriAuNo"] = tmpresDicData["AuNo"];
            }
            tmpResult["BillNo"] =  tmpBillNo;
            tmpResult["TrdAmt"] = tmpresDicData["TrdAmt"];
            tmpResult["TaxAmt"] = tmpresDicData["TaxAmt"];
            tmpResult["SvcAmt"] = tmpresDicData["SvcAmt"];
            tmpResult["TaxFreeAmt"] = tmpresDicData["TaxFreeAmt"];
            tmpResult["Month"] = tmpresDicData["Month"];
            if (!tmpBillNo.isEmpty && tmpBillNo.count == 12) {
                sqlite.instance.insertAppToAppData(resultData: tmpResult)
            }
        }
        
        tmpBillNo = ""
        tmpTrdType = ""
        tmpresDicData = [:]
        
        
        for (key,value) in _message {
            if _message.count - 1 == keyCount {
                _totalString += key + "=" + value
            }
            else{
                _totalString += key + "=" + value + "&"
            }
            keyCount += 1
            WebPostParamameter.updateValue(value, forKey: key)
        }
        self.scanTimeout?.invalidate()
        self.scanTimeout = nil
        Utils.customAlertBoxClear()
        // 카드애니메이션뷰 컨트롤러가 여전히 떠있으니 해당 뷰를 지운다
        Utils.CatAnimationViewInitClear()
        
        var message = ""
        if _totalString.isEmpty {
            message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
        } else {
//            if WebToAppSendDataFail == 1 {
//                if (_message["AnsCode"] ?? "") == "0000" {
//                    _totalString = "Message=" + "연동데이터 전송 실패로 거래를 취소하였습니다"
//                } else {
//                    _totalString = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생").replacingOccurrences(of: " ", with: "") + " 연동데이터 전송 실패로 거래 취소를 진행하였지만 취소처리에 실패하였습니다"
//                }
//            }
            let _t1 = _totalString.replacingOccurrences(of: "/", with: "%2F")
            let _t2 = _t1.replacingOccurrences(of: ":", with: "%3A")
            message = _t2.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        }
    
        debugPrint(" res StringCode = \(message)")
        
        var cusomUrl = ""
        if WebORApp == 0 {  //webToApp
            cusomUrl = Setting.shared.mWebAPPReturnAddr //웹페이지랑 연동시 처리 해당페이지 주소입력 이부분은 환경설정이나 이런곳에서 셋팅하는 방향?
        } else {    //AppToApp
            //            cusomUrl = define.APPTOAPP_ADDR + "\(message)"  //앱투앱으로 처리시
                        cusomUrl = define.APPTOAPP_ADDR + "?" + "\(message)"  //앱투앱으로 처리시
        }
        guard let url = URL(string: cusomUrl) else {
//            if WebToAppSendDataFail == 0 {
//                switch _message["TrdType"] {
//                case "G120":
//                    if _message["AnsCode"] == "0000" {
//                        //거래고유키 취소 진행
//                        WebToAppSendDataFail = 1
//                        mCatSdk.PayCredit(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                        return
//                    }
//                    break
//                case "G130":
//                    if _message["AnsCode"] == "0000" {
//                        //거래고유키 취소 진행
//                        WebToAppSendDataFail = 1
//                        mCatSdk.CashRecipt(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 고객번호: "", 개인법인구분: Setting.shared.tmpInsYn, 취소: true, 최소사유: "1", 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                        return
//                    }
//                    break
//                case "G140":
//                    if _message["AnsCode"] == "0000" {
//                        //거래고유키 취소 진행
//                        WebToAppSendDataFail = 1
//                        mCatSdk.PayCredit(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                        return
//                    }
//                    break
//                case "G150":
//                    if _message["AnsCode"] == "0000" {
//                        //거래고유키 취소 진행
//                        WebToAppSendDataFail = 1
//                        mCatSdk.EasyRecipt(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", App카드번호: String(_message["CardNo"] ?? ""), CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                        return
//                    }
//                    break
//                default:
//                    break
//                }
//            }
            message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
            var _error:Dictionary<String,String> = [:]
            _error["Message"] = ((_message["AnsCode"] ?? "") != "0000") ? ((_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")):"거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요"
            _error["TrdType"] = _message["TrdType"] ?? ""
            self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: (_message["AnsCode"] ?? "") == "0000" ? true:false)
            return
        }

        guard UIApplication.shared.canOpenURL(url) else {
//            if WebToAppSendDataFail == 0 {
//                switch _message["TrdType"] {
//                case "G120":
//                    if _message["AnsCode"] == "0000" {
//                        //거래고유키 취소 진행
//                        WebToAppSendDataFail = 1
//                        mCatSdk.PayCredit(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                        return
//                    }
//                    break
//                case "G130":
//                    if _message["AnsCode"] == "0000" {
//                        //거래고유키 취소 진행
//                        WebToAppSendDataFail = 1
//                        mCatSdk.CashRecipt(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 고객번호: "", 개인법인구분: Setting.shared.tmpInsYn, 취소: true, 최소사유: "1", 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                        return
//                    }
//                    break
//                case "G140":
//                    if _message["AnsCode"] == "0000" {
//                        //거래고유키 취소 진행
//                        WebToAppSendDataFail = 1
//                        mCatSdk.PayCredit(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                        return
//                    }
//                    break
//                case "G150":
//                    if _message["AnsCode"] == "0000" {
//                        //거래고유키 취소 진행
//                        WebToAppSendDataFail = 1
//                        mCatSdk.EasyRecipt(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", App카드번호: String(_message["CardNo"] ?? ""), CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                        return
//                    }
//                    break
//                default:
//                    break
//                }
//            }
            message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
            var _error:Dictionary<String,String> = [:]
            _error["Message"] = ((_message["AnsCode"] ?? "") != "0000") ? ((_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")):"거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요"
            _error["TrdType"] = _message["TrdType"] ?? ""
            self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: (_message["AnsCode"] ?? "") == "0000" ? true:false)
            return
        }

        if WebORApp == 0{
            let url = URL(string: cusomUrl)!
            var request = URLRequest(url: url)
            //2020-06-25 json 데이터가 정상적으로 전달 되지 않는 문제 수정
            //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept-Type")
            request.httpMethod = "POST"
            let postData = (try? JSONSerialization.data(withJSONObject: WebPostParamameter, options: []))
            request.httpBody = postData
      
            let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {   // check for fundamental networking error
//                    if WebToAppSendDataFail == 0 {
//                        switch _message["TrdType"] {
//                        case "G120":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.PayCredit(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        case "G130":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.CashRecipt(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 고객번호: "", 개인법인구분: Setting.shared.tmpInsYn, 취소: true, 최소사유: "1", 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        case "G140":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.PayCredit(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        case "G150":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.EasyRecipt(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", App카드번호: String(_message["CardNo"] ?? ""), CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        default:
//                            break
//                        }
//                    }
                    message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
                    var _error:Dictionary<String,String> = [:]
                    _error["Message"] = ((_message["AnsCode"] ?? "") != "0000") ? ((_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")):"거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요"
                    _error["TrdType"] = _message["TrdType"] ?? ""
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _message.count > 0 ? _message:_error, resultCheck: (_message["AnsCode"] ?? "") == "0000" ? true:false)
                    return
                }

                guard (200 ... 299) ~= response.statusCode else {  // check for http errors
//                    if WebToAppSendDataFail == 0 {
//                        switch _message["TrdType"] {
//                        case "G120":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.PayCredit(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        case "G130":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.CashRecipt(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 고객번호: "", 개인법인구분: Setting.shared.tmpInsYn, 취소: true, 최소사유: "1", 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        case "G140":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.PayCredit(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        case "G150":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.EasyRecipt(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", App카드번호: String(_message["CardNo"] ?? ""), CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        default:
//                            break
//                        }
//                    }
                    message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
                    var _error:Dictionary<String,String> = [:]
                    _error["Message"] = ((_message["AnsCode"] ?? "") != "0000") ? ((_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")):"거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요"
                    _error["TrdType"] = _message["TrdType"] ?? ""
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _message.count > 0 ? _message:_error, resultCheck: (_message["AnsCode"] ?? "") == "0000" ? true:false)
                    return
                }

                
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
       
                self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _message, resultCheck: _state == .OK ? true:false)
            }

            task.resume()
        }
        else{
        
            UIApplication.shared.open(url, options: [:], completionHandler: { [self](success) in
                if success {
                
                    WebToAppSendDataFail = 0
                } else {
//                    if WebToAppSendDataFail == 0 {
//                        switch _message["TrdType"] {
//                        case "G120":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.PayCredit(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        case "G130":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.CashRecipt(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 고객번호: "", 개인법인구분: Setting.shared.tmpInsYn, 취소: true, 최소사유: "1", 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        case "G140":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.PayCredit(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        case "G150":
//                            if _message["AnsCode"] == "0000" {
//                                //거래고유키 취소 진행
//                                WebToAppSendDataFail = 1
//                                mCatSdk.EasyRecipt(TID: Setting.shared.tmpTid, 거래금액: Setting.shared.tmpMoney, 세금: Setting.shared.tmpTax, 봉사료: Setting.shared.tmpSvc, 비과세: Setting.shared.tmpTxf, 원거래일자: String(_message["TrdDate"] ?? ""), 원승인번호: String(_message["AuNo"]!), 코세스거래고유번호: String(_message["TradeNo"] ?? ""), 할부: Setting.shared.tmpInstallment, 취소: true, 가맹점데이터: String(_message["MchData"]!), 여유필드: "", App카드번호: String(_message["CardNo"] ?? ""), CompletionCallback: catlistener?.delegate as! CatResultDelegate)
//                                return
//                            }
//                            break
//                        default:
//                            break
//                        }
//                    }
                    message = "Message=" +  (_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")
                    var _error:Dictionary<String,String> = [:]
                    _error["Message"] = ((_message["AnsCode"] ?? "") != "0000") ? ((_message["Message"] ?? _message["ERROR"] ?? "통신장애발생")):"거래내역 전송이 실패되었습니다. 결제 내역을 확인하세요"
                    _error["TrdType"] = _message["TrdType"] ?? ""
                    self.SfSafariViewControllerView(WebOrApp: WebORApp, result: _error, resultCheck: (_message["AnsCode"] ?? "") == "0000" ? true:false)
                    return
                   
                }
            })
        }
    }
    


    func SfSafariViewControllerView(WebOrApp _WebOrApp:Int, result: Dictionary<String, String>, resultCheck:Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            //만일 resultCheck = false 이면 해당결과는 거래가 실패인경우. 따라서 타이틀을 요청 실패 로 처리한다
            alert.dismiss(animated: true){[self] in
                let webToAppView = storyboard?.instantiateViewController(withIdentifier: "WebToAppResultViewController") as? WebToAppResultViewController
                webToAppView?.mMessageText = result
                webToAppView?.mTitleText = resultCheck == true ? "정상승인":"승인오류"

                webToAppView?.WebToAppSendDataFail = self.WebToAppSendDataFail == 0 ? 0:1
                let _labelText1:String = resultCheck == true ?  "요청을 완료했습니다. ":"요청을 실패했습니다. "
                let _labelText2:String = _WebOrApp == 0 ? "좌측 상단의 ◀Safari 를 눌러주세요.":"좌측 상단의 ◀apptoapp 를 눌러주세요."
                webToAppView?.mLabelText = _labelText1 + _labelText2
                webToAppView?.modalPresentationStyle = .fullScreen
                self.WebToAppSendDataFail = 0
                self.present(webToAppView!, animated: true, completion: nil)
            }
        }
    }

    /**
     신용, 현금, 신용취소, 현금취소, 가맹점등록 을 진행 할 시 정상적으로 데이터를 앱투앱/웹투앱으로 받았는지를 확인한다
     */
    func creditParserCheck(Tid _tid:String, Money _money:String, Tax _tax:String, ServiceCharge _serviceCharge:String, TaxFree _taxFree:String, InstallMent _installMent:String, DscYn _dscYn:String, DscData _dscData:String) -> String {
        var _check = ""

        if _tid.isEmpty {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " TID가 없습니다. "
            }
        } else if Setting.shared.getDefaultUserData(_key: define.APPTOAPP_TID) != _tid {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if KeychainWrapper.standard.string(forKey: keyChainTarget.AppToApp.rawValue + _tid) == nil {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if _money.isEmpty || (_money.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 금액이 없습니다. "
        } else if _tax.isEmpty || (_tax.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 세금이 없습니다. "
        } else if _serviceCharge.isEmpty || (_serviceCharge.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 봉사료가 없습니다. "
        } else if _taxFree.isEmpty || (_taxFree.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 비과세가 없습니다. "
        } else if _installMent.isEmpty || (_installMent.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 할부가 없습니다. "
        } else if _dscYn.isEmpty || (_dscYn.range(of: "^[0-3]*$", options: .regularExpression) == nil) {
            _check += " 전자서명 구분체크가 값을 벗어났습니다(0~3 사용). "
        } else if _dscYn == "2" || _dscYn == "3" {
            if _dscData.isEmpty || _dscData == "" {
                _check += " 서명데이터가 없습니다. "
            }
        }
        return _check
    }
    
    func cashParserCheck(Tid _tid:String, Money _money:String, Tax _tax:String, ServiceCharge _serviceCharge:String, TaxFree _taxFree:String, InsYn _insYn:String, KeyYn _keyYn:String, CashNum _cashNum:String) -> String {
        var _check = ""
        
        if _tid.isEmpty {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " TID가 없습니다. "
            }
        } else if Setting.shared.getDefaultUserData(_key: define.APPTOAPP_TID) != _tid {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if KeychainWrapper.standard.string(forKey: keyChainTarget.AppToApp.rawValue + _tid) == nil {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if _money.isEmpty || (_money.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 금액이 없습니다. "
        } else if _tax.isEmpty || (_tax.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 세금이 없습니다. "
        } else if _serviceCharge.isEmpty || (_serviceCharge.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 봉사료가 없습니다. "
        } else if _taxFree.isEmpty || (_taxFree.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 비과세가 없습니다. "
        } else if _insYn.isEmpty || (_insYn.range(of: "^[1-4]*$", options: .regularExpression) == nil) {
            _check += " 개인/법인(InsYn)가 없습니다. "
        } else if _cashNum.count > 13 {
            _check += " 고객번호를"
        }
//        else if _cashNum.count == 0 {
//            if KocesSdk.instance.bleState != define.TargetDeviceState.CATCONNECTED {
//                _check += " 고객번호를 확인해 주세요"
//            }
//        }
        
        return _check
    }
    func easyParserCheck(Tid _tid:String, Money _money:String, Tax _tax:String, ServiceCharge _serviceCharge:String, TaxFree _taxFree:String, InstallMent _installMent:String, DscYn _dscYn:String, DscData _dscData:String, QrKind _qrKind:String) -> String {
        var _check = ""

        if _tid.isEmpty {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " TID가 없습니다. "
            }
        } else if Setting.shared.getDefaultUserData(_key: define.APPTOAPP_TID) != _tid {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if KeychainWrapper.standard.string(forKey: keyChainTarget.AppToApp.rawValue + _tid) == nil {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if _money.isEmpty || (_money.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 금액이 없습니다. "
        } else if _tax.isEmpty || (_tax.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 세금이 없습니다. "
        } else if _serviceCharge.isEmpty || (_serviceCharge.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 봉사료가 없습니다. "
        } else if _taxFree.isEmpty || (_taxFree.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 비과세가 없습니다. "
        } else if _installMent.isEmpty || (_installMent.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 할부가 없습니다. "
        } else if _dscYn.isEmpty || (_dscYn.range(of: "^[0-3]*$", options: .regularExpression) == nil) {
            _check += " 전자서명 구분체크가 값을 벗어났습니다(0~3 사용). "
        } else if _dscYn == "2" || _dscYn == "3" {
            if _dscData.isEmpty || _dscData == "" {
                _check += " 서명데이터가 없습니다. "
            }
        } else if _qrKind.isEmpty || _qrKind == "" {
            _check += " Qr 종류가 없습니다. "
        }
        return _check
    }
    func creditCancelParserCheck(Tid _tid:String, Money _money:String, Tax _tax:String, ServiceCharge _serviceCharge:String, TaxFree _taxFree:String, InstallMent _installMent:String, AuDate _auDate:String, AuNo _auNo:String, TradeNo _tradeNo:String, TrdCode _trdCode:String, DscYn _dscYn:String, DscData _dscData:String) -> String {
        var _check = ""
        if !_trdCode.isEmpty && _trdCode == "T" {
            if _tradeNo.isEmpty {
                _check += " 거래고유키가 없습니다. "
            }
        }
        
        if _tid.isEmpty {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " TID가 없습니다. "
            }
        } else if Setting.shared.getDefaultUserData(_key: define.APPTOAPP_TID) != _tid {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if KeychainWrapper.standard.string(forKey: keyChainTarget.AppToApp.rawValue + _tid) == nil {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if _money.isEmpty || (_money.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 금액이 없습니다. "
        } else if _tax.isEmpty || (_tax.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 세금이 없습니다. "
        } else if _serviceCharge.isEmpty || (_serviceCharge.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 봉사료가 없습니다. "
        } else if _taxFree.isEmpty || (_taxFree.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 비과세가 없습니다. "
        } else if _installMent.isEmpty || (_installMent.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 할부가 없습니다. "
        } else if _auDate.isEmpty || (_auDate.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 승인날짜가 없습니다. "
        } else if _auNo.isEmpty || (_auNo.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 승인번호가 없습니다. "
        } else if _dscYn.isEmpty || (_dscYn.range(of: "^[0-3]*$", options: .regularExpression) == nil) {
            _check += " 전자서명 구분체크가 값을 벗어났습니다(0~3 사용). "
        } else if _dscYn == "2" || _dscYn == "3" {
            if _dscData.isEmpty || _dscData == "" {
                _check += " 서명데이터가 없습니다. "
            }
        }
        
        return _check
    }
    
    func cashCancelParserCheck(Tid _tid:String, Money _money:String, Tax _tax:String, ServiceCharge _serviceCharge:String, TaxFree _taxFree:String, InsYn _insYn:String, KeyYn _keyYn:String, CashNum _cashNum:String, CancelReason _cancelReason:String, AuDate _auDate:String, AuNo _auNo:String, TradeNo _tradeNo:String, TrdCode _trdCode:String) -> String {
        var _check = ""
        if !_trdCode.isEmpty && _trdCode == "T" {
            if _tradeNo.isEmpty {
                _check += " 거래고유키가 없습니다. "
            }
        }
        
        //신기하게 이녀석은 뒤에 스페이스패딩이 붙어서 들어온다
        let auNo = _auNo.replacingOccurrences(of: " ", with: "")
        
        if _tid.isEmpty {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " TID가 없습니다. "
            }
        } else if Setting.shared.getDefaultUserData(_key: define.APPTOAPP_TID) != _tid {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if KeychainWrapper.standard.string(forKey: keyChainTarget.AppToApp.rawValue + _tid) == nil {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if _money.isEmpty || (_money.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 금액이 없습니다. "
        } else if _tax.isEmpty || (_tax.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 세금이 없습니다. "
        } else if _serviceCharge.isEmpty || (_serviceCharge.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 봉사료가 없습니다. "
        } else if _taxFree.isEmpty || (_taxFree.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 비과세가 없습니다. "
        } else if _insYn.isEmpty || (_insYn.range(of: "^[1-4]*$", options: .regularExpression) == nil) {
            _check += " 개인/법인(InsYn)가 없습니다. "
        } else if _cancelReason.isEmpty || (_insYn.range(of: "^[1-3]*$", options: .regularExpression) == nil)  {
            _check += " 취소사유가 없습니다. "
        } else if _auDate.isEmpty || (_auDate.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 승인날짜가 없습니다. "
        } else if auNo.isEmpty || (auNo.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 승인번호가 없습니다. "
        }

        return _check
    }
    
    func easyCancelParserCheck(Tid _tid:String, Money _money:String, Tax _tax:String, ServiceCharge _serviceCharge:String, TaxFree _taxFree:String, InstallMent _installMent:String, AuDate _auDate:String, AuNo _auNo:String, TradeNo _tradeNo:String, TrdCode _trdCode:String, DscYn _dscYn:String, DscData _dscData:String, QrKind _qrKind:String) -> String {
        var _check = ""
        if !_trdCode.isEmpty && _trdCode == "T" {
            if _tradeNo.isEmpty {
                _check += " 거래고유키가 없습니다. "
            }
        }
        
        if _tid.isEmpty {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " TID가 없습니다. "
            }
        } else if Setting.shared.getDefaultUserData(_key: define.APPTOAPP_TID) != _tid {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if KeychainWrapper.standard.string(forKey: keyChainTarget.AppToApp.rawValue + _tid) == nil {
            if mKocesSdk.bleState != define.TargetDeviceState.CATCONNECTED {
                _check += " 가맹점 TID 불일치입니다. "
            }
        } else if _money.isEmpty || (_money.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 금액이 없습니다. "
        } else if _tax.isEmpty || (_tax.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 세금이 없습니다. "
        } else if _serviceCharge.isEmpty || (_serviceCharge.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 봉사료가 없습니다. "
        } else if _taxFree.isEmpty || (_taxFree.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 비과세가 없습니다. "
        } else if _installMent.isEmpty || (_installMent.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 할부가 없습니다. "
        } else if _auDate.isEmpty || (_auDate.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 승인날짜가 없습니다. "
        } else if _auNo.isEmpty || (_auNo.range(of: "^[0-9]*$", options: .regularExpression) == nil) {
            _check += " 승인번호가 없습니다. "
        } else if _dscYn.isEmpty || (_dscYn.range(of: "^[0-3]*$", options: .regularExpression) == nil) {
            _check += " 전자서명 구분체크가 값을 벗어났습니다(0~3 사용). "
        } else if _dscYn == "2" || _dscYn == "3" {
            if _dscData.isEmpty || _dscData == "" {
                _check += " 서명데이터가 없습니다. "
            }
        } else if _qrKind.isEmpty || _qrKind == "" {
            _check += " Qr 종류가 없습니다. "
        }
        return _check
    }
    
    func storeParserCheck(Tid _tid:String, BSN _bsn:String, Serial _serial:String) -> String {
        var _check = ""
        if _tid.isEmpty {
            _check += " TID가 없습니다. "
        } else if _bsn.isEmpty {
            _check += " 사업자번호가 없습니다. "
        } else if _serial.isEmpty {
            _check += " 시리얼번호가 없습니다. "
        }
        return _check
    }
    
    //앱투앱에서 프린트 시 디바이스 체크
    func printParserCheck() -> String {
        var _check = Utils.PrintDeviceCheck()
        return _check
    }
    
    //앱투앱에서 프린트 시 타임아웃설정
    func printTimeOut() {
        self.scanTimeout = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false, block: { timer in
            var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
            resDataDic["Message"] = NSString("프린트를 실패(타임아웃)하였습니다") as String
            self.onPrintResult(printStatus: .OK, printResult: resDataDic)
            self.scanTimeout?.invalidate()
            self.scanTimeout = nil
        })
    }
    
    //출력용 바코드 번호 4자리 마다 "-" 를 넣는다. 단, 캐쉬는 제외
//    func barcodeParser(바코드 _printBarcd:String) -> String {
//        let barchars:[Character] = Array(_printBarcd.replacingOccurrences(of: " ", with: ""))
//        var _barcd:String = ""
//        if barchars.count == 8 {
//            _barcd = String(barchars[0...3]) + "-" + String(barchars[4...]) + "-" + "****" + "-" + "****"
//        } else {
//            _barcd = _printBarcd.replacingOccurrences(of: " ", with: "")
//        }
//        return _barcd
//    }
    func barcodeParser(바코드 _printBarcd:String, 승인날짜 _audate:String, 간편신용현금IC _간편신용현금IC:String) -> String {
        var _barcd:String = ""
        if _간편신용현금IC == "신용" {
            //만일 90일이 지난 거래라면 여기서 다시 한번 재마스킹처리한다
            _barcd = Utils.CardParser(카드번호: _printBarcd, 날짜90일경과: Utils.dateComp(승인날짜: _audate))
        } else if _간편신용현금IC == "간편" {
            //만일 90일이 지난 거래라면 여기서 다시 한번 재마스킹처리한다
            _barcd = Utils.EasyParser(바코드qr번호: _printBarcd, 날짜90일경과: Utils.dateComp(승인날짜: _audate))
        } else if _간편신용현금IC == "현금" {
            //만일 90일이 지난 거래라면 여기서 다시 한번 재마스킹처리한다
            _barcd = Utils.CashParser(현금영수증번호: _printBarcd, 날짜90일경과: Utils.dateComp(승인날짜: _audate))
        } else {
            // 이거 뭐지? 현금IC 는 현금으로 체크
            
        }

        return _barcd
    }
    
    //프린트 할 문장 전체 파싱
    func PrintReceiptInit(HashMap _hash:Dictionary<String,String>) -> String {
        // 신용승인/신용취소/현금승인/현금취소 총4개로 구분지어서 파싱한다
        //신용매출
        if _hash["TrdType"] == "A25" {
            printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "카드취소")) + define.PENTER)
        } else if _hash["TrdType"] == "A15" {
            printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "카드승인")) + define.PENTER)
        } else if _hash["TrdType"] == "E25" {
            printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "간편취소")) + define.PENTER)
        } else if _hash["TrdType"] == "E15"{
            printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "간편승인")) + define.PENTER)
        } else if _hash["TrdType"] == "B25" {
            printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "현금취소")) + define.PENTER)
        } else {
            printParser(프린트메세지: Utils.PrintCenter(Center: Utils.PrintBold(_bold: "현금승인")) + define.PENTER)
        }
       
        //전표번호(로컬DB에 저장되어 있는 거래내역리스트의 번호) + 전표출력일시
        printParser(프린트메세지: Utils.PrintPad(leftString: "No." + Utils.leftPad(str: tmpBillNo, fillChar: "0", length: 6), rightString: Utils.titleDateParser()) + define.PENTER)

        //-------------
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        
        //가맹점명
        let _storeName = _hash["ShpNm"] ?? ""
        printParser(프린트메세지: Utils.PrintPad(leftString: "가맹점명", rightString: _storeName.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        //대표자명 사업자번호 연락처
        let _storeOwner = _hash["PreNm"] ?? ""
        printParser(프린트메세지: Utils.PrintPad(leftString: "대표자명", rightString: _storeOwner.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        printParser(프린트메세지: Utils.PrintPad(leftString: "사업자번호", rightString: bsnParser(사업자번호: _hash["BsnNo"] ?? "")) + define.PENTER)
        printParser(프린트메세지: Utils.PrintPad(leftString: "연락처", rightString: phoneParser(전화번호: _hash["ShpTno"] ?? "")) + define.PENTER)
        //단말기TID
        printParser(프린트메세지: Utils.PrintPad(leftString: "단말기ID", rightString: tidParser(단말기ID: _hash["TermID"] ?? "")) + define.PENTER)
        //주소
        let _storeAddr = _hash["ShpAr"] ?? ""
        printParser(프린트메세지: Utils.PrintPad(leftString:  "주소  ", rightString: _storeAddr) + define.PENTER)

        //-------------
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        
        if _hash["InpNm"] != "" {
            //매입사명
            printParser(프린트메세지: Utils.PrintPad(leftString: "매입사명", rightString: _hash["InpNm"] ?? "") + define.PENTER)
        }
        if _hash["OrdNm"] != "" {
            //카드종류
            printParser(프린트메세지: Utils.PrintPad(leftString: "발급사명", rightString: _hash["OrdNm"] ?? "") + define.PENTER)
        }
        //카드번호
        var _cardNo = _hash["CardNo"] ?? ""
        if !_cardNo.isEmpty && _cardNo != "" {
            if _hash["TrdType"] == "A15" || _hash["TrdType"] == "A25" {
                printParser(프린트메세지: Utils.PrintPad(leftString: "카드번호", rightString: barcodeParser(바코드: _hash["CardNo"] ?? "", 승인날짜: _hash["TrdDate"] ?? "", 간편신용현금IC: "신용")) + define.PENTER)
            } else if  _hash["TrdType"] == "E15" || _hash["TrdType"] == "E25"  {
                printParser(프린트메세지: Utils.PrintPad(leftString: "바코드번호", rightString: barcodeParser(바코드: _hash["CardNo"] ?? "", 승인날짜: _hash["TrdDate"] ?? "", 간편신용현금IC: "간편")) + define.PENTER)
            } else {
                printParser(프린트메세지: Utils.PrintPad(leftString: "고객번호", rightString:barcodeParser(바코드: _hash["CardNo"] ?? "", 승인날짜: _hash["TrdDate"] ?? "", 간편신용현금IC: "현금")) + define.PENTER)
            }
        }
        //승인일시
        printParser(프린트메세지: Utils.PrintPad(leftString: "승인일시", rightString: dateParser(거래일자: _hash["TrdDate"] ?? ""))  + define.PENTER)
        //만약 취소 시에는 여기에서 원거래일자를 삽입해야 한다. 결국 sqlLITE 에 원거래일자 항목을 하나 만들어서 취소시에는 원거래일자에 승인일자를 삽입해야 한다.
        if _hash["TrdType"] == "A25" || _hash["TrdType"] == "E25" || _hash["TrdType"] == "B25" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "원거래일", rightString: oriDateParser(원거레: _hash["OriAuDate"] ?? "")) + define.PENTER)
        }
      
        //승인번호 할부개월
        let 승인번호 = _hash["AuNo"] ?? ""
        if _hash["TrdType"] == "A15" || _hash["TrdType"] == "A25" || _hash["TrdType"] == "E15" || _hash["TrdType"] == "E25" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "할부개월", rightString: installmentParser(할부: _hash["Month"] ?? "")) + define.PENTER)
        }
        printParser(프린트메세지: Utils.PrintPad(leftString: "승인번호", rightString: 승인번호.replacingOccurrences(of: " ", with: "")) + define.PENTER)

        //가맹점번호
        var _MchNo = _hash["MchNo"] ?? ""
        if _MchNo != "" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "가맹점번호", rightString:_MchNo.replacingOccurrences(of: " ", with: "")) + define.PENTER)
        }
        //-------------
        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        
        //간편결제거래종류
        let QrKind = _hash["QrKind"] ?? ""
        if !QrKind.isEmpty {
            printParser(프린트메세지: Utils.PrintPad(leftString: "간편결제종류", rightString: QrKind) + define.PENTER)
        }
        
        //카카오거래
        let DisAmt = _hash["DisAmt"] ?? ""
        if !DisAmt.isEmpty && DisAmt != "0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "카카오할인금액", rightString: Utils.PrintMoney(Money: DisAmt) + "원") + define.PENTER)
        }
        //카카오페이일 때만 표시한다
        if QrKind == "KP" {
            let AuthType = _hash["AuthType"] ?? ""
            if !AuthType.isEmpty {
                printParser(프린트메세지: Utils.PrintPad(leftString: "카카오결제수단", rightString: AuthType) + define.PENTER)
            }
        }
        //위쳇페이
        let AnswerTrdNo = _hash["AnswerTrdNo"] ?? ""
        if !AnswerTrdNo.isEmpty {
            printParser(프린트메세지: Utils.PrintPad(leftString: "위쳇거래번호", rightString: AnswerTrdNo) + define.PENTER)
        }
        //제로페이
        let ChargeAmt = _hash["ChargeAmt"] ?? ""
        if !ChargeAmt.isEmpty && ChargeAmt != "0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "가맹점수수료", rightString: Utils.PrintMoney(Money: ChargeAmt) + "원") + define.PENTER)
        }
        let RefundAmt = _hash["RefundAmt"] ?? ""
        if !RefundAmt.isEmpty && RefundAmt != "0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "가맹점환불금액", rightString: Utils.PrintMoney(Money: RefundAmt) + "원") + define.PENTER)
        }
        //페이코
        let PcCoupon =  _hash["PcCoupon"] ?? ""
        let PcPoint =  _hash["PcPoint"] ?? ""
        let PcCard =  _hash["PcCard"] ?? ""
        if !PcCoupon.isEmpty && PcCoupon != "0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "페이코쿠폰", rightString: Utils.PrintMoney(Money: PcCoupon) + "원") + define.PENTER)
        }
        if !PcPoint.isEmpty && PcPoint != "0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "페이코포인트", rightString: Utils.PrintMoney(Money: PcPoint) + "원") + define.PENTER)
        }
        if !PcCard.isEmpty && PcCard != "0" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "페이코카드", rightString: Utils.PrintMoney(Money: PcCard) + "원") + define.PENTER)
        }
        
        
        //공급가액
        var correctMoney:Int = 0
        correctMoney = Int(_hash["TrdAmt"] ?? "0")!
        
        //결제금액
        let _totalMoney:String = "\(getTotalMoney(_money: Int(_hash["TrdAmt"] ?? "0")!, _tax: Int(_hash["TaxAmt"] ?? "0")!, _Svc: Int(_hash["SvcAmt"] ?? "0")!, _Txf:Int(_hash["TaxFreeAmt"] ?? "0")!))"
        let _taxAmt = _hash["TaxAmt"] ?? "0"
        let _svcAmt = _hash["SvcAmt"] ?? "0"
        let _taxFreeAmt = _hash["TaxFreeAmt"] ?? "0"
        
        if _hash["TrdType"] == "A25" || _hash["TrdType"] == "E25" || _hash["TrdType"] == "B25"{
            //공급가액
            if correctMoney == 0 || correctMoney == -0{
                printParser(프린트메세지: Utils.PrintPad(leftString: "공급가액", rightString: Utils.PrintMoney(Money: "0") + "원" ) + define.PENTER)
            } else {
                printParser(프린트메세지: Utils.PrintPad(leftString: "공급가액", rightString: "- " + Utils.PrintMoney(Money: String(correctMoney)) + "원" ) + define.PENTER)
            }
            //부가세
            if _taxAmt == "0" || _taxAmt == "-0"{
                printParser(프린트메세지: Utils.PrintPad(leftString: "부가세", rightString: Utils.PrintMoney(Money: "0") + "원" ) + define.PENTER)
            } else {
                printParser(프린트메세지: Utils.PrintPad(leftString: "부가세", rightString: "- " + Utils.PrintMoney(Money: _taxAmt) + "원") + define.PENTER)
            }
       
            //봉사료
            if !_svcAmt.isEmpty && _svcAmt != "0" && _svcAmt != "-0" {
                printParser(프린트메세지: Utils.PrintPad(leftString: "봉사료", rightString: "- " + Utils.PrintMoney(Money: _svcAmt) + "원") + define.PENTER)
            }
            //비과세
            if !_taxFreeAmt.isEmpty && _taxFreeAmt != "0" && _taxFreeAmt != "-0" {
                printParser(프린트메세지: Utils.PrintPad(leftString: "비과세", rightString: "- " + Utils.PrintMoney(Money: _taxFreeAmt) + "원") + define.PENTER)
            }
            //결제금액
            printParser(프린트메세지: Utils.PrintPad(leftString: Utils.PrintBold(_bold: "결제금액") , rightString: Utils.PrintBold(_bold: "- " + Utils.PrintMoney(Money: _totalMoney) + "원")) + define.PENTER)
//            printParser(프린트메세지: Utils.PrintPadBold(leftString: "결제금액" , rightString: "- " + Utils.PrintMoney(Money: _totalMoney) + "원") + define.PENTER)
        } else if _hash["TrdType"] == "A15" || _hash["TrdType"] == "E15" || _hash["TrdType"] == "B15" {
            printParser(프린트메세지: Utils.PrintPad(leftString: "공급가액", rightString: Utils.PrintMoney(Money: String(correctMoney)) + "원" ) + define.PENTER)
            //부가세
            printParser(프린트메세지: Utils.PrintPad(leftString: "부가세", rightString: Utils.PrintMoney(Money: _taxAmt) + "원") + define.PENTER)
            //봉사료
            if !_svcAmt.isEmpty && _svcAmt != "0" {
                printParser(프린트메세지: Utils.PrintPad(leftString: "봉사료", rightString: Utils.PrintMoney(Money: _svcAmt) + "원") + define.PENTER)
            }
            //비과세
            if !_taxFreeAmt.isEmpty && _taxFreeAmt != "0" {
                printParser(프린트메세지: Utils.PrintPad(leftString: "비과세", rightString: Utils.PrintMoney(Money: _taxFreeAmt) + "원") + define.PENTER)
            }
            //결제금액
            printParser(프린트메세지: Utils.PrintPad(leftString: Utils.PrintBold(_bold: "결제금액") , rightString: Utils.PrintBold(_bold: Utils.PrintMoney(Money: _totalMoney) + "원")) + define.PENTER)
//            printParser(프린트메세지: Utils.PrintPadBold(leftString: "결제금액" , rightString: Utils.PrintMoney(Money: _totalMoney) + "원") + define.PENTER)
        } else {
            printParser(프린트메세지: Utils.PrintPad(leftString: "공급가액", rightString: Utils.PrintMoney(Money: String(correctMoney)) + "원" ) + define.PENTER)
            //부가세
            printParser(프린트메세지: Utils.PrintPad(leftString: "부가세", rightString: Utils.PrintMoney(Money: _taxAmt) + "원") + define.PENTER)
            //봉사료
            if !_svcAmt.isEmpty && _svcAmt != "0" {
                printParser(프린트메세지: Utils.PrintPad(leftString: "봉사료", rightString: Utils.PrintMoney(Money: _svcAmt) + "원") + define.PENTER)
            }
            //비과세
            if !_taxFreeAmt.isEmpty && _taxFreeAmt != "0" {
                printParser(프린트메세지: Utils.PrintPad(leftString: "비과세", rightString: Utils.PrintMoney(Money: _taxFreeAmt) + "원") + define.PENTER)
            }
            //결제금액
            printParser(프린트메세지: Utils.PrintPad(leftString: Utils.PrintBold(_bold: "결제금액") , rightString: Utils.PrintBold(_bold:  Utils.PrintMoney(Money: _totalMoney) + "원")) + define.PENTER)
//            printParser(프린트메세지: Utils.PrintPadBold(leftString: "결제금액" , rightString: Utils.PrintMoney(Money: _totalMoney) + "원") + define.PENTER)
        }
        
        //기프트카드 잔액
        var 카드종류 = _hash["CardKind"] ?? ""
        if 카드종류.contains("3") || 카드종류.contains("4") {
            printParser(프린트메세지: Utils.PrintPad(leftString: "기프트카드잔액", rightString: Utils.PrintMoney(Money: (_hash["GiftAmt"] ?? "0").filter{$0.isNumber}) + "원") + define.PENTER)
        }


        printParser(프린트메세지: Utils.PrintLine(line: "- ") + define.PENTER)
        
        var _msg = _hash["Message"] ?? ""
        if _msg != "" {
            printParser(프린트메세지: "메세지 " + _msg + define.PENTER)
        }
     
        //실제앱에 저장되어있는 추가메시지
        if !Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL).isEmpty {
            printParser(프린트메세지: define.PLEFT + Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL) + define.PENTER)
        }

//        PrintReceipt(프린트메세지: printMsg)

        return printMsg
    
    }
    
    //개개 메세지 한줄씩 파싱
    func printParser(프린트메세지 _msg:String) {
        self.printMsg += _msg
    }
    
    //할부를 0-> 일시불, 개월 로 수정
    func installmentParser(할부 Inst:String) -> String{
        var InstString:String = ""
        if Inst == "" {
            return InstString
        }
        if Inst == "0" {
            InstString = "(일시불)"
        } else {
            InstString = Inst + " 개월"
        }
        return InstString
    }
    
    //거래일자를 프린트용으로 파싱
    func dateParser(거래일자 AuDate:String) -> String {
        let auchars:[Character] = Array(AuDate)
        var dateString:String = ""
        if AuDate.count > 10 {
            dateString = String(auchars[0...1]) + "/" + String(auchars[2...3]) + "/" + String(auchars[4...5]) + " " +
                String(auchars[6...7]) + ":" + String(auchars[8...9]) + ":" + String(auchars[10...])
        } else {
            dateString = AuDate
        }
        return dateString
    }
    
    //원거래일자를 프린트용으로 파싱
    func oriDateParser(원거레 원거래일자:String) -> String {
        if 원거래일자 == nil || 원거래일자 == "" {
            return ""
        }
        let auchars:[Character] = Array(원거래일자)
        var dateString:String = ""
        if 원거래일자.count >= 6 {
            dateString = String(auchars[0...1]) + "/" + String(auchars[2...3]) + "/" + String(auchars[4...5])
//            + " " +
//                String(auchars[6...7]) + ":" + String(auchars[8...9]) + ":" + String(auchars[10...])
        } else {
            dateString = 원거래일자
        }
        return dateString
    }
    
    //타이틀의 옆에 나오는 (현재시간)
    func titleDateParser() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yy/MM/dd HH:mm:ss"
    
        let currentDate:String = dateFormatter.string(from: Date())
        let dateString:String = currentDate
        return dateString
    }
    
    //사업자번호의 중간에 - 를 넣는다
    func bsnParser(사업자번호 BSN:String) -> String {
        let bsnchars:[Character] = Array(BSN.replacingOccurrences(of: " ", with: ""))
        var _bsn:String = ""
        if bsnchars.count > 9 {
            _bsn = String(bsnchars[0...2]) + "-" + String(bsnchars[3...4]) + "-" + String(bsnchars[5...])
        } else {
            _bsn = BSN.replacingOccurrences(of: " ", with: "")
        }
        return _bsn
    }
    //전화번호 중간에 - 를 넣는다
    func phoneParser(전화번호 StorePhone:String) -> String {
        let telchars:[Character] = Array(StorePhone.replacingOccurrences(of: " ", with: ""))
        var _tel:String = ""
        if telchars.count == 9 {
            _tel = String(telchars[0...1]) + "-" + String(telchars[2...4]) + "-" + String(telchars[5...8])
        } else if telchars.count == 10 {
            _tel = String(telchars[0...1]) + "-" + String(telchars[2...5]) + "-" + String(telchars[6...9])
        } else if telchars.count == 11 {
            _tel = String(telchars[0...2]) + "-" + String(telchars[3...6]) + "-" + String(telchars[7...10])
        } else {
            _tel = StorePhone.replacingOccurrences(of: " ", with: "")
        }
        return _tel
    }
    
    //프린트에 TID 앞에 *** 를 넣는다
    func tidParser(단말기ID TID:String) -> String {
        let tidchars:[Character] = Array(TID.replacingOccurrences(of: " ", with: ""))
        var _tid:String = ""
        
        _tid = "***" + String(tidchars[3...])
        
        return _tid
    }
    
    func getTotalMoney(_money:Int,_tax:Int,_Svc:Int,_Txf:Int) -> Int {

//        var TotalMoney:Int = _money + _tax + _Svc
//        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
//            TotalMoney = _money + _tax + _Svc + _Txf
//        }
        
        var TotalMoney:Int = _money + _tax + _Svc + _Txf
        return TotalMoney
    }
    
}
