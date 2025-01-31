//
//  CatSdk.swift
//  KocesICIOS
//
//  Created by 金載龍 on 2021/05/07.
//

import Foundation
import SwiftSocket


class CatSdk {
    static let instance:CatSdk = CatSdk()
    var catlistener: CatResultDelegate?
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var tcplinstener:TcpResultDelegate?

    var mSwiftSocket:TCPClient?
    
    //간편결제를 할 때 스캐너를 통해 확인 해야 하기 때문에
    var Tid = ""
    var mStoreName = "";
    var mStoreAddr = "";
    var mStoreNumber = "";
    var mStorePhone = "";
    var mStoreOwner = "";
    
    var Money = ""
    var Tax = ""
    var Svc = ""
    var Txf = ""
    var AuDate = ""
    var AuNo = ""
    /** 원서브승인번호(간편결제) */
    var SubAuNo = "";
    var UniqueNumber = ""
    var InstallMent = ""
    var Cancel = false
    var MchData = ""
    var ExtraField = ""
    var pb = ""
    var CancelReason = ""
    var Class:define.CashICBusinessClassification = define.CashICBusinessClassification.Search
    var DirectTrade = ""
    var CardInfo = ""
    var OriAuDate = ""
    var OriAuNo = ""
    
    var TrdType = ""
    var QrBarcode = ""
    /** 간편결제 거래종류 카카오,제로,위쳇,앱카드 등 */
    var EasyKind = ""

    /** 호스트가맹점데이터(간편결제) */
    var HostMchData = ""
    
    /** 현재 화면이 앱투앱인지 아닌지를 체크 DB 저장을 위해서 */
    var mDBAppToApp:Bool = false

    let LOG_CONNECT_PRINT_FAIL_IP:String = "CAT 프린트 연결 실패 : IP 미설정"
    let LOG_CONNECT_PRINT_FAIL_PORT:String = "CAT 프린트 연결 실패 : PORT 미설정"
    let LOG_CONNECT_PRINT_FAIL_NETWORK_UNKNOWN_TYPE:String = "CAT 프린트 연결 실패 : 네트워크 연결은 있지만 타입 확인 불가(와아파이 등을 확인하지 못함)"
    let LOG_CONNECT_PRINT_FAIL_NETWORK_FAIL:String = "CAT 프린트 연결 실패 : 네트워크 연결 실패"
    
    let LOG_CONNECT_FAIL_IP:String = "CAT 연결 실패 : IP 미설정"
    let LOG_CONNECT_FAIL_PORT:String = "CAT 연결 실패 : PORT 미설정"
    let LOG_CONNECT_FAIL_NETWORK_UNKNOWN_TYPE:String = "CAT 연결 실패 : 네트워크 연결은 있지만 타입 확인 불가(와아파이 등을 확인하지 못함)"
    let LOG_CONNECT_FAIL_NETWORK_FAIL:String = "CAT 연결 실패 : 네트워크 연결 실패"
    
    let LOG_CONNECT_FAIL_SOCKET_FAIL:String = "CAT 연결 실패 : 소켓 설정 실패"
    let LOG_CONNECT_FAIL_TIMEOUT_FAIL:String = "CAT 연결 실패 : 연결 시도 중 실패 : "
    let LOG_CONNECT_FAIL_SEND_ACK_FAIL:String = "CAT 연결 실패 : ACK 전송 실패로 인한 연결 실패 처리"
    let LOG_CONNECT_FAIL_RECEIVE_ACK_FAIL_1:String = "CAT 연결 실패 : ACK 전송 후 ACK 응답을 받아야 하는데 값이 없다 연결 실패 처리"
    let LOG_CONNECT_FAIL_RECEIVE_ACK_FAIL_2:String = "CAT 연결 실패 : ACK 전송 후 ACK 응답을 받아야 하는데 값이 ACK가 아니다 연결 실패 처리"
    
    let LOG_SEND_DATA:String = "CAT Data Send :"
    let LOG_SEND_DATA_FAIL:String = "CAT Data Send 실패 : "
    
    let LOG_RECEIVE_DATA_FAIL:String = "CAT Data read 실패 : "
    let LOG_RECEIVE_DATA_SUCCESS:String = "CAT Data read 성공 : "
    
    let LOG_RECEIVE_ACK_FAIL:String = "CAT Data read ACK 실패 : CAT 단말기 데이터(ACK) 수신에 실패"
    let LOG_RECEIVE_A110:String = "CAT Data read A110 : "
    let LOG_RECEIVE_D:String = "CAT Data read : D : "
    let LOG_RECEIVE_F:String = "CAT Data read : F : "
    let LOG_RECEIVE_Q:String = "CAT Data read : Q : "
    let LOG_RECEIVE_E:String = "CAT Data read : E : "
    let LOG_RECEIVE_UNKNOWN:String = "CAT Data read : 정의되지 않은 응답 : "
    let LOG_RECEIVE_G:String = "CAT read Data : G"
    let LOG_RECEIVE_NAK:String = "CAT read Data : NAK 수신"
    let LOG_RECEIVE_EOT_FAIL_1:String = "CAT read Data : EOT 미수신. 응답값이 없다."
    let LOG_RECEIVE_EOT_FAIL_2:String = "CAT read Data : EOT 미수신. EOT가 아니다."
    let LOG_RECEIVE_EOT_SUCCESS:String = "CAT read Data : EOT 정상수신"
    
    let LOG_RECEIVE_ERROR_CODE_SUCCESS:String = "CAT read Data error 응답코드 : "
    let LOG_RECEIVE_ERROR_MESSAGE_SUCCESS:String = "CAT read Data error 메세지 : "
    
    let LOG_RECEIVE_ERROR_PARSING_FAIL:String = "CAT read Data error : 응답데이터 파싱에 실패했습니다"
    
    //사용한 데이터 삭제
    func Clear() {
        Tid = ""
        Money = ""
        Tax = ""
        Svc = ""
        Txf = ""
        AuDate = ""
        AuNo = ""
        UniqueNumber = ""
        InstallMent = ""
        Cancel = false
        MchData = ""
        ExtraField = ""
        pb = ""
        mDBAppToApp = false
        CancelReason = ""
        Class = define.CashICBusinessClassification.Search
        DirectTrade = ""
        CardInfo = ""
        OriAuDate = ""
        OriAuNo = ""
        TrdType = ""
        QrBarcode = ""
        EasyKind = ""
        
        HostMchData = ""
        mStoreName = "";
        mStoreAddr = "";
        mStoreNumber = "";
        mStorePhone = "";
        mStoreOwner = "";
    }
    
    func ConnectPrintServer() -> Bool {
        let IP:String = Setting.shared.getDefaultUserData(_key: define.CAT_PRINT_SERVER_IP)
        let Port:Int = (String(Setting.shared.getDefaultUserData(_key: define.CAT_PRINT_SERVER_PORT)) as NSString).integerValue
        
        if IP == "" {
            LogFile.instance.InsertLog(LOG_CONNECT_PRINT_FAIL_IP, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return false
        }
        if String(Setting.shared.getDefaultUserData(_key: define.CAT_PRINT_SERVER_PORT)) == "" {
            LogFile.instance.InsertLog(LOG_CONNECT_PRINT_FAIL_PORT, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return false
        }
        
        if NetworkManager.shared.isConnected {
            print("연결됨...")
            if NetworkManager.shared.connectionType == .unknown {
                print("CAT 단말기 연동을 위해선 와이파이등을 통해 연동해야 한다")
                LogFile.instance.InsertLog(LOG_CONNECT_PRINT_FAIL_NETWORK_UNKNOWN_TYPE, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                return false
            }
        }else{
            print("연결안됨...ㅜ")
            LogFile.instance.InsertLog(LOG_CONNECT_PRINT_FAIL_NETWORK_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return false
        }

        mSwiftSocket = TCPClient.init(address: IP, port: Int32(Port))
        return true
        
    }
    
    func ConnectServer() -> Bool {
        let IP:String = Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_IP)
        let Port:Int = (String(Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_PORT)) as NSString).integerValue
        
        if IP == "" {
            LogFile.instance.InsertLog(LOG_CONNECT_FAIL_IP, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return false
        }
        if String(Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_PORT)) == "" {
            LogFile.instance.InsertLog(LOG_CONNECT_FAIL_PORT, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return false
        }
        
        if NetworkManager.shared.isConnected {
            print("연결됨...")
            if NetworkManager.shared.connectionType == .unknown {
                print("CAT 단말기 연동을 위해선 와이파이등을 통해 연동해야 한다")
                LogFile.instance.InsertLog(LOG_CONNECT_FAIL_NETWORK_UNKNOWN_TYPE, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                return false
            }
        }else{
            print("연결안됨...ㅜ")
            LogFile.instance.InsertLog(LOG_CONNECT_FAIL_NETWORK_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return false
        }

        mSwiftSocket = TCPClient.init(address: IP, port: Int32(Port))
        return true
        
    }
    
    //전문상에서는 연결 후에 Ack -> 전송 , Ack*2 -> 수신으로 되어 있으나 안 해도 무방해서 코드 주석 처리 함.
    func CheckBeforeTrade() -> Bool {
        var _check = false
        guard let client = mSwiftSocket  else {
            LogFile.instance.InsertLog(LOG_CONNECT_FAIL_SOCKET_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return false
        }
        
        switch client.connect(timeout: 5) {
        case .success:
  
            let ack:[UInt8] = [Command.ACK]
            _check = TcpSend(Data: Data(ack), Client: client)
            break
        case .failure(let error):
            debugPrint("SwiftSocket Connect Error : ", error)
            LogFile.instance.InsertLog(LOG_CONNECT_FAIL_TIMEOUT_FAIL + error.localizedDescription, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return false
        }

        if !_check {
            LogFile.instance.InsertLog(LOG_CONNECT_FAIL_SEND_ACK_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return _check
        }
        
        let recv:[UInt8] = TcpRead(Client: client)
        if recv.count == 0 {
            LogFile.instance.InsertLog(LOG_CONNECT_FAIL_RECEIVE_ACK_FAIL_1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return false
        }
        
        if recv[0] == Command.ACK {
            return true
        }

        LogFile.instance.InsertLog(LOG_CONNECT_FAIL_RECEIVE_ACK_FAIL_2, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        return false
    }
    
    func TcpSend(Data _data:Data, Client _client:TCPClient) -> Bool{

        LogFile.instance.InsertLog(LOG_SEND_DATA + Utils.UInt8ArrayToHexCode(_value: [UInt8](_data), _option: true), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        switch _client.send(data: _data) {
        case .success:
            debugPrint("CAT Send Success -> ", Utils.UInt8ArrayToHexCode(_value: [UInt8](_data), _option: true))

            return true
        case .failure(let error):
            debugPrint("Swift Socket Data Send Error : ", error)
            LogFile.instance.InsertLog(LOG_SEND_DATA_FAIL + error.localizedDescription, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return false
        }
    }
    
    func TcpRead(Client _client:TCPClient, Timeout _time:Int = 10) -> [UInt8] {
        guard let response = _client.read(1024*10, timeout: _time) else {
            LogFile.instance.InsertLog(LOG_RECEIVE_DATA_FAIL + "데이터 없음", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            return []
        }

        debugPrint("CAT Read Success -> ", Utils.UInt8ArrayToHexCode(_value: response, _option: true))
        LogFile.instance.InsertLog(LOG_RECEIVE_DATA_SUCCESS + Utils.UInt8ArrayToHexCode(_value: response, _option: true), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        return response
    }
    
    /// CAT 신용 결제
    /// - Parameters:
    ///   - _tid: <#_tid description#>
    ///   - _money: <#_money description#>
    ///   - _tax: <#_tax description#>
    ///   - _svc: <#_svc description#>
    ///   - _txf: <#_txf description#>
    ///   - _AuDate: <#_AuDate description#>
    ///   - _AuNo: <#_AuNo description#>
    ///   - _UniqueNumber: <#_UniqueNumber description#>
    ///   - _InstallMent: <#_InstallMent description#>
    ///   - _Cancel: <#_Cancel description#>
    ///   - _MchData: <#_MchData description#>
    ///   - _ExtraFiled: <#_ExtraFiled description#>
    ///   - Result: <#Result description#>
    /// - Returns: <#description#>
    func PayCredit(TID _tid:String,거래금액 _money:String, 세금 _tax:String,봉사료 _svc:String,비과세 _txf:String,원거래일자 _AuDate:String, 원승인번호 _AuNo:String, 코세스거래고유번호 _UniqueNumber:String, 할부 _InstallMent:String, 취소 _Cancel:Bool,가맹점데이터 _MchData:String, 여유필드 _ExtraFiled:String, StoreName _storeName:String, StoreAddr _storeAddr:String, StoreNumber _storeNumber:String, StorePhone _storePhone:String, StoreOwner _storeOwner:String, CompletionCallback Result:CatResultDelegate) {
        Clear()
        CatSdk.instance.catlistener = Result
        CatSdk.instance.Tid = _tid
        CatSdk.instance.mStoreName = _storeName
        CatSdk.instance.mStoreAddr = _storeAddr
        CatSdk.instance.mStoreNumber = _storeNumber
        CatSdk.instance.mStorePhone = _storePhone
        CatSdk.instance.mStoreOwner = _storeOwner
        if _Cancel {
            CatSdk.instance.Money = String(Int(Int(_money)! + Int(_tax)! + Int(_svc)! + Int(_txf)!))
            CatSdk.instance.Tax = "0"
            CatSdk.instance.Svc = "0"
            CatSdk.instance.Txf = "0"
        } else {
            CatSdk.instance.Money = _money
            CatSdk.instance.Tax = _tax
            CatSdk.instance.Svc = _svc
            CatSdk.instance.Txf = _txf
        }
        
        var _audate = _AuDate
        if _audate.count > 5 && String(_audate.prefix(2)) != "20" {
            _audate = "20" + _audate
        }
        if _audate.count > 8 {
            _audate = String(_audate.prefix(8))
        }
        CatSdk.instance.AuDate = _audate
        CatSdk.instance.AuNo = _AuNo
        CatSdk.instance.UniqueNumber = _UniqueNumber
        CatSdk.instance.InstallMent = _InstallMent
        CatSdk.instance.Cancel = _Cancel
        CatSdk.instance.MchData = _MchData
        CatSdk.instance.ExtraField = _ExtraFiled
        if String(describing: Result).contains("AppToApp") {
            CatSdk.instance.mDBAppToApp = true
            /** log : PayCredit */
            LogFile.instance.InsertLog("<APPTOAPP> App -> CAT(신용결제)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
        } else  {
            CatSdk.instance.mDBAppToApp = false
            /** log : PayCredit */
            LogFile.instance.InsertLog("<KocesICIOS> App -> CAT(신용결제)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
        }


        DispatchQueue.main.async {
            Utils.CatAnimationViewInit(Message: "단말기에서 카드를 읽어주세요", Listener: CatSdk.instance.catlistener!)
        }

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) { [self] in
            
            if ConnectServer() == false {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 IP/PORT 설정이 잘못되었습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            if CheckBeforeTrade() == false {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 연결에 실패했습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            let SendData:[UInt8] = Command.Cat_Credit(TID: _tid, 거래금액: CatSdk.instance.Money, 세금: CatSdk.instance.Tax, 봉사료: CatSdk.instance.Svc, 비과세: CatSdk.instance.Txf, 원거래일자: CatSdk.instance.AuDate, 원승인번호: _AuNo, 코세스거래고유번호: _UniqueNumber, 할부: _InstallMent, 취소: _Cancel, 가맹점데이터: _MchData, 여유필드: _ExtraFiled)

            if !TcpSend(Data: Data(SendData), Client: mSwiftSocket!) {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(전문) 전송에 실패했습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }

            var recv:[UInt8] = TcpRead(Client: mSwiftSocket!)

            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
             
                return
            }
            
            if recv[0] != Command.ACK
            {
                LogFile.instance.InsertLog(LOG_RECEIVE_ACK_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(ACK) 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                
                return
            }

            recv = TcpRead(Client: mSwiftSocket!, Timeout: 60)
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }
            var str1 = Utils.UInt8ArrayToStr(UInt8Array: recv)
            if str1.contains("A110") {
                
                LogFile.instance.InsertLog(LOG_RECEIVE_A110 + str1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
                if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
                debugPrint("1st A110 수신후 애크2개 보냄)")
            } else if recv[1] == 0x44 { //D
                debugPrint("dcc trade")
                LogFile.instance.InsertLog(LOG_RECEIVE_D + "IC 우선 거래", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                Utils.CatAnimationViewInit(Message: "단말기에서 카드를 읽어주세요", Listener: CatSdk.instance.catlistener!)
                CreditFallBack()
                return
            } else if recv[1] == 0x46 { //F
                debugPrint("fallback trade")
                LogFile.instance.InsertLog(LOG_RECEIVE_F + "폴백 거래", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                Utils.CatAnimationViewInit(Message: "단말기에서 MSR을 읽어주세요", Listener: CatSdk.instance.catlistener!)
                CreditFallBack()
                return
            } else if recv[1] == 0x51 { //Q
                LogFile.instance.InsertLog(LOG_RECEIVE_Q + "가맹점TID 불일치", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                DisConnectServer()
                debugPrint("복수가맹점TID 불일치")
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "거래 가능한 TID 가 아닙니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
            
                return
            }  else if recv[1] == 0x45 { //E
                LogFile.instance.InsertLog(LOG_RECEIVE_E + "거래 취소", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                DisConnectServer()
                debugPrint("거래 취소")
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 거래 취소"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
            
                return
            } else {
                LogFile.instance.InsertLog(LOG_RECEIVE_UNKNOWN + "거래 실패", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
//                Cat_SendCancelCommandE()
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 거래에 실패했습니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
          
                return
            }
            
            recv = TcpRead(Client: mSwiftSocket!)
            
            /** log : PayCredit */
            LogFile.instance.InsertLog("CAT -> App(신용결제)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            if recv[1] == 0x47 {
                LogFile.instance.InsertLog(LOG_RECEIVE_G, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                debugPrint("result complete")
                var responseData = recv
                responseData.removeFirst()  //stx
                var range = 0...3
                let stringcomand = [UInt8](responseData[range])
                responseData.removeSubrange(range)
                range = 0...91
                responseData.removeSubrange(range)
                range = 0...3
                let resCode = [UInt8](responseData[range])
                responseData.removeSubrange(range)
                range = 0...39
                let msg = [UInt8](responseData[range])
                responseData.removeSubrange(range)

                let finish:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                if !TcpSend(Data: Data(finish), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }

            } else if recv[1] == Command.NAK {
                debugPrint("result nak")
                LogFile.instance.InsertLog(LOG_RECEIVE_NAK, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                //Nak 올라오면 재전송1회 시도
                let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
                if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
                recv = TcpRead(Client: mSwiftSocket!)
                if recv.count == 0 {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                  
                    return
                }
                if recv[1] == 0x47 {
                    LogFile.instance.InsertLog(LOG_RECEIVE_G, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                    var responseData = recv
                    responseData.removeFirst()  //stx
                    var range = 0...3
                    let stringcomand = [UInt8](responseData[range])
                    responseData.removeSubrange(range)
                    range = 0...91
                    responseData.removeSubrange(range)
                    range = 0...3
                    let resCode = [UInt8](responseData[range])
                    responseData.removeSubrange(range)
                    range = 0...39
                    let msg = [UInt8](responseData[range])
                    responseData.removeSubrange(range)

                    let _:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                    if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                        DisConnectServer()
                        var resDataDic:[String:String] = [:]
                        resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                        CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                        return
                    }
                }
            }
            
            let recvEOT:[UInt8] = TcpRead(Client: mSwiftSocket!)
            
            if recvEOT.count == 0 {
                LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }
            
            if recvEOT[0] != Command.EOT
            {
                LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_2, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(EOT) 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                
                return
            }
            
            LogFile.instance.InsertLog(LOG_RECEIVE_EOT_SUCCESS, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            
            var responseData = recv
            responseData.removeFirst()  //stx
            var range = 0...3
            let stringcomand = [UInt8](responseData[range])
            responseData.removeSubrange(range)
            range = 0...91
            responseData.removeSubrange(range)
            range = 0...3
            let resCode = [UInt8](responseData[range])
            responseData.removeSubrange(range)
            range = 0...39
            let msg = [UInt8](responseData[range])
            responseData.removeSubrange(range)
//            let finish:[UInt8] = Command.Cat_ResponseTrade(Command: Command.CMD_CAT_CREDIT_RES, Code: resCode, Message: msg)
            if Utils.utf8toHangul(str: resCode) != "0000" {
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = Utils.utf8toHangul(str: msg)
                resDataDic["AnsCode"] = Utils.utf8toHangul(str: resCode)
                
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_CODE_SUCCESS + Utils.utf8toHangul(str: resCode), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_MESSAGE_SUCCESS + Utils.utf8toHangul(str: msg), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            
            guard let pData = ParsingresData(수신데이터: recv) else {
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_PARSING_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "데이터 파싱에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            //만일 apptoapp 이면 여기서 db 저장으로 가지 않고 델리게이트로 보낸다. 본앱이면 db로 간다
//            if apptoapp == true {
//                InsertDBTradeData_TypeCrdit(수신데이터: pData)
//            } else {
//                Result.onResult(CatState: 0, ResultData: recv)
//            }
            InsertDBTradeData_TypeCrdit(수신데이터: pData)
        }
    }
    
    func CreditFallBack() {
        DispatchQueue.global(qos: .background).async() { [self] in
            var recv = TcpRead(Client: mSwiftSocket!, Timeout: 60)
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            let str1 = Utils.UInt8ArrayToStr(UInt8Array: recv)
            if str1.contains("A110") {
                
                LogFile.instance.InsertLog(LOG_RECEIVE_A110 + str1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
                if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
                debugPrint("fallback A110 수신후 애크2개 보냄)")
            } else if recv[1] == 0x51 { //Q
                LogFile.instance.InsertLog(LOG_RECEIVE_Q + "가맹점TID 불일치", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                debugPrint("복수가맹점TID 불일치")
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "거래 가능한 TID 가 아닙니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }  else if recv[1] == 0x45 { //E
                LogFile.instance.InsertLog(LOG_RECEIVE_E + "거래 취소", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                debugPrint("거래 취소")
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 거래 취소"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
            
                return
            } else {
                LogFile.instance.InsertLog(LOG_RECEIVE_UNKNOWN + "거래 실패", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
//                Cat_SendCancelCommandE()
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 거래에 실패했습니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
          
                return
            }
            
            recv = TcpRead(Client: mSwiftSocket!)
            /** log : PayCredit */
            LogFile.instance.InsertLog("CAT -> App(Fallback신용결제)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
            

            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                
                return
            }
            if recv[1] == 0x47 {
                LogFile.instance.InsertLog(LOG_RECEIVE_G, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                debugPrint("result complete")
                var responseData = recv
                responseData.removeFirst()  //stx
                var range = 0...3
                let stringcomand = [UInt8](responseData[range])
                responseData.removeSubrange(range)
                range = 0...91
                responseData.removeSubrange(range)
                range = 0...3
                let resCode = [UInt8](responseData[range])
                responseData.removeSubrange(range)
                range = 0...39
                let msg = [UInt8](responseData[range])
                responseData.removeSubrange(range)

                let finish:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                if !TcpSend(Data: Data(finish), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }

            } else if recv[1] == Command.NAK {
                debugPrint("result nak")
                LogFile.instance.InsertLog(LOG_RECEIVE_NAK, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                //Nak 올라오면 재전송1회 시도
                let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
                if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
                recv = TcpRead(Client: mSwiftSocket!)
                if recv.count == 0 {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                   
                    return
                }
                if recv[1] == 0x47 {
                    LogFile.instance.InsertLog(LOG_RECEIVE_G, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                    var responseData = recv
                    responseData.removeFirst()  //stx
                    var range = 0...3
                    let stringcomand = [UInt8](responseData[range])
                    responseData.removeSubrange(range)
                    range = 0...91
                    responseData.removeSubrange(range)
                    range = 0...3
                    let resCode = [UInt8](responseData[range])
                    responseData.removeSubrange(range)
                    range = 0...39
                    let msg = [UInt8](responseData[range])
                    responseData.removeSubrange(range)

                    let _:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                    if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                        DisConnectServer()
                        var resDataDic:[String:String] = [:]
                        resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                        CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                        return
                    }
                }
            }
            
            let recvEOT:[UInt8] = TcpRead(Client: mSwiftSocket!)
            
            if recvEOT.count == 0 {
                LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
             
                return
            }
            
            if recvEOT[0] != Command.EOT
            {
                LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_2, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(EOT) 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
            
                return
            }
            
            LogFile.instance.InsertLog(LOG_RECEIVE_EOT_SUCCESS, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            
            var responseData = recv
            responseData.removeFirst()  //stx
            var range = 0...3
            let stringcomand = [UInt8](responseData[range])
            responseData.removeSubrange(range)
            range = 0...91
            responseData.removeSubrange(range)
            range = 0...3
            let resCode = [UInt8](responseData[range])
            responseData.removeSubrange(range)
            range = 0...39
            let msg = [UInt8](responseData[range])
            responseData.removeSubrange(range)
//            let finish:[UInt8] = Command.Cat_ResponseTrade(Command: Command.CMD_CAT_CREDIT_RES, Code: resCode, Message: msg)
            if Utils.utf8toHangul(str: resCode) != "0000" {
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = Utils.utf8toHangul(str: msg)
                resDataDic["AnsCode"] = Utils.utf8toHangul(str: resCode)
                
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_CODE_SUCCESS + Utils.utf8toHangul(str: resCode), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_MESSAGE_SUCCESS + Utils.utf8toHangul(str: msg), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)

                DisConnectServer()
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            
            guard let pData = ParsingresData(수신데이터: recv) else {
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_PARSING_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "데이터 파싱에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            //만일 apptoapp 이면 여기서 db 저장으로 가지 않고 델리게이트로 보낸다. 본앱이면 db로 간다
//            if apptoapp == true {
//                InsertDBTradeData_TypeCrdit(수신데이터: pData)
//            } else {
//                Result.onResult(CatState: 0, ResultData: recv)
//            }
            InsertDBTradeData_TypeCrdit(수신데이터: pData)
            return
        }
    }
 
    
    func CashIC(업무구분 _Class:define.CashICBusinessClassification, TID _tid:String,거래금액 _money:String,세금 _tax:String,봉사료 _svc:String,비과세 _txf:String,원거래일자 _AuDate:String,원승인번호 _AuNo:String,간소화거래여부 _directTrade:String,카드정보수록여부 _cardInfo:String,취소 _cancel:Bool,가맹점데이터 _mchData:String,여유필드 _extrafield:String, StoreName _storeName:String, StoreAddr _storeAddr:String, StoreNumber _storeNumber:String, StorePhone _storePhone:String, StoreOwner _storeOwner:String, CompletionCallback Result:CatResultDelegate) {
        Clear()
        CatSdk.instance.catlistener = Result
        CatSdk.instance.Tid = _tid
        CatSdk.instance.mStoreName = _storeName;
        CatSdk.instance.mStoreAddr = _storeAddr;
        CatSdk.instance.mStoreNumber = _storeNumber;
        CatSdk.instance.mStorePhone = _storePhone;
        CatSdk.instance.mStoreOwner = _storeOwner;
        
        if _cancel {
            CatSdk.instance.Money = String(Int(Int(_money)! + Int(_tax)! + Int(_svc)! + Int(_txf)!))
            CatSdk.instance.Tax = "0"
            CatSdk.instance.Svc = "0"
            CatSdk.instance.Txf = "0"
        } else {
            CatSdk.instance.Money = _money
            CatSdk.instance.Tax = _tax
            CatSdk.instance.Svc = _svc
            CatSdk.instance.Txf = _txf
        }
        var _audate = _AuDate
        if String(_audate.prefix(2)) == "20" {
            _audate.removeFirst(); _audate.removeFirst();
        }
        CatSdk.instance.AuDate = String(_audate.prefix(6))
        CatSdk.instance.AuNo = _AuNo
        CatSdk.instance.Class = _Class
        CatSdk.instance.DirectTrade = _directTrade
        CatSdk.instance.CardInfo = _cardInfo
        CatSdk.instance.Cancel = _cancel
        CatSdk.instance.MchData = _mchData
        CatSdk.instance.ExtraField = _extrafield
        
        /** log : CashIC */
        if String(describing: Result).contains("AppToApp") {
            CatSdk.instance.mDBAppToApp = true
            LogFile.instance.InsertLog("<APPTOAPP> App -> CAT(현금IC)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
        } else  {
            CatSdk.instance.mDBAppToApp = false
            LogFile.instance.InsertLog("<KocesICIOS> App -> CAT(현금IC)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
        }
        
        DispatchQueue.main.async {
            Utils.CatAnimationViewInit(Message: "단말기에서 카드를 읽어주세요", Listener: CatSdk.instance.catlistener!)
        }

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) { [self] in
            
            if ConnectServer() == false {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 IP/PORT 설정이 잘못되었습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            if CheckBeforeTrade() == false {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 연결에 실패했습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            
            let SendData:[UInt8] = Command.Cat_CashIC(업무구분: _Class, TID: _tid, 거래금액: CatSdk.instance.Money, 세금: CatSdk.instance.Tax, 봉사료: CatSdk.instance.Svc, 비과세: CatSdk.instance.Txf, 원거래일자: CatSdk.instance.AuDate, 원승인번호: _AuNo, 간소화거래여부: _directTrade, 카드정보수록여부: _cardInfo, 취소: _cancel, 가맹점데이터: _mchData, 여유필드: _extrafield)
            debugPrint(Utils.UInt8ArrayToHexCode(_value: SendData, _option: true))
            
            if !TcpSend(Data: Data(SendData), Client: mSwiftSocket!) {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(전문) 전송에 실패했습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }

            var recv:[UInt8] = TcpRead(Client: mSwiftSocket!)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }
            
            if recv[0] != Command.ACK
            {
                LogFile.instance.InsertLog(LOG_RECEIVE_ACK_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(ACK) 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            
            recv = TcpRead(Client: mSwiftSocket!, Timeout: 60)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }
            let str1 = Utils.UInt8ArrayToStr(UInt8Array: recv)
            if str1.contains("A110") {
                
                LogFile.instance.InsertLog(LOG_RECEIVE_A110 + str1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
                if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
                debugPrint("A110 수신후 애크2개 보냄)")
            } else if recv[1] == 0x51 { //Q
                debugPrint("복수가맹점TID 불일치")
                LogFile.instance.InsertLog(LOG_RECEIVE_Q + "가맹점TID 불일치", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "거래 가능한 TID 가 아닙니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                
                return
            }  else if recv[1] == 0x45 { //E
                LogFile.instance.InsertLog(LOG_RECEIVE_E + "거래 취소", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                debugPrint("거래 취소")
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 거래 취소"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
            
                return
            } else {
                LogFile.instance.InsertLog(LOG_RECEIVE_UNKNOWN + "거래 실패", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
//                Cat_SendCancelCommandE()
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 거래에 실패했습니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
          
                return
            }
            
            recv = TcpRead(Client: mSwiftSocket!)
            /** log : CashIC */
            LogFile.instance.InsertLog("CAT -> App(현금IC)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }
            if recv[1] == 0x47 {
                LogFile.instance.InsertLog(LOG_RECEIVE_G, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                var responseData = recv
                responseData.removeFirst()  //stx
                var range = 0...3
                let stringcomand = [UInt8](responseData[range])
                responseData.removeSubrange(range)
                range = 0...24
                responseData.removeSubrange(range)
                range = 0...3
                let resCode = [UInt8](responseData[range])
                responseData.removeSubrange(range)
                range = 0...39
                let msg = [UInt8](responseData[range])
                responseData.removeSubrange(range)

                let finish:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                if !TcpSend(Data: Data(finish), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
            } else if recv[1] == Command.NAK {
                LogFile.instance.InsertLog(LOG_RECEIVE_NAK, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                //Nak 올라오면 재전송1회 시도
                let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
                if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
                recv = TcpRead(Client: mSwiftSocket!)


                if recv.count == 0 {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                   
                    return
                }
                if recv[1] == 0x47 {
                    LogFile.instance.InsertLog(LOG_RECEIVE_G, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                    var responseData = recv
                    responseData.removeFirst()  //stx
                    var range = 0...3
                    let stringcomand = [UInt8](responseData[range])
                    responseData.removeSubrange(range)
                    range = 0...24
                    responseData.removeSubrange(range)
                    range = 0...3
                    let resCode = [UInt8](responseData[range])
                    responseData.removeSubrange(range)
                    range = 0...39
                    let msg = [UInt8](responseData[range])
                    responseData.removeSubrange(range)

                    let finish:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                    if !TcpSend(Data: Data(finish), Client: mSwiftSocket!) {
                        DisConnectServer()
                        var resDataDic:[String:String] = [:]
                        resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                        CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                        return
                    }
                }
            }
            
            let recvEOT:[UInt8] = TcpRead(Client: mSwiftSocket!)
            
            if recvEOT.count == 0 {
                LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }
            
            if recvEOT[0] != Command.EOT
            {
                LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_2, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(EOT) 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }
            
            LogFile.instance.InsertLog(LOG_RECEIVE_EOT_SUCCESS, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            
            var responseData = recv
            responseData.removeFirst()  //stx
            var range = 0...3
            let stringcomand = [UInt8](responseData[range])
            responseData.removeSubrange(range)
            range = 0...24
            responseData.removeSubrange(range)
            range = 0...3
            let resCode = [UInt8](responseData[range])
            responseData.removeSubrange(range)
            range = 0...39
            let msg = [UInt8](responseData[range])
            responseData.removeSubrange(range)
//            let finish:[UInt8] = Command.Cat_ResponseTrade(Command: Command.CMD_CAT_CASH_RES, Code: resCode, Message: msg)
            if Utils.utf8toHangul(str: resCode) != "0000" {
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = Utils.utf8toHangul(str: msg)
                resDataDic["AnsCode"] = Utils.utf8toHangul(str: resCode)
                
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_CODE_SUCCESS + Utils.utf8toHangul(str: resCode), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_MESSAGE_SUCCESS + Utils.utf8toHangul(str: msg), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)

                DisConnectServer()
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                
                return
            }
            
            guard let pData = ParsingresCashIC(수신데이터: recv) else {
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_PARSING_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "데이터 파싱에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            //만일 apptoapp 이면 여기서 db 저장으로 가지 않고 델리게이트로 보낸다. 본앱이면 db로 간다
//            if apptoapp == true {
//                InsertDBTradeData_TypeCrdit(수신데이터: pData)
//            } else {
//                Result.onResult(CatState: 0, ResultData: recv)
//            }
            InsertDBTradeData_TypeCashIC(수신데이터: pData)
            return
        }
    }
    
    func CashRecipt(TID _tid:String,거래금액 _money:String, 세금 _tax:String,봉사료 _svc:String,비과세 _txf:String,원거래일자 _AuDate:String, 원승인번호 _AuNo:String, 코세스거래고유번호 _UniqueNumber:String, 할부 _InstallMent:String,고객번호 _id:String,개인법인구분 _pb:String, 취소 _Cancel:Bool,최소사유 _CancelReason:String , 가맹점데이터 _MchData:String, 여유필드 _ExtraFiled:String, StoreName _storeName:String, StoreAddr _storeAddr:String, StoreNumber _storeNumber:String, StorePhone _storePhone:String, StoreOwner _storeOwner:String, CompletionCallback Result:CatResultDelegate) {
        Clear()
        CatSdk.instance.catlistener = Result
        CatSdk.instance.Tid = _tid
        CatSdk.instance.mStoreName = _storeName;
        CatSdk.instance.mStoreAddr = _storeAddr;
        CatSdk.instance.mStoreNumber = _storeNumber;
        CatSdk.instance.mStorePhone = _storePhone;
        CatSdk.instance.mStoreOwner = _storeOwner;

        if _Cancel {
            CatSdk.instance.Money = String(Int(Int(_money)! + Int(_tax)! + Int(_svc)! + Int(_txf)!))
            CatSdk.instance.Tax = "0"
            CatSdk.instance.Svc = "0"
            CatSdk.instance.Txf = "0"
        } else {
            CatSdk.instance.Money = _money
            CatSdk.instance.Tax = _tax
            CatSdk.instance.Svc = _svc
            CatSdk.instance.Txf = _txf
        }
        var _audate = _AuDate
        if _audate.count > 5 && String(_audate.prefix(2)) != "20" {
            _audate = "20" + _audate
        }
        if _audate.count > 8 {
            _audate = String(_audate.prefix(8))
        }
        CatSdk.instance.AuDate = _audate
        CatSdk.instance.AuNo = _AuNo
        CatSdk.instance.UniqueNumber = _UniqueNumber
        CatSdk.instance.InstallMent = _InstallMent
        CatSdk.instance.Cancel = _Cancel
        CatSdk.instance.MchData = _MchData
        CatSdk.instance.ExtraField = _ExtraFiled
        CatSdk.instance.pb = _pb
        CatSdk.instance.CancelReason = _CancelReason
        
        /** log : CashRecipt */
        if String(describing: Result).contains("AppToApp") {
            CatSdk.instance.mDBAppToApp = true
            LogFile.instance.InsertLog("<APPTOAPP> App -> CAT(현금IC)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
        } else  {
            CatSdk.instance.mDBAppToApp = false
            LogFile.instance.InsertLog("<KocesICIOS> App -> CAT(현금IC)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
        }

        DispatchQueue.main.async {
            Utils.CatAnimationViewInit(Message: "단말기에서 MSR을 읽어주세요", Listener: CatSdk.instance.catlistener!)
        }

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) { [self] in
            if ConnectServer() == false {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 IP/PORT 설정이 잘못되었습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            if CheckBeforeTrade() == false {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 연결에 실패했습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }

            let SendData:[UInt8] = Command.Cat_CashRecipt(TID: _tid, 거래금액: CatSdk.instance.Money, 세금: CatSdk.instance.Tax, 봉사료: CatSdk.instance.Svc, 비과세: CatSdk.instance.Txf, 원거래일자: CatSdk.instance.AuDate, 원승인번호: _AuNo, 코세스거래고유번호: _UniqueNumber, 할부: _InstallMent, 고객번호: _id, 개인법인구분: _pb, 취소: _Cancel, 취소사유: _CancelReason, 가맹점데이터: _MchData, 여유필드: _ExtraFiled)
            debugPrint(Utils.UInt8ArrayToHexCode(_value: SendData, _option: true))
            
            if !TcpSend(Data: Data(SendData), Client: mSwiftSocket!){
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(전문) 전송에 실패했습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }

            var recv:[UInt8] = TcpRead(Client: mSwiftSocket!)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            
            if recv[0] != Command.ACK
            {
                LogFile.instance.InsertLog(LOG_RECEIVE_ACK_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(ACK) 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                
                return
            }
            
            recv = TcpRead(Client: mSwiftSocket!, Timeout: 60)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            let str1 = Utils.UInt8ArrayToStr(UInt8Array: recv)
            if str1.contains("A110") {
                LogFile.instance.InsertLog(LOG_RECEIVE_A110 + str1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
                if !TcpSend(Data: Data(ack), Client: mSwiftSocket!){
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
                debugPrint("A110 수신후 애크2개 보냄)")
            } else if recv[1] == 0x51 { //Q
                debugPrint("복수가맹점TID 불일치")
                LogFile.instance.InsertLog(LOG_RECEIVE_Q + "가맹점TID 불일치", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "거래 가능한 TID 가 아닙니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }  else if recv[1] == 0x45 { //E
                LogFile.instance.InsertLog(LOG_RECEIVE_E + "거래 취소", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                debugPrint("거래 취소")
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 거래 취소"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
            
                return
            } else {
                LogFile.instance.InsertLog(LOG_RECEIVE_UNKNOWN + "거래 실패", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
//                Cat_SendCancelCommandE()
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 거래에 실패했습니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
          
                return
            }
            
            recv = TcpRead(Client: mSwiftSocket!)
            /** log : CashRecipt */
            LogFile.instance.InsertLog("CAT -> App(현금영수증)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }
            if recv[1] == 0x47 {
                LogFile.instance.InsertLog(LOG_RECEIVE_G, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                var responseData = recv
                responseData.removeFirst()  //stx
                var range = 0...3
                let stringcomand = [UInt8](responseData[range])
                responseData.removeSubrange(range)
                range = 0...91
                responseData.removeSubrange(range)
                range = 0...3
                let resCode = [UInt8](responseData[range])
                responseData.removeSubrange(range)
                range = 0...39
                let msg = [UInt8](responseData[range])
                responseData.removeSubrange(range)

                let finish:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                if !TcpSend(Data: Data(finish), Client: mSwiftSocket!){
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
            } else if recv[1] == Command.NAK {
                LogFile.instance.InsertLog(LOG_RECEIVE_NAK, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                //Nak 올라오면 재전송1회 시도
                let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
                if !TcpSend(Data: Data(ack), Client: mSwiftSocket!){
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
                recv = TcpRead(Client: mSwiftSocket!)
                
                if recv.count == 0 {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                 
                    return
                }
                if recv[1] == 0x47 {
                    LogFile.instance.InsertLog(LOG_RECEIVE_G, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                    
                    var responseData = recv
                    responseData.removeFirst()  //stx
                    var range = 0...3
                    let stringcomand = [UInt8](responseData[range])
                    responseData.removeSubrange(range)
                    range = 0...91
                    responseData.removeSubrange(range)
                    range = 0...3
                    let resCode = [UInt8](responseData[range])
                    responseData.removeSubrange(range)
                    range = 0...39
                    let msg = [UInt8](responseData[range])
                    responseData.removeSubrange(range)

                    let finish:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                    if !TcpSend(Data: Data(finish), Client: mSwiftSocket!){
                        DisConnectServer()
                        var resDataDic:[String:String] = [:]
                        resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                        CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                        return
                    }
                }
            }
            
            let recvEOT:[UInt8] = TcpRead(Client: mSwiftSocket!)
            
            if recvEOT.count == 0 {
                LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
            
                return
            }
            
            if recvEOT[0] != Command.EOT
            {
                LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_2, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(EOT) 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }
            
            LogFile.instance.InsertLog(LOG_RECEIVE_EOT_SUCCESS, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            
            var responseData = recv
            responseData.removeFirst()  //stx
            var range = 0...3
            let stringcomand = [UInt8](responseData[range])
            responseData.removeSubrange(range)
            range = 0...91
            responseData.removeSubrange(range)
            range = 0...3
            let resCode = [UInt8](responseData[range])
            responseData.removeSubrange(range)
            range = 0...39
            let msg = [UInt8](responseData[range])
            responseData.removeSubrange(range)
//            let finish:[UInt8] = Command.Cat_ResponseTrade(Command: Command.CMD_CAT_CASH_RES, Code: resCode, Message: msg)
            if Utils.utf8toHangul(str: resCode) != "0000" {
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = Utils.utf8toHangul(str: msg)
                resDataDic["AnsCode"] = Utils.utf8toHangul(str: resCode)
                
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_CODE_SUCCESS + Utils.utf8toHangul(str: resCode), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_MESSAGE_SUCCESS + Utils.utf8toHangul(str: msg), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)

                DisConnectServer()
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                
                return
            }
            
            guard let pData = ParsingresData(수신데이터: recv) else {
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_PARSING_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "데이터 파싱에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
           
                return
            }
            //만일 apptoapp 이면 여기서 db 저장으로 가지 않고 델리게이트로 보낸다. 본앱이면 db로 간다
//            if apptoapp == true {
//                InsertDBTradeData_TypeCash(수신데이터: pData)
//            } else {
//                Result.onResult(CatState: 0, ResultData: recv)
//            }
            InsertDBTradeData_TypeCrdit(수신데이터: pData)
            return
        }
    }

    func EasyRecipt(TrdType _trdType:String,TID _tid:String,Qr _qr:String,거래금액 _money:String, 세금 _tax:String,봉사료 _svc:String,비과세 _txf:String,EasyKind _easyKind:String,원거래일자 _AuDate:String, 원승인번호 _AuNo:String, 서브승인번호 _subAuNo:String,할부 _InstallMent:String, 가맹점데이터 _MchData:String, 호스트가맹점데이터 _hostMchData:String,코세스거래고유번호 _UniqueNumber:String, StoreName _storeName:String, StoreAddr _storeAddr:String, StoreNumber _storeNumber:String, StorePhone _storePhone:String, StoreOwner _storeOwner:String, CompletionCallback Result:CatResultDelegate) {
        Clear()
        CatSdk.instance.catlistener = Result
        CatSdk.instance.TrdType = _trdType;
        CatSdk.instance.QrBarcode = _qr;
        if(_trdType == "A10" || _trdType == "E10")
        {
            CatSdk.instance.TrdType = "A10";
        }
        else if(_trdType == "A20" || _trdType == "E20")
        {
            CatSdk.instance.TrdType = "A20";
        }
        else
        {
            CatSdk.instance.TrdType = "Z30";
        }
        
        CatSdk.instance.Tid = _tid
        if (_trdType == "A20" || _trdType == "E20") {
            CatSdk.instance.Money = String(Int(Int(_money)! + Int(_tax)! + Int(_svc)! + Int(_txf)!))
            CatSdk.instance.Tax = "0"
            CatSdk.instance.Svc = "0"
            CatSdk.instance.Txf = "0"
            CatSdk.instance.Cancel = true;
        } else {
            CatSdk.instance.Money = _money
            CatSdk.instance.Tax = _tax
            CatSdk.instance.Svc = _svc
            CatSdk.instance.Txf = _txf
            CatSdk.instance.Cancel = false
        }
        
        if _easyKind == "" {
            if _qr != "" {
                CatSdk.instance.EasyKind = Scan_Data_Parser(Scan: _qr)
            }
           
        } else {
            CatSdk.instance.EasyKind = _easyKind
        }
        var _audate = _AuDate
        if _audate.count >= 8 && String(_audate.prefix(2)) == "20" {
            _audate.removeFirst();_audate.removeFirst();
            _audate = String(_audate.prefix(6))
        }
        if _audate.count >= 6 {
            _audate = String(_audate.prefix(6))
        }
        CatSdk.instance.AuDate = _audate
        CatSdk.instance.AuNo = _AuNo
        CatSdk.instance.SubAuNo = _subAuNo;
        CatSdk.instance.InstallMent = _InstallMent
        CatSdk.instance.MchData = _MchData
        CatSdk.instance.HostMchData = _hostMchData;
        CatSdk.instance.UniqueNumber = _UniqueNumber
        
        CatSdk.instance.mStoreName = _storeName;
        CatSdk.instance.mStoreAddr = _storeAddr;
        CatSdk.instance.mStoreNumber = _storeNumber;
        CatSdk.instance.mStorePhone = _storePhone;
        CatSdk.instance.mStoreOwner = _storeOwner;

//        CatSdk.instance.AppCard = Utils.rightPad(str: _AppCard, fillChar: " ", length: 40)
        if String(describing: Result).contains("AppToApp") {
            CatSdk.instance.mDBAppToApp = true
        } else  {
            CatSdk.instance.mDBAppToApp = false
        }
        
        //만일 바코드번호가 있는경우 스캐너를 열지 않고 해당 값으로 비교한다
        if _qr != "" {
            Res_Scanner(Result: true, Message: "", Scanner: _qr)
            return
        }
        
        
        if Setting.shared.getDefaultUserData(_key: define.QR_CAT_CAMERA) == "1" {
            if TrdType != "A20" {
                CatSdk.instance.EasyKind = "UN"
            }
            Res_Scanner(Result: true, Message: "", Scanner: "")
            return
        }
        
        if CatSdk.instance.EasyKind == "ZP" && CatSdk.instance.TrdType == "A20" {
            Res_Scanner(Result: true, Message: "", Scanner: "")
            return
        }
        
        //거래고유키 취소인 경우
        if CatSdk.instance.TrdType == "A20" && CatSdk.instance.UniqueNumber != ""{
            Res_Scanner(Result: true, Message: "", Scanner: "")
            return
        }
        
        Utils.ScannerOpen(Sdk: "CAT")
        return
    }
    
    /**
     스캐너 결과값
     */
    func Res_Scanner(Result _result:Bool, Message _msg:String, Scanner _scanner:String)
    {
        DispatchQueue.global(qos: .background).async { [self] in
            if _result != true {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = _msg
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            
            if _scanner != "" {
                CatSdk.instance.EasyKind = Scan_Data_Parser(Scan: _scanner)
            }
            
            if CatSdk.instance.EasyKind == "" {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "해당 BARCODE/QR 은 지원하지 않는 번호입니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            if ConnectServer() == false {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 IP/PORT 설정이 잘못되었습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            if CheckBeforeTrade() == false {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 연결에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            
            /** log : EasyRecipt */
            LogFile.instance.InsertLog("App -> CAT(간편결제)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)

            
            DispatchQueue.main.async {
                Utils.CatAnimationViewInit(Message: "CAT단말기에 거래 요청 중 입니다.", Listener: CatSdk.instance.catlistener!)
            }
            
            CatSdk.instance.QrBarcode = _scanner
//            CatSdk.instance.AppCard = Utils.rightPad(str: _scanner, fillChar: " ", length: 40)

            let SendData:[UInt8] = Command.Cat_CreditAppCard(TrdType: CatSdk.instance.TrdType, TID: CatSdk.instance.Tid, Qr: CatSdk.instance.QrBarcode, 거래금액: CatSdk.instance.Money, 세금: CatSdk.instance.Tax, 봉사료: CatSdk.instance.Svc, 비과세: CatSdk.instance.Txf, EasyKind: CatSdk.instance.EasyKind, 원거래일자: CatSdk.instance.AuDate, 원승인번호: CatSdk.instance.AuNo, 서브승인번호: CatSdk.instance.SubAuNo, 할부: CatSdk.instance.InstallMent, 가맹점데이터: CatSdk.instance.MchData, 호스트가맹점데이터: CatSdk.instance.HostMchData, 코세스거래고유번호: CatSdk.instance.UniqueNumber)

            debugPrint(Utils.UInt8ArrayToHexCode(_value: SendData, _option: true))
  
            if !TcpSend(Data: Data(SendData), Client: mSwiftSocket!) {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(전문) 전송에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            
    //        var recv = recvData()
            var recv:[UInt8] = TcpRead(Client: mSwiftSocket!)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
             
                return
            }
            
            if recv[0] != Command.ACK
            {
                LogFile.instance.InsertLog(LOG_RECEIVE_ACK_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(ACK) 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
             
                return
            }
            
            recv = TcpRead(Client: mSwiftSocket!, Timeout: 60)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                
                return
            }
            let str1 = Utils.UInt8ArrayToStr(UInt8Array: recv)
            if str1.contains("A110") {
                LogFile.instance.InsertLog(LOG_RECEIVE_A110 + str1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
                if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
                debugPrint("A110 수신후 애크2개 보냄)")
            } else if recv[1] == 0x51 { //Q
                debugPrint("복수가맹점TID 불일치")
                LogFile.instance.InsertLog(LOG_RECEIVE_Q + "가맹점TID 불일치", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "거래 가능한 TID 가 아닙니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }  else if recv[1] == 0x45 { //E
                LogFile.instance.InsertLog(LOG_RECEIVE_E + "거래 취소", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                debugPrint("거래 취소")
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 거래 취소"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
            
                return
            } else {
                LogFile.instance.InsertLog(LOG_RECEIVE_UNKNOWN + "거래 실패", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
//                Cat_SendCancelCommandE()
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 거래에 실패했습니다"
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
          
                return
            }
            
            recv = TcpRead(Client: mSwiftSocket!)
            
            LogFile.instance.InsertLog("CAT -> App(간편결제)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
        
                return
            }
            if recv[1] == 0x54 {
                var responseData = recv
                responseData.removeFirst()  //stx
                var range = 0...3
                let stringcomand = [UInt8](responseData[range])
                debugPrint("Command -> ", Utils.utf8toHangul(str: stringcomand))
                responseData.removeSubrange(range)
                range = 0...91
                responseData.removeSubrange(range)
                range = 0...3
                let resCode = [UInt8](responseData[range])
                debugPrint("AnsCode -> ", Utils.utf8toHangul(str: resCode))
                responseData.removeSubrange(range)
                range = 0...39
                let msg = [UInt8](responseData[range])
                debugPrint("msg -> ", Utils.utf8toHangul(str: msg))
                responseData.removeSubrange(range)

                let finish:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: Utils.utf8toHangul(str: stringcomand)), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                debugPrint(Utils.UInt8ArrayToHexCode(_value: finish, _option: true))
                if !TcpSend(Data: Data(finish), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
            } else if recv[1] == Command.NAK {
                LogFile.instance.InsertLog(LOG_RECEIVE_NAK, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                //Nak 올라오면 재전송1회 시도
                let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
                if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
                recv = TcpRead(Client: mSwiftSocket!)
                
                if recv.count == 0 {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                   
                    return
                }
                if recv[1] == 0x54 {
                    var responseData = recv
                    responseData.removeFirst()  //stx
                    var range = 0...3
                    let stringcomand = [UInt8](responseData[range])
                    responseData.removeSubrange(range)
                    range = 0...91
                    responseData.removeSubrange(range)
                    range = 0...3
                    let resCode = [UInt8](responseData[range])
                    responseData.removeSubrange(range)
                    range = 0...39
                    let msg = [UInt8](responseData[range])
                    responseData.removeSubrange(range)

                    let finish:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                    if !TcpSend(Data: Data(finish), Client: mSwiftSocket!) {
                        DisConnectServer()
                        var resDataDic:[String:String] = [:]
                        resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                        CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                        return
                    }
                }
            }
            
            let recvEOT:[UInt8] = TcpRead(Client: mSwiftSocket!)
            
            if recvEOT.count == 0 {
                LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
             
                return
            }
            
            if recvEOT[0] != Command.EOT
            {
                LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_2, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(EOT) 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
              
                return
            }
            
            LogFile.instance.InsertLog(LOG_RECEIVE_EOT_SUCCESS, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            
            var responseData = recv
            responseData.removeFirst()  //stx
            var range = 0...3
            let stringcomand = [UInt8](responseData[range])
            debugPrint("Command -> ", Utils.utf8toHangul(str: stringcomand))
            responseData.removeSubrange(range)
            range = 0...3
            responseData.removeSubrange(range)  //길이
            
            var _all = ""
            _all = Utils.utf8toHangul(str: responseData)
            var res = _all.split(separator: ";", omittingEmptySubsequences: false)
            if res.isEmpty || res.count < 12 {
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "응답 데이터 이상"
                resDataDic["AnsCode"] = "9999"

                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_CODE_SUCCESS + "9999", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_MESSAGE_SUCCESS + "응답 데이터 이상", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            res[11].removeFirst();res[11].removeFirst();res[11].removeFirst();res[11].removeFirst();
            let resCode = String(res[11])
            debugPrint("AnsCode -> ", resCode)
            
            res[12].removeFirst();res[12].removeFirst();res[12].removeFirst();res[12].removeFirst();
            let msg = String(res[12])
            debugPrint("msg -> ", res[12])

            if resCode != "0000" {
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = msg
                resDataDic["AnsCode"] = resCode
                
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_CODE_SUCCESS + resCode, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_MESSAGE_SUCCESS + msg, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)

                DisConnectServer()
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            
            guard let pData = ParsingEasyresData(수신데이터: recv, 간편결제체크: true) else {
                LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_PARSING_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "데이터 파싱에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
               
                return
            }
            
//            if(pData["AuNo"] == nil || pData["AuNo"] == "")
//            {
//                DisConnectServer()
//                var resDataDic:[String:String] = [:]
//                resDataDic["AnsCode"] = pData["AnsCode"]
//                resDataDic["Message"] = pData["Message"]
//                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
//                return;
//            }
            
            InsertDBTradeData_TypeEasy(수신데이터: pData)
            return
        }
    }
    
    /**
     스캔한 데이터를 파싱해서 제로/카카오/emv 등을 구분한다
     */
    func Scan_Data_Parser(Scan _scan:String) -> String{
        var returnData = ""
        if _scan.prefix(7) == "hQVDUFY" {
            //EMV QR
            returnData = "AP"
        } else if _scan.prefix(6) == "281006" {
            //카카오페이
            returnData = "KP"
        } else if _scan.prefix(6) == "800088" {
            //제로페이 Barcode
            returnData = "ZP"
        } else if _scan.prefix(2) == "3-" {
            //제로페이 QRcode
            returnData = "ZP"
        } else {
            if (_scan.count == 20 && _scan.substring(시작: 16, 끝: 17) == "95") {
                if (_scan.prefix(2) == "10") {
                    // 페이코 쿠폰결제
                    returnData = "PC"
                } else if (_scan.prefix(2) == "20") {
                    //페이코 포인트결제
                    returnData = "PC"
                } else {
                    //페이코 신용결제
                    returnData = "PC"
                }
            } else if (_scan.count == 21 && _scan.substring(시작: 16, 끝: 17) == "95") {
                //페이코 신용결제
                returnData = "PC"
            }
            
            else if _scan.prefix(2) == "11" || _scan.prefix(2) == "12" ||
                        _scan.prefix(2) == "13" || _scan.prefix(2) == "14" ||
                        _scan.prefix(2) == "15" || _scan.prefix(2) == "10"  {
                //위쳇페이
                returnData = "WC"
            } else if _scan.prefix(2) == "25" || _scan.prefix(2) == "26" ||
                        _scan.prefix(2) == "27" || _scan.prefix(2) == "28" ||
                        _scan.prefix(2) == "29" || _scan.prefix(2) == "30" {
                //알리페이
                returnData = "AL"
            } else {
                if _scan.count == 21 {
                    //APP 카드
                    returnData = "AP"
                }
            }
        }
        
        return returnData
    }
    
    /**
     CAT 프린터
     */
    func Print(파싱할프린트내용 _Contents:String, CompletionCallback Result:CatResultDelegate) {
        catlistener = Result
        var cont:String = _Contents.replacingOccurrences(of: define.PFont_LF, with: "\n")
        cont = cont.replacingOccurrences(of: "___LF___", with: "\n")
        let StrArr = cont.split(separator: "\n")
        
        var UInt8Array:Array<[UInt8]> = Array()
        UInt8Array.append(define.Init)
        UInt8Array.append(define.Logo_Print)
        for n in StrArr {
            let n1 = Utils.ParserPrint(내용: String(n))

            var temp:[UInt8] = Utils.hangultoUint8(str: n1)

            temp.append(0x0A)
            
            UInt8Array.append(temp)
        }
        
        /** 해당 주석은 이미지 프린트 내용 */
//        let img = Bundle.main.url(forResource: "sign1", withExtension: "bmp")!
//        let imgData = try! Data(contentsOf: img)
//        let uiImg:UIImage = UIImage(data: imgData)!
//        let signUInt8Array:[UInt8] = Utils.pixelValues(fromCGImage: uiImg )!
//        var length: String = String(signUInt8Array.count)
//
//        UInt8Array.append([0x1D, 0x76, 0x30, 0x30])
//        UInt8Array.append([0x10, 0x00, 0x40, 0x00])
//        UInt8Array.append(signUInt8Array)
//        UInt8Array.append([0x1b, 0x64, 0x03])
//        UInt8Array.append(define.Cut_print)
//        UInt8Array.append([0x1b, 0x64, 0x03])
        /** 해당 주석은 이미지 프린트 내용 */
        
        var temp:[UInt8] = [0x0A,0x0A,0x0A,0x0A,0x0A]
        UInt8Array.append(temp)
        
        UInt8Array.append(define.Cut_print)
        
        var last:[UInt8] = Array()
        
        for n in UInt8Array{
            last += n
        }

        /** log  */
        LogFile.instance.InsertLog("App -> CAT(프린트)", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)


        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) { [self] in
            
            if ConnectPrintServer() == false {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 IP/PORT 설정이 잘못되었습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            if CheckBeforeTrade() == false {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 연결에 실패했습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }

            let SendData:[UInt8] = last
            debugPrint(Utils.UInt8ArrayToHexCode(_value: SendData, _option: true))
            
            if !TcpSend(Data: Data(SendData), Client: mSwiftSocket!){
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(전문) 전송에 실패했습니다."
                Result.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }

            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 프린트 전송이 완료되었습니다"
            DisConnectServer()
            CatSdk.instance.catlistener?.onResult(CatState: .OK, Result: resDataDic)
            return
        }
        
    }
    
    
    //정상적으로 데이터를 받아서 캣단말기에 수신완료메세지를 보낼 때, G120 G150 등에 따른 응답인 G125 G155 로 보내도록 추출
    func ResponseCommand(커맨드 _Command:String) -> String {
        var _cmd = ""
        switch _Command {
        case "G120":
            _cmd = "G125"
            break
        case "G130":
            _cmd = "G135"
            break
        case "G140":
            _cmd = "G145"
            break
        case "T180":
            _cmd = "T185";
            break
        case "G160":
            _cmd = "G165"
            break
        case "G170":
            _cmd = "G175"
            break
        default:
            break
        }
        
        return _cmd
    }
    
    func ParsingEasyresData(수신데이터 _recv:[UInt8], 간편결제체크 _easyCheck:Bool = false) -> Dictionary<String,String>?
    {
        var parseData:[UInt8] = _recv   //데이터를 지워 가면서 작업을 해야 해서 임시로 변수 하나 지정
        //본격적인 파싱 시작
        var data:[String:String] = [:]
        //데이터 사이즈 체크
        if _recv.count < 6 {
            return nil
        }
        //데이터 시작이 stx가 아니면 취소
        if _recv[0] != Command.STX {
            return nil
        }
        
        LogFile.instance.InsertLog("CAT 간편결제 데이터파싱", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
        
        parseData.remove(at: 0) //STX 삭제
        var rng = 4 //데이터를 짜르기 위한 범위
        parseData.removeSubrange(0..<rng) //명령코드 4byte
        parseData.removeSubrange(0..<rng) //길이 삭제
        
        var _all = ""
        _all = Utils.utf8toHangul(str: parseData)
        var splited = _all.split(separator: ";", omittingEmptySubsequences: false)
        splited[0].removeFirst();splited[0].removeFirst();splited[0].removeFirst();splited[0].removeFirst();
        var _type = String(splited[0])
        if(_type == "A15")
        {
            _type = "E15";
        }
        else if(_type == "A25")
        {
            _type = "E25";
        }
        else if(_type == "Z35")
        {
            _type = "E35";
        }
        data["TrdDate"] = Utils.getDate(format: "yyMMddHHmmss");
        data["TrdType"] = _type
        data["ResponseNo"] = _type
        LogFile.instance.InsertLog("TrdType : " + (data["TrdType"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        LogFile.instance.InsertLog("TrdDate : " + (data["TrdDate"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        LogFile.instance.InsertLog("ResponseNo : " + (data["ResponseNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        for split in splited {
            if (split.contains("R01")) {}
            else if (split.contains("R02")) {
                data["QrKind"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("QrKind : " + (data["QrKind"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //간편결제 거래 종류
            else if (split.contains("R03")) {
                data["TermID"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("TermID : " + (data["TermID"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //Terminal ID
            else if (split.contains("R04")) {
                data["CatVersion"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("CatVersion : " + (data["CatVersion"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //단말기 Ver
            else if (split.contains("R05")) {
                data["Month"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("Month : " + (data["Month"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //할부기간
            else if (split.contains("R06")) {
                data["TrdAmt"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("TrdAmt : " + (data["TrdAmt"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //거래금액
            else if (split.contains("R07")) {
                data["TaxAmt"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("TaxAmt : " + (data["TaxAmt"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //세금
            else if (split.contains("R08")) {
                data["SvcAmt"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("SvcAmt : " + (data["SvcAmt"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //봉사료
            else if (split.contains("R09")) {
                data["TaxFreeAmt"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("TaxFreeAmt : " + (data["TaxFreeAmt"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //비과세
            else if (split.contains("R10")) {
                data["DisAmt"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("DisAmt : " + (data["DisAmt"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //카카오페이 할인 금액
            else if (split.contains("R11")) {
                data["CardNo"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("CardNo : " + (data["CardNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                
                data["CardNo"] = CatSdk.instance.mDBAppToApp ?
                Utils.EasyParser(바코드qr번호: data["CardNo"]!,날짜90일경과: true):Utils.EasyParser(바코드qr번호: data["CardNo"]!)
            } //전표출력 시 사용될 바코드번호
            else if (split.contains("R12")) {
                data["AnsCode"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("AnsCode : " + (data["AnsCode"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //응답코드
            else if (split.contains("R13")) {
                data["Message"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("Message : " + (data["Message"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //응답메세지
            else if (split.contains("R14")) {
                data["AuNo"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("AuNo : " + (data["AuNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //승인번호
            else if (split.contains("R15")) {
                data["SubAuNo"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("SubAuNo : " + (data["SubAuNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //서브승인번호
            else if (split.contains("R16")) {
                data["TradeNo"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("TradeNo : " + (data["TradeNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //KOCES 거래고유번호
            else if (split.contains("R17")) {
                data["AuthType"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("AuthType : " + (data["AuthType"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //결제수단
            else if (split.contains("R18")) {
                data["AnswerTrdNo"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("AnswerTrdNo : " + (data["AnswerTrdNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //출력용 거래고유번호
            else if (split.contains("R19")) {
                data["CardKind"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("CardKind : " + (data["CardKind"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //카드종류
            else if (split.contains("R20")) {
                data["DDCYn"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("DDCYn : " + (data["DDCYn"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //DDC여부
            else if (split.contains("R21")) {
                data["EDCYn"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("EDCYn : " + (data["EDCYn"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //EDC여부
            else if (split.contains("R22")) {
                data["OrdCd"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("OrdCd : " + (data["OrdCd"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //발급기관코드
            else if (split.contains("R23")) {
                data["OrdNm"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("OrdNm : " + (data["OrdNm"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //발급기관명
            else if (split.contains("R24")) {
                data["InpCd"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("InpCd : " + (data["InpCd"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //매입기관코드
            else if (split.contains("R25")) {
                data["InpNm"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("InpNm : " + (data["InpNm"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //매입기관명
            else if (split.contains("R26")) {
                data["MchNo"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("MchNo : " + (data["MchNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //가맹점번호
            else if (split.contains("R27")) {
                data["ChargeAmt"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("ChargeAmt : " + (data["ChargeAmt"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //가맹점수수료
            else if (split.contains("R28")) {
                data["RefundAmt"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("RefundAmt : " + (data["RefundAmt"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //가맹점환불금액
            else if (split.contains("R29")) {
                data["MchData"] = split.count >= 4 ? String(split).substring(시작:4):""
                LogFile.instance.InsertLog("MchData : " + (data["MchData"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //가맹점데이터
            else if (split.contains("R30")) { } //R30 거래전문번호
            else if (split.contains("R31")) { } //R31 거래일시
            else if (split.contains("R32")) { } //R32 거래종류명
            else if (split.contains("R33")) { } //R33 전표구분
            else if (split.contains("R34")) { } //R34 전표번호
            else if (split.contains("R35")) { } //R35 전표구분명
            else if (split.contains("R36")) { } //R36 KEYIN 여부
            else if (split.contains("R37")) { } //R37 DDC 업체구분
            else if (split.contains("R38")) { } //R38 DDC 응답여부
            else if (split.contains("R39")) { } //R39 자국통화코드
            else if (split.contains("R40")) { } //R40 자국통화금액
            else if (split.contains("R41")) { } //R41 자국통화 소수점단위
            else if (split.contains("R42")) { } //R42 환율응답
            else if (split.contains("R43")) { } //R43 환율 소수점단위
            else if (split.contains("R44")) { } //R44 역환율
            else if (split.contains("R45")) { } //R45 역 환율 소수점단위
            else if (split.contains("R46")) { } //R46 Inver Rate Dis Unit
            else if (split.contains("R47")) { } //R47 Markup Per
            else if (split.contains("R48")) { } //R48 Markup 표시단위
            else if (split.contains("R49")) { } //R49 Comm Per
            else if (split.contains("R50")) { } //R50 Comm Per Minor
            else if (split.contains("R51")) { } //R51 Comm 통화 Number
            else if (split.contains("R52")) { } //R52 Comm Amount
            else if (split.contains("R53")) { } //R53 Comm Amunt Minor
            else if (split.contains("R54")) { } //R54 RateID
            else if (split.contains("R55")) { } //R55 영문전표출력여부
            else if (split.contains("R56")) { } //R56 여유필드
            else if (split.contains("R57")) { } //R57 잔액
            else if (split.contains("R58")) { } //R58 컵보증금
            else if (split.contains("R59")) { } //R59 한글코드구분
            else if (split.contains("R60")) {
                data["PcKind"] = split.count >= 4 ? String(split).substring(시작: 4):""
                LogFile.instance.InsertLog("PcKind : " + (data["PcKind"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //R60 PAYCO 결제수단
            else if (split.contains("R61")) {
                data["PcCoupon"] = split.count >= 4 ? String(split).substring(시작: 4):""
                LogFile.instance.InsertLog("PcCoupon : " + (data["PcCoupon"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //R61 PAYCO 쿠폰승인금액
            else if (split.contains("R62")) {
                data["PcPoint"] = split.count >= 4 ? String(split).substring(시작: 4):""
                LogFile.instance.InsertLog("PcPoint : " + (data["PcPoint"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //R62 PAYCO 포인트승인금액
            else if (split.contains("R63")) {
                data["PcCard"] = split.count >= 4 ? String(split).substring(시작: 4):""
                LogFile.instance.InsertLog("PcCard : " + (data["PcCard"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            } //R63 PAYCO 신용카드승인금액
        }

        return data
    }
    
    func ParsingresData(수신데이터 _recv:[UInt8], 간편결제체크 _easyCheck:Bool = false) -> Dictionary<String,String>?
    {
        var parseData:[UInt8] = _recv   //데이터를 지워 가면서 작업을 해야 해서 임시로 변수 하나 지정
        //본격적인 파싱 시작
        var data:[String:String] = [:]

        //데이터 사이즈 체크
        if _recv.count < 6 {
            return nil
        }
        //데이터 시작이 stx가 아니면 취소
        if _recv[0] != Command.STX {
            return nil
        }
        
        LogFile.instance.InsertLog("CAT 신용/현금결제 데이터파싱", Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid, TimeStamp: true)
        
        parseData.remove(at: 0) //STX 삭제
        var rng = 4 //데이터를 짜르기 위한 범위
        var _tmp = ""
        _tmp = _easyCheck == true ? "G150":Utils.utf8toHangul(str: Array(parseData[0..<rng])); parseData.removeSubrange(0..<rng) //명령코드 4byte
        //TODO: 120 130 140 150 앱투앱일 경우
        if (CatSdk.instance.mDBAppToApp)
        {
            if (_tmp == "G120")
            {
                _tmp = (CatSdk.instance.Cancel == false ? "A15":"A25");
                data["TrdType"] = _easyCheck == true ? "T180":_tmp; //명령코드 4byte
            }
            else if (_tmp == "G130")
            {
                _tmp = (CatSdk.instance.Cancel == false ? "B15":"B25");
                data["TrdType"] = _easyCheck == true ? "T180":_tmp //명령코드 4byte
            }
            else if (_tmp == "G160")
            {
                _tmp = (CatSdk.instance.Cancel == false ? "A15":"A25");
                data["TrdType"] = _easyCheck == true ? "T180":_tmp //명령코드 4byte
            }
            else {
                data["TrdType"] = _easyCheck == true ? "T180":_tmp //명령코드 4byte
            }
        }
        else
        {
            data["TrdType"] = _easyCheck == true ? "T180":_tmp //명령코드 4byte
        }
        LogFile.instance.InsertLog("TrdType : " + (data["TrdType"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        /*data["ResponseNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //거래전문번호 4byte  //x
        rng = 10;data["TermID"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])); parseData.removeSubrange(0..<rng) //TID 10byte   //x
        LogFile.instance.InsertLog("TermID : " + (data["TermID"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 5;/*data["CatVer"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //단말기 Ver 5byte  //x
        rng = 2;/*data["Installment"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //할부 2byte //x
        rng = 10;/*data["Money"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //거래금액 10byte   //x
        rng = 9
        /*data["Tax"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //세금 9byte  //x
        /*data["Svc"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //봉사료 9byte    //x
        /*data["Txf"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //비과세 9byte    //x
        rng = 8;/*data["OriAuDate"]*/  CatSdk.instance.OriAuDate = Utils.utf8toHangul(str: Array(parseData[2..<rng])).replacingOccurrences(of: " ", with: ""); parseData.removeSubrange(0..<rng) //원거래일자 8byte    //x
        rng = 12;/*data["OriAuNo"]*/ CatSdk.instance.OriAuNo = Utils.utf8toHangul(str: Array(parseData[0..<rng])).replacingOccurrences(of: " ", with: ""); parseData.removeSubrange(0..<rng) //원거래번호 12byte    //x
        rng = 14;data["TrdDate"] = Utils.utf8toHangul(str: Array(parseData[2..<rng])).replacingOccurrences(of: " ", with: ""); parseData.removeSubrange(0..<rng) //거래일시 14byte Format:YYYYMMDDhhmmss -> yymmddhhmmss 12자리만 저장하기 위해서
        LogFile.instance.InsertLog("TrdDate : " + (data["TrdDate"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 4;data["AnsCode"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])); parseData.removeSubrange(0..<rng) //응답코드 정상응답(응답코드: 0000, 0001, 0002, 9901)
        LogFile.instance.InsertLog("AnsCode : " + (data["AnsCode"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 80;data["Message"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])); parseData.removeSubrange(0..<rng) //신용:앞 40Byte+뒤 40Byte Space
        LogFile.instance.InsertLog("Message : " + (data["Message"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 40;data["CardNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])).replacingOccurrences(of: " ", with: ""); parseData.removeSubrange(0..<rng) //신용,은련,DCC: 출력시 사용될 Track2 정보,현금: 출력 시 사용될 신분확인번호 정보
        LogFile.instance.InsertLog("CardNo : " + (data["CardNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        if _tmp == "B15" || _tmp == "B25" {
            data["CardNo"] = CatSdk.instance.mDBAppToApp ?
            Utils.CashParser(현금영수증번호: data["CardNo"]!, 날짜90일경과: true):Utils.CashParser(현금영수증번호: data["CardNo"]!)
        } else {
            data["CardNo"] = CatSdk.instance.mDBAppToApp ?
            Utils.CardParser(카드번호: data["CardNo"]!, 날짜90일경과: true):Utils.CardParser(카드번호: data["CardNo"]!)
        }
        rng = 12;data["AuNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])).replacingOccurrences(of: " ", with: ""); parseData.removeSubrange(0..<rng) //승인번호
        LogFile.instance.InsertLog("AuNo : " + (data["AuNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 20;data["TradeNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])).replacingOccurrences(of: " ", with: ""); parseData.removeSubrange(0..<rng) //코세스거래고유번호
        LogFile.instance.InsertLog("TradeNo : " + (data["TradeNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 8;/*data["TrType"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //거래종류명  //x
        data["CardKind"] = Utils.utf8toHangul(str: [parseData[0]]); parseData.remove(at: 0)  //카드 종류
        LogFile.instance.InsertLog("CardKind : " + (data["CardKind"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 4;data["OrdCd"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //발급사코드
        LogFile.instance.InsertLog("OrdCd : " + (data["OrdCd"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 12;data["OrdNm"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //발급사명
        LogFile.instance.InsertLog("OrdNm : " + (data["OrdNm"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 4;data["InpCd"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //매입사코드
        LogFile.instance.InsertLog("InpCd : " + (data["InpCd"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 12;data["InpNm"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //매입사명
        LogFile.instance.InsertLog("InpNm : " + (data["InpNm"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 16;data["MchNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //가맹점번호
        LogFile.instance.InsertLog("MchNo : " + (data["MchNo"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        data["DCCYn"] = Utils.utf8toHangul(str: [parseData[0]]); parseData.remove(at: 0)  //DDC여부 1:Yes, 0:No
        LogFile.instance.InsertLog("DCCYn : " + (data["DCCYn"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        data["EDCYn"] = Utils.utf8toHangul(str: [parseData[0]]); parseData.remove(at: 0)  //EDC여부 1:Yes, 0:No
        LogFile.instance.InsertLog("EDCYn : " + (data["EDCYn"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        /*data["ChitType"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //전표구분 //x
        rng = 4;/*data["ChitNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //전표번호   //x
        rng = 10;/*data["ChitNm"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //전표구분명  //x
        data["KeyIn"] = Utils.utf8toHangul(str: [parseData[0]]); parseData.remove(at: 0)  //KeyIn 여부    //x
        LogFile.instance.InsertLog("KeyIn : " + (data["KeyIn"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        /*data["DCCCom"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //DCC 업체구분 A : Alliex G :GCMC    //x
        /*data["DCCRes"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //DCC 응답 여부 0: 일반 신용승인,2:DCC 승인  //x
        rng = 3;/*data["CurrencyCode"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //자국통화코드   //x
        rng = 12;/*data["CurrencyMoney"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //자국통화금액 //x
        /*data["CurrencyFt"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //자국통화 소수점단 위,결제예정 자국통화 소수점, 엔화, 베트남 통 0, 나머지 2  //x
        rng = 9;/*data["ExchRes"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //환율응답  //x
        /*data["ExchFt"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //환율의 소수점단위 - 7 ex) 20.07    //x
        rng = 9;/*data["ReExchRes"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //표시 목적을 위한 역 환율 ex) 000049808    //x
        /*data["ReExchFt"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //역 환율의 소수점단위 4 ex) 04.98  //x
        /*data["InvertedRateDisplayUnit"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //"지수(승수) - 자국통화표현단위 “0” : 1단위 ex) USD  //x
        //ex) USD 1.00 = KRW xxxx.xxx,
        //“2” : 100 단위
        //ex) JPY 100 = KRW xxxx.xxx
        //ex) VND 100 = KRW xxxx.xxx 일반적으로 0 이 전송되며, JPY, VND 와 같은 100 단위 통화의 경우는 2
        //ex) 2007722 VND * 04.98 / 100 = 99984.5556 WON"
        rng = 8;/*data["MarkUpPercentage"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //소수점을 포함하는 환율에 적용된 Markup percentage (이 필드만 소수점이 포함된 값)   //x
        //ex) 4.000000 - DCC 업체 수수료
        /*data["MarkUpPercentageUnit"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //Markuppercentage 표시단위    //x
        rng = 8;/*data["CommissionPercentage"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //GCMC 전용  //x
        /*data["CommissionPercentageMinorUnit"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //GCMC 전용 //x
        rng = 3;/*data["CommissionCurrencyNumber"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //GCMC 전용  //x
        rng = 12;/*data["CommissionAmount"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //GCMC 전용 //x
        /*data["CommissionAmountMinorUnit"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //GCMC 전용 //x
        rng = 20;/*data["RateId"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //GCMC 전용   //x
        
        /*data["ChitEngPrint"] = Utils.utf8toHangul(str: [parseData[0]]);*/ parseData.remove(at: 0)  //영문전표출력여부 '1: 영문전표 출력, 그외 : 한글전표 출력   //x
        rng = 50;data["MchData"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //가맹점데이터
        LogFile.instance.InsertLog("MchData : " + (data["MchData"] ?? ""), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        rng = 20;/*data["ExtraField"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/parseData.removeSubrange(0..<rng) //GCMC 전용   //x
        
        if parseData.count == 2 {
            return data
        }

        //남은데이터가 맞지 않는다. 파싱이 잘못되었다.
        return nil
    }
    
    /// 간편 결제 수신 데이터 DB에 추가 하는 함수
    /// - Parameter _recv: _recv description
    func InsertDBTradeData_TypeEasy(수신데이터 _recv:[String:String])
    {
        var _신용현금:define.TradeMethod = define.TradeMethod.CAT_Credit
        var _현금영수증타겟:define.TradeMethod = define.TradeMethod.NULL
        var _현금영수증발급형태:define.TradeMethod = define.TradeMethod.NULL
        var _현금발급번호 = ""
        var _카드번호 = ""
        var _취소여부:define.TradeMethod  = define.TradeMethod.NoCancel
        _현금발급번호 = MarkingCardNumber(카드번호앞자리:_recv["CardNo"]!)
        
        if(_recv["QrKind"] == "AP")
        {
            _신용현금 = define.TradeMethod.CAT_App;
        } else if(_recv["QrKind"] == "ZP")
        {
            _신용현금 = define.TradeMethod.CAT_Zero;
        } else if(_recv["QrKind"] == "KP")
        {
            _신용현금 = define.TradeMethod.CAT_Kakao;
        } else if(_recv["QrKind"] == "AL")
        {
            _신용현금 = define.TradeMethod.CAT_Ali;
        } else if(_recv["QrKind"] == "WC")
        {
            _신용현금 = define.TradeMethod.CAT_We;
        } else if(_recv["QrKind"] == "PC")
        {
            _신용현금 = define.TradeMethod.CAT_Payco;
        }
        _카드번호 = MarkingCardNumber(카드번호앞자리:_recv["CardNo"]!)
        if CatSdk.instance.mDBAppToApp {
            DisConnectServer()
            CatSdk.instance.catlistener?.onResult(CatState: .OK, Result: _recv)
           
            return
        }
        
        var tid = CatSdk.instance.Tid == "" ? (_recv["TermID"] ?? ""):CatSdk.instance.Tid
        var productNum = tid +
        Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO) +
        (_recv["TrdDate"] ?? "") +
        (_recv["AuNo"] ?? "")
        
        switch _recv["ResponseNo"]! {
        case "E15":
            sqlite.instance.InsertTrade(Tid: CatSdk.instance.Tid == "" ? _recv["TermID"]!:CatSdk.instance.Tid,
                                        StoreName: CatSdk.instance.mStoreName == "" ? "":CatSdk.instance.mStoreName,
                                        StoreAddr: CatSdk.instance.mStoreAddr == "" ? "":CatSdk.instance.mStoreAddr,
                                        StoreNumber: CatSdk.instance.mStoreNumber == "" ? "":CatSdk.instance.mStoreNumber,
                                        StorePhone: CatSdk.instance.mStorePhone == "" ? "":CatSdk.instance.mStorePhone,
                                        StoreOwner: CatSdk.instance.mStoreOwner == "" ? "":CatSdk.instance.mStoreOwner,
                                        신용현금: _신용현금,
                                        취소여부: _취소여부,
                                        금액:Int(CatSdk.instance.Money)!,
                                        선불카드잔액: "",
                                        세금:  Int(CatSdk.instance.Tax)!,
                                        봉사료: Int(CatSdk.instance.Svc)!,
                                        비과세: Int(CatSdk.instance.Txf)!,
                                        할부: Int(CatSdk.instance.InstallMent.replacingOccurrences(of: " ", with: "")) ?? 0,
                                        현금영수증타겟: _현금영수증타겟,
                                        현금영수증발급형태: _현금영수증발급형태,
                                        현금발급번호: _현금발급번호,
                                        카드번호: _카드번호,
                                        카드종류:_recv["CardKind"]!,
                                        카드매입사: _recv["InpNm"]!.replacingOccurrences(of: " ", with: ""),
                                        카드발급사: _recv["OrdNm"]!.replacingOccurrences(of: " ", with: ""),
                                        가맹점번호: _recv["MchNo"]!.replacingOccurrences(of: " ", with: ""),
                                        승인날짜: _recv["TrdDate"]!.replacingOccurrences(of: " ", with: ""),
                                        원거래일자: CatSdk.instance.AuDate.replacingOccurrences(of: " ", with: ""),
                                        승인번호: _recv["AuNo"]!.replacingOccurrences(of: " ", with: ""),
                                        원승인번호: CatSdk.instance.AuNo.replacingOccurrences(of: " ", with: ""),
                                        코세스고유거래키: _recv["TradeNo"]!.replacingOccurrences(of: " ", with: ""), 응답메시지: _recv["Message"] ?? "",
                                        KakaoMessage: "",PayType: _recv["AuthType"]!.replacingOccurrences(of: " ", with: ""),KakaoAuMoney: "",KakaoSaleMoney: _recv["DisAmt"]!.replacingOccurrences(of: " ", with: ""),KakaoMemberCd: "",KakaoMemberNo: "",Otc: "",Pem: "",Trid: "",CardBin: "",SearchNo: _recv["TradeNo"]!.replacingOccurrences(of: " ", with: ""),PrintBarcd: _recv["CardNo"]!.replacingOccurrences(of: " ", with: ""),PrintUse: "",PrintNm: "",MchFee: _recv["ChargeAmt"]!.replacingOccurrences(of: " ", with: ""),MchRefund: _recv["RefundAmt"]!.replacingOccurrences(of: " ", with: ""),
                                        PcKind: _recv["PcKind"] ?? "", PcCoupon: _recv["PcCoupon"] ?? "", PcPoint: _recv["PcPoint"] ?? "", PcCard: _recv["PcCard"] ?? "",
                                        ProductNum: productNum,_ddc: _recv["DDCYn"] ?? "",_edc: _recv["EDCYn"] ?? "",
                                        _icInputType: "",_emvTradeType: "",_pointCode: _recv["PtResCode"] ?? "",_serviceName: _recv["PtResService"] ?? "",_earnPoint: _recv["PtResEarnPoint"] ?? "",_usePoint: _recv["PtResUsePoint"] ?? "",_totalPoint: _recv["PtResTotalPoint"] ?? "",_percent:  _recv["PtResPercentPoint"] ?? "",_userName: _recv["PtResUserName"] ?? "",_pointStoreNumber: _recv["PtResStoreNumber"] ?? "",_MemberCardTypeText: _recv["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _recv["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _recv["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _recv["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _recv["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _recv["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _recv["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _recv["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _recv["MemberStoreNoText"] ?? "")
            break
        case "E25":
            _취소여부  = define.TradeMethod.Cancel
            sqlite.instance.InsertTrade(Tid: CatSdk.instance.Tid == "" ? _recv["TermID"]!:CatSdk.instance.Tid,
                                        StoreName: CatSdk.instance.mStoreName == "" ? "":CatSdk.instance.mStoreName,
                                        StoreAddr: CatSdk.instance.mStoreAddr == "" ? "":CatSdk.instance.mStoreAddr,
                                        StoreNumber: CatSdk.instance.mStoreNumber == "" ? "":CatSdk.instance.mStoreNumber,
                                        StorePhone: CatSdk.instance.mStorePhone == "" ? "":CatSdk.instance.mStorePhone,
                                        StoreOwner: CatSdk.instance.mStoreOwner == "" ? "":CatSdk.instance.mStoreOwner,
                                        신용현금: _신용현금,
                                        취소여부: _취소여부,
                                        금액:Int(CatSdk.instance.Money)!,
                                        선불카드잔액: "",
                                        세금:  Int(CatSdk.instance.Tax)!,
                                        봉사료: Int(CatSdk.instance.Svc)!,
                                        비과세: Int(CatSdk.instance.Txf)!,
                                        할부: Int(CatSdk.instance.InstallMent.replacingOccurrences(of: " ", with: "")) ?? 0,
                                        현금영수증타겟: _현금영수증타겟,
                                        현금영수증발급형태: _현금영수증발급형태,
                                        현금발급번호: _현금발급번호,
                                        카드번호: _카드번호,
                                        카드종류:_recv["CardKind"]!,
                                        카드매입사: _recv["InpNm"]!.replacingOccurrences(of: " ", with: ""),
                                        카드발급사: _recv["OrdNm"]!.replacingOccurrences(of: " ", with: ""),
                                        가맹점번호: _recv["MchNo"]!.replacingOccurrences(of: " ", with: ""),
                                        승인날짜: _recv["TrdDate"]!.replacingOccurrences(of: " ", with: ""),
                                        원거래일자: CatSdk.instance.AuDate.replacingOccurrences(of: " ", with: ""),
                                        승인번호: _recv["AuNo"]!.replacingOccurrences(of: " ", with: ""),
                                        원승인번호: CatSdk.instance.AuNo.replacingOccurrences(of: " ", with: ""),
                                        코세스고유거래키: _recv["TradeNo"]!.replacingOccurrences(of: " ", with: ""), 응답메시지: _recv["Message"] ?? "",
                                        KakaoMessage: "",PayType: _recv["AuthType"]!.replacingOccurrences(of: " ", with: ""),KakaoAuMoney: "",KakaoSaleMoney: _recv["DisAmt"]!.replacingOccurrences(of: " ", with: ""),KakaoMemberCd: "",KakaoMemberNo: "",Otc: "",Pem: "",Trid: "",CardBin: "",SearchNo: _recv["TradeNo"]!.replacingOccurrences(of: " ", with: ""),PrintBarcd: _recv["CardNo"]!.replacingOccurrences(of: " ", with: ""),PrintUse: "",PrintNm: "",MchFee: _recv["ChargeAmt"]!.replacingOccurrences(of: " ", with: ""),MchRefund: _recv["RefundAmt"]!.replacingOccurrences(of: " ", with: ""),
                                        PcKind: _recv["PcKind"] ?? "", PcCoupon: _recv["PcCoupon"] ?? "", PcPoint: _recv["PcPoint"] ?? "", PcCard: _recv["PcCard"] ?? "",
                                        ProductNum: productNum,_ddc: _recv["DDCYn"] ?? "",_edc: _recv["EDCYn"] ?? "",
                                        _icInputType: "",_emvTradeType: "",_pointCode: _recv["PtResCode"] ?? "",_serviceName: _recv["PtResService"] ?? "",_earnPoint: _recv["PtResEarnPoint"] ?? "",_usePoint: _recv["PtResUsePoint"] ?? "",_totalPoint: _recv["PtResTotalPoint"] ?? "",_percent:  _recv["PtResPercentPoint"] ?? "",_userName: _recv["PtResUserName"] ?? "",_pointStoreNumber: _recv["PtResStoreNumber"] ?? "",_MemberCardTypeText: _recv["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _recv["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _recv["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _recv["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _recv["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _recv["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _recv["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _recv["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _recv["MemberStoreNoText"] ?? "")
            break
        case "E35":
            DisConnectServer()
            CatSdk.instance.catlistener?.onResult(CatState: .OK, Result: _recv)
            return
        default:
            break
        }
        
        DisConnectServer()
        if String(describing: Utils.topMostViewController()).contains("CatAnimationViewController") {
            let controller = Utils.topMostViewController() as! CatAnimationViewController
//            controller.GoToReceiptSwiftUI()
            controller.GoToReceiptEasySwiftUI()
            return
        }
//        if String(describing: Utils.topMostViewController()).contains("CardAnimationViewController") {
//            let controller = Utils.topMostViewController() as! CardAnimationViewController
//            controller.GoToReceiptEasyPaySwiftUI()
//
//        }
        
    }
    /// 신용 결제 수신 데이터 DB에 추가 하는 함수
    /// - Parameter _recv: _recv description
    func InsertDBTradeData_TypeCrdit(수신데이터 _recv:[String:String])
    {
        var _신용현금:define.TradeMethod = define.TradeMethod.CAT_Credit
        var _현금영수증타겟:define.TradeMethod = define.TradeMethod.NULL
        var _현금영수증발급형태:define.TradeMethod = define.TradeMethod.NULL
        var _현금발급번호 = ""
        var _카드번호 = ""
        var _취소여부:define.TradeMethod  = define.TradeMethod.NoCancel
        switch _recv["TrdType"]! {
        case "G120":
            _신용현금 = define.TradeMethod.CAT_Credit
            _카드번호 = MarkingCardNumber(카드번호앞자리:_recv["CardNo"]!)
            break
        case "G130":
            _신용현금 = define.TradeMethod.CAT_Cash
            _현금영수증타겟 = getCashTarget(대상입력: Int(CatSdk.instance.pb) ?? 0)
            if _recv["KeyIn"]! == "N" {
                _현금영수증발급형태 = define.TradeMethod.CashMs
            } else if _recv["KeyIn"]! == "Y" {
                _현금영수증발급형태 = define.TradeMethod.CashDirect
            } else {
                _현금영수증발급형태 = define.TradeMethod.CashDirect
            }
//            _현금영수증발급형태 = define.TradeMethod.NULL
            _현금발급번호 = MarkingCardNumber(카드번호앞자리:_recv["CardNo"]!)
            break
        case "G140":
            _신용현금 = define.TradeMethod.CAT_Credit
            _카드번호 = MarkingCardNumber(카드번호앞자리:_recv["CardNo"]!)
            break
        case "G150":
            _신용현금 = define.TradeMethod.CAT_App
            _카드번호 = MarkingCardNumber(카드번호앞자리:_recv["CardNo"]!)
//            _카드번호 = CatSdk.instance.AppCard
            break
        case "G160":
            _신용현금 = define.TradeMethod.CAT_Credit
            _카드번호 = MarkingCardNumber(카드번호앞자리:_recv["CardNo"]!)
//            _카드번호 = CatSdk.instance.AppCard
            break
        default:
            _신용현금 = define.TradeMethod.CAT_Credit
            _카드번호 = MarkingCardNumber(카드번호앞자리:_recv["CardNo"]!)
            break
        }
        
        if CatSdk.instance.OriAuDate.replacingOccurrences(of: " ", with: "") != "" {
            _취소여부 = define.TradeMethod.Cancel
        }
        
        if CatSdk.instance.mDBAppToApp {
            DisConnectServer()
            CatSdk.instance.catlistener?.onResult(CatState: .OK, Result: _recv)
           
            return
        }
        
        var tid = CatSdk.instance.Tid == "" ? (_recv["TermID"] ?? ""):CatSdk.instance.Tid
        var productNum = tid +
        Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO) +
        (_recv["TrdDate"] ?? "") +
        (_recv["AuNo"] ?? "")

        if _recv["CardKind"]! == "3" || _recv["CardKind"]! == "4" {
            sqlite.instance.InsertTrade(Tid: CatSdk.instance.Tid == "" ? _recv["TermID"]!:CatSdk.instance.Tid,
                                        StoreName: CatSdk.instance.mStoreName == "" ? "":CatSdk.instance.mStoreName,
                                        StoreAddr: CatSdk.instance.mStoreAddr == "" ? "":CatSdk.instance.mStoreAddr,
                                        StoreNumber: CatSdk.instance.mStoreNumber == "" ? "":CatSdk.instance.mStoreNumber,
                                        StorePhone: CatSdk.instance.mStorePhone == "" ? "":CatSdk.instance.mStorePhone,
                                        StoreOwner: CatSdk.instance.mStoreOwner == "" ? "":CatSdk.instance.mStoreOwner,
                                        신용현금: _신용현금,
                                        취소여부: _취소여부,
                                        금액:Int(CatSdk.instance.Money)!,
                                        선불카드잔액: _recv["Message"]!,
                                        세금:  Int(CatSdk.instance.Tax)!,
                                        봉사료: Int(CatSdk.instance.Svc)!,
                                        비과세: Int(CatSdk.instance.Txf)!,
                                        할부: Int(CatSdk.instance.InstallMent.replacingOccurrences(of: " ", with: "")) ?? 0,
                                        현금영수증타겟: _현금영수증타겟,
                                        현금영수증발급형태: _현금영수증발급형태,
                                        현금발급번호: _현금발급번호,
                                        카드번호: _카드번호,
                                        카드종류:_recv["CardKind"]!,
                                        카드매입사: _recv["InpNm"]!.replacingOccurrences(of: " ", with: ""),
                                        카드발급사: _recv["OrdNm"]!.replacingOccurrences(of: " ", with: ""),
                                        가맹점번호: _recv["MchNo"]!.replacingOccurrences(of: " ", with: ""),
                                        승인날짜: _recv["TrdDate"]!.replacingOccurrences(of: " ", with: ""),
                                        원거래일자: CatSdk.instance.OriAuDate.replacingOccurrences(of: " ", with: ""),
                                        승인번호: _recv["AuNo"]!.replacingOccurrences(of: " ", with: ""),
                                        원승인번호: CatSdk.instance.OriAuNo.replacingOccurrences(of: " ", with: ""),
                                        코세스고유거래키: _recv["TradeNo"]!.replacingOccurrences(of: " ", with: ""), 응답메시지: _recv["Message"] ?? "",
                                        KakaoMessage: "",PayType: "",KakaoAuMoney: "",KakaoSaleMoney: "",KakaoMemberCd: "",KakaoMemberNo: "",Otc: "",Pem: "",Trid: "",CardBin: "",SearchNo: "",PrintBarcd: "",PrintUse: "",PrintNm: "",MchFee: "",MchRefund: "",
                                        PcKind: _recv["PcKind"] ?? "", PcCoupon: _recv["PcCoupon"] ?? "", PcPoint: _recv["PcPoint"] ?? "", PcCard: _recv["PcCard"] ?? "",
                                        ProductNum: productNum,_ddc: _recv["DDCYn"] ?? "",_edc: _recv["EDCYn"] ?? "",
                                        _icInputType: "",_emvTradeType: "",_pointCode: _recv["PtResCode"] ?? "",_serviceName: _recv["PtResService"] ?? "",_earnPoint: _recv["PtResEarnPoint"] ?? "",_usePoint: _recv["PtResUsePoint"] ?? "",_totalPoint: _recv["PtResTotalPoint"] ?? "",_percent:  _recv["PtResPercentPoint"] ?? "",_userName: _recv["PtResUserName"] ?? "",_pointStoreNumber: _recv["PtResStoreNumber"] ?? "",_MemberCardTypeText: _recv["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _recv["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _recv["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _recv["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _recv["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _recv["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _recv["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _recv["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _recv["MemberStoreNoText"] ?? "")
        } else {
            sqlite.instance.InsertTrade(Tid: CatSdk.instance.Tid == "" ? _recv["TermID"]!:CatSdk.instance.Tid,
                                        StoreName: CatSdk.instance.mStoreName == "" ? "":CatSdk.instance.mStoreName,
                                        StoreAddr: CatSdk.instance.mStoreAddr == "" ? "":CatSdk.instance.mStoreAddr,
                                        StoreNumber: CatSdk.instance.mStoreNumber == "" ? "":CatSdk.instance.mStoreNumber,
                                        StorePhone: CatSdk.instance.mStorePhone == "" ? "":CatSdk.instance.mStorePhone,
                                        StoreOwner: CatSdk.instance.mStoreOwner == "" ? "":CatSdk.instance.mStoreOwner,
                                        신용현금: _신용현금,
                                        취소여부: _취소여부,
                                        금액:Int(CatSdk.instance.Money)!,
                                        선불카드잔액: "",
                                        세금:  Int(CatSdk.instance.Tax)!,
                                        봉사료: Int(CatSdk.instance.Svc)!,
                                        비과세: Int(CatSdk.instance.Txf)!,
                                        할부: Int(CatSdk.instance.InstallMent.replacingOccurrences(of: " ", with: "")) ?? 0,
                                        현금영수증타겟: _현금영수증타겟,
                                        현금영수증발급형태: _현금영수증발급형태,
                                        현금발급번호: _현금발급번호,
                                        카드번호: _카드번호,
                                        카드종류:_recv["CardKind"]!,
                                        카드매입사: _recv["InpNm"]!.replacingOccurrences(of: " ", with: ""),
                                        카드발급사: _recv["OrdNm"]!.replacingOccurrences(of: " ", with: ""),
                                        가맹점번호: _recv["MchNo"]!.replacingOccurrences(of: " ", with: ""),
                                        승인날짜: _recv["TrdDate"]!.replacingOccurrences(of: " ", with: ""),
                                        원거래일자: CatSdk.instance.OriAuDate.replacingOccurrences(of: " ", with: ""),
                                        승인번호: _recv["AuNo"]!.replacingOccurrences(of: " ", with: ""),
                                        원승인번호: CatSdk.instance.OriAuNo.replacingOccurrences(of: " ", with: ""),
                                        코세스고유거래키: _recv["TradeNo"]!.replacingOccurrences(of: " ", with: ""), 응답메시지: _recv["Message"] ?? "",
                                        KakaoMessage: "",PayType: "",KakaoAuMoney: "",KakaoSaleMoney: "",KakaoMemberCd: "",KakaoMemberNo: "",Otc: "",Pem: "",Trid: "",CardBin: "",SearchNo: "",PrintBarcd: "",PrintUse: "",PrintNm: "",MchFee: "",MchRefund: "",
                                        PcKind: _recv["PcKind"] ?? "", PcCoupon: _recv["PcCoupon"] ?? "", PcPoint: _recv["PcPoint"] ?? "", PcCard: _recv["PcCard"] ?? "",
                                        ProductNum: productNum,_ddc: _recv["DDCYn"] ?? "",_edc: _recv["EDCYn"] ?? "",
                                        _icInputType: "",_emvTradeType: "",_pointCode: _recv["PtResCode"] ?? "",_serviceName: _recv["PtResService"] ?? "",_earnPoint: _recv["PtResEarnPoint"] ?? "",_usePoint: _recv["PtResUsePoint"] ?? "",_totalPoint: _recv["PtResTotalPoint"] ?? "",_percent:  _recv["PtResPercentPoint"] ?? "",_userName: _recv["PtResUserName"] ?? "",_pointStoreNumber: _recv["PtResStoreNumber"] ?? "",_MemberCardTypeText: _recv["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _recv["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _recv["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _recv["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _recv["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _recv["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _recv["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _recv["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _recv["MemberStoreNoText"] ?? "")
        }
        DisConnectServer()
        if String(describing: Utils.topMostViewController()).contains("CatAnimationViewController") {
            let controller = Utils.topMostViewController() as! CatAnimationViewController
            controller.GoToReceiptSwiftUI()
            return
        }
    }
    
    func InsertDBTradeData_TypeCashIC(수신데이터 _recv:[String:String])
    {
        if CatSdk.instance.mDBAppToApp {
            DisConnectServer()
            CatSdk.instance.catlistener?.onResult(CatState: .OK, Result: _recv)
           
            return
        }
        
        var _현금영수증타겟:define.TradeMethod = define.TradeMethod.NULL
        var _현금영수증발급형태:define.TradeMethod = define.TradeMethod.NULL
        var _현금발급번호 = ""
//        if _recv["CardNo"]!.count > 6 {
//            _현금영수증발급형태 = define.TradeMethod.CashDirect
//        } else {
//            _현금영수증발급형태 = define.TradeMethod.CashMs
//        }
        _현금영수증발급형태 = define.TradeMethod.CashMs
        _현금발급번호 = MarkingCardNumber(카드번호앞자리:_recv["CardNo"]!)
        
        var tid = CatSdk.instance.Tid == "" ? (_recv["TermID"] ?? ""):CatSdk.instance.Tid
        var productNum = tid +
        Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO) +
        (_recv["TrdDate"] ?? "") +
        (_recv["AuNo"] ?? "")
        
        switch _recv["ResponseNo"]! {
        case "C15":
            sqlite.instance.InsertTrade(Tid: CatSdk.instance.Tid == "" ? _recv["TermID"]!:CatSdk.instance.Tid,
                                        StoreName: CatSdk.instance.mStoreName == "" ? "":CatSdk.instance.mStoreName,
                                        StoreAddr: CatSdk.instance.mStoreAddr == "" ? "":CatSdk.instance.mStoreAddr,
                                        StoreNumber: CatSdk.instance.mStoreNumber == "" ? "":CatSdk.instance.mStoreNumber,
                                        StorePhone: CatSdk.instance.mStorePhone == "" ? "":CatSdk.instance.mStorePhone,
                                        StoreOwner: CatSdk.instance.mStoreOwner == "" ? "":CatSdk.instance.mStoreOwner,
                                        신용현금: define.TradeMethod.CAT_CashIC,
                                        취소여부: define.TradeMethod.NoCancel,
                                        금액:Int(CatSdk.instance.Money)!,
                                        선불카드잔액: "",
                                        세금:  Int(CatSdk.instance.Tax)!,
                                        봉사료: Int(CatSdk.instance.Svc)!,
                                        비과세: Int(CatSdk.instance.Txf)!,
                                        할부: Int(CatSdk.instance.InstallMent.replacingOccurrences(of: " ", with: "")) ?? 0,
                                        현금영수증타겟: define.TradeMethod.NULL,
                                        현금영수증발급형태: _현금영수증발급형태,
                                        현금발급번호: _현금발급번호,
                                        카드번호: "",
                                        카드종류: "",
                                        카드매입사: _recv["InpNm"]!.replacingOccurrences(of: " ", with: ""),
                                        카드발급사: _recv["OrdNm"]!.replacingOccurrences(of: " ", with: ""),
                                        가맹점번호: _recv["MchNo"]!.replacingOccurrences(of: " ", with: ""),
                                        승인날짜: _recv["TrdDate"]!.replacingOccurrences(of: " ", with: ""),
                                        원거래일자: CatSdk.instance.AuDate.replacingOccurrences(of: " ", with: ""),
                                        승인번호: _recv["AuNo"]!.replacingOccurrences(of: " ", with: ""),
                                        원승인번호: CatSdk.instance.AuNo.replacingOccurrences(of: " ", with: ""),
                                        코세스고유거래키: _recv["TradeNo"]!.replacingOccurrences(of: " ", with: ""), 응답메시지: _recv["Message"] ?? "",
                                        KakaoMessage: "",PayType: "",KakaoAuMoney: "",KakaoSaleMoney: "",KakaoMemberCd: "",KakaoMemberNo: "",Otc: "",Pem: "",Trid: "",CardBin: "",SearchNo: "",PrintBarcd: "",PrintUse: "",PrintNm: "",MchFee: "",MchRefund: "",
                                        PcKind: _recv["PcKind"] ?? "", PcCoupon: _recv["PcCoupon"] ?? "", PcPoint: _recv["PcPoint"] ?? "", PcCard: _recv["PcCard"] ?? "",
                                        ProductNum: productNum,_ddc: _recv["DDCYn"] ?? "",_edc: _recv["EDCYn"] ?? "",
                                        _icInputType: "",_emvTradeType: "",_pointCode: _recv["PtResCode"] ?? "",_serviceName: _recv["PtResService"] ?? "",_earnPoint: _recv["PtResEarnPoint"] ?? "",_usePoint: _recv["PtResUsePoint"] ?? "",_totalPoint: _recv["PtResTotalPoint"] ?? "",_percent:  _recv["PtResPercentPoint"] ?? "",_userName: _recv["PtResUserName"] ?? "",_pointStoreNumber: _recv["PtResStoreNumber"] ?? "",_MemberCardTypeText: _recv["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _recv["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _recv["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _recv["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _recv["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _recv["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _recv["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _recv["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _recv["MemberStoreNoText"] ?? "")
            
            
            break
        case "C25":
            sqlite.instance.InsertTrade(Tid: CatSdk.instance.Tid == "" ? _recv["TermID"]!:CatSdk.instance.Tid,
                                        StoreName: CatSdk.instance.mStoreName == "" ? "":CatSdk.instance.mStoreName,
                                        StoreAddr: CatSdk.instance.mStoreAddr == "" ? "":CatSdk.instance.mStoreAddr,
                                        StoreNumber: CatSdk.instance.mStoreNumber == "" ? "":CatSdk.instance.mStoreNumber,
                                        StorePhone: CatSdk.instance.mStorePhone == "" ? "":CatSdk.instance.mStorePhone,
                                        StoreOwner: CatSdk.instance.mStoreOwner == "" ? "":CatSdk.instance.mStoreOwner,
                                        신용현금: define.TradeMethod.CAT_CashIC,
                                        취소여부: define.TradeMethod.Cancel,
                                        금액:Int(CatSdk.instance.Money)!,
                                        선불카드잔액: "",
                                        세금:  Int(CatSdk.instance.Tax)!,
                                        봉사료: Int(CatSdk.instance.Svc)!,
                                        비과세: Int(CatSdk.instance.Txf)!,
                                        할부: Int(CatSdk.instance.InstallMent.replacingOccurrences(of: " ", with: "")) ?? 0,
                                        현금영수증타겟: define.TradeMethod.NULL,
                                        현금영수증발급형태: _현금영수증발급형태,
                                        현금발급번호: _현금발급번호,
                                        카드번호: "",
                                        카드종류: "",
                                        카드매입사: _recv["InpNm"]!.replacingOccurrences(of: " ", with: ""),
                                        카드발급사: _recv["OrdNm"]!.replacingOccurrences(of: " ", with: ""),
                                        가맹점번호: _recv["MchNo"]!.replacingOccurrences(of: " ", with: ""),
                                        승인날짜: _recv["TrdDate"]!.replacingOccurrences(of: " ", with: ""),
                                        원거래일자: CatSdk.instance.AuDate.replacingOccurrences(of: " ", with: ""),
                                        승인번호: _recv["AuNo"]!.replacingOccurrences(of: " ", with: ""),
                                        원승인번호: CatSdk.instance.AuNo.replacingOccurrences(of: " ", with: ""),
                                        코세스고유거래키: _recv["TradeNo"]!.replacingOccurrences(of: " ", with: ""), 응답메시지: _recv["Message"] ?? "",
                                        KakaoMessage: "",PayType: "",KakaoAuMoney: "",KakaoSaleMoney: "",KakaoMemberCd: "",KakaoMemberNo: "",Otc: "",Pem: "",Trid: "",CardBin: "",SearchNo: "",PrintBarcd: "",PrintUse: "",PrintNm: "",MchFee: "",MchRefund: "",
                                        PcKind: _recv["PcKind"] ?? "", PcCoupon: _recv["PcCoupon"] ?? "", PcPoint: _recv["PcPoint"] ?? "", PcCard: _recv["PcCard"] ?? "",
                                        ProductNum: productNum,_ddc: _recv["DDCYn"] ?? "",_edc: _recv["EDCYn"] ?? "",
                                        _icInputType: "",_emvTradeType: "",_pointCode: _recv["PtResCode"] ?? "",_serviceName: _recv["PtResService"] ?? "",_earnPoint: _recv["PtResEarnPoint"] ?? "",_usePoint: _recv["PtResUsePoint"] ?? "",_totalPoint: _recv["PtResTotalPoint"] ?? "",_percent:  _recv["PtResPercentPoint"] ?? "",_userName: _recv["PtResUserName"] ?? "",_pointStoreNumber: _recv["PtResStoreNumber"] ?? "",_MemberCardTypeText: _recv["MemberCardTypeText"] ?? "",_MemberServiceTypeText: _recv["MemberServiceTypeText"] ?? "",_MemberServiceNameText:  _recv["MemberServiceNameText"] ?? "",_MemberTradeMoneyText: _recv["MemberTradeMoneyText"] ?? "",_MemberSaleMoneyText: _recv["MemberSaleMoneyText"] ?? "",_MemberAfterTradeMoneyText: _recv["MemberAfterTradeMoneyText"] ?? "",_MemberAfterMemberPointText: _recv["MemberAfterMemberPointText"] ?? "",_MemberOptionCodeText: _recv["MemberOptionCodeText"] ?? "",_MemberStoreNoText: _recv["MemberStoreNoText"] ?? "")
            
            break
        case "C35":
            DisConnectServer()
            CatSdk.instance.catlistener?.onResult(CatState: .OK, Result: _recv)
            return
        case "C45":
            DisConnectServer()
            CatSdk.instance.catlistener?.onResult(CatState: .OK, Result: _recv)

            return
        case "C55":
            DisConnectServer()
            CatSdk.instance.catlistener?.onResult(CatState: .OK, Result: _recv)

            return
        default:
            break
        }
        
        DisConnectServer()
        if String(describing: Utils.topMostViewController()).contains("CatAnimationViewController") {
            let controller = Utils.topMostViewController() as! CatAnimationViewController
            controller.GoToReceiptSwiftUI()
            return
        }
    }
    
    
    /// 현금 ic 수신 데이터 파싱 함수
    /// - Parameter _recv: <#_recv description#>
    func ParsingresCashIC(수신데이터 _recv:[UInt8]) -> Dictionary<String,String>?
    {
        var parseData:[UInt8] = _recv   //데이터를 지워 가면서 작업을 해야 해서 임시로 변수 하나 지정
        //본격적인 파싱 시작
        var data:[String:String] = [:]

        //데이터 사이즈 체크
        if _recv.count < 6 {
            return nil
        }
        //데이터 시작이 stx가 아니면 취소
        if _recv[0] != Command.STX {
            return nil
        }
        
        parseData.remove(at: 0) //STX 삭제
        var rng = 4 //데이터를 짜르기 위한 범위
        data["TrdType"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])); parseData.removeSubrange(0..<rng) //명령코드 4byte
        rng = 3;data["ResponseNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])); parseData.removeSubrange(0..<rng) //거래전문번호 3byte  //x
        rng = 10;data["TermID"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])); parseData.removeSubrange(0..<rng) //TID 10byte   //x
        rng = 12;data["TrdDate"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])).replacingOccurrences(of: " ", with: ""); parseData.removeSubrange(0..<rng) //거래일시
        rng = 4;data["AnsCode"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])); parseData.removeSubrange(0..<rng) //응답코드 정상응답(응답코드: 0000, 0001, 0002, 9901)
        rng = 64;data["Message"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])); parseData.removeSubrange(0..<rng) //신용:앞 40Byte+뒤 40Byte Space
        rng = 13;data["AuNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])).replacingOccurrences(of: " ", with: ""); parseData.removeSubrange(0..<rng) //승인번호
        rng = 20;data["TradeNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])).replacingOccurrences(of: " ", with: ""); parseData.removeSubrange(0..<rng) //코세스거래고유번호
        rng = 20;data["CardNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng])).replacingOccurrences(of: " ", with: ""); parseData.removeSubrange(0..<rng) //신용,은련,DCC: 출력시 사용될 Track2 정보,현금: 출력 시 사용될 신분확인번호 정보
        //현금 IC 는 서버에서 주는 대로 쓴다
//        data["CardNo"] = CatSdk.instance.mDBAppToApp ?
//        Utils.CardParser(카드번호: data["CardNo"]!, 날짜90일경과: true):Utils.CardParser(카드번호: data["CardNo"]!)
        rng = 8;/*data["TrType"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //거래종류명  //x
        rng = 16;data["MchNo"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //가맹점번호
        rng = 7;data["OrdCd"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //발급사코드
        rng = 16;data["OrdNm"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //발급사명
        rng = 7;data["InpCd"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //매입사코드
        rng = 16;data["InpNm"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //매입사명
        rng = 25;data["ServeMoney"] = Utils.utf8toHangul(str: Array(parseData[13..<rng]));parseData.removeSubrange(0..<rng) //잔액 -> 데이터가 이상해서 뒤에서부터 잘라서 총 12자리만 실어보냄
        rng = 64;data["MchData"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));parseData.removeSubrange(0..<rng) //가맹점데이터
        rng = 12;/*data["Money"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //거래금액 12byte   //x
        rng = 12
        /*data["Tax"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //세금 12byte  //x
        /*data["Svc"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //봉사료 12byte    //x
        /*data["Txf"] = Utils.utf8toHangul(str: Array(parseData[0..<rng]));*/ parseData.removeSubrange(0..<rng) //비과세 12byte    //x
  
        if parseData.count == 2 {
            return data
        }

        //남은데이터가 맞지 않는다. 파싱이 잘못되었다.
        return nil
    }
    
    func getCashTarget(대상입력 _Target:Int) -> define.TradeMethod {
        var tar:define.TradeMethod = define.TradeMethod.NULL
        switch _Target {
        case 1:
            tar = define.TradeMethod.CashPrivate
            break
        case 2:
            tar = define.TradeMethod.CashBusiness
            break
        case 3:
            tar = define.TradeMethod.CashSelf
            break
        default:
            tar = define.TradeMethod.NULL
            break
        }
        
        return tar
    }

    func CnvStr(_c:[UInt8]) -> String {
        if _c == nil {
            return ""
        }
        
        if _c.count == 0 {
            return ""
        }
        return Utils.UInt8ArrayToStr(UInt8Array: _c)
    }
    
    func MarkingCardNumber(카드번호앞자리 _cardNum:String) -> String {

        if(_cardNum.count == 6) {
            let arr:[Character] = Array(_cardNum)
            var cardNo:String = String( arr[0...3])
            cardNo += "-"
            cardNo += String(arr[4...5])
            cardNo += "**-****-****"
            return cardNo
        }
        
        return _cardNum
    }
    
    //캣으로부터 E 취소커맨드가 들어오면 우리도 E 취소커맨드를 날리고 Ack가 들어오는지 확인후 종료한다
    func Cat_SendCancelCommandE(메세지 _msg:String) {
        DispatchQueue.global(qos: .background).async() { [self] in
            if !TcpSend(Data: Data(Command.Cat_CancelCMD_E()), Client: mSwiftSocket!) {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(전문) 전송에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            
            let recv:[UInt8] = TcpRead(Client: mSwiftSocket!)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                
                return
            }
            
            //        if recv[0] != Command.ACK
            //        {
            //            DisConnectServer()
            //            var resDataDic:[String:String] = [:]
            //            resDataDic["Message"] = "CAT 단말기 데이터(ACK) 수신에 실패했습니다."
            //            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
            //          
            //            return
            //        }
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = _msg
            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
        }
        return
    }
    
    func Cat_noTranTrade(CompletionCallback Result:CatResultDelegate) {
        Clear()
        CatSdk.instance.catlistener = Result
        
        if ConnectServer() == false {
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 단말기 IP/PORT 설정이 잘못되었습니다."
            Result.onResult(CatState: .ERROR, Result: resDataDic)
            return
        }
        if CheckBeforeTrade() == false {
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 단말기 연결에 실패했습니다."
            Result.onResult(CatState: .ERROR, Result: resDataDic)
            return
        }
        
        if !TcpSend(Data: Data(Command.Cat_noTranTrade()), Client: mSwiftSocket!) {
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 단말기 데이터(전문) 전송에 실패했습니다."
            Result.onResult(CatState: .ERROR, Result: resDataDic)
            return
        }
        
        var recv:[UInt8] = TcpRead(Client: mSwiftSocket!)
        
        if recv.count == 0 {
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
          
            return
        }
        
        if recv[0] != Command.ACK
        {
            LogFile.instance.InsertLog(LOG_RECEIVE_ACK_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 단말기 데이터(ACK) 수신에 실패했습니다."
            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
         
            return
        }
        
        recv = TcpRead(Client: mSwiftSocket!, Timeout: 60)
        
        if recv.count == 0 {
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
           
            return
        }
        let str1 = Utils.UInt8ArrayToStr(UInt8Array: recv)
        if str1.contains("A110") {
            LogFile.instance.InsertLog(LOG_RECEIVE_A110 + str1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            
            let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
            if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            debugPrint("A110 수신후 애크2개 보냄)")
        } else {
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 단말기 거래내역 수신 실패"
            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
           
            return
        }
        
        recv = TcpRead(Client: mSwiftSocket!)
        if recv.count == 0 {
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
         
            return
        }
        if recv[1] == 0x47 {
            LogFile.instance.InsertLog(LOG_RECEIVE_G, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            var responseData = recv
            responseData.removeFirst()  //stx
            var range = 0...3
            let stringcomand = [UInt8](responseData[range])
            debugPrint("Command -> ", Utils.utf8toHangul(str: stringcomand))
            responseData.removeSubrange(range)
            range = 0...91
            responseData.removeSubrange(range)
            range = 0...3
            let resCode = [UInt8](responseData[range])
            debugPrint("AnsCode -> ", Utils.utf8toHangul(str: resCode))
            responseData.removeSubrange(range)
            range = 0...39
            let msg = [UInt8](responseData[range])
            debugPrint("msg -> ", Utils.utf8toHangul(str: msg))
            responseData.removeSubrange(range)

            let finish:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
            if !TcpSend(Data: Data(finish), Client: mSwiftSocket!) {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
        } else if recv[1] == Command.NAK {
            LogFile.instance.InsertLog(LOG_RECEIVE_NAK, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            //Nak 올라오면 재전송1회 시도
            let ack:[UInt8] = [Command.ACK,Command.ACK] // TR Command가 오면 ACK 2개를 보낸다.
            if !TcpSend(Data: Data(ack), Client: mSwiftSocket!) {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터(ACK,ACK) 전송에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                return
            }
            recv = TcpRead(Client: mSwiftSocket!)
            
            if recv.count == 0 {
                DisConnectServer()
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
                CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                
                return
            }
            if recv[1] == 0x47 {
                LogFile.instance.InsertLog(LOG_RECEIVE_G, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
                var responseData = recv
                responseData.removeFirst()  //stx
                var range = 0...3
                let stringcomand = [UInt8](responseData[range])
                responseData.removeSubrange(range)
                range = 0...91
                responseData.removeSubrange(range)
                range = 0...3
                let resCode = [UInt8](responseData[range])
                responseData.removeSubrange(range)
                range = 0...39
                let msg = [UInt8](responseData[range])
                responseData.removeSubrange(range)

                let finish:[UInt8] = Command.Cat_ResponseTrade(Command: ResponseCommand(커맨드: String(bytes: stringcomand, encoding: .utf8)!), Code: [0x30,0x30,0x30,0x30], Message: "정상수신")
                if !TcpSend(Data: Data(finish), Client: mSwiftSocket!) {
                    DisConnectServer()
                    var resDataDic:[String:String] = [:]
                    resDataDic["Message"] = "CAT 단말기 데이터(완료) 전송에 실패했습니다."
                    CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
                    return
                }
            }
        }
        
        let recvEOT:[UInt8] = TcpRead(Client: mSwiftSocket!)
        
        if recvEOT.count == 0 {
            LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_1, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 단말기 데이터 수신에 실패했습니다."
            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
           
            return
        }
        
        if recvEOT[0] != Command.EOT
        {
            LogFile.instance.InsertLog(LOG_RECEIVE_EOT_FAIL_2, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "CAT 단말기 데이터(EOT) 수신에 실패했습니다."
            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
          
            return
        }
        
        LogFile.instance.InsertLog(LOG_RECEIVE_EOT_SUCCESS, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
        
        var responseData = recv
        responseData.removeFirst()  //stx
        var range = 0...3
        let stringcomand = [UInt8](responseData[range])
        debugPrint("Command -> ", Utils.utf8toHangul(str: stringcomand))
        responseData.removeSubrange(range)
        range = 0...91
        responseData.removeSubrange(range)
        range = 0...3
        let resCode = [UInt8](responseData[range])
        debugPrint("AnsCode -> ", Utils.utf8toHangul(str: resCode))
        responseData.removeSubrange(range)
        range = 0...39
        let msg = [UInt8](responseData[range])
        debugPrint("msg -> ", Utils.utf8toHangul(str: msg))
        responseData.removeSubrange(range)
        if Utils.utf8toHangul(str: resCode) != "0000" {
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = Utils.utf8toHangul(str: msg)
            resDataDic["AnsCode"] = Utils.utf8toHangul(str: resCode)
            
            LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_CODE_SUCCESS + Utils.utf8toHangul(str: resCode), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_MESSAGE_SUCCESS + Utils.utf8toHangul(str: msg), Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)

            DisConnectServer()
            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
         
            return
        }
        
        guard let pData = ParsingresData(수신데이터: recv) else {
            LogFile.instance.InsertLog(LOG_RECEIVE_ERROR_PARSING_FAIL, Tid: CatSdk.instance.Tid == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):CatSdk.instance.Tid)
            
            DisConnectServer()
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "데이터 파싱에 실패했습니다."
            CatSdk.instance.catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
          
            return
        }
        
        InsertDBTradeData_TypeCrdit(수신데이터: pData)

        DisConnectServer()
        return
    }

    func DisConnectServer() {
        mSwiftSocket?.close()
        Clear()
    }
}
extension String {
    func substring(시작: Int, 끝: Int) -> String {
        guard 시작 < count, 끝 >= 0, 끝 - 시작 >= 0 else {
            return ""
        }
        
        // Index 값 획득
        let startIndex = index(self.startIndex, offsetBy: 시작)
        let endIndex = index(self.startIndex, offsetBy: 끝 + 1) // '+1'이 있는 이유: endIndex는 문자열의 마지막 그 다음을 가리키기 때문
        
        // 파싱
        return String(self[startIndex ..< endIndex])
    }
    
    func substring(시작: Int) -> String {
        guard 시작 < count else {
            return ""
        }
        
        // Index 값 획득
        let startIndex = index(self.startIndex, offsetBy: 시작)
     
        // 파싱
        return String(self[startIndex... ])
    }
}
