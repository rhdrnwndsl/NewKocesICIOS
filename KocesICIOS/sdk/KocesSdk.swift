//
//  KocesSdk.swift
//  osxapp
//
//  Created by 金載龍 on 2021/01/12.
//

import Foundation
import UIKit
import CoreBluetooth
import SwiftSocket

class KocesSdk : BLEManagerDelegate{
    
    static let instance:KocesSdk = KocesSdk()
    var mSetting:Setting = Setting.shared
    let mPaySdk = PaySdk.instance
    let mKakaoSdk = KaKaoPaySdk.instance
    let mSqlite = sqlite.instance
    let mTaxCalc = TaxCalculator.Instance
    
    //블루투스 상태에관한 변수명을 선언한다
    var bleState:define.TargetDeviceState = define.TargetDeviceState.BLENOCONNECT
    var blePrintState:define.PrintDeviceState = define.PrintDeviceState.BLENOPRINT
    
    var tcplinstener:TcpResultDelegate?
    var mSwiftSocket:TCPClient? //soket 통신은 이걸로 한다

    
    var printListener:PrintResultDelegate?
    var devices:[[String: Any]] = [[String: Any]]()
    var isPaireduuid: UUID = UUID()
    var isPairedDevice: [[String: Any]] = [[String: Any]]()
    var manager = BLEManager()
    var focusViewController : UIViewController?
    var mReceivedData:[UInt8] = Array() //ble 수신 전체 데이터 담는 배열
    var mReceiveDataSize:Int = 0    //ble 수신 데이터 전체 길이
    var mSendLastData:[UInt8] = []   //데이터를 정상적으로 모두 보내고 마지막으로 보낸 데이터의 값
    var mEotCheck:Int = 0  //EOT를 받았는지 체크
    var mVerityCheck:String = define.VerityMethod.Default.rawValue //앱무결성검사를 정상적으로 통과했는지를 체크 fail=실패 success=성공. default=기본(미실행) 실패일경우 신용/현금 거래를 할 수 없다
    
    var StringPlist:NSDictionary?
    
    /** 메인화면 혹은 기타 다른 특정 뷰에서 표시할 ble 장치의 정보 */
    var mModelNumber = ""
    var mSerialNumber = ""
    var mModelVersion = ""
    var mKocesCode:String = ""
    var mAppCode:String = ""
    
    /** 지금 현재 연결된  ble 장비 이름과 uuid */
    public var mBleConnectedName:String = ""
    public var mBleConnectedUUID:String = ""
    
    /** 최초 실행 중인지 체크. 메인화면에서 블루투스검사를 1회만 하기 위해서 체크 */
    var mFirstRunning:Int = 0  //1 = 최초실행, 2 = 메인화면에 2회이상 들어옴
    
    var mLogTid:String = "" //로그를 찍는데 사용된 TID. 해당 TID는 서버에 데이터를 전송시 오류가 났을 경우에 로그찍을 때 사용된다
    
    var BleConnectCound:Int = 0 //ble 연결시 재시도 횟수
    
    public var listProducts:[Product] = Array()
    
    private init()
    {

        setDefault()
    }
    
    /**
     최초 실행시 기본 필요한 모든 정보를 저장 한다
     */
    private func setDefault()
    {
        //초기 설정 값들을 읽어서 설정 시킨다.
        //설정 Setting
        if Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_IP) == "" {
            Setting.shared.setDefaultUserData(_data: Setting.HOST_STORE_DOWNLOAD_IP, _key: define.HOST_SERVER_IP)
            Setting.shared.setDefaultUserData(_data: String(Setting.HOST_STORE_DOWNLOAD_PORT), _key: define.HOST_SERVER_PORT)
        }
        
        //프린트 설정은 일단 고객용은 출력하게 설정해 둔다
        if Setting.shared.getDefaultUserData(_key: define.PRINT_CUSTOMER) == "" {
            Setting.shared.setDefaultUserData(_data: "PRINT_CUSTOMER", _key: define.PRINT_CUSTOMER)
        }
        
        //Qr 설정. 초기에는 카메라를 불러오는 것으로 설정해 둔다
        if Setting.shared.getDefaultUserData(_key: define.QR_CAT_CAMERA) == "" {
            Setting.shared.setDefaultUserData(_data: "0", _key: define.QR_CAT_CAMERA)
        }
        
        //프린트 설정에서 일단 출력을 cat으로 설정한다
        if Setting.shared.getDefaultUserData(_key: define.PRINTDEVICE).isEmpty ||
            Setting.shared.getDefaultUserData(_key: define.PRINTDEVICE) == "" {
            
            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE).isEmpty ||
                Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == "" {
                blePrintState = define.PrintDeviceState.BLENOPRINT  //cat 연결 되어 있는 상태로 변경한다.
                //어플 기동 할 때 타겟 대상을 결정
                Setting.shared.setDefaultUserData(_data: define.PRINTBLE, _key: define.PRINTDEVICE)
            } else if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.PRINTCAT {
                blePrintState = define.PrintDeviceState.CATUSEPRINT
                Setting.shared.setDefaultUserData(_data: define.PRINTCAT, _key: define.PRINTDEVICE)
            } else if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.PRINTBLE {
                blePrintState = define.PrintDeviceState.BLEUSEPRINT
                Setting.shared.setDefaultUserData(_data: define.PRINTBLE, _key: define.PRINTDEVICE)
            } else {
                //프린트 없음
                blePrintState = define.PrintDeviceState.BLENOPRINT
                Setting.shared.setDefaultUserData(_data: define.PRINTBLE, _key: define.PRINTDEVICE)
            }
          
        } else if Setting.shared.getDefaultUserData(_key: define.PRINTDEVICE) == define.PRINTCAT {
            blePrintState = define.PrintDeviceState.CATUSEPRINT
            Setting.shared.setDefaultUserData(_data: define.PRINTCAT, _key: define.PRINTDEVICE)
        } else if Setting.shared.getDefaultUserData(_key: define.PRINTDEVICE) == define.PRINTBLE {
            blePrintState = define.PrintDeviceState.BLEUSEPRINT
            Setting.shared.setDefaultUserData(_data: define.PRINTBLE, _key: define.PRINTDEVICE)
        } else {
            //프린트 없음
            blePrintState = define.PrintDeviceState.BLENOPRINT
            Setting.shared.setDefaultUserData(_data: define.PRINTBLE, _key: define.PRINTDEVICE)
        }

        //sqlite 파일 생성
        
        //string plist 읽어 온다.
        StringPlist = Utils.getStringPlist()

        mPaySdk.Clear()
        mKakaoSdk.Clear()
        LogFile.instance.DeleteLog()
        let _key = KeychainWrapper.standard.data(forKey: define.APP_KEYCHAIN)
        KeychainWrapper.standard.removeObject(forKey: define.APP_KEYCHAIN)

        DispatchQueue.main.async {
            self.mSqlite.DBUpdate()
            self.getProductList()
        }
    }
    
    func getTid() -> String {
        return Utils.getIsCAT() ?
        Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID):
        Setting.shared.getDefaultUserData(_key: define.STORE_TID)
    }
    
    func getProductList() {
        // DB에서 전체 상품정보를 가져옴 (옵셔널 바인딩 사용)
        guard let allProducts = sqlite.instance.getProductInfoAllList(pSeq: "") else {
            listProducts.removeAll()
            return
        }
        
        // 가져온 전체 데이터 중 현재 TID와 일치하는 데이터만 처리
        for data in allProducts where data.tid == getTid() {
            // 새로운 Product 객체 생성 및 데이터 설정
            var newProduct = Product()
            newProduct.setAll(
                id: data.id,
                tid: data.tid,
                productSeq: data.productSeq,
                tableNo: data.tableNo,
                code: data.code,
                name: data.name,
                category: data.category,
                price: Int(data.price) ?? 0,
                pDate: data.date,
                barcode: data.barcode,
                isUse: data.isUse,
                imgUrl: data.imgUrl,
                desc: "",
                imgString: data.imgString,
                useVAT: data.vatUse,
                autoVAT: data.vatMode,
                includeVAT: data.vatInclude,
                vatRate: data.vatRate,
                vatWon: data.vatWon,
                useSVC: data.svcUse,
                autoSVC: data.svcMode,
                includeSVC: data.svcInclude,
                svcRate: data.svcRate,
                svcWon: data.svcWon,
                totalPrice: data.totalPrice,
                count: 0,
                isImgUse: data.isImgUse
            )
            
            // 동일한 코드가 이미 등록되어 있는지 확인
            if let index = listProducts.firstIndex(where: { $0.code == data.code }) {
                // 이미 등록되어 있다면 해당 상품의 내용을 업데이트
                listProducts[index].setAll(
                    id: data.id,
                    tid: data.tid,
                    productSeq: data.productSeq,
                    tableNo: data.tableNo,
                    code: data.code,
                    name: data.name,
                    category: data.category,
                    price: Int(data.price) ?? 0,
                    pDate: data.date,
                    barcode: data.barcode,
                    isUse: data.isUse,
                    imgUrl: data.imgUrl,
                    desc: "",
                    imgString: data.imgString,
                    useVAT: data.vatUse,
                    autoVAT: data.vatMode,
                    includeVAT: data.vatInclude,
                    vatRate: data.vatRate,
                    vatWon: data.vatWon,
                    useSVC: data.svcUse,
                    autoSVC: data.svcMode,
                    includeSVC: data.svcInclude,
                    svcRate: data.svcRate,
                    svcWon: data.svcWon,
                    totalPrice: data.totalPrice,
                    count: 0,
                    isImgUse: data.isImgUse
                )
            } else {
                // 동일한 코드가 없다면 리스트에 추가
                listProducts.append(newProduct)
            }
        }
    }
    
    func setProductData(seq:String) {
        // DB에서 전체 상품정보를 가져옴 (옵셔널 바인딩 사용)
        guard let allProducts = sqlite.instance.getProductInfoAllList(pSeq: seq) else {
            return
        }
        // 가져온 전체 데이터 중 현재 TID와 일치하는 데이터만 처리
        for data in allProducts where data.tid == getTid() {
            // 새로운 Product 객체 생성 및 데이터 설정
            var newProduct = Product()
            newProduct.setAll(
                id: data.id,
                tid: data.tid,
                productSeq: data.productSeq,
                tableNo: data.tableNo,
                code: data.code,
                name: data.name,
                category: data.category,
                price: Int(data.price) ?? 0,
                pDate: data.date,
                barcode: data.barcode,
                isUse: data.isUse,
                imgUrl: data.imgUrl,
                desc: "",
                imgString: data.imgString,
                useVAT: data.vatUse,
                autoVAT: data.vatMode,
                includeVAT: data.vatInclude,
                vatRate: data.vatRate,
                vatWon: data.vatWon,
                useSVC: data.svcUse,
                autoSVC: data.svcMode,
                includeSVC: data.svcInclude,
                svcRate: data.svcRate,
                svcWon: data.svcWon,
                totalPrice: data.totalPrice,
                count: 0,
                isImgUse: data.isImgUse
            )
            
            // 동일한 코드가 이미 등록되어 있는지 확인
            if let index = listProducts.firstIndex(where: { $0.code == data.code }) {
                // 이미 등록되어 있다면 해당 상품의 내용을 업데이트
                listProducts[index].setAll(
                    id: data.id,
                    tid: data.tid,
                    productSeq: data.productSeq,
                    tableNo: data.tableNo,
                    code: data.code,
                    name: data.name,
                    category: data.category,
                    price: Int(data.price) ?? 0,
                    pDate: data.date,
                    barcode: data.barcode,
                    isUse: data.isUse,
                    imgUrl: data.imgUrl,
                    desc: "",
                    imgString: data.imgString,
                    useVAT: data.vatUse,
                    autoVAT: data.vatMode,
                    includeVAT: data.vatInclude,
                    vatRate: data.vatRate,
                    vatWon: data.vatWon,
                    useSVC: data.svcUse,
                    autoSVC: data.svcMode,
                    includeSVC: data.svcInclude,
                    svcRate: data.svcRate,
                    svcWon: data.svcWon,
                    totalPrice: data.totalPrice,
                    count: 0,
                    isImgUse: data.isImgUse
                )
            } else {
                // 동일한 코드가 없다면 리스트에 추가
                listProducts.append(newProduct)
            }
        }
        
    }
    
    func TcpSend(Data _data:Data, Client _client:TCPClient) -> Bool{

        switch _client.send(data: _data) {
        case .success:

            return true
        case .failure(let error):
            debugPrint("Swift Socket Data Send Error : ", error)

            return false
        }
    }
    
    func clearProductList() {
        listProducts.removeAll()
        listProducts = []
    }
    
    func TcpRead(Client _client:TCPClient, Time _time:Int = 30) -> [UInt8] {
        guard let response = _client.read(1024*10, timeout: _time) else {

            return []
        }

        return response
    }
    
    func SendTcpTran(requstData _Data:[UInt8]) -> [UInt8]
    {
        if !Utils.isInternetAvailable() {
            let responseData: [UInt8] = []
            return responseData
        }

        var _ip = ""
        var _port = ""
        if Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_IP).isEmpty {
            _ip = Setting.HOST_STORE_DOWNLOAD_IP
        } else {
            _ip = Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_IP)
        }
        
        if Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_PORT).isEmpty {
            _port = String(Setting.HOST_STORE_DOWNLOAD_PORT)
        } else {
            _port = Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_PORT)
        }
        
        mSwiftSocket = TCPClient.init(address: _ip, port: Int32(_port) ?? 10555)

        guard let client = mSwiftSocket  else {
            let responseData: [UInt8] = []
            mSwiftSocket?.close()
            return responseData
        }
        
        switch client.connect(timeout: 5) {
        case .success:

            debugPrint("SwiftSocket Connect Success")
            break
        case .failure(let error):
            debugPrint("SwiftSocket Connect Error : ", error)
            LogFile.instance.InsertLog("TCPServer Error : 서버연결실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
            let responseData: [UInt8] = []
            client.close()
            mSwiftSocket?.close()
            return responseData
        }

        var CheckEnqData: [UInt8] = TcpRead(Client: client, Time: 15)
        if CheckEnqData.count == 0 || CheckEnqData[0] != Command.ENQ {
            //다시한번 받아서 enq 가 안올라온다면 연결이 정상적으로 안된 것이니 연결을 끊는다
            CheckEnqData = TcpRead(Client: client, Time: 15)
            if CheckEnqData.count == 0 || CheckEnqData[0] != Command.ENQ {
                debugPrint("'Enq' data not received from server")
                // 연결이 되지 않았다
                LogFile.instance.InsertLog("TCPServer Error : 'Enq' 데이터 받기 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                client.close()
                mSwiftSocket?.close()
                return responseData
            }
        }

        if !TcpSend(Data: Data(_Data), Client: client) {
            LogFile.instance.InsertLog("TCPServer Error : 전문 보내기 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
            let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
            client.close()
            mSwiftSocket?.close()
            return responseData
        }

        var chunk = TcpRead(Client: client)
        
        if chunk.count == 0 {
            LogFile.instance.InsertLog("TCPServer Error : 요청전문 보낸 후 서버대기(30초) 타임아웃으로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
            let responseData: [UInt8] = Command.TIMEOUT
            client.close()
            mSwiftSocket?.close()
            return responseData
        }
        
        //nak 1
        if chunk[0] == Command.NAK {
            LogFile.instance.InsertLog("TCPServer Error : NAK(1) 수신 후 전문 다시보내기", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: _Data), Tid: KocesSdk.instance.mLogTid)
            if !TcpSend(Data: Data(_Data), Client: client) {
                LogFile.instance.InsertLog("TCPServer Error : NAK(1) 수신 후 전문 다시보내기 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                client.close()
                mSwiftSocket?.close()
                return responseData
            }
            chunk = TcpRead(Client: client)
            //nak 2
            if chunk.count == 0 || chunk[0] == Command.NAK {
                LogFile.instance.InsertLog("TCPServer Error : NAK(2) 수신 후 전문 다시보내기", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: _Data), Tid: KocesSdk.instance.mLogTid)
                if !TcpSend(Data: Data(_Data), Client: client) {
                    LogFile.instance.InsertLog("TCPServer Error : NAK(2) 수신 후 전문 다시보내기 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                    let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                    client.close()
                    mSwiftSocket?.close()
                    return responseData
                }
                chunk = TcpRead(Client: client)
                //nak 3 = disconnect
                if chunk.count == 0 || chunk[0] == Command.NAK {
                    LogFile.instance.InsertLog("TCPServer Error : NAK(3) 수신 후 거래 종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                    let responseData: [UInt8] = Array(arrayLiteral: Command.NAK)
                    client.close()
                    mSwiftSocket?.close()
                    return responseData
                }
            }
        }
        
        //오류전문 1
        if !Utils.CheckLRC(bytes: chunk) {
            LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보내기(1)", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: [Command.NAK]), Tid: KocesSdk.instance.mLogTid)
            if !TcpSend(Data: Data([Command.NAK]), Client: client) {
                LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보내기(1) 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                client.close()
                mSwiftSocket?.close()
                return responseData
            }
         
            chunk = TcpRead(Client: client, Time: 3)
          
            if chunk.count == 0 {
                sleep(3)
                chunk = TcpRead(Client: client, Time: 3)
                if !TcpSend(Data: Data([Command.NAK]), Client: client) {
                    LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보낸 후 3초간 무응답으로 NAK 보내기 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                    let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                    client.close()
                    mSwiftSocket?.close()
                    return responseData
                }
//                sleep(3)
                LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보낸 후 3초간 무응답으로 NAK 보내기", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: [Command.NAK]), Tid: KocesSdk.instance.mLogTid)
                
                sleep(3)
                chunk = TcpRead(Client: client, Time: 3)
                
                if chunk.count == 0 {
//                    LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보낸 후 3초간 무응답으로 NAK 보내기(2)", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
//                    LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: [Command.NAK]), Tid: KocesSdk.instance.mLogTid)
//                    if !TcpSend(Data: Data([Command.NAK]), Client: client) {
//                        LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보낸 후 3초간 무응답으로 NAK 보내기(2) 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
//                        let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
//                        return responseData
//                    }
                   
                    LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보낸 후 3초간 무응답으로 NAK 보내고 3초뒤 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                    let responseData: [UInt8] = Array(arrayLiteral: Command.ETX)
                    client.close()
                    mSwiftSocket?.close()
                    return responseData
                }
                
            }
            
            //오류전문 2
            if !Utils.CheckLRC(bytes: chunk) {
                LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보내기(2)", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: [Command.NAK]), Tid: KocesSdk.instance.mLogTid)
                if !TcpSend(Data: Data([Command.NAK]), Client: client) {
                    LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보내기(2) 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                    let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                    client.close()
                    mSwiftSocket?.close()
                    return responseData
                }
                chunk = TcpRead(Client: client)
                //오류전문 3
                if !Utils.CheckLRC(bytes: chunk) {
                    LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보내기(3)", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                    LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: [Command.NAK]), Tid: KocesSdk.instance.mLogTid)
                        if !TcpSend(Data: Data([Command.NAK]), Client: client) {
                            LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK 보내기(3) 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                            let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                            client.close()
                            mSwiftSocket?.close()
                            return responseData
                        }
                    LogFile.instance.InsertLog("TCPServer Error : LRC값 오류로 NAK(총3회) 보낸 후 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                    let responseData: [UInt8] = Array(arrayLiteral: Command.ESC)
                    client.close()
                    mSwiftSocket?.close()
                    return responseData
                }
            }

        }
        
        var responseData: [UInt8] = Array()
        if(chunk.count > 0){
            responseData += [UInt8](chunk)
        }

        let sendTripleAck:[UInt8] = [Command.ACK,Command.ACK,Command.ACK]
        if !TcpSend(Data: Data(sendTripleAck), Client: client) {
            LogFile.instance.InsertLog("TCPServer Error : ARK,ARK,ARK 보내기 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
            let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
            client.close()
            mSwiftSocket?.close()
            return responseData
        }
        var CheckEOTData: [UInt8] = TcpRead(Client: client, Time: 10)
        
        if CheckEOTData.count == 0 || CheckEOTData[0] != Command.EOT
        {
            LogFile.instance.InsertLog("TCPServer Error : EOT 미수신(1)으로 ARK,ARK,ARK 재전송", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
            LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: sendTripleAck), Tid: KocesSdk.instance.mLogTid)
            if !TcpSend(Data: Data(sendTripleAck), Client: client) {
                LogFile.instance.InsertLog("TCPServer Error : EOT 미수신(1)으로 ARK,ARK,ARK 재전송 실패로 거래종료", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                client.close()
                mSwiftSocket?.close()
                return responseData
            }

            CheckEOTData = TcpRead(Client: client, Time: 10)
            if CheckEOTData.count == 0 || CheckEOTData[0] != Command.EOT
            {
                LogFile.instance.InsertLog("TCPServer Error : EOT 미수신(2)으로 망취소 진행", Tid: KocesSdk.instance.mLogTid, TimeStamp: true)
                debugPrint("'EOT' data not received from server")
                //eot 미수신 mEotCheck 가 0이 아니면 2번 이상 미수신이라 초기화 한다
                KocesSdk.instance.mEotCheck += 1
            }
            else
            {
                //eot 수신 성공해서 다시 mEotCheck 를 초기화한다
                KocesSdk.instance.mEotCheck = 0
            }
        }
        else
        {
            //eot 수신 성공해서 다시 mEotCheck 를 초기화한다
            KocesSdk.instance.mEotCheck = 0
        }

        client.close()
        mSwiftSocket?.close()
        return responseData
    }
    
    
    func CalendarResult(Command 전문번호:String,Tid _Tid:String,Date 거래일시: String,PosVer 단말버전:String,Etc 단말추가정보:String, StartDay 조회시작일자:String, EndDay 조회종료일자:String, MchData 가맹점데이터:String, CallbackListener _linstener:TcpResultDelegate)
    {
        typealias ar = Array
        tcplinstener = _linstener
        
        //서버 요청 전문 만들기
        var Response: [UInt8] = SendTcpTran(requstData: Command.TcpCalendarResult(Command: 전문번호, Tid: _Tid, Date: 거래일시, PosVer: 단말버전, Etc: 단말추가정보, StartDay: 조회시작일자, EndDay: 조회종료일자, MchData: 가맹점데이터))
        
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        
        if Response.count == 0
        {
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint(" TCP server To Device = \(strRes)")
        
        
        if Response.isEmpty {
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.NAK {
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (NAK 응답 수신)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (오류전문 수신)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        
        let res:Command.TcpResParsingData = Command.TcpResDataParser(ResData: Response)

        
        if res.Data.count < 3 || res.error=="fail" {
            resDataDic["Message"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            resDataDic["ERROR"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        var des:[UInt8] = ar(res.Data[2])
        //응답 코드
        resDataDic["AnsCode"] = des == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: des) //응답 코드가 0000
        //응답 메세지
        des = ar(res.Data[3])
        resDataDic["Message"] = Utils.utf8toHangul(str: des)
        //길이
        
        if resDataDic["AnsCode"] != "0000" {
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        des = ar(res.Data[4])   //집계시작일
        resDataDic["StartDay"] = Utils.utf8toHangul(str: des)
        des = ar(res.Data[5])   //집계종료일
        resDataDic["EndDay"] = Utils.utf8toHangul(str: des)
        des = ar(res.Data[6])   //집계데이터
        resDataDic["국내신용총승인건수"] = Utils.utf8toHangul(str: Array(des[0...5]))
        resDataDic["국내신용총승인금액"] = Utils.utf8toHangul(str: Array(des[6...15]))
        resDataDic["국내신용총취소건수"] = Utils.utf8toHangul(str: Array(des[16...21]))
        resDataDic["국내신용총취소금액"] = Utils.utf8toHangul(str: Array(des[22...31]))
        resDataDic["국내신용레코드개수"] = Utils.utf8toHangul(str: Array(des[32...33]))
        //국내신용총승인건수6
        //국내신용총승인금액10
        //국내신용총취소건수6
        //국내신용총취소금액10
        //국내신용레코드개수2
        ////신용카드사코드4
        ////신용카드사명12
        ////신용승인건수6
        ////신용승인금액10
        ////신용취소건수6
        ////신용취소금액10
        //외화구분개수2
        //외화표기문자코드3
        //외화표기소수점1
        var 국내신용:Int = Int(resDataDic["국내신용레코드개수"]! )! * 48
        resDataDic["외화구분개수"] = Utils.utf8toHangul(str: Array(des[34+국내신용...35+국내신용]))
        var 외화:Int = 0
        if Int(resDataDic["외화구분개수"]! )! > 0 {
            국내신용 = 국내신용 + 2 + 3 + 1
            resDataDic["외화총승인건수"] = Utils.utf8toHangul(str: Array(des[34+국내신용...39+국내신용]))
            resDataDic["외화총승인금액"] = Utils.utf8toHangul(str: Array(des[40+국내신용...49+국내신용]))
            resDataDic["외화총취소건수"] = Utils.utf8toHangul(str: Array(des[50+국내신용...55+국내신용]))
            resDataDic["외화총취소금액"] = Utils.utf8toHangul(str: Array(des[56+국내신용...65+국내신용]))
            resDataDic["외화레코드개수"] = Utils.utf8toHangul(str: Array(des[66+국내신용...67+국내신용]))
            외화 = Int(resDataDic["외화레코드개수"]! )! * 48 + 34
        } else {
            국내신용 = 국내신용 + 2
        }

       
        //외화총승인건수6
        //외화총승인금액10
        //외화총취소건수6
        //외화총취소금액10
        //외화레코드개수2
        ////외화매입사코드4
        ////외화매입사명12
        ////외화승인건수6
        ////외화승인금액10
        ////외화취소건수6
        ////외화취소금액10
        
        resDataDic["현금총승인건수"] = Utils.utf8toHangul(str: Array(des[34+국내신용+외화...39+국내신용+외화]))
        resDataDic["현금총승인금액"] = Utils.utf8toHangul(str: Array(des[40+국내신용+외화...49+국내신용+외화]))
        resDataDic["현금총취소건수"] = Utils.utf8toHangul(str: Array(des[50+국내신용+외화...55+국내신용+외화]))
        resDataDic["현금총취소금액"] = Utils.utf8toHangul(str: Array(des[56+국내신용+외화...65+국내신용+외화]))
        resDataDic["현금레코드개수"] = Utils.utf8toHangul(str: Array(des[66+국내신용+외화...67+국내신용+외화]))
        var 현금:Int = Int(resDataDic["현금레코드개수"]! )! * 44
        if 현금 > 0 {
            for i in 1 ... Int(resDataDic["현금레코드개수"]! )! {
                var 구분자 = Utils.utf8toHangul(str: Array(des[68+국내신용+외화+44*(i-1)...79+국내신용+외화+44*(i-1)])).replacingOccurrences(of: " ", with: "")
                resDataDic["현금구분_" + 구분자] = 구분자
                resDataDic["현금승인건수_" + 구분자] = Utils.utf8toHangul(str: Array(des[80+국내신용+외화+44*(i-1)...85+국내신용+외화+44*(i-1)]))
                resDataDic["현금승인금액_" + 구분자] = Utils.utf8toHangul(str: Array(des[86+국내신용+외화+44*(i-1)...95+국내신용+외화+44*(i-1)]))
                resDataDic["현금취소건수_" + 구분자] = Utils.utf8toHangul(str: Array(des[96+국내신용+외화+44*(i-1)...101+국내신용+외화+44*(i-1)]))
                resDataDic["현금취소금액_" + 구분자] = Utils.utf8toHangul(str: Array(des[102+국내신용+외화+44*(i-1)...111+국내신용+외화+44*(i-1)]))
            }
        }
        //현금총승인건수6
        //현금총승인금액10
        //현금총취소건수6
        //현금총취소금액10
        //현금레코드개수2
        ////현금구분12
        ////현금승인건수6
        ////현금승인금액10
        ////현금취소건수6
        ////현금취소금액10
        resDataDic["간편총승인건수"] = Utils.utf8toHangul(str: Array(des[68+국내신용+외화+현금...73+국내신용+외화+현금]))
        resDataDic["간편총승인금액"] = Utils.utf8toHangul(str: Array(des[74+국내신용+외화+현금...83+국내신용+외화+현금]))
        resDataDic["간편총취소건수"] = Utils.utf8toHangul(str: Array(des[84+국내신용+외화+현금...89+국내신용+외화+현금]))
        resDataDic["간편총취소금액"] = Utils.utf8toHangul(str: Array(des[90+국내신용+외화+현금...99+국내신용+외화+현금]))
        resDataDic["간편레코드개수"] = Utils.utf8toHangul(str: Array(des[100+국내신용+외화+현금...101+국내신용+외화+현금]))
        var 간편:Int = Int(resDataDic["간편레코드개수"]! )! * 48
        if 간편 > 0 {
            for i in 1 ... Int(resDataDic["간편레코드개수"]! )! {
                var 구분자 = Utils.utf8toHangul(str: Array(des[106+국내신용+외화+현금+48*(i-1)...117+국내신용+외화+현금+48*(i-1)])).replacingOccurrences(of: " ", with: "")
                resDataDic["간편카드사코드_" + 구분자] = Utils.utf8toHangul(str: Array(des[102+국내신용+외화+현금+48*(i-1)...105+국내신용+외화+현금+48*(i-1)]))
                resDataDic["간편카드사명_" + 구분자] = 구분자
                resDataDic["간편승인건수_" + 구분자] = Utils.utf8toHangul(str: Array(des[118+국내신용+외화+현금+48*(i-1)...123+국내신용+외화+현금+48*(i-1)]))
                resDataDic["간편승인금액_" + 구분자] = Utils.utf8toHangul(str: Array(des[124+국내신용+외화+현금+48*(i-1)...133+국내신용+외화+현금+48*(i-1)]))
                resDataDic["간편취소건수_" + 구분자] = Utils.utf8toHangul(str: Array(des[134+국내신용+외화+현금+48*(i-1)...139+국내신용+외화+현금+48*(i-1)]))
                resDataDic["간편취소금액_" + 구분자] = Utils.utf8toHangul(str: Array(des[140+국내신용+외화+현금+48*(i-1)...149+국내신용+외화+현금+48*(i-1)]))
            }
        }
        //간편총승인건수6
        //간편총승인금액10
        //간편총취소건수6
        //간편총취소금액10
        //간편레코드개수2
        ////간편카드사코드4
        ////간편카드사명12
        ////간편승인건수6
        ////간편승인금액10
        ////간편취소건수6
        ////간편취소금액10
//        resDataDic["ResultData"] = Utils.utf8toHangul(str: des)
        des = ar(res.Data[7])   //가맹점데이터
        resDataDic["MchData"] = Utils.utf8toHangul(str: des)
        
        tcplinstener?.onResult(tcpStatus: tcpStatus.sucess, Result: resDataDic)
        
        //사용한 데이터 초기화
        des = [0]
        des.removeAll()
        resDataDic.removeAll()
        Response = [0]
        Response.removeAll()
    }
    
    /**
     다운로드 가맹점다운로드
     - parameter _Command: "D10" : 가맹점다운로드  "D11","D12" : 복수가맹점다운로드  "D20" : 키업데이트 6
     - parameter _Tid: 단말기 ID
     - parameter _Date: 거래일시 14 N YYMMDDhhmmss
     - parameter _posVer: 전문일련번호
     - parameter _etc: 미정
     - parameter _length: 길이 4byte 128byte => 0128
     - parameter _posCheckdata: 단말 검증 요청 데이터 길이(3byte, ex.087)+TrsmID(7)+Crandom(16)+KEY1_ENC(25바이 트Timpstamp+가변SvrInfo+7바이트TID+16바이트CRandom) MDO : 가맹점 정보 다운로드 ONLY(Key 다운로드 안함) 15
     - parameter _Bsn: 가맹점 사업자 번호
     - parameter _Serial: 장비 제조일련번호
     - parameter _posData: 가맹점데이터
     - parameter _macAddr: 맥어드레스 또는 UUID
     - parameter _directData: 가맹점 다운로드 이후 에 다이렉트로 결제를 요청 하는 경우(앱투앱, 웹투앱으로 해당 내용이 내려올 경우 처리)
     - parameter _data: 서버접속시 사용되는 데이터. 해당데이터가 있다면 서버접속이 완료되었을 때 해당
     - parameter _linstener: 응답 리스너
     */
    func StoreDownload(Command _Command:String,Tid _Tid:String,Date _Date:String,PosVer _posVer:String,Etc _etc:String,Length _length:String,
                       PosCheckData _posCheckdata:String ,BSN _Bsn:String,Serial _Serial:String,PosData _posData:String,MacAddr _macAddr:String,DirectData _directData:Dictionary<String, String> = [:], CallbackListener _linstener:TcpResultDelegate)
    {
        typealias ar = Array
        /** log : StoreDownload */
        LogFile.instance.InsertLog("가맹점다운로드 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        tcplinstener = _linstener
        var Response: [UInt8] = [UInt8]()
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분

        Response = SendTcpTran(requstData: Command.StoreDownloadReq(Command: _Command, Tid: _Tid, Date: _Date, PosVer: _posVer,
                                                                                 Etc: _etc, Length: _length, PosCheckData: _posCheckdata, BSN: _Bsn, Serial: _Serial, PosData: _posData, MacAddr: _macAddr))
        /** log : StoreDownload */
        LogFile.instance.InsertLog("TCPServer -> 가맹점다운로드 App", Tid: _Tid, TimeStamp: true)

        if Response.count == 0
        {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint(" TCP server To Device = \(strRes)")
        
        
        if Response.isEmpty {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.NAK {
            LogFile.instance.InsertLog("NAK 수신.", Tid: _Tid)
            
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (NAK 응답 수신)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            LogFile.instance.InsertLog("응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            LogFile.instance.InsertLog("ESC 수신. 오류전문 수신", Tid: _Tid)
            
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (오류전문 수신)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        
        //var res:Command.TcpResParsingData = Command.TcpResDataParser(ResData: Response)

        if Response.count < 70 { //70bytes STX ~ 단말추가정보까지
            LogFile.instance.InsertLog("응답데이터 오류. 다시 시도해 주세요", Tid: _Tid)
            
            resDataDic["Message"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            resDataDic["ERROR"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        var des:[UInt8] = Array()
        var rangeSize:Int = 0
        
        Response.removeFirst()  //STX 삭제
        rangeSize = 4 + 4 //전문길이,전문버전
        Response.removeSubrange(0..<rangeSize)
        if Response[0] != Command.FS {
            LogFile.instance.InsertLog("응답데이터 파싱 오류. 정상적인 데이터가 아닙니다", Tid: _Tid)
            
            resDataDic["Message"] = NSString("정상적인 데이터가 아닙니다.") as String
            resDataDic["ERROR"] = NSString("정상적인 데이터가 아닙니다.") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        Response.removeFirst()  //FS 삭제
        
        //TrdType
        var TcpCommand = Array(Response[0..<3])
        resDataDic["TrdType"] = Utils.utf8toHangul(str: TcpCommand)
        Response.removeSubrange(0..<3)  //전문번호
        //tid
        resDataDic["TermID"] = Utils.utf8toHangul(str: Array(Response[0..<10]))
        Response.removeSubrange(0..<10)  //TermID
        //date
        resDataDic["TrdDate"] = Utils.utf8toHangul(str: Array(Response[0..<12]))
        Response.removeSubrange(0..<12)  //거래일시
        Response.removeSubrange(0..<6)  //전문일련번호
        Response.removeSubrange(0..<6)  //단말구분,단말버전
        
        if Response[0] != Command.FS{
            for i in 0...Response.count {
                if Response[i] == Command.FS {
                    Response.removeSubrange(0..<i)  //단말 추가 정보
                    break
                }
            }
        }
        
        Response.removeFirst()  //FS 삭제

        resDataDic["AnsCode"] = Array(Response[0..<4]) == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: Array(Response[0..<4]) ) //응답 코드가 0000

        Response.removeSubrange(0..<4)  //응답코드 삭제
        
        Response.removeFirst()  //FS 삭제
        
        //응답 메세지

        resDataDic["Message"] = Utils.utf8toHangul(str: des)
        
        //길이
        //응답메시지
        if Response[0] != Command.FS{
            for i in 0...Response.count {
                if Response[i] == Command.FS {
                    des = Array(Response[0..<i])
                    Response.removeSubrange(0..<i)  //단말 추가 정보
                    break
                }
            }
        }
        
        resDataDic["Message"] = Utils.utf8toHangul(str: des)
        
        Response.removeFirst()  //FS 삭제
        
        if resDataDic["AnsCode"] != "0000" {
            LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        let termialCheckResponseDataSize:Int = Int(Utils.UInt8ArrayToStr(UInt8Array: Array(Response[0..<4])))!
        resDataDic["length"] = Utils.utf8toHangul(str: Array(Response[0..<4]))
        Response.removeSubrange(0..<4)  //길이 삭제
        
        //단말검증응답데이터
        resDataDic["posCheckData"] = Utils.utf8toHangul(str: Array(Response[0..<termialCheckResponseDataSize]))
        Response.removeSubrange(0..<termialCheckResponseDataSize)  //길이 삭제
        
        if Response[0] != Command.FS {
            LogFile.instance.InsertLog("응답데이터 파싱 오류. 정상적인 데이터가 아닙니다", Tid: _Tid)
            
            resDataDic["Message"] = NSString("정상적인 데이터가 아닙니다.") as String
            resDataDic["ERROR"] = NSString("정상적인 데이터가 아닙니다.") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        Response.removeFirst() //FS삭제
        
        var res = Command.FSspliter(Data: Response)
        
        LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
        
//        des = ar(res[0]);resDataDic["creditA1200"] = Utils.utf8toHangul(str: des) //1200 신용접속번호(A)
//        des = ar(res[1]);resDataDic["creditB1200"] = Utils.utf8toHangul(str: des) //1200 신용접속번호(B)
//        des = ar(res[2]);resDataDic["creditC1200"] = Utils.utf8toHangul(str: des) //1200 신용접속번호(C)
//        des = ar(res[3]);resDataDic["creditD1200"] = Utils.utf8toHangul(str: des) //1200 신용접속번호(D)
//        des = ar(res[4]);resDataDic["creditA2400"] = Utils.utf8toHangul(str: des) //2400 신용접속번호(A)
//        des = ar(res[5]);resDataDic["creditB2400"] = Utils.utf8toHangul(str: des) //2400 신용접속번호(B)
//        des = ar(res[6]);resDataDic["etcA2400"] = Utils.utf8toHangul(str: des) //2400 기타접속번호(A)
//        des = ar(res[7]);resDataDic["etcB2400"] = Utils.utf8toHangul(str: des) //2400 기타접속번호(B)
        //A/S(가맹점)전화번호
        des = ar(res[8]);resDataDic["AsNum"] = Utils.utf8toHangul(str: des)
        LogFile.instance.InsertLog("AsNum : " + (resDataDic["AsNum"] ?? ""), Tid: _Tid)
        
        //복수가맹점인경우
        if _Command == "D11" || _Command == "D12" {
            //가맹점갯수
            des = ar(res[9]);resDataDic["ShpCount"] = Utils.utf8toHangul(str: des)
            let _count:Int = Int(resDataDic["ShpCount"] ?? "0") ?? 0
            //각 TID(10) 가맹점이름(40) 사업자번호(10) 대표자명(20) 주소(50) 전화번호(15)
            des = ar(res[10])
            for i in 0 ..< _count {
                resDataDic["TermID" + String(i)] = Utils.utf8toHangul(str: Array(des[(145 * i + 0)..<(145 * i + 10)]))
                resDataDic["ShpNm" + String(i)] = Utils.utf8toHangul(str: Array(des[(145 * i + 10)..<(145 * i + 50)]))
                resDataDic["BsnNo" + String(i)] = Utils.utf8toHangul(str: Array(des[(145 * i + 50)..<(145 * i + 60)]))
                resDataDic["PreNm" + String(i)] = Utils.utf8toHangul(str: Array(des[(145 * i + 60)..<(145 * i + 80)]))
                resDataDic["ShpAdr" + String(i)] = Utils.utf8toHangul(str: Array(des[(145 * i + 80)..<(145 * i + 130)]))
                resDataDic["ShpTel" + String(i)] = Utils.utf8toHangul(str: Array(des[(145 * i + 130)..<(145 * i + 145)]))
            }

            //working key index
            des = ar(res[11]);resDataDic["keyIndex"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("keyIndex : " + (resDataDic["keyIndex"] ?? ""), Tid: _Tid)
            
            Setting.shared.WorkingKeyIndex = Utils.utf8toHangul(str: des) //설정에 workingkeyIndex 설정
            Setting.shared.setDefaultUserData(_data: Setting.shared.WorkingKeyIndex, _key: define.WORKINGKEY_INDEX)
            
            //working key
            des = ar(res[12]);resDataDic["key"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("key : " + (resDataDic["key"] ?? ""), Tid: _Tid)
            
            Setting.shared.WorkingKey = Utils.utf8toHangul(str: des)    //설정에 workingkey 설정
            Setting.shared.setDefaultUserData(_data: Setting.shared.WorkingKey, _key: define.WORKINGKEY)
            //tmk
            des = ar(res[13]);resDataDic["tmk"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("tmk : " + (resDataDic["tmk"] ?? ""), Tid: _Tid)
            //포인트카드 갯수
            des = ar(res[14]);resDataDic["pointCardCount"] = Utils.utf8toHangul(str: des)
            //포인트카드
            des = ar(res[15]);resDataDic["pointCard"] = Utils.utf8toHangul(str: des)
            //한글및 특수문자 포함된 데이터[UInt8] 를 문자열로 변환한다

            des = ar(res[16]); //가맹점데이터
            resDataDic["MchData"] = Utils.utf8toHangul(str: des)
            
            if res.count > 17 {
                des = ar(res[17]) //서버에서 보내준 부정취소방지를 위한 하드웨어고유키값.
                //만일 하드웨어키값의 길이가 15개를 넘지 않을 경우는 1개만 보낸 것으로 판단한다.
                if des.count <= 15 {
                    resDataDic["HardwareKey"] = Utils.utf8toHangul(str: des)
                    let _key = resDataDic["HardwareKey"] ?? ""
                    //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
                    if String(describing: tcplinstener).contains("AppToApp") {
                        Utils.setPosKeyChainUUIDtoBase64(Target: .AppToApp, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                    } else {
                        Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                    }
                } else {
                    //길이가 15개를 넘겼다면 여러 하드웨어 키를 보낸것으로 판단한다.
                    var _tmpKey:String = ""
                    for i in 0 ..< _count {
                        _tmpKey = Utils.utf8toHangul(str: Array(des[(25 * i + 0)..<(25 * i + 25)]))
                        for j in 0 ..< _count {
                            if _tmpKey.contains(resDataDic["TermID" + String(j)]!) {
                                resDataDic["HardwareKey" + resDataDic["TermID" + String(j)]!] = _tmpKey.replacingOccurrences(of: resDataDic["TermID" + String(j)]!, with: "")
                                if String(describing: tcplinstener).contains("AppToApp") {
                                    Utils.setPosKeyChainUUIDtoBase64(Target: .AppToApp, Tid: (resDataDic["TermID" + String(j)] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: resDataDic["HardwareKey" + resDataDic["TermID" + String(j)]!]!)
                                } else {
                                    Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (resDataDic["TermID" + String(j)]! ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: resDataDic["HardwareKey" + resDataDic["TermID" + String(j)]!]!)
                                }
                            }
                        }
                        
                    }
                    

                    
                }

              
    //            if !_key.isEmpty {
    //                Utils.setPosKeyChainUUIDtoBase64(PosKeyChain: _key)
    //            }
                
            } else {
                resDataDic["HardwareKey"] = ""
                let _key = resDataDic["HardwareKey"] ?? ""
                //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
                if String(describing: tcplinstener).contains("AppToApp") {
                    Utils.setPosKeyChainUUIDtoBase64(Target: .AppToApp, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                } else {
                    Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                }
            }
        }
        else
        {
            //가맹점 이름
            des = ar(res[9]);resDataDic["ShpNm"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("ShpNm : " + (resDataDic["ShpNm"] ?? ""), Tid: _Tid)
            //가맹점 사업자 번호
            des = ar(res[10]);resDataDic["BsnNo"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("BsnNo : " + (resDataDic["BsnNo"] ?? ""), Tid: _Tid)
            //대표자명
            des = ar(res[11]);resDataDic["PreNm"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("PreNm : " + (resDataDic["PreNm"] ?? ""), Tid: _Tid)
            //주소
            des = ar(res[12]);resDataDic["ShpAdr"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("ShpAdr : " + (resDataDic["ShpAdr"] ?? ""), Tid: _Tid)
            //가맹점 전화번호
            des = ar(res[13]);resDataDic["ShpTel"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("ShpTel : " + (resDataDic["ShpTel"] ?? ""), Tid: _Tid)
            
            //working key index
            des = ar(res[14]);resDataDic["keyIndex"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("keyIndex : " + (resDataDic["keyIndex"] ?? ""), Tid: _Tid)
            Setting.shared.WorkingKeyIndex = Utils.utf8toHangul(str: des) //설정에 workingkeyIndex 설정
            Setting.shared.setDefaultUserData(_data: Setting.shared.WorkingKeyIndex, _key: define.WORKINGKEY_INDEX)
            
            //working key
            des = ar(res[15]);resDataDic["key"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("key : " + (resDataDic["key"] ?? ""), Tid: _Tid)
            Setting.shared.WorkingKey = Utils.utf8toHangul(str: des)    //설정에 workingkey 설정
            Setting.shared.setDefaultUserData(_data: Setting.shared.WorkingKey, _key: define.WORKINGKEY)
            //tmk
            des = ar(res[16]);resDataDic["tmk"] = Utils.utf8toHangul(str: des)
            LogFile.instance.InsertLog("tmk : " + (resDataDic["tmk"] ?? ""), Tid: _Tid)
            //포인트카드 갯수
            des = ar(res[17]);resDataDic["pointCardCount"] = Utils.utf8toHangul(str: des)
            //포인트카드
            des = ar(res[18]);resDataDic["pointCard"] = Utils.utf8toHangul(str: des)
            //한글및 특수문자 포함된 데이터[UInt8] 를 문자열로 변환한다

            des = ar(res[19]); //가맹점데이터
            resDataDic["MchData"] = Utils.utf8toHangul(str: des)
            
            if res.count > 20 {
                des = ar(res[20]) //서버에서 보내준 부정취소방지를 위한 하드웨어고유키값.
                resDataDic["HardwareKey"] = Utils.utf8toHangul(str: des)
                let _key = resDataDic["HardwareKey"] ?? ""
                //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
                if String(describing: tcplinstener).contains("AppToApp") {
                    Utils.setPosKeyChainUUIDtoBase64(Target: .AppToApp, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                } else {
                    Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                }
              
    //            if !_key.isEmpty {
    //                Utils.setPosKeyChainUUIDtoBase64(PosKeyChain: _key)
    //            }
                
            } else {
                resDataDic["HardwareKey"] = ""
                let _key = resDataDic["HardwareKey"] ?? ""
                //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
                if String(describing: tcplinstener).contains("AppToApp") {
                    Utils.setPosKeyChainUUIDtoBase64(Target: .AppToApp, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                } else {
                    Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                }
            }
        }
 

        //모든 공백 제거
//        Utils.utf8toHangul(str: Array(res.Data[i])).trimmingCharacters(in: .newlines)
//        Utils.utf8toHangul(str: Array(res.Data[i])).filter{!$0.isWhitespace}
//        Utils.utf8toHangul(str: Array(res.Data[i])).components(separatedBy: [" "]).joined()
//        Utils.utf8toHangul(str: Array(res.Data[i])).replacingOccurrences(of: " ", with: "")

        
        //APP to APP의 경우
        resDataDic.removeValue(forKey: "pointCard")
        resDataDic.removeValue(forKey: "pointCardCount")
        resDataDic.removeValue(forKey: "tmk")
        resDataDic.removeValue(forKey: "key")
        resDataDic.removeValue(forKey: "keyIndex")
        resDataDic.removeValue(forKey: "length")
        resDataDic.removeValue(forKey: "posCheckData")
        if String(describing: tcplinstener).contains("AppToApp") {
//            resDataDic.removeValue(forKey: "pointCard")
//            resDataDic.removeValue(forKey: "pointCardCount")
//            resDataDic.removeValue(forKey: "tmk")
//            resDataDic.removeValue(forKey: "key")
//            resDataDic.removeValue(forKey: "keyIndex")
//            resDataDic.removeValue(forKey: "length")
//            resDataDic.removeValue(forKey: "posCheckData")
        }
        
        if _directData.count > 0 {
            tcplinstener?.onDirectResult(tcpStatus: tcpStatus.sucess, Result: resDataDic, DirectData: _directData)
        } else {
            tcplinstener?.onResult(tcpStatus: tcpStatus.sucess, Result: resDataDic)
        }
    
        
        //사용한 가맹점다운로드 데이터 초기화
        des = [0]
        des.removeAll()
        resDataDic.removeAll()
        Response = [0]
        Response.removeAll()
        return
    }
    
    /**
     다운로드 키다운로드
     - parameter _Command: "D10" : 가맹점다운로드  "D11","D12" : 복수가맹점다운로드  "D20" : 키업데이트 6
     - parameter _Tid: 단말기 ID
     - parameter _Date: 거래일시 14 N YYMMDDhhmmss
     - parameter _posVer: 전문일련번호
     - parameter _etc: 미정
     - parameter _length: 길이 4byte 128byte => 0128
     - parameter _posCheckdata: 단말 검증 요청 데이터 길이(3byte, ex.087)+TrsmID(7)+Crandom(16)+KEY1_ENC(25바이 트Timpstamp+가변SvrInfo+7바이트TID+16바이트CRandom) MDO : 가맹점 정보 다운로드 ONLY(Key 다운로드 안함) 15
     - parameter _Bsn: 가맹점 사업자 번호
     - parameter _Serial: 장비 제조일련번호
     - parameter _posData: 가맹점데이터
     - parameter _macAddr: 맥어드레스 또는 UUID
     - parameter _linstener: 응답 리스너
     */
    func KeyDownload(Command _Command:String,Tid _Tid:String,Date _Date:String,PosVer _posVer:String,Etc _etc:String,Length _length:String,
                     PosCheckData _posCheckdata:[UInt8] ,BSN _Bsn:String,Serial _Serial:String,PosData _posData:String, MacAddr _macAddr:String, CallbackListener _linstener:TcpResultDelegate)
    {
        typealias ar = Array
        /** log : KeyDownload */
        LogFile.instance.InsertLog("키다운로드 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        tcplinstener = _linstener
        var Response: [UInt8] = [UInt8]()
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        Response = SendTcpTran(requstData: Command.KeyReq(Command: _Command, Tid: _Tid, Date: _Date, PosVer: _posVer, Etc: _etc, Length: _length, PosCheckData: _posCheckdata, BSN: _Bsn, Serial: _Serial, PosData: _posData, MacAddr: _macAddr))

        /** log : KeyDownload */
        LogFile.instance.InsertLog("TCPServer -> 키다운로드 App", Tid: _Tid, TimeStamp: true)
//        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: Response), Tid: _Tid)
        
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint("TCP server To Device = \(strRes)")

        if Response.isEmpty {
            resDataDic["TrdType"] = "D25"
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            LogFile.instance.InsertLog("응답데이터 오류. 네트워크를 확인해 주세요", Tid: _Tid)
            
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.NAK {
            resDataDic["TrdType"] = "D25"
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (NAK 응답 수신)") as String
            LogFile.instance.InsertLog("NAK 수신", Tid: _Tid)
            
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            resDataDic["TrdType"] = "D25"
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            resDataDic["TrdType"] = "D25"
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과)") as String
            LogFile.instance.InsertLog("응답대기시간 초과", Tid: _Tid)
            
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            resDataDic["TrdType"] = "D25"
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (오류전문 수신)") as String
            LogFile.instance.InsertLog("ESC 수신. 오류전문 수신", Tid: _Tid)
            
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        //let res:Command.TcpResParsingData = Command.TcpResDataParser(ResData: Response)

        
        var des:[UInt8] = Array()
        var rangeSize:Int = 0
        Response.removeFirst()  //STX 삭제
        rangeSize = 4 + 4 //전문길이,전문버전
        Response.removeSubrange(0..<rangeSize)
        if Response[0] != Command.FS {
            resDataDic["TrdType"] = "D25"
            resDataDic["Message"] = NSString("정상적인 데이터가 아닙니다.") as String
            resDataDic["ERROR"] = NSString("정상적인 데이터가 아닙니다.") as String
            LogFile.instance.InsertLog("응답데이터 파싱오류. 정상적인 데이터가 아닙니다", Tid: _Tid)
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        Response.removeFirst()  //FS 삭제
        
        //TrdType
        var TcpCommand = Array(Response[0..<3])
        resDataDic["TrdType"] = Utils.utf8toHangul(str: TcpCommand)
        Response.removeSubrange(0..<3)  //전문번호
        //tid
        resDataDic["TermID"] = Utils.utf8toHangul(str: Array(Response[0..<10]))
        Response.removeSubrange(0..<10)  //TermID
        //date
        resDataDic["TrdDate"] = Utils.utf8toHangul(str: Array(Response[0..<12]))
        Response.removeSubrange(0..<12)  //거래일시
        Response.removeSubrange(0..<6)  //전문일련번호
        Response.removeSubrange(0..<6)  //단말구분,단말버전
        
        if Response[0] != Command.FS{
            for i in 0...Response.count {
                if Response[i] == Command.FS {
                    Response.removeSubrange(0..<i)  //단말 추가 정보
                    break
                }
            }
        }
        
        Response.removeFirst()  //FS 삭제

        resDataDic["AnsCode"] = Array(Response[0..<4]) == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: Array(Response[0..<4]) ) //응답 코드가 0000
        Response.removeSubrange(0..<4)  //응답코드 삭제
        
        Response.removeFirst()  //FS 삭제
        
        //응답 메세지

        resDataDic["Message"] = Utils.utf8toHangul(str: des)
        //길이
        //응답메시지
        if Response[0] != Command.FS{
            for i in 0...Response.count {
                if Response[i] == Command.FS {
                    des = Array(Response[0..<i])
                    Response.removeSubrange(0..<i)  //단말 추가 정보
                    break
                }
            }
        }
        
        resDataDic["Message"] = Utils.utf8toHangul(str: des)
        
        Response.removeFirst()  //FS 삭제
        
        if resDataDic["AnsCode"] != "0000" {
            LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
            
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        let termialCheckResponseDataSize:Int = Int(Utils.UInt8ArrayToStr(UInt8Array: Array(Response[0..<4])))!
        resDataDic["length"] = Utils.utf8toHangul(str: Array(Response[0..<4]))
        Response.removeSubrange(0..<4)  //길이 삭제
        
        //단말검증응답데이터
        var dataRes: [UInt8] = Array(Response[0..<termialCheckResponseDataSize])
        resDataDic["posCheckData"] = String(decoding: Array(Response[0..<termialCheckResponseDataSize]), as: UTF8.self)
        Response.removeSubrange(0..<termialCheckResponseDataSize)  //길이 삭제
        
        if Response[0] != Command.FS {
            resDataDic["Message"] = NSString("정상적인 데이터가 아닙니다.") as String
            resDataDic["ERROR"] = NSString("정상적인 데이터가 아닙니다.") as String
            
            LogFile.instance.InsertLog("응답데이터 파싱오류. 정상적인 데이터가 아닙니다", Tid: _Tid)
            
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        Response.removeFirst() //FS삭제
        
        var res = Command.FSspliter(Data: Response)
//        des = ar(res.Data[5]);resDataDic["creditA1200"] = Utils.utf8toHangul(str: des) //1200 신용접속번호(A)
//        des = ar(res.Data[6]);resDataDic["creditB1200"] = Utils.utf8toHangul(str: des) //1200 신용접속번호(B)
//        des = ar(res.Data[7]);resDataDic["creditC1200"] = Utils.utf8toHangul(str: des) //1200 신용접속번호(C)
//        des = ar(res.Data[8]);resDataDic["creditD1200"] = Utils.utf8toHangul(str: des) //1200 신용접속번호(D)
//        des = ar(res.Data[9]);resDataDic["creditA2400"] = Utils.utf8toHangul(str: des) //2400 신용접속번호(A)
//        des = ar(res.Data[10]);resDataDic["creditB2400"] = Utils.utf8toHangul(str: des) //2400 신용접속번호(B)
//        des = ar(res.Data[11]);resDataDic["etcA2400"] = Utils.utf8toHangul(str: des) //2400 기타접속번호(A)
//        des = ar(res.Data[12]);resDataDic["etcB2400"] = Utils.utf8toHangul(str: des) //2400 기타접속번호(B_cardName)
        
        LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)

        //A/S(가맹점)전화번호
        des = ar(res[8]);resDataDic["AsNum"] = Utils.utf8toHangul(str: des)
        LogFile.instance.InsertLog("AsNum : " + (resDataDic["AsNum"] ?? ""), Tid: _Tid)
        //가맹점 이름
        des = ar(res[9]);resDataDic["ShpNm"] = Utils.utf8toHangul(str: des)
        LogFile.instance.InsertLog("ShpNm : " + (resDataDic["ShpNm"] ?? ""), Tid: _Tid)
        //가맹점 사업자 번호
        des = ar(res[10]);resDataDic["BsnNo"] = Utils.utf8toHangul(str: des)
        LogFile.instance.InsertLog("BsnNo : " + (resDataDic["BsnNo"] ?? ""), Tid: _Tid)
        //대표자명
        des = ar(res[11]);resDataDic["PreNm"] = Utils.utf8toHangul(str: des)
        LogFile.instance.InsertLog("PreNm : " + (resDataDic["PreNm"] ?? ""), Tid: _Tid)
        //주소
        des = ar(res[12]);resDataDic["ShpAdr"] = Utils.utf8toHangul(str: des)
        LogFile.instance.InsertLog("ShpAdr : " + (resDataDic["ShpAdr"] ?? ""), Tid: _Tid)
        //가맹점 전화번호
        des = ar(res[13]);resDataDic["ShpTel"] = Utils.utf8toHangul(str: des)
        LogFile.instance.InsertLog("ShpTel : " + (resDataDic["ShpTel"] ?? ""), Tid: _Tid)
        //working key index
        des = ar(res[14]);resDataDic["keyIndex"] = Utils.utf8toHangul(str: des)
        LogFile.instance.InsertLog("keyIndex : " + (resDataDic["keyIndex"] ?? ""), Tid: _Tid)
        Setting.shared.WorkingKeyIndex = Utils.utf8toHangul(str: des) //설정에 workingkeyIndex 설정
        Setting.shared.setDefaultUserData(_data: Setting.shared.WorkingKeyIndex, _key: define.WORKINGKEY_INDEX)

        des = ar(res[15]);resDataDic["key"] = Utils.utf8toHangul(str: des)   //working key
        LogFile.instance.InsertLog("key : " + (resDataDic["key"] ?? ""), Tid: _Tid)
        Setting.shared.WorkingKey = Utils.utf8toHangul(str: des)    //설정에 workingkey 설정
        Setting.shared.setDefaultUserData(_data: Setting.shared.WorkingKey, _key: define.WORKINGKEY)
    
//        des = ar(res.Data[21]); resDataDic["tmk"] = Utils.utf8toHangul(str: des)        //tmk
//        des = ar(res.Data[22]); resDataDic["pointCardCount"] = Utils.utf8toHangul(str: des)     //포인트카드 갯수
//        des = ar(res.Data[23]);  resDataDic["pointCard"] = Utils.utf8toHangul(str: des) //포인트카드

        des = ar(res[19]); //가맹점데이터
        resDataDic["MchData"] = Utils.utf8toHangul(str: des)
        LogFile.instance.InsertLog("MchData : " + (resDataDic["MchData"] ?? ""), Tid: _Tid)
        if res.count > 20 {
            des = ar(res[20]); //서버에서 보내준 부정취소방지를 위한 하드웨어고유키값.
            resDataDic["HardwareKey"] = Utils.utf8toHangul(str: des)
            
            let _key = resDataDic["HardwareKey"] ?? ""
            //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
            if String(describing: tcplinstener).contains("AppToApp") {
                Utils.setPosKeyChainUUIDtoBase64(Target: .AppToApp, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
            } else {
                Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
            }
//            if !_key.isEmpty {
//                Utils.setPosKeyChainUUIDtoBase64(PosKeyChain: _key)
//            }
            
        } else {
            resDataDic["HardwareKey"] = ""
            let _key = resDataDic["HardwareKey"] ?? ""
            //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
            if String(describing: tcplinstener).contains("AppToApp") {
                Utils.setPosKeyChainUUIDtoBase64(Target: .AppToApp, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
            } else {
                Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (resDataDic["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
            }
        }

        //APP to APP의 경우
//        tcplinstener?.onResult(tcpStatus: tcpStatus.sucess, Result: resDataDic)
        tcplinstener?.onKeyResult(tcpStatus: tcpStatus.sucess, Result: dataRes, DicResult: resDataDic)
        
        //사용한 키다운로드 데이터 초기화
        des = [0]
        des.removeAll()
        resDataDic.removeAll()
        dataRes.removeAll()
        Response = [0]
        Response.removeAll()

        return
    }
    
    /**
     TCP 광고메세지 다운로드(D30)
     - parameter _Command: "D30" : 광고메세지다운로드
     - parameter _Tid: 단말기 ID
     - parameter _Date: 거래일시 14 N YYMMDDhhmmss
     - parameter _posVer: 전문일련번호
     - parameter  광고출력구분: 0:문자광고, 1:화면이미지, 2:2인치전표이미지, 3:3인치전표이미지
     - parameter _문자출력코드 0:완성형, 1:조합형
     - parameter _문자출력가능길이 3바이트
     - parameter _문자출력가능라아니 2바이트
     - parameter _이미지출력포맷 BMP, JPG, PNG 현재 BMP 만 지원, 스페이스패등은 이미지출력불가단말기 3바이트
     - parameter _이미지출력가능 가로사이즈 4바이트
     - parameter _이미지출력가능 세로사이즈 4바이트
     - parameter _PosData 가맹점데이터
     - returns: [UInt8] 서버 요청 전문
     */
    func AdDownload(Command _Command:String,Tid _Tid:String,Date _Date:String,PosVer _posVer:String,Etc _etc:String,
                    광고출력구분 _광고출력구분:String, 문자출력구분 _문자출력구분:String, 문자출력길이 _문자출력길이:String, 문자출력라인 _문자출력라인:String,
                    이미지출력포맷 _이미지출력포맷:String, 이미지출력가로사이즈 _이미지출력가로사이즈:String, 이미지출력세로사이즈 _이미지출력세로사이즈:String,
                    PosData _posData:String, CallbackListener _linstener:TcpResultDelegate) {
        typealias ar = Array
        /** log : KeyDownload */
        LogFile.instance.InsertLog("광고메세지다운로드 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        tcplinstener = _linstener
        var Response: [UInt8] = [UInt8]()
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        Response = SendTcpTran(requstData: Command.AdDownload(Command: _Command, Tid: _Tid, Date: _Date, PosVer: _posVer, Etc: _etc, 광고출력구분: _광고출력구분, 문자출력구분: _문자출력구분, 문자출력길이: _문자출력길이, 문자출력라인: _문자출력라인, 이미지출력포맷: _이미지출력포맷, 이미지출력가로사이즈: _이미지출력가로사이즈, 이미지출력세로사이즈: _이미지출력세로사이즈, PosData: _posData))

        /** log : KeyDownload */
        LogFile.instance.InsertLog("TCPServer -> 광고메세지다운로드 App", Tid: _Tid, TimeStamp: true)
        
        
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint("TCP server To Device = \(strRes)")

        if Response.isEmpty {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["TrdType"] = "D35"
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.NAK {
            LogFile.instance.InsertLog("NAK 수신", Tid: _Tid)
            resDataDic["TrdType"] = "D35"
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (NAK 응답 수신)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["TrdType"] = "D35"
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            LogFile.instance.InsertLog("응답대기시간 초과", Tid: _Tid)
            resDataDic["TrdType"] = "D35"
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (응답대기시간 초과)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            LogFile.instance.InsertLog("ESC 수신. 오류전문 수신.", Tid: _Tid)
            resDataDic["TrdType"] = "D35"
            resDataDic["Message"] = NSString("다시 시도해 주세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("다시 시도해 주세요 \n (오류전문 수신)") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        
        var des:[UInt8] = Array()
        var rangeSize:Int = 0
        Response.removeFirst()  //STX 삭제
        rangeSize = 4 + 4 //전문길이,전문버전
        Response.removeSubrange(0..<rangeSize)
        if Response[0] != Command.FS {
            LogFile.instance.InsertLog("응답데이터 파싱오류. 정상적인 데이터가 아닙니다.", Tid: _Tid)

            resDataDic["TrdType"] = "D35"
            resDataDic["Message"] = NSString("정상적인 데이터가 아닙니다.") as String
            resDataDic["ERROR"] = NSString("정상적인 데이터가 아닙니다.") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        Response.removeFirst()  //FS 삭제
        
        //TrdType
        var TcpCommand = Array(Response[0..<3])
        resDataDic["TrdType"] = Utils.utf8toHangul(str: TcpCommand)
        Response.removeSubrange(0..<3)  //전문번호
        //tid
        resDataDic["TermID"] = Utils.utf8toHangul(str: Array(Response[0..<10]))
        Response.removeSubrange(0..<10)  //TermID
        //date
        resDataDic["TrdDate"] = Utils.utf8toHangul(str: Array(Response[0..<12]))
        Response.removeSubrange(0..<12)  //거래일시
        Response.removeSubrange(0..<6)  //전문일련번호
        Response.removeSubrange(0..<6)  //단말구분,단말버전
        
        if Response[0] != Command.FS{
            for i in 0...Response.count {
                if Response[i] == Command.FS {
                    Response.removeSubrange(0..<i)  //단말 추가 정보
                    break
                }
            }
        }
        
        Response.removeFirst()  //FS 삭제

        resDataDic["AnsCode"] = Array(Response[0..<4]) == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: Array(Response[0..<4]) ) //응답 코드가 0000
        Response.removeSubrange(0..<4)  //응답코드 삭제
        
        Response.removeFirst()  //FS 삭제
        
        //응답 메세지
        resDataDic["Message"] = Utils.utf8toHangul(str: des)
        //길이
        //응답메시지
        if Response[0] != Command.FS{
            for i in 0...Response.count {
                if Response[i] == Command.FS {
                    des = Array(Response[0..<i])
                    Response.removeSubrange(0..<i)  //응답메시지
                    break
                }
            }
        }
        
        resDataDic["Message"] = Utils.utf8toHangul(str: des)
        
        Response.removeFirst()  //FS 삭제
        
        if resDataDic["AnsCode"] != "0000" {
            LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
            
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
        
        let termialCheckResponseDataSize:Int = Int(Utils.UInt8ArrayToStr(UInt8Array: Array(Response[0..<4])))!
        resDataDic["length"] = Utils.utf8toHangul(str: Array(Response[0..<4]))
        Response.removeSubrange(0..<4)  //길이 삭제
        
        //광고메세지 응답정보
        var dataRes: [UInt8] = Array(Response[0..<termialCheckResponseDataSize])
        resDataDic["AdInfo"] = String(decoding: Array(Response[0..<termialCheckResponseDataSize]), as: UTF8.self)
        LogFile.instance.InsertLog("AdInfo : " + (resDataDic["AdInfo"] ?? ""), Tid: _Tid)
        Response.removeSubrange(0..<termialCheckResponseDataSize)  //광고메세지 응답정보 삭제
        
        resDataDic["AdInfoType"] = String(decoding: Array(arrayLiteral: dataRes[0]), as: UTF8.self)
        LogFile.instance.InsertLog("AdInfoType : " + (resDataDic["AdInfoType"] ?? ""), Tid: _Tid)
        dataRes.removeFirst()  // 출력구분삭제
        
        resDataDic["AdInfoStartDate"] = String(decoding: Array(dataRes[0..<8]), as: UTF8.self)
        LogFile.instance.InsertLog("AdInfoStartDate : " + (resDataDic["AdInfoStartDate"] ?? ""), Tid: _Tid)
        dataRes.removeSubrange(0..<8)  // 출력시작일삭제
        
        resDataDic["AdInfoLastDate"] = String(decoding: Array(dataRes[0..<8]), as: UTF8.self)
        LogFile.instance.InsertLog("AdInfoLastDate : " + (resDataDic["AdInfoLastDate"] ?? ""), Tid: _Tid)
        dataRes.removeSubrange(0..<8)  // 출력종료일삭제
        
        resDataDic["AdInfoLength"] = String(decoding: Array(dataRes[0..<4]), as: UTF8.self)
        let AdInfoLengthDataSize:Int = Int(Utils.UInt8ArrayToStr(UInt8Array: Array(dataRes[0..<4])))!
        dataRes.removeSubrange(0..<4)  // 출력문자열길이삭제
        
        var _AdInfoData:String = Utils.utf8toHangul(str: Array(dataRes[0..<AdInfoLengthDataSize]))
        for  i in 0 ..< _AdInfoData.count {
            _AdInfoData = _AdInfoData.replacingOccurrences(of: "  ", with: "\n")
        }
        for  i in 0 ..< _AdInfoData.count {
            _AdInfoData = _AdInfoData.replacingOccurrences(of: "\n\n", with: "\n")
        }
   
        resDataDic["AdInfoData"] = _AdInfoData
        LogFile.instance.InsertLog("AdInfoData : " + (resDataDic["AdInfoData"] ?? ""), Tid: _Tid)
        dataRes.removeSubrange(0..<AdInfoLengthDataSize)     // 출력문자열삭제
        
        if resDataDic["AdInfoType"] != "0" {
            resDataDic["AdInfoImageLength"] = String(decoding: Array(dataRes[0..<4]), as: UTF8.self)
            let AdInfoLengthImageSize:Int = Int(Utils.UInt8ArrayToStr(UInt8Array: Array(dataRes[0..<4])))!
            dataRes.removeSubrange(0..<4)  // 이미지데이터길이삭제
            
            resDataDic["AdInfoImageData"] = String(decoding: Array(dataRes[0..<AdInfoLengthImageSize]), as: UTF8.self)
            dataRes.removeSubrange(0..<AdInfoLengthImageSize)     // 이미지데이터삭제
        }

        
        if Response[0] != Command.FS {
            LogFile.instance.InsertLog("응답데이터 파싱오류. 정상적인 데이터가 아닙니다.", Tid: _Tid)
            resDataDic["Message"] = NSString("정상적인 데이터가 아닙니다.") as String
            resDataDic["ERROR"] = NSString("정상적인 데이터가 아닙니다.") as String
            tcplinstener?.onResult(tcpStatus: tcpStatus.fail, Result: resDataDic)
            return
        }
        
        Response.removeFirst() //FS삭제

        //가맹점데이터는 사용안함
        tcplinstener?.onResult(tcpStatus: tcpStatus.sucess, Result: resDataDic)
        
        //사용한 데이터 초기화
        des = [0]
        des.removeAll()
        resDataDic.removeAll()
        dataRes.removeAll()
        Response = [0]
        Response.removeAll()

        return
        
        
        
    }
    

    /**
      * 현금영수증요청
      *
      */
    func Cash(Command _Command:String,Tid _Tid:String,Date _date:String,PosVer _posVer:String,Etc _etc:String,CancelInfo _cancelInfo:String,InputMethod _inputMethod:String,Id _id:[UInt8],Idencrypt _idencrpyt:[UInt8],Money _money:String,Tax _tax:String,ServiceCharge _svc:String, TaxFree _taxfree:String,PrivateOrCorp _privateOrCorp:String,CancelReason _cancelReason:String,pointCardCode _pointCardCode:String,pointAceeptNum _pointAcceptNum:String,businessData _businessData:String,bangi _bangi:String, kocesNumber _kocesNumber:String, AppToApp 앱투앱:Bool)
     {
        typealias ar = Array
        /** log : Cash */
        LogFile.instance.InsertLog("현금영수증요청 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        Setting.shared.mInputCashMethod = _inputMethod;
        Setting.shared.mPrivateOrCorp = _privateOrCorp;
        
        var Response: [UInt8] = [UInt8]()
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        Response = SendTcpTran(requstData: Command.TcpCash(Command: _Command, Tid: _Tid, Date: _date, PosVer: _posVer, Etc: _etc, CancelInfo: _cancelInfo, Method: _inputMethod, Id: _id, IdEncrptying: _idencrpyt, Money: _money, Tax: _tax, ServiceCharge: _svc, TaxFree: _taxfree, Target: _privateOrCorp, ResonCancel: _cancelReason, PointCardCode: _pointCardCode, PointAcceptNumber: _pointAcceptNum, BusinessData: _businessData, halfYear: _bangi, KocesNumber: _kocesNumber))
        /** log : Cash */
        LogFile.instance.InsertLog("TCPServer -> 현금영수증요청 App", Tid: _Tid, TimeStamp: true)
//        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: Response), Tid: _Tid)

        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint(" TCP server To Device = \(strRes)")

        if Response.isEmpty {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            mPaySdk.Res_Tcp_Cash(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.NAK {
            LogFile.instance.InsertLog("NAK 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            mPaySdk.Res_Tcp_Cash(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            mPaySdk.Res_Tcp_Cash(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            LogFile.instance.InsertLog("응답대기시간 초과", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            mPaySdk.Res_Tcp_Cash(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            LogFile.instance.InsertLog("ESC 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            mPaySdk.Res_Tcp_Cash(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        let res:Command.TcpResParsingData = Command.TcpResDataParser(ResData: Response)

        
        if res.Data.count < 3 || res.error=="fail" {
            LogFile.instance.InsertLog("응답데이터 오류. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            resDataDic["ERROR"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            mPaySdk.Res_Tcp_Cash(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        // eot 로 에러메세지를 보낸다
        if KocesSdk.instance.mEotCheck == 2 {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mPaySdk.Res_Tcp_Cash(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        //tid
        resDataDic["TermID"] = res.TermID
        //date
        resDataDic["TrdDate"] = res.TrdDate
        //전문코드 ex)D15 A15 ...
        resDataDic["TrdType"] = res.TrdType
        
        var des:[UInt8] = ar(res.Data[2])
        //응답 코드
        resDataDic["AnsCode"] = des == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: des) //응답 코드가 0000
        //응답 메세지 응답메세지를 앱투앱으로 보내면 에러가 난다. html:// 하면서 인터넷주소창을 보내는데 이것때문에 에러가 난다. 그래서 정상일경우 메세지를 보내지 않는다
        resDataDic["Message"] = ""
        des = ar(res.Data[3])
        resDataDic["Message"] = Utils.utf8toHangul(str: des)
        //길이
        
        if resDataDic["AnsCode"]! != "0000" {
            // 응답 코드가 정상이 아닌 경우
            // 응답 코드, 응답 메세지만 올린다.
            LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
            
            resDataDic["ERROR"] = Utils.utf8toHangul(str: des)
            mPaySdk.Res_Tcp_Cash(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        if _cancelInfo.prefix(1) == "1" {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mPaySdk.Res_Tcp_Cash(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        des = ar(res.Data[4])
        resDataDic["AuNo"] = Utils.utf8toHangul(str: des)
        des = ar(res.Data[5])
        resDataDic["TradeNo"] = Utils.utf8toHangul(str: des)    //KOCES거래고유번호
        des = ar(res.Data[6])
        var CNumber = String(Utils.utf8toHangul(str: des))   //출력용카드번호
         resDataDic["CardNo"] = Utils.CashParser(현금영수증번호: CNumber, 날짜90일경과: 앱투앱)
         CNumber = ""    //카드 번호 삭제
        
        
        //des = ar(res.Data[7]) //포인트 응답코드
        //des = ar(res.Data[8]) //포인트 응답메세지
        //des = ar(res.Data[9])  //포인트 응답정보
        
        des = ar(res.Data[10])
        resDataDic["Keydate"] = Utils.utf8toHangul(str: des)  //암호키만료잔여일
        des = ar(res.Data[11])
        resDataDic["MchData"] = Utils.utf8toHangul(str: des)  //가맹점데이터
        
        //des = ar(res.Data[12]) //거래금액
        //des = ar(res.Data[13]) //세금
        //des = ar(res.Data[14]) //봉사료
        //des = ar(res.Data[15]) //비과세
        //des = ar(res.Data[16]) //지급명세기간
         
         LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
         LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
         LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
         LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
         LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
         
         LogFile.instance.InsertLog("AuNo : " + (resDataDic["AuNo"] ?? ""), Tid: _Tid)
         LogFile.instance.InsertLog("TradeNo : " + (resDataDic["TradeNo"] ?? ""), Tid: _Tid)
         LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
         LogFile.instance.InsertLog("Keydate : " + (resDataDic["Keydate"] ?? ""), Tid: _Tid)
         LogFile.instance.InsertLog("MchData : " + (resDataDic["MchData"] ?? ""), Tid: _Tid)

        mPaySdk.Res_Tcp_Cash(tcpStatus: tcpStatus.sucess, ResData: resDataDic)
        
        //사용한 현금 데이터 초기화
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        for i in 0 ..< des.count {
            des[i] = 0xFF
        }
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        
        des.removeAll()
        resDataDic.removeAll()
        Response = [0]
        Response.removeAll()

        return
     }
    
    /**
     신용결제요청
     */
    func Credit(Command _Command:String,Tid _Tid:String,Date _date:String,PosVer _posVer:String,Etc _etc:String,ResonCancel _ResonCancel:String,InputType _inputType:String,
                CardNumber _CardNum:String,EncryptInfo _encryptInfo:[UInt8],Money _money:String,Tax _tax:String,ServiceCharge _svc:String,TaxFree _txf:String,Currency _currency:String,
                InstallMent _Installment:String,PosCertificationNumber _PoscertifiNum:String,TradeType _tradeType:String,EmvData _emvData:String,ResonFallBack _fallback:String,
                ICreqData _ICreqData:[UInt8],WorkingKeyIndex _keyIndex:String,Password _passwd:String,OilSurpport _oil:String,OilTaxFree _txfOil:String,DccFlag _Dccflag:String,
                DccReqInfo _DccreqInfo:String,PointCardCode _ptCode:String,PointCardNumber  _ptNum:String,PointCardEncprytInfo _ptCardEncprytInfo:[UInt8],SignInfo _SignInfo:String,
                SignPadSerial _signPadSerial:String,SignData _SignData:[UInt8],Certification _Cert:String,PosData _posData:String,KocesUid _kocesUid:String,UniqueCode _uniqueCode:String,MacAddr _macAddr:String, HardwareKey _hardwareKey:String, AppToApp 앱투앱:Bool)
    {
        typealias ar = Array
        /** log : Credit */
        LogFile.instance.InsertLog("신용결제요청 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        var Response: [UInt8] = [UInt8]()
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        Response = SendTcpTran(requstData: Command.TCPICReq(Command: _Command, Tid: _Tid, Date: _date, PosVer: _posVer, Etc: _etc, ResonCancel: _ResonCancel, InputType: _inputType, CardNumber: _CardNum, EncryptInfo: _encryptInfo, Money: _money, Tax: _tax, ServiceCharge: _svc, TaxFree: _txf, Currency: _currency, InstallMent: _Installment, PosCertificationNumber: _PoscertifiNum, TradeType: _tradeType, EmvData: _emvData, ResonFallBack: _fallback, ICreqData: _ICreqData, WorkingKeyIndex: _keyIndex, Password: _passwd, OilSurpport: _oil, OilTaxFree: _txfOil, DccFlag: _Dccflag, DccReqInfo: _DccreqInfo, PointCardCode: _ptCode,  PointCardNumber: _ptNum, PointCardEncprytInfo: _ptCardEncprytInfo, SignInfo: _SignInfo, SignPadSerial: _signPadSerial, SignData: _SignData, Certification: _Cert, PosData: _posData, KocesUid: _kocesUid, UniqueCode: _uniqueCode ,MacAddr: _macAddr, HardwareKey: _hardwareKey))
        /** log : Credit */
        LogFile.instance.InsertLog("TCPServer -> 신용결제요청 App", Tid: _Tid, TimeStamp: true)
//        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: Response), Tid: _Tid)
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        
        
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint(" TCP server To Device = \(strRes)")

        if Response.isEmpty {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            mPaySdk.Res_Tcp_Credit(tcpStatus: tcpStatus.fail, ResData: resDataDic)

            return
        } else if Response[0] == Command.NAK {
            LogFile.instance.InsertLog("NAK 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            mPaySdk.Res_Tcp_Credit(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            mPaySdk.Res_Tcp_Credit(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            LogFile.instance.InsertLog("응답대기시간 초과", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            mPaySdk.Res_Tcp_Credit(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            LogFile.instance.InsertLog("ESC 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            mPaySdk.Res_Tcp_Credit(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        let res:Command.TcpResParsingData = Command.TcpResDataParser(ResData: Response)

        
        if res.Data.count < 3 || res.error=="fail" {
            LogFile.instance.InsertLog("응답데이터 오류. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            resDataDic["ERROR"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            mPaySdk.Res_Tcp_Credit(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        // eot 로 에러메세지를 보낸다
        if KocesSdk.instance.mEotCheck == 2 {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mPaySdk.Res_Tcp_Credit(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        //tid
        resDataDic["TermID"] = res.TermID
        //date
        resDataDic["TrdDate"] = res.TrdDate
        //전문코드 ex)D15 A15 ...
        resDataDic["TrdType"] = res.TrdType
        
        var des:[UInt8] = ar(res.Data[2])

        resDataDic["AnsCode"] = des == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: des) //응답 코드가 0000
        des = ar(res.Data[3])
        resDataDic["Message"] = Utils.utf8toHangul(str: des)    //응답메세지

        if resDataDic["AnsCode"]! != "0000" {
            // 응답 코드가 정상이 아닌 경우
            // 응답 코드, 응답 메세지만 올린다.
            LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
            
            mPaySdk.Res_Tcp_Credit(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        if _ResonCancel.prefix(1) == "I" {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mPaySdk.Res_Tcp_Credit(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[4])
        resDataDic["AuNo"] = Utils.utf8toHangul(str: des)   //신용 승인번호
        LogFile.instance.InsertLog("AuNo : " + (resDataDic["AuNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[5])
        resDataDic["TradeNo"] = Utils.utf8toHangul(str: des)    //KOCES거래고유번호
        LogFile.instance.InsertLog("TradeNo : " + (resDataDic["TradeNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[6])
        
//        var _tmpCard = String(Utils.utf8toHangul(str: des).replacingOccurrences(of: "-", with: "").prefix(8))
        var CNumber = Utils.utf8toHangul(str: des)
        resDataDic["CardNo"] = Utils.CardParser(카드번호: CNumber, 날짜90일경과: 앱투앱)
        LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
//        resDataDic["CardNo"] = String(_CardNum.prefix(8))  //바코드번호

        //des = ar(res.Data[7]) //거래종류명

        des = ar(res.Data[8])
        resDataDic["CardKind"] = Utils.utf8toHangul(str: des)   //카드종류
        LogFile.instance.InsertLog("CardKind : " + (resDataDic["CardKind"] ?? ""), Tid: _Tid)
        des = ar(res.Data[9])
        resDataDic["OrdCd"] = Utils.utf8toHangul(str: des)  //발급사코드
        LogFile.instance.InsertLog("OrdCd : " + (resDataDic["OrdCd"] ?? ""), Tid: _Tid)
        des = ar(res.Data[10])
        resDataDic["OrdNm"] = Utils.utf8toHangul(str: des)  //발급사명
        LogFile.instance.InsertLog("OrdNm : " + (resDataDic["OrdNm"] ?? ""), Tid: _Tid)
        des = ar(res.Data[11])
        resDataDic["InpCd"] = Utils.utf8toHangul(str: des)  //매입사코드
        LogFile.instance.InsertLog("InpCd : " + (resDataDic["InpCd"] ?? ""), Tid: _Tid)
        des = ar(res.Data[12])
        resDataDic["InpNm"] = Utils.utf8toHangul(str: des)  //매입사명
        LogFile.instance.InsertLog("InpNm : " + (resDataDic["InpNm"] ?? ""), Tid: _Tid)
        des = ar(res.Data[13])
        resDataDic["DDCYn"] = Utils.utf8toHangul(str: des)  //DDC 여부
        LogFile.instance.InsertLog("DDCYn : " + (resDataDic["DDCYn"] ?? ""), Tid: _Tid)
        des = ar(res.Data[14])
        resDataDic["EDCYn"] = Utils.utf8toHangul(str: des)  //EDC 여부
        LogFile.instance.InsertLog("EDCYn : " + (resDataDic["EDCYn"] ?? ""), Tid: _Tid)
        
        //des = ar(res.Data[15]) //전표출력여부
        //des = ar(res.Data[16]) //전표구분명
       
        des = ar(res.Data[17])
        resDataDic["GiftAmt"] = Utils.utf8toHangul(str: des)  //기프트카드 잔액
        LogFile.instance.InsertLog("GiftAmt : " + (resDataDic["GiftAmt"] ?? ""), Tid: _Tid)
        des = ar(res.Data[18])
        resDataDic["MchNo"] = Utils.utf8toHangul(str: des)  //가맹점번호
        LogFile.instance.InsertLog("MchNo : " + (resDataDic["MchNo"] ?? ""), Tid: _Tid)
        
        //des = ar(res.Data[19]) //길이 + IC 응답 Data //응답코드가 정상("0000") 이나 Issuer Authentication Data가 없을 경우(len=0x00) 2ndGenerate AC 단계는 skip
        //des = ar(res.Data[20]) //Working Key
        //des = ar(res.Data[21]) //유류거래응답정보
        //des = ar(res.Data[22]) //DCC조회응답여부
        //des = ar(res.Data[23]) //DCC 응답 정보
        //des = ar(res.Data[24]) //포인트응답코드
        //des = ar(res.Data[25]) //포인트응답메세지
        //des = ar(res.Data[26]) //포인트응답정보
        
        des = ar(res.Data[27])
        resDataDic["Keydate"] = Utils.utf8toHangul(str: des)  //암호키만료잔여일
        LogFile.instance.InsertLog("Keydate : " + (resDataDic["Keydate"] ?? ""), Tid: _Tid)
        des = ar(res.Data[28])
        resDataDic["MchData"] = Utils.utf8toHangul(str: des)  //가맹점데이터
        LogFile.instance.InsertLog("MchData : " + (resDataDic["MchData"] ?? ""), Tid: _Tid)
        
        if _inputType == "U" || _CardNum.replacingOccurrences(of: " ", with: "").count == 26 {
            resDataDic["DisAmt"] = ""  //카카오할임금액
            resDataDic["AuthType"] = "" //카카오페이 결제수단 C:Card, M:Money
            
            resDataDic["AnswerTrdNo"] = ""  //위쳇페이거래고유번호
            resDataDic["ChargeAmt"] = ""  //가맹점수수료
            resDataDic["RefundAmt"] = ""  //가맹점환불금액
            
            resDataDic["QrKind"] = "AP"  //간편결제 거래종류
            LogFile.instance.InsertLog("QrKind : " + (resDataDic["QrKind"] ?? ""), Tid: _Tid)
        }


        mPaySdk.Res_Tcp_Credit(tcpStatus: tcpStatus.sucess, ResData: resDataDic)
        
        //사용한 신용 데이터 초기화
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        for i in 0 ..< des.count {
            des[i] = 0xFF
        }
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        
        des.removeAll()
        resDataDic.removeAll()
        Response = [0]
        Response.removeAll()

        return
    }
    
    /**
     포인트결제요청
     */
    func PointPay(Command _Command:String,Tid _Tid:String,Date _date:String,PosVer _posVer:String,Etc _etc:String,ResonCancel _ResonCancel:String,InputType _inputType:String,CardNumber _CardNum:[UInt8],EncryptInfo _encryptInfo:[UInt8],Money _money:String,PointCode _pointCode:String,PayType _payType:String,WorkingKeyIndex _keyIndex:String,Password _passwd:String,PosData _posData:String, AppToApp 앱투앱:Bool)
    {
        typealias ar = Array
        /** log : Credit */
        LogFile.instance.InsertLog("포인트결제요청 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        var Response: [UInt8] = [UInt8]()
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        Response = SendTcpTran(requstData: Command.TCPPointPay(Command: _Command, Tid: _Tid, Date: _date, PosVer: _posVer, Etc: _etc, ResonCancel: _ResonCancel, InputType: _inputType, CardNumber: _CardNum, EncryptInfo: _encryptInfo, Money: _money, PointCode: _pointCode, PayType: _payType, WorkingKeyIndex: _keyIndex, Password: _passwd, PosData: _posData))
        /** log : Credit */
        LogFile.instance.InsertLog("TCPServer -> 포인트결제요청 App", Tid: _Tid, TimeStamp: true)
//        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: Response), Tid: _Tid)
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        
        
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint(" TCP server To Device = \(strRes)")

        if Response.isEmpty {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            mPaySdk.Res_Tcp_Point(tcpStatus: tcpStatus.fail, ResData: resDataDic)

            return
        } else if Response[0] == Command.NAK {
            LogFile.instance.InsertLog("NAK 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            mPaySdk.Res_Tcp_Point(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            mPaySdk.Res_Tcp_Point(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            LogFile.instance.InsertLog("응답대기시간 초과", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            mPaySdk.Res_Tcp_Point(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            LogFile.instance.InsertLog("ESC 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            mPaySdk.Res_Tcp_Point(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        let res:Command.TcpResParsingData = Command.TcpResDataParser(ResData: Response)

        
        if res.Data.count < 3 || res.error=="fail" {
            LogFile.instance.InsertLog("응답데이터 오류. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            resDataDic["ERROR"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            mPaySdk.Res_Tcp_Point(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        // eot 로 에러메세지를 보낸다
        if KocesSdk.instance.mEotCheck == 2 {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mPaySdk.Res_Tcp_Point(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        //tid
        resDataDic["TermID"] = res.TermID
        //date
        resDataDic["TrdDate"] = res.TrdDate
        //전문코드 ex)D15 A15 ...
        resDataDic["TrdType"] = res.TrdType
        
        var des:[UInt8] = ar(res.Data[2])

        resDataDic["AnsCode"] = des == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: des) //응답 코드가 0000
        des = ar(res.Data[3])
        resDataDic["Message"] = Utils.utf8toHangul(str: des)    //응답메세지

        if resDataDic["AnsCode"]! != "0000" {
            // 응답 코드가 정상이 아닌 경우
            // 응답 코드, 응답 메세지만 올린다.
            LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
            
            mPaySdk.Res_Tcp_Point(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        if _ResonCancel.prefix(1) == "I" {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mPaySdk.Res_Tcp_Point(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[4]) //포인트는 4번이 포인트 응답정보
        var pointCode:[UInt8] = Array(des[0...1])//포인트코드
        des.removeSubrange(0..<2)
        var cardNumber:[UInt8] = Array(des[0...24])//출력용포인트카드번호
        var CNumber = Utils.utf8toHangul(str: cardNumber)
        des.removeSubrange(0..<25)
        var serviceName:[UInt8] = Array(des[0...7])//서비스명
        des.removeSubrange(0..<8)
        var earnPoint:[UInt8] = Array(des[0...8])//적립포인트
        des.removeSubrange(0..<9)
        var usePoint:[UInt8] = Array(des[0...8])//가용포인트
        des.removeSubrange(0..<9)
        var totalPoint:[UInt8] = Array(des[0...8])//누적포인트
        des.removeSubrange(0..<9)
        var percent:[UInt8] = Array(des[0...8])//할인율
        des.removeSubrange(0..<9)
        var userName:[UInt8] = Array(des[0...11])//고객성명
        des.removeSubrange(0..<12)
        var auNo:[UInt8] = Array(des[0...11])   //포인트승인번호
        des.removeSubrange(0..<12)
        var mchNo:[UInt8] = Array(des[0...14])  //포인트가맹점번호
        des.removeSubrange(0..<15)
        
        resDataDic["PtResCode"] = Utils.utf8toHangul(str: pointCode)   //포인트코드
        LogFile.instance.InsertLog("PtResCode : " + (resDataDic["PtResCode"] ?? ""), Tid: _Tid)
        
        resDataDic["PtResService"] = Utils.utf8toHangul(str: serviceName)   //서비스명
        LogFile.instance.InsertLog("PtResService : " + (resDataDic["PtResService"] ?? ""), Tid: _Tid)
        
        resDataDic["PtResEarnPoint"] = Utils.utf8toHangul(str: earnPoint)   //적립포인트
        LogFile.instance.InsertLog("PtResEarnPoint : " + (resDataDic["PtResEarnPoint"] ?? ""), Tid: _Tid)
        
        resDataDic["PtResUsePoint"] = Utils.utf8toHangul(str: usePoint)   //가용포인트
        LogFile.instance.InsertLog("PtResUsePoint : " + (resDataDic["PtResUsePoint"] ?? ""), Tid: _Tid)
        
        resDataDic["PtResTotalPoint"] = Utils.utf8toHangul(str: totalPoint)   //누적포인트
        LogFile.instance.InsertLog("PtResTotalPoint : " + (resDataDic["PtResTotalPoint"] ?? ""), Tid: _Tid)
        
        resDataDic["PtResPercentPoint"] = Utils.utf8toHangul(str: percent)   //할인율
        LogFile.instance.InsertLog("PtResPercentPoint : " + (resDataDic["PtResPercentPoint"] ?? ""), Tid: _Tid)
        
        resDataDic["PtResUserName"] = Utils.utf8toHangul(str: userName)   //고객성명
        LogFile.instance.InsertLog("PtResUserName : " + (resDataDic["PtResUserName"] ?? ""), Tid: _Tid)
        
        resDataDic["PtResStoreNumber"] = Utils.utf8toHangul(str: mchNo)   //포인트가맹점번호
        LogFile.instance.InsertLog("PtResStoreNumber : " + (resDataDic["PtResStoreNumber"] ?? ""), Tid: _Tid)
        
        resDataDic["AuNo"] = Utils.utf8toHangul(str: auNo)   //포인트승인번호
        LogFile.instance.InsertLog("AuNo : " + (resDataDic["AuNo"] ?? ""), Tid: _Tid)
        
        resDataDic["CardNo"] = Utils.CardParser(카드번호: CNumber, 날짜90일경과: 앱투앱)   //출력용카드번호
        LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
        
        
        des = ar(res.Data[5])   //Working key
        resDataDic["WorkingKey"] = Utils.utf8toHangul(str: des)    //Working key
        LogFile.instance.InsertLog("WorkingKey : " + (resDataDic["WorkingKey"] ?? ""), Tid: _Tid)
        
//        des = ar(res.Data[6])
//        var CNumber = Utils.utf8toHangul(str: des)
//        resDataDic["CardNo"] = Utils.CardParser(카드번호: CNumber, 날짜90일경과: 앱투앱)
//        LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
//
//        des = ar(res.Data[8])
//        resDataDic["CardKind"] = Utils.utf8toHangul(str: des)   //카드종류
//        LogFile.instance.InsertLog("CardKind : " + (resDataDic["CardKind"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[9])
//        resDataDic["OrdCd"] = Utils.utf8toHangul(str: des)  //발급사코드
//        LogFile.instance.InsertLog("OrdCd : " + (resDataDic["OrdCd"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[10])
//        resDataDic["OrdNm"] = Utils.utf8toHangul(str: des)  //발급사명
//        LogFile.instance.InsertLog("OrdNm : " + (resDataDic["OrdNm"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[11])
//        resDataDic["InpCd"] = Utils.utf8toHangul(str: des)  //매입사코드
//        LogFile.instance.InsertLog("InpCd : " + (resDataDic["InpCd"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[12])
//        resDataDic["InpNm"] = Utils.utf8toHangul(str: des)  //매입사명
//        LogFile.instance.InsertLog("InpNm : " + (resDataDic["InpNm"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[13])
//        resDataDic["DDCYn"] = Utils.utf8toHangul(str: des)  //DDC 여부
//        LogFile.instance.InsertLog("DDCYn : " + (resDataDic["DDCYn"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[14])
//        resDataDic["EDCYn"] = Utils.utf8toHangul(str: des)  //EDC 여부
//        LogFile.instance.InsertLog("EDCYn : " + (resDataDic["EDCYn"] ?? ""), Tid: _Tid)
//
//        des = ar(res.Data[17])
//        resDataDic["GiftAmt"] = Utils.utf8toHangul(str: des)  //기프트카드 잔액
//        LogFile.instance.InsertLog("GiftAmt : " + (resDataDic["GiftAmt"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[18])
//        resDataDic["MchNo"] = Utils.utf8toHangul(str: des)  //가맹점번호
//        LogFile.instance.InsertLog("MchNo : " + (resDataDic["MchNo"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[6])
        resDataDic["Keydate"] = Utils.utf8toHangul(str: des)  //암호키만료잔여일
        LogFile.instance.InsertLog("Keydate : " + (resDataDic["Keydate"] ?? ""), Tid: _Tid)
        des = ar(res.Data[7])
        resDataDic["MchData"] = Utils.utf8toHangul(str: des)  //가맹점데이터
        LogFile.instance.InsertLog("MchData : " + (resDataDic["MchData"] ?? ""), Tid: _Tid)


        mPaySdk.Res_Tcp_Point(tcpStatus: tcpStatus.sucess, ResData: resDataDic)
        
        //사용한 신용 데이터 초기화
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        for i in 0 ..< des.count {
            des[i] = 0xFF
        }
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        
        des.removeAll()
        resDataDic.removeAll()
        Response = [0]
        Response.removeAll()

        return
    }
    
    /**
     멤버십결제요청
     */
    func MemberPay(Command _Command:String,Tid _Tid:String,Date _date:String,PosVer _posVer:String,Etc _etc:String,ResonCancel _ResonCancel:String,InputType _inputType:String,CardNumber _CardNum:[UInt8],EncryptInfo _encryptInfo:[UInt8],Money _money:String,memberProductCode _memberProductCode:String,dongul _dongul:String,PosData _posData:String, AppToApp 앱투앱:Bool)
    {
        typealias ar = Array
        /** log : Credit */
        LogFile.instance.InsertLog("멤버십결제요청 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        var Response: [UInt8] = [UInt8]()
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        Response = SendTcpTran(requstData: Command.TCPMemberPay(Command: _Command, Tid: _Tid, Date: _date, PosVer: _posVer, Etc: _etc, ResonCancel: _ResonCancel, InputType: _inputType, CardNumber: _CardNum, EncryptInfo: _encryptInfo, Money: _money, memberProductCode: _memberProductCode, dongul: _dongul, PosData: _posData))
        /** log : Credit */
        LogFile.instance.InsertLog("TCPServer -> 멤버십결제요청 App", Tid: _Tid, TimeStamp: true)
//        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: Response), Tid: _Tid)
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        
        
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint(" TCP server To Device = \(strRes)")

        if Response.isEmpty {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            mPaySdk.Res_Tcp_Member(tcpStatus: tcpStatus.fail, ResData: resDataDic)

            return
        } else if Response[0] == Command.NAK {
            LogFile.instance.InsertLog("NAK 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            mPaySdk.Res_Tcp_Member(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            mPaySdk.Res_Tcp_Member(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            LogFile.instance.InsertLog("응답대기시간 초과", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            mPaySdk.Res_Tcp_Member(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            LogFile.instance.InsertLog("ESC 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            mPaySdk.Res_Tcp_Member(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        let res:Command.TcpResParsingData = Command.TcpResDataParser(ResData: Response)

        
        if res.Data.count < 3 || res.error=="fail" {
            LogFile.instance.InsertLog("응답데이터 오류. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            resDataDic["ERROR"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            mPaySdk.Res_Tcp_Member(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        // eot 로 에러메세지를 보낸다
        if KocesSdk.instance.mEotCheck == 2 {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mPaySdk.Res_Tcp_Member(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        //tid
        resDataDic["TermID"] = res.TermID
        //date
        resDataDic["TrdDate"] = res.TrdDate
        //전문코드 ex)D15 A15 ...
        resDataDic["TrdType"] = res.TrdType
        
        var des:[UInt8] = ar(res.Data[2])

        resDataDic["AnsCode"] = des == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: des) //응답 코드가 0000
        des = ar(res.Data[3])
        resDataDic["Message"] = Utils.utf8toHangul(str: des)    //응답메세지

        if resDataDic["AnsCode"]! != "0000" {
            // 응답 코드가 정상이 아닌 경우
            // 응답 코드, 응답 메세지만 올린다.
            LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
            
            mPaySdk.Res_Tcp_Member(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        if _ResonCancel.prefix(1) == "I" {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mPaySdk.Res_Tcp_Member(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[4]) //포인트는 4번이 포인트 응답정보
        var cardNumber:[UInt8] = Array(des[0...24])//출력용 멤버십 카드번호
        var CNumber = Utils.utf8toHangul(str: cardNumber)
        des.removeSubrange(0..<25)
   
        var cardType:[UInt8] = Array(des[0...19])//카드종류명
        des.removeSubrange(0..<20)
        var serviceType:[UInt8] = Array(des[0...1])//서비스구분
        des.removeSubrange(0..<2)
        var serviceName:[UInt8] = Array(des[0...11])//서비스명
        des.removeSubrange(0..<12)
        var tradeMoney:[UInt8] = Array(des[0...11])//거래금액
        des.removeSubrange(0..<12)
        var saleMoney:[UInt8] = Array(des[0...8])//할인금액
        des.removeSubrange(0..<9)
        var saleAfterMoney:[UInt8] = Array(des[0...8])//할인후금액
        des.removeSubrange(0..<9)
        var tradeAfterPoint:[UInt8] = Array(des[0...8])//잔여포인트
        des.removeSubrange(0..<9)
        var optionCode:[UInt8] = Array(des[0...3])   //옵션코드
        des.removeSubrange(0..<4)
        var auNo:[UInt8] = Array(des[0...11])   //포인트승인번호
        des.removeSubrange(0..<12)
        var mchNo:[UInt8] = Array(des[0...14])  //포인트가맹점번호
        des.removeSubrange(0..<15)
        
        resDataDic["MemberCardTypeText"] = Utils.utf8toHangul(str: cardType)   //카드타입
        LogFile.instance.InsertLog("MemberCardTypeText : " + (resDataDic["MemberCardTypeText"] ?? ""), Tid: _Tid)
        
        resDataDic["MemberServiceTypeText"] = Utils.utf8toHangul(str: serviceType)   //서비스타입
        LogFile.instance.InsertLog("MemberServiceTypeText : " + (resDataDic["MemberServiceTypeText"] ?? ""), Tid: _Tid)
        
        resDataDic["MemberServiceNameText"] = Utils.utf8toHangul(str: serviceName)   //서비스명
        LogFile.instance.InsertLog("MemberServiceNameText : " + (resDataDic["MemberServiceNameText"] ?? ""), Tid: _Tid)
        
        resDataDic["MemberTradeMoneyText"] = Utils.utf8toHangul(str: tradeMoney)   //거래금액
        LogFile.instance.InsertLog("MemberTradeMoneyText : " + (resDataDic["MemberTradeMoneyText"] ?? ""), Tid: _Tid)
        
        resDataDic["MemberSaleMoneyText"] = Utils.utf8toHangul(str: saleMoney)   //할인금액
        LogFile.instance.InsertLog("MemberSaleMoneyText : " + (resDataDic["MemberSaleMoneyText"] ?? ""), Tid: _Tid)
        
        resDataDic["MemberAfterTradeMoneyText"] = Utils.utf8toHangul(str: saleAfterMoney)   //할인후금액
        LogFile.instance.InsertLog("MemberAfterTradeMoneyText : " + (resDataDic["MemberAfterTradeMoneyText"] ?? ""), Tid: _Tid)
        
        resDataDic["MemberAfterMemberPointText"] = Utils.utf8toHangul(str: tradeAfterPoint)   //잔여포인트
        LogFile.instance.InsertLog("MemberAfterMemberPointText : " + (resDataDic["MemberAfterMemberPointText"] ?? ""), Tid: _Tid)
        
        resDataDic["MemberOptionCodeText"] = Utils.utf8toHangul(str: optionCode)   //옵션코드
        LogFile.instance.InsertLog("MemberOptionCodeText : " + (resDataDic["MemberOptionCodeText"] ?? ""), Tid: _Tid)
        
        resDataDic["MemberStoreNoText"] = Utils.utf8toHangul(str: mchNo)   //멤버십가맹점번호
        LogFile.instance.InsertLog("MemberStoreNoText : " + (resDataDic["MemberStoreNoText"] ?? ""), Tid: _Tid)
        
        resDataDic["AuNo"] = Utils.utf8toHangul(str: auNo)   //멤버십승인번호
        LogFile.instance.InsertLog("AuNo : " + (resDataDic["AuNo"] ?? ""), Tid: _Tid)
        
        resDataDic["CardNo"] = Utils.CardParser(카드번호: CNumber, 날짜90일경과: 앱투앱)   //출력용카드번호
        LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
        
        
//        des = ar(res.Data[5])   //Working key
//        resDataDic["WorkingKey"] = Utils.utf8toHangul(str: des)    //Working key
//        LogFile.instance.InsertLog("WorkingKey : " + (resDataDic["WorkingKey"] ?? ""), Tid: _Tid)
        
//        des = ar(res.Data[6])
//        var CNumber = Utils.utf8toHangul(str: des)
//        resDataDic["CardNo"] = Utils.CardParser(카드번호: CNumber, 날짜90일경과: 앱투앱)
//        LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
//
//        des = ar(res.Data[8])
//        resDataDic["CardKind"] = Utils.utf8toHangul(str: des)   //카드종류
//        LogFile.instance.InsertLog("CardKind : " + (resDataDic["CardKind"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[9])
//        resDataDic["OrdCd"] = Utils.utf8toHangul(str: des)  //발급사코드
//        LogFile.instance.InsertLog("OrdCd : " + (resDataDic["OrdCd"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[10])
//        resDataDic["OrdNm"] = Utils.utf8toHangul(str: des)  //발급사명
//        LogFile.instance.InsertLog("OrdNm : " + (resDataDic["OrdNm"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[11])
//        resDataDic["InpCd"] = Utils.utf8toHangul(str: des)  //매입사코드
//        LogFile.instance.InsertLog("InpCd : " + (resDataDic["InpCd"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[12])
//        resDataDic["InpNm"] = Utils.utf8toHangul(str: des)  //매입사명
//        LogFile.instance.InsertLog("InpNm : " + (resDataDic["InpNm"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[13])
//        resDataDic["DDCYn"] = Utils.utf8toHangul(str: des)  //DDC 여부
//        LogFile.instance.InsertLog("DDCYn : " + (resDataDic["DDCYn"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[14])
//        resDataDic["EDCYn"] = Utils.utf8toHangul(str: des)  //EDC 여부
//        LogFile.instance.InsertLog("EDCYn : " + (resDataDic["EDCYn"] ?? ""), Tid: _Tid)
//
//        des = ar(res.Data[17])
//        resDataDic["GiftAmt"] = Utils.utf8toHangul(str: des)  //기프트카드 잔액
//        LogFile.instance.InsertLog("GiftAmt : " + (resDataDic["GiftAmt"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[18])
//        resDataDic["MchNo"] = Utils.utf8toHangul(str: des)  //가맹점번호
//        LogFile.instance.InsertLog("MchNo : " + (resDataDic["MchNo"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[5])
        resDataDic["Keydate"] = Utils.utf8toHangul(str: des)  //암호키만료잔여일
        LogFile.instance.InsertLog("Keydate : " + (resDataDic["Keydate"] ?? ""), Tid: _Tid)
        des = ar(res.Data[6])
        resDataDic["MchData"] = Utils.utf8toHangul(str: des)  //가맹점데이터
        LogFile.instance.InsertLog("MchData : " + (resDataDic["MchData"] ?? ""), Tid: _Tid)


        mPaySdk.Res_Tcp_Member(tcpStatus: tcpStatus.sucess, ResData: resDataDic)
        
        //사용한 신용 데이터 초기화
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        for i in 0 ..< des.count {
            des[i] = 0xFF
        }
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        
        des.removeAll()
        resDataDic.removeAll()
        Response = [0]
        Response.removeAll()

        return
    }
    
    /**
     간편결제 앱카드 신용결제요청
     */
    func AppCredit(Command _Command:String,Tid _Tid:String,Date _date:String,PosVer _posVer:String,Etc _etc:String,ResonCancel _ResonCancel:String,InputType _inputType:String,
                CardNumber _CardNum:String,EncryptInfo _encryptInfo:[UInt8],Money _money:String,Tax _tax:String,ServiceCharge _svc:String,TaxFree _txf:String,Currency _currency:String,
                InstallMent _Installment:String,PosCertificationNumber _PoscertifiNum:String,TradeType _tradeType:String,EmvData _emvData:String,ResonFallBack _fallback:String,
                ICreqData _ICreqData:[UInt8],WorkingKeyIndex _keyIndex:String,Password _passwd:String,OilSurpport _oil:String,OilTaxFree _txfOil:String,DccFlag _Dccflag:String,
                DccReqInfo _DccreqInfo:String,PointCardCode _ptCode:String,PointCardNumber  _ptNum:String,PointCardEncprytInfo _ptCardEncprytInfo:[UInt8],SignInfo _SignInfo:String,
                SignPadSerial _signPadSerial:String,SignData _SignData:[UInt8],Certification _Cert:String,PosData _posData:String,KocesUid _kocesUid:String,UniqueCode _uniqueCode:String,MacAddr _macAddr:String, HardwareKey _hardwareKey:String, AppToApp 앱투앱:Bool)
    {
        typealias ar = Array
        /** log : Credit */
        LogFile.instance.InsertLog("간편결제앱카드 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        var Response: [UInt8] = [UInt8]()
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        Response = SendTcpTran(requstData: Command.TCPICReq(Command: _Command, Tid: _Tid, Date: _date, PosVer: _posVer, Etc: _etc, ResonCancel: _ResonCancel, InputType: _inputType, CardNumber: _CardNum, EncryptInfo: _encryptInfo, Money: _money, Tax: _tax, ServiceCharge: _svc, TaxFree: _txf, Currency: _currency, InstallMent: _Installment, PosCertificationNumber: _PoscertifiNum, TradeType: _tradeType, EmvData: _emvData, ResonFallBack: _fallback, ICreqData: _ICreqData, WorkingKeyIndex: _keyIndex, Password: _passwd, OilSurpport: _oil, OilTaxFree: _txfOil, DccFlag: _Dccflag, DccReqInfo: _DccreqInfo, PointCardCode: _ptCode,  PointCardNumber: _ptNum, PointCardEncprytInfo: _ptCardEncprytInfo, SignInfo: _SignInfo, SignPadSerial: _signPadSerial, SignData: _SignData, Certification: _Cert, PosData: _posData, KocesUid: _kocesUid, UniqueCode: _uniqueCode ,MacAddr: _macAddr, HardwareKey: _hardwareKey))
        /** log : Credit */
        LogFile.instance.InsertLog("TCPServer -> 간편결제앱카드 App", Tid: _Tid, TimeStamp: true)
//        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: Response), Tid: _Tid)
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        
        
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint(" TCP server To Device = \(strRes)")

        if Response.isEmpty {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)

            return
        } else if Response[0] == Command.NAK {
            LogFile.instance.InsertLog("NAK 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            LogFile.instance.InsertLog("응답대기시간 초과", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            LogFile.instance.InsertLog("ESC 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        let res:Command.TcpResParsingData = Command.TcpResDataParser(ResData: Response)

        
        if res.Data.count < 3 || res.error=="fail" {
            LogFile.instance.InsertLog("응답데이터 오류. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            resDataDic["ERROR"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        // eot 로 에러메세지를 보낸다
        if KocesSdk.instance.mEotCheck == 2 {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        //tid
        resDataDic["TermID"] = res.TermID
        //date
        resDataDic["TrdDate"] = res.TrdDate
        //전문코드 ex)D15 A15 ...
        resDataDic["TrdType"] = res.TrdType
        
        var des:[UInt8] = ar(res.Data[2])

        resDataDic["AnsCode"] = des == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: des) //응답 코드가 0000
        des = ar(res.Data[3])
        resDataDic["Message"] = Utils.utf8toHangul(str: des)    //응답메세지

        if resDataDic["AnsCode"]! != "0000" {
            // 응답 코드가 정상이 아닌 경우
            // 응답 코드, 응답 메세지만 올린다.
            LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
            
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        if _ResonCancel.prefix(1) == "I" {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[4])
        resDataDic["AuNo"] = Utils.utf8toHangul(str: des)   //신용 승인번호
        LogFile.instance.InsertLog("AuNo : " + (resDataDic["AuNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[5])
        resDataDic["TradeNo"] = Utils.utf8toHangul(str: des)    //KOCES거래고유번호
        LogFile.instance.InsertLog("TradeNo : " + (resDataDic["TradeNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[6])
        
//        var _tmpCard = String(Utils.utf8toHangul(str: des).replacingOccurrences(of: "-", with: "").prefix(8))
        var CNumber = Utils.utf8toHangul(str: des)
        resDataDic["CardNo"] = Utils.CardParser(카드번호: CNumber, 날짜90일경과: 앱투앱)
        LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
//        resDataDic["CardNo"] = String(_CardNum.prefix(8))  //바코드번호

        //des = ar(res.Data[7]) //거래종류명

        des = ar(res.Data[8])
        resDataDic["CardKind"] = Utils.utf8toHangul(str: des)   //카드종류
        LogFile.instance.InsertLog("CardKind : " + (resDataDic["CardKind"] ?? ""), Tid: _Tid)
        des = ar(res.Data[9])
        resDataDic["OrdCd"] = Utils.utf8toHangul(str: des)  //발급사코드
        LogFile.instance.InsertLog("OrdCd : " + (resDataDic["OrdCd"] ?? ""), Tid: _Tid)
        des = ar(res.Data[10])
        resDataDic["OrdNm"] = Utils.utf8toHangul(str: des)  //발급사명
        LogFile.instance.InsertLog("OrdNm : " + (resDataDic["OrdNm"] ?? ""), Tid: _Tid)
        des = ar(res.Data[11])
        resDataDic["InpCd"] = Utils.utf8toHangul(str: des)  //매입사코드
        LogFile.instance.InsertLog("InpCd : " + (resDataDic["InpCd"] ?? ""), Tid: _Tid)
        des = ar(res.Data[12])
        resDataDic["InpNm"] = Utils.utf8toHangul(str: des)  //매입사명
        LogFile.instance.InsertLog("InpNm : " + (resDataDic["InpNm"] ?? ""), Tid: _Tid)
        des = ar(res.Data[13])
        resDataDic["DDCYn"] = Utils.utf8toHangul(str: des)  //DDC 여부
        LogFile.instance.InsertLog("DDCYn : " + (resDataDic["DDCYn"] ?? ""), Tid: _Tid)
        des = ar(res.Data[14])
        resDataDic["EDCYn"] = Utils.utf8toHangul(str: des)  //EDC 여부
        LogFile.instance.InsertLog("EDCYn : " + (resDataDic["EDCYn"] ?? ""), Tid: _Tid)
        
        //des = ar(res.Data[15]) //전표출력여부
        //des = ar(res.Data[16]) //전표구분명
       
        des = ar(res.Data[17])
        resDataDic["GiftAmt"] = Utils.utf8toHangul(str: des)  //기프트카드 잔액
        LogFile.instance.InsertLog("GiftAmt : " + (resDataDic["GiftAmt"] ?? ""), Tid: _Tid)
        des = ar(res.Data[18])
        resDataDic["MchNo"] = Utils.utf8toHangul(str: des)  //가맹점번호
        LogFile.instance.InsertLog("MchNo : " + (resDataDic["MchNo"] ?? ""), Tid: _Tid)
        
        //des = ar(res.Data[19]) //길이 + IC 응답 Data //응답코드가 정상("0000") 이나 Issuer Authentication Data가 없을 경우(len=0x00) 2ndGenerate AC 단계는 skip
        //des = ar(res.Data[20]) //Working Key
        //des = ar(res.Data[21]) //유류거래응답정보
        //des = ar(res.Data[22]) //DCC조회응답여부
        //des = ar(res.Data[23]) //DCC 응답 정보
        //des = ar(res.Data[24]) //포인트응답코드
        //des = ar(res.Data[25]) //포인트응답메세지
        //des = ar(res.Data[26]) //포인트응답정보
        
        des = ar(res.Data[27])
        resDataDic["Keydate"] = Utils.utf8toHangul(str: des)  //암호키만료잔여일
        LogFile.instance.InsertLog("Keydate : " + (resDataDic["Keydate"] ?? ""), Tid: _Tid)
        des = ar(res.Data[28])
        resDataDic["MchData"] = Utils.utf8toHangul(str: des)  //가맹점데이터
        LogFile.instance.InsertLog("MchData : " + (resDataDic["MchData"] ?? ""), Tid: _Tid)
        
        if _inputType == "U" || _CardNum.replacingOccurrences(of: " ", with: "").count == 26 {
            resDataDic["DisAmt"] = ""  //카카오할임금액
            resDataDic["AuthType"] = "" //카카오페이 결제수단 C:Card, M:Money
            
            resDataDic["AnswerTrdNo"] = ""  //위쳇페이거래고유번호
            resDataDic["ChargeAmt"] = ""  //가맹점수수료
            resDataDic["RefundAmt"] = ""  //가맹점환불금액
            
            resDataDic["QrKind"] = "AP"  //간편결제 거래종류
            LogFile.instance.InsertLog("QrKind : " + (resDataDic["QrKind"] ?? ""), Tid: _Tid)
        }


        mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.sucess, ResData: resDataDic)
        
        //사용한 신용 데이터 초기화
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        for i in 0 ..< des.count {
            des[i] = 0xFF
        }
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        
        des.removeAll()
        resDataDic.removeAll()
        Response = [0]
        Response.removeAll()

        return
    }
    
    /**
     위쳇/알리페이
     */
    func WeChat_AliPay(Command 전문번호:String,Tid _Tid:String,Date 거래일시: String,PosVer 단말버전:String,Etc 단말추가정보:String,CancelInfo 취소정보:String,OriDate 원거래일자:String,OriAuNumber 원승인번호:String, OriSubAuNumber 원서브승인번호:String, InputType 입력방법:String, BarCode 바코드번호:String, PayType 지불수단구분:String,Money 거래금액:String,Tax 세금:String,ServiceCharge 봉사료:String,TaxFree 비과세:String,Currency 통화코드:String, SearchUniqueNum 조회거래고유번호:String, HostStoreData 호스트가맹점데이터:String, TmicNo 단말인증번호:String, StoreData 가맹점데이터:String, KocesUniqueNum KOCES거래고유번호:String, AppToApp 앱투앱:Bool)
    {
        typealias ar = Array
        /** log : WeChat_AliPay */
        LogFile.instance.InsertLog("위쳇/알리페이 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        //서버 요청 전문 만들기
        var Response: [UInt8] = SendTcpTran(requstData: Command.TcpWeChat_AliPay(Command: 전문번호, Tid: _Tid, Date: 거래일시, PosVer: 단말버전, Etc: 단말추가정보, CancelInfo: 취소정보, OriDate: 원거래일자, OriAuNumber: 원승인번호, OriSubAuNumber: 원서브승인번호, InputType: 입력방법, BarCode: 바코드번호, PayType: 지불수단구분, Money: 거래금액, Tax: 세금, ServiceCharge: 봉사료, TaxFree: 비과세, Currency: 통화코드, SearchUniqueNum: 조회거래고유번호, HostStoreData: 호스트가맹점데이터, TmicNo: 단말인증번호, StoreData: 가맹점데이터, KocesUniqueNum: KOCES거래고유번호))
        /** log : WeChat_AliPay */
        LogFile.instance.InsertLog("TCPServer -> 위쳇/알리페이 App", Tid: _Tid, TimeStamp: true)
//        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: Response), Tid: _Tid)
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint(" TCP server To Device = \(strRes)")
        
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        if Response.isEmpty {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.NAK {
            LogFile.instance.InsertLog("NAK 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            LogFile.instance.InsertLog("응답대기시간 초과", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            LogFile.instance.InsertLog("ESC 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        let res:Command.TcpResParsingData = Command.TcpResDataParser(ResData: Response)

        
        if res.Data.count < 3 || res.error=="fail" {
            LogFile.instance.InsertLog("응답데이터 오류. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            resDataDic["ERROR"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        // eot 로 에러메세지를 보낸다
        if KocesSdk.instance.mEotCheck == 2 {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        //tid
        resDataDic["TermID"] = res.TermID
        //date
        resDataDic["TrdDate"] = res.TrdDate
        //전문코드 ex)D15 A15 ...
        resDataDic["TrdType"] = res.TrdType
        
        var des:[UInt8] = ar(res.Data[2])

        resDataDic["AnsCode"] = des == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: des) //응답 코드가 0000
        des = ar(res.Data[3])
        resDataDic["Message"] = Utils.utf8toHangul(str: des)    //응답메세지

        if resDataDic["AnsCode"]! != "0000" {
            // 응답 코드가 정상이 아닌 경우
            // 응답 코드, 응답 메세지만 올린다.
            LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
            
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        if 취소정보.prefix(1) == "1" {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        /**
         여기서부터 만들어야 함
         */
        LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[4])
        resDataDic["AuNo"] = Utils.utf8toHangul(str: des)    //승인번호
        LogFile.instance.InsertLog("AuNo : " + (resDataDic["AuNo"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[5])
//        resDataDic["SubAuNo"] = Utils.utf8toHangul(str: des)    //서브승인번호(미사용)
        des = ar(res.Data[6])
        resDataDic["TradeNo"] = Utils.utf8toHangul(str: des)    //KOCES거래고유번호
        LogFile.instance.InsertLog("TradeNo : " + (resDataDic["TradeNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[7])
//        resDataDic["CardNo"] = Utils.utf8toHangul(str: des)   //출력용바코드번호
        let CNumber = Utils.utf8toHangul(str: des)
        resDataDic["CardNo"] = Utils.EasyParser(바코드qr번호: CNumber, 날짜90일경과: 앱투앱)
        LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[8])
        resDataDic["TradeNo"] = Utils.utf8toHangul(str: des)    //조회고유번호(위쳇페이 조회 시 필수)
        LogFile.instance.InsertLog("TradeNo : " + (resDataDic["TradeNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[9])
        resDataDic["PrintNo"] = Utils.utf8toHangul(str: des)    //출력용거래고유번호(위쳇페이 전표출력 필수)
        LogFile.instance.InsertLog("PrintNo : " + (resDataDic["PrintNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[10])
        resDataDic["OrdCd"] = Utils.utf8toHangul(str: des)    //기관코드
        LogFile.instance.InsertLog("OrdCd : " + (resDataDic["OrdCd"] ?? ""), Tid: _Tid)
        des = ar(res.Data[11])
        resDataDic["OrdNm"] = Utils.utf8toHangul(str: des)    //기관명
        LogFile.instance.InsertLog("OrdNm : " + (resDataDic["OrdNm"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[12])//가맹점번호(미사용)
//        des = ar(res.Data[13])//고객청구통화(미사용)
//        des = ar(res.Data[14])//고객청구금액(미사용)
//        des = ar(res.Data[15])//Qr 길이 + Qr 데이터(미사용)
        des = ar(res.Data[16])
        resDataDic["MchData"] = Utils.utf8toHangul(str: des)  //가맹점데이터
        LogFile.instance.InsertLog("MchData : " + (resDataDic["MchData"] ?? ""), Tid: _Tid)
//        des = ar(res.Data[17])
//        resDataDic["Money"] = Utils.utf8toHangul(str: des)  //거래금액
//        des = ar(res.Data[18])
//        resDataDic["Tax"] = Utils.utf8toHangul(str: des)  //세금
//        des = ar(res.Data[19])
//        resDataDic["ServiceCharge"] = Utils.utf8toHangul(str: des)  //봉사료
//        des = ar(res.Data[20])
//        resDataDic["TaxFree"] = Utils.utf8toHangul(str: des)  //비과세
 
        resDataDic["Money"] = String(Int(거래금액)!)    //거래금액
        if 세금.isEmpty {resDataDic["Tax"] = "0"}
        else {resDataDic["Tax"] = String(Int(세금)!)}//세금
        if 봉사료.isEmpty {resDataDic["ServiceCharge"] = "0"}
        else {resDataDic["ServiceCharge"] = String(Int(봉사료)!)}//봉사료
        if 비과세.isEmpty {resDataDic["TaxFree"] = "0"}
        else {resDataDic["TaxFree"] = String(Int(비과세)!)}//비과세
        
        LogFile.instance.InsertLog("Money : " + (resDataDic["Money"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Tax : " + (resDataDic["Tax"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("ServiceCharge : " + (resDataDic["ServiceCharge"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TaxFree : " + (resDataDic["TaxFree"] ?? ""), Tid: _Tid)
        
        mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.sucess, ResData: resDataDic)
        
        //사용한 위쳇/알리 데이터 초기화
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        for i in 0 ..< des.count {
            des[i] = 0xFF
        }
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        
        des.removeAll()
        resDataDic.removeAll()
        Response = [0]
        Response.removeAll()
        return
    }
    
    /**
     제로페이
     */
    func ZeroPay(Command 전문번호:String,Tid _Tid:String,Date 거래일시: String,PosVer 단말버전:String,Etc 단말추가정보:String,CancelInfo 취소정보:String,InputType 입력방법:String, OriDate 원거래일자:String,OriAuNumber 원승인번호:String, BarCode 바코드번호:String,Money 거래금액:String,Tax 세금:String,ServiceCharge 봉사료:String,TaxFree 비과세:String,Currency 통화코드:String, Installment 할부개월:String,StoreInfo 가맹점추가정보:String, StoreData 가맹점데이터:String, KocesUniqueNum KOCES거래고유번호:String, Data _data:[UInt8] = [UInt8](), AppToApp 앱투앱:Bool)
    {
        /** log : ZeroPay */
        LogFile.instance.InsertLog("제로페이 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        typealias ar = Array
        var Response: [UInt8] = [UInt8]()
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        Response = SendTcpTran(requstData: Command.TcpZeroPay(Command: 전문번호, Tid: _Tid, Date: 거래일시, PosVer: 단말버전, Etc: 단말추가정보, CancelInfo: 취소정보, InputType: 입력방법, OriDate: 원거래일자, OriAuNumber: 원승인번호, BarCode: 바코드번호, Money: 거래금액, Tax: 세금, ServiceCharge: 봉사료, TaxFree: 비과세, Currency: 통화코드, Installment: 할부개월, StoreInfo: 가맹점추가정보, StoreData: 가맹점데이터, KocesUniqueNum: KOCES거래고유번호))
        /** log : ZeroPay */
        LogFile.instance.InsertLog("TCPServer -> 제로페이 App", Tid: _Tid, TimeStamp: true)
//        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: Response), Tid: _Tid)
 
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        
        var strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint(" TCP server To Device = \(strRes)")
        
        if Response.isEmpty {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.NAK {
            LogFile.instance.InsertLog("NAK 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            LogFile.instance.InsertLog("응답대기시간 초과", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            LogFile.instance.InsertLog("ESC 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        let res:Command.TcpResParsingData = Command.TcpResDataParser(ResData: Response)

        
        if res.Data.count < 3 || res.error=="fail" {
            LogFile.instance.InsertLog("응답데이터 오류. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            resDataDic["ERROR"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        // eot 로 에러메세지를 보낸다
        if KocesSdk.instance.mEotCheck == 2 {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        //tid
        resDataDic["TermID"] = res.TermID
        //date
        resDataDic["TrdDate"] = res.TrdDate
        //전문코드 ex)D15 A15 ...
        resDataDic["TrdType"] = res.TrdType
        
        var des:[UInt8] = ar(res.Data[2])

        resDataDic["AnsCode"] = des == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: des) //응답 코드가 0000
        des = ar(res.Data[3])
        resDataDic["Message"] = Utils.utf8toHangul(str: des)    //응답메세지

        if resDataDic["AnsCode"]! != "0000" {
            // 응답 코드가 정상이 아닌 경우
            // 응답 코드, 응답 메세지만 올린다.
            
            if resDataDic["TrdType"]! == "Z35" {
                KocesSdk.instance.mEotCheck = 0
                resDataDic["Message"] = NSString("취소 결과 확인 필요") as String
                resDataDic["ERROR"] = NSString("취소 결과 확인 필요") as String
                
                LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
                LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
                LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
                LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
                LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
                
                mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
                return
            }
            
            if resDataDic["AnsCode"]! != "0100" {
                KocesSdk.instance.mEotCheck = 0
                
                LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
                LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
                LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
                LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
                LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
                
                mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
                return
            }
          
        }
        if 취소정보.prefix(1) == "1" {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        /**
         여기서부터 만들어야 함
         */
        
        LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[4])
        resDataDic["AuNo"] = Utils.utf8toHangul(str: des)    //승인번호
        LogFile.instance.InsertLog("AuNo : " + (resDataDic["AuNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[5])
        resDataDic["TradeNo"] = Utils.utf8toHangul(str: des)    //KOCES거래고유번호
        LogFile.instance.InsertLog("TradeNo : " + (resDataDic["TradeNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[6])
        resDataDic["OrdCd"] = Utils.utf8toHangul(str: des)    //기관코드
        LogFile.instance.InsertLog("OrdCd : " + (resDataDic["OrdCd"] ?? ""), Tid: _Tid)
        des = ar(res.Data[7])
        resDataDic["OrdNm"] = Utils.utf8toHangul(str: des)    //기관명
        LogFile.instance.InsertLog("OrdNm : " + (resDataDic["OrdNm"] ?? ""), Tid: _Tid)
        des = ar(res.Data[8])
        resDataDic["MchNo"] = Utils.utf8toHangul(str: des)  //가맹점번호
        LogFile.instance.InsertLog("MchNo : " + (resDataDic["MchNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[9])
        resDataDic["ChargeAmt"] = Utils.utf8toHangul(str: des)  //가맹점수수료
        LogFile.instance.InsertLog("ChargeAmt : " + (resDataDic["ChargeAmt"] ?? ""), Tid: _Tid)
        des = ar(res.Data[10])
        resDataDic["RefundAmt"] = Utils.utf8toHangul(str: des)  //가맹점환불금액
        LogFile.instance.InsertLog("RefundAmt : " + (resDataDic["RefundAmt"] ?? ""), Tid: _Tid)
        des = ar(res.Data[11])
        resDataDic["MchData"] = Utils.utf8toHangul(str: des)  //가맹점데이터
        LogFile.instance.InsertLog("MchData : " + (resDataDic["MchData"] ?? ""), Tid: _Tid)

        resDataDic["Money"] = String(Int(거래금액)!)    //거래금액
        if 세금.isEmpty {resDataDic["Tax"] = "0"}
        else {resDataDic["Tax"] = String(Int(세금)!)}//세금
        if 봉사료.isEmpty {resDataDic["ServiceCharge"] = "0"}
        else {resDataDic["ServiceCharge"] = String(Int(봉사료)!)}//봉사료
        if 비과세.isEmpty {resDataDic["TaxFree"] = "0"}
        else {resDataDic["TaxFree"] = String(Int(비과세)!)}//비과세
        
        LogFile.instance.InsertLog("Money : " + (resDataDic["Money"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Tax : " + (resDataDic["Tax"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("ServiceCharge : " + (resDataDic["ServiceCharge"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TaxFree : " + (resDataDic["TaxFree"] ?? ""), Tid: _Tid)
        
//        resDataDic["CardNo"] = 바코드번호.isEmpty || 바코드번호.count < 8 ? "":String(바코드번호.prefix(8))  //바코드번호
        resDataDic["CardNo"] = Utils.EasyParser(바코드qr번호: 바코드번호, 날짜90일경과: 앱투앱)  //바코드번호
        LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
        resDataDic["PrintBarcd"] = Utils.EasyParser(바코드qr번호: 바코드번호, 날짜90일경과: 앱투앱)
        LogFile.instance.InsertLog("PrintBarcd : " + (resDataDic["PrintBarcd"] ?? ""), Tid: _Tid)

        resDataDic["CardKind"] = ""
        resDataDic["InpNm"] = "" //매입사명
        resDataDic["InpCd"] = "" //매입사코드
        resDataDic["DDCYn"] = "" //DDC 여부
        resDataDic["EDCYn"] = "" //EDC 여부
        
        resDataDic["DisAmt"] = "" //카카오페이할인금액
        resDataDic["AuthType"] = "" //카카오페이 결제수단
        resDataDic["AnswerTrdNo"] = "" //위쳇페이거래고유번호

        resDataDic["QrKind"] = "ZP" //간편결제 거래종류
        LogFile.instance.InsertLog("QrKind : " + (resDataDic["QrKind"] ?? ""), Tid: _Tid)

//        des = ar(res.Data[12])
//        resDataDic["Money"] = Utils.utf8toHangul(str: des).isEmpty ?  거래금액:Utils.utf8toHangul(str: des)  //거래금액
//        des = ar(res.Data[13])
//        resDataDic["Tax"] = Utils.utf8toHangul(str: des).isEmpty ?  세금:Utils.utf8toHangul(str: des)  //세금
//        des = ar(res.Data[14])
//        resDataDic["ServiceCharge"] = Utils.utf8toHangul(str: des).isEmpty ?  봉사료:Utils.utf8toHangul(str: des)  //봉사료
//        des = ar(res.Data[15])
//        resDataDic["TaxFree"] = Utils.utf8toHangul(str: des).isEmpty ?  비과세:Utils.utf8toHangul(str: des)  //비과세


        mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.sucess, ResData: resDataDic)
        
        //사용한 제로페이 데이터 초기화
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        for i in 0 ..< des.count {
            des[i] = 0xFF
        }
        for i in 0 ..< des.count {
            des[i] = 0x00
        }
        
        des.removeAll()
        resDataDic.removeAll()
        Response = [0]
        Response.removeAll()

        return
    }

    
    /**
     카카오페이
     */
    func KakaoPay(Command 전문번호:String,Tid _Tid:String,Date 거래일시: String,PosVer 단말버전:String,Etc 단말추가정보:String,CancelInfo 취소정보:String,InputType 입력방법:String, BarCode 바코드번호:String, OTCCardCode OTC카드번호:[UInt8], Money 거래금액:String,Tax 세금:String,ServiceCharge 봉사료:String,TaxFree 비과세:String,Currency 통화코드:String, Installment 할부개월:String, PayType 결제수단:String, CancelMethod 취소종류:String, CancelType 취소타입:String, StoreCode 점포코드:String, PEM _PEM:String, trid _trid:String, CardBIN 카드BIN:String, SearchNumber 조회고유번호:String, WorkingKeyIndex _WorkingKeyIndex:String, SignUse 전자서명사용여부:String, SignPadSerial 사인패드시리얼번호:String, SignData 전자서명데이터:[UInt8], StoreData 가맹점데이터:String, Data _data:[UInt8] = [UInt8](), AppToApp 앱투앱:Bool)
    {
        typealias ar = Array
        /** log : KakaoPay */
        LogFile.instance.InsertLog("카카오페이 App -> TCPServer", Tid: _Tid, TimeStamp: true)
        mLogTid = _Tid
        //카카오페이는 승인 전에 무조건 조회를 하고 해야 한다. 그래야 만일 취소처리 시 정상적으로 취소를 할 수 있다. 따라서 여기서 먼저 조회를 하고 그다음에 받은 결과값을 토대로 다시 서버로 전문을 전송한다
        var Response: [UInt8] = []
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        Response = SendTcpTran(requstData: Command.TcpKakaoPay(Command: 전문번호, Tid: _Tid, Date: 거래일시, PosVer: 단말버전, Etc: 단말추가정보, CancelInfo: 취소정보, InputType: 입력방법, BarCode: 바코드번호, OTCCardCode: OTC카드번호, Money: 거래금액, Tax: 세금, ServiceCharge: 봉사료, TaxFree: 비과세, Currency: 통화코드, Installment: 할부개월, PayType: 결제수단, CancelMethod: 취소종류, CancelType: 취소타입, StoreCode: 점포코드, PEM: _PEM, trid: _trid, CardBIN: 카드BIN, SearchNumber: 조회고유번호, WorkingKeyIndex: _WorkingKeyIndex, SignUse: 전자서명사용여부, SignPadSerial: 사인패드시리얼번호, SignData: 전자서명데이터, StoreData: 가맹점데이터))
        /** log : KakaoPay */
        LogFile.instance.InsertLog("TCPServer -> 카카오페이 App", Tid: _Tid, TimeStamp: true)
//        LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: Response), Tid: _Tid)
        var SearchNo = ""   //조회고유번호
        
        /**
         여기서부터 만들어야 함
         */

        //여기는 무조건 K28 조회응답으로 들어온다. 여기서 다시 승인/취소 전문을 보내야 한다
      
        
        for _ in 0 ..< Response.count {
            if Response[0] == 0x05 {
                Response.remove(at: 0)
            }
        }
        
        
        let strRes:String = Utils.UInt8ArrayToHexCode(_value: Response, _option: true)
        debugPrint(" TCP server To Device = \(strRes)")

        if Response.isEmpty {
            LogFile.instance.InsertLog("응답데이터 없음. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            resDataDic["ERROR"] = NSString("통신 장애 발생. 네트워크를 확인해 주세요") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.NAK {
            LogFile.instance.InsertLog("NAK 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (NAK 응답 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ETX {
            LogFile.instance.InsertLog("ETX 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과, 오류전문 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response == Command.TIMEOUT {
            LogFile.instance.InsertLog("응답대기시간 초과", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (응답대기시간 초과)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        } else if Response[0] == Command.ESC {
            LogFile.instance.InsertLog("ESC 수신. 응답대기시간 초과, 오류전문 수신", Tid: _Tid)
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (오류전문 수신)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        let res = Command.TcpResDataParser(ResData: Response)

        
        if res.Data.count < 3 || res.error=="fail" {
            LogFile.instance.InsertLog("응답데이터 오류. 네트워크를 확인해 주세요", Tid: _Tid)
            resDataDic["Message"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            resDataDic["ERROR"] = NSString("데이터를 받아오지 못했습니다. 다시 시도해 주세요") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        // eot 로 에러메세지를 보낸다
        if KocesSdk.instance.mEotCheck == 2 {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        
        //tid
        resDataDic["TermID"] = res.TermID
        //date
        resDataDic["TrdDate"] = res.TrdDate
        //전문코드 ex)D15 A15 ...
        resDataDic["TrdType"] = res.TrdType
        
        var des = ar(res.Data[2])

        resDataDic["AnsCode"] = des == [ 0x30,0x30,0x30,0x30 ] ? "0000": Utils.utf8toHangul(str: des) //응답 코드가 0000
        des = ar(res.Data[3])
        resDataDic["Message"] = Utils.utf8toHangul(str: des)    //응답메세지

        if resDataDic["AnsCode"]! != "0000" {
            // 응답 코드가 정상이 아닌 경우
            // 응답 코드, 응답 메세지만 올린다.
            LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
            LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
            
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        if 취소정보.prefix(1) == "I" {
            KocesSdk.instance.mEotCheck = 0
            LogFile.instance.InsertLog("승인오류 다시 거래 하세요 (EOT 망취소)", Tid: _Tid)
            
            resDataDic["TrdType"] = res.TrdType
            resDataDic["AnsCode"] = "9999"
            resDataDic["Message"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            resDataDic["ERROR"] = NSString("승인오류 다시 거래 하세요 \n (EOT 망취소)") as String
            mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.fail, ResData: resDataDic)
            return
        }
        // 이제 아래에서 정상적으로 승인/취소 에 대한 데이터를 파싱해서 보낸다
        
        LogFile.instance.InsertLog("TrdType : " + (resDataDic["TrdType"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TermID : " + (resDataDic["TermID"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TrdDate : " + (resDataDic["TrdDate"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("AnsCode : " + (resDataDic["AnsCode"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[4])
        resDataDic["Message"] = Utils.utf8toHangul(str: des)    //알림메세지
        LogFile.instance.InsertLog("Message : " + (resDataDic["Message"] ?? ""), Tid: _Tid)
        des = ar(res.Data[5])
        resDataDic["AuNo"] = Utils.utf8toHangul(str: des).replacingOccurrences(of: " ", with: "")    //승인번호
        LogFile.instance.InsertLog("AuNo : " + (resDataDic["AuNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[6])
        resDataDic["AuthType"] = Utils.utf8toHangul(str: des)    //결제수단
        LogFile.instance.InsertLog("AuthType : " + (resDataDic["AuthType"] ?? ""), Tid: _Tid)
        des = ar(res.Data[7])
        resDataDic["KakaoAuMoney"] = Utils.utf8toHangul(str: des)    //승인금액(카카오머니 승인 응답 시(승인금액 = 거래금액 - 카카오할인금액))
        LogFile.instance.InsertLog("KakaoAuMoney : " + (resDataDic["KakaoAuMoney"] ?? ""), Tid: _Tid)
        des = ar(res.Data[8])
        resDataDic["DisAmt"] = Utils.utf8toHangul(str: des)    //카카오페이할인금액
        LogFile.instance.InsertLog("DisAmt : " + (resDataDic["DisAmt"] ?? ""), Tid: _Tid)
        var KakaoSaleMoney = Utils.utf8toHangul(str: des)
        des = ar(res.Data[9])
        resDataDic["KakaoMemberCd"] = Utils.utf8toHangul(str: des)    //카카오 멤버십바코드
        LogFile.instance.InsertLog("KakaoMemberCd : " + (resDataDic["KakaoMemberCd"] ?? ""), Tid: _Tid)
        des = ar(res.Data[10])
        resDataDic["KakaoMemberNo"] = Utils.utf8toHangul(str: des)    //카카오 멤버십 번호
        LogFile.instance.InsertLog("KakaoMemberNo : " + (resDataDic["KakaoMemberNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[11])
        resDataDic["Otc"] = Utils.utf8toHangul(str: des)   //카드번호정보(OTC) - 결제수단 카드 시
        LogFile.instance.InsertLog("Otc : " + (resDataDic["Otc"] ?? ""), Tid: _Tid)
        des = ar(res.Data[12])
        resDataDic["Pem"] = Utils.utf8toHangul(str: des)   //PEM - 결제수단 카드 시
        LogFile.instance.InsertLog("Pem : " + (resDataDic["Pem"] ?? ""), Tid: _Tid)
        des = ar(res.Data[13])
        resDataDic["Trid"] = Utils.utf8toHangul(str: des)   //trid - 결제수단 카드 시
        LogFile.instance.InsertLog("Trid : " + (resDataDic["Trid"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[14])
        var CNumber = Utils.utf8toHangul(str: des)
        resDataDic["CardNo"] = CNumber.isEmpty || CNumber.count < 8 ? Utils.EasyParser(바코드qr번호: 바코드번호):Utils.EasyParser(바코드qr번호: CNumber)  //바코드번호
        LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
        
//        resDataDic["CardNo"] = Utils.utf8toHangul(str: des)    //카드Bin - 결제수단 카드 시
        
        des = ar(res.Data[15])
        if Utils.utf8toHangul(str: des).isEmpty {
            resDataDic["TradeNo"] = 조회고유번호
            LogFile.instance.InsertLog("TradeNo : " + (resDataDic["TradeNo"] ?? ""), Tid: _Tid)
        } else {
            resDataDic["TradeNo"] = Utils.utf8toHangul(str: des)    //조회고유번호
            LogFile.instance.InsertLog("TradeNo : " + (resDataDic["TradeNo"] ?? ""), Tid: _Tid)
        }
        des = ar(res.Data[16])
//        resDataDic["PrintBarcd"] = Utils.utf8toHangul(str: des)    //출력용 바코드 번호(전표 출력시 사용될 바코드 번호)
        var CNumber2 = Utils.utf8toHangul(str: des)
        resDataDic["PrintBarcd"] = Utils.EasyParser(바코드qr번호: CNumber2, 날짜90일경과: 앱투앱)
        LogFile.instance.InsertLog("PrintBarcd : " + (resDataDic["PrintBarcd"] ?? ""), Tid: _Tid)
        resDataDic["CardNo"] = Utils.EasyParser(바코드qr번호: CNumber2, 날짜90일경과: 앱투앱)
        LogFile.instance.InsertLog("CardNo : " + (resDataDic["CardNo"] ?? ""), Tid: _Tid)
        
        des = ar(res.Data[17])
        resDataDic["CardKind"] = Utils.utf8toHangul(str: des)    //카드종류
        LogFile.instance.InsertLog("CardKind : " + (resDataDic["CardKind"] ?? ""), Tid: _Tid)
        des = ar(res.Data[18])
        resDataDic["OrdCd"] = Utils.utf8toHangul(str: des)    //발급사코드
        LogFile.instance.InsertLog("OrdCd : " + (resDataDic["OrdCd"] ?? ""), Tid: _Tid)
        des = ar(res.Data[19])
        resDataDic["OrdNm"] = Utils.utf8toHangul(str: des)    //발급사명
        LogFile.instance.InsertLog("OrdNm : " + (resDataDic["OrdNm"] ?? ""), Tid: _Tid)
        des = ar(res.Data[20])
        resDataDic["InpCd"] = Utils.utf8toHangul(str: des)  //매입사코드
        LogFile.instance.InsertLog("InpCd : " + (resDataDic["InpCd"] ?? ""), Tid: _Tid)
        des = ar(res.Data[21])
        resDataDic["InpNm"] = Utils.utf8toHangul(str: des)  //매입사명
        LogFile.instance.InsertLog("InpNm : " + (resDataDic["InpNm"] ?? ""), Tid: _Tid)
        des = ar(res.Data[22])
        resDataDic["DDCYn"] = Utils.utf8toHangul(str: des)  //DDC 여부
        LogFile.instance.InsertLog("DDCYn : " + (resDataDic["DDCYn"] ?? ""), Tid: _Tid)
        des = ar(res.Data[23])
        resDataDic["EDCYn"] = Utils.utf8toHangul(str: des)  //EDC 여부
        LogFile.instance.InsertLog("EDCYn : " + (resDataDic["EDCYn"] ?? ""), Tid: _Tid)
        des = ar(res.Data[24])
        resDataDic["PrintUse"] = Utils.utf8toHangul(str: des)    //전표출력여부
        LogFile.instance.InsertLog("PrintUse : " + (resDataDic["PrintUse"] ?? ""), Tid: _Tid)
        des = ar(res.Data[25])
        resDataDic["PrintNm"] = Utils.utf8toHangul(str: des)    //전표구분명
        LogFile.instance.InsertLog("PrintNm : " + (resDataDic["PrintNm"] ?? ""), Tid: _Tid)
        des = ar(res.Data[26])
        resDataDic["MchNo"] = Utils.utf8toHangul(str: des)    //가맹점번호
        LogFile.instance.InsertLog("MchNo : " + (resDataDic["MchNo"] ?? ""), Tid: _Tid)
        des = ar(res.Data[27])
        resDataDic["WorkinKey"] = Utils.utf8toHangul(str: des)    //Workingkey(데이터에 null(0x00) 또는 스페이스(0x20) 있을 경우 업데이트 하지 말 것
        LogFile.instance.InsertLog("WorkinKey : " + (resDataDic["WorkinKey"] ?? ""), Tid: _Tid)
        des = ar(res.Data[28])
        resDataDic["MchData"] = Utils.utf8toHangul(str: des)    //가맹점데이터
        LogFile.instance.InsertLog("MchData : " + (resDataDic["MchData"] ?? ""), Tid: _Tid)
        
        resDataDic["AnswerTrdNo"] = "" //위쳇페이거래고유번호
        resDataDic["ChargeAmt"] = "" //가맹점수수료
        resDataDic["RefundAmt"] = "" //가맹점환불금액
        resDataDic["QrKind"] = "KP" //간편결제 거래종류
        LogFile.instance.InsertLog("QrKind : " + (resDataDic["QrKind"] ?? ""), Tid: _Tid)

        var _totalMoney = 0
        var Money = 거래금액
        var Tax = 세금
        var ServiceCharge = 봉사료
        var TaxFree = 비과세
        if !KakaoSaleMoney.isEmpty {
            _totalMoney = Int(Money)! + Int(Tax)! + (ServiceCharge.isEmpty ? 0:Int(ServiceCharge)!) - Int(KakaoSaleMoney)!
            let tax:[String:Int]  = mTaxCalc.TaxCalc(금액: _totalMoney,비과세금액: (TaxFree.isEmpty ? 0:Int(TaxFree)!), 봉사료: (ServiceCharge.isEmpty ? 0:Int(ServiceCharge)!))
            Money = String(tax["Money"]!)
//            Money = Utils.leftPad(str: String(tax["Money"]!), fillChar: "0", length: 10)
            Tax = String(tax["VAT"]!)
            ServiceCharge = String(tax["SVC"]!)
            TaxFree = String(tax["TXF"]!)
        }
//        des = ar(res.Data[29])
        resDataDic["Money"] = String(Int(Money)!)    //거래금액
//        des = ar(res.Data[30])
        if Tax.isEmpty {resDataDic["Tax"] = "0"}
        else {resDataDic["Tax"] = String(Int(Tax)!)}//세금
    
//        des = ar(res.Data[31])
        if ServiceCharge.isEmpty {resDataDic["ServiceCharge"] = "0"}
        else {resDataDic["ServiceCharge"] = String(Int(ServiceCharge)!)}//봉사료
//        resDataDic["ServiceCharge"] = 봉사료  //봉사료
//        des = ar(res.Data[32])
        if TaxFree.isEmpty {resDataDic["TaxFree"] = "0"}
        else {resDataDic["TaxFree"] = String(Int(TaxFree)!)}//비과세
//        resDataDic["TaxFree"] = 비과세  //비과세
        if 할부개월.isEmpty {resDataDic["Installment"] = "0"}
        else {resDataDic["Installment"] = String(Int(할부개월)!)}//할부
//        resDataDic["Installment"] = 할부개월  //할부

        LogFile.instance.InsertLog("Money : " + (resDataDic["Money"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Tax : " + (resDataDic["Tax"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("ServiceCharge : " + (resDataDic["ServiceCharge"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("TaxFree : " + (resDataDic["TaxFree"] ?? ""), Tid: _Tid)
        LogFile.instance.InsertLog("Installment : " + (resDataDic["Installment"] ?? ""), Tid: _Tid)
        
        mKakaoSdk.Res_Tcp_KakaoPay(tcpStatus: tcpStatus.sucess, ResData: resDataDic)
        
        //사용한 카카오페이 데이터 초기화
//        for i in 0 ..< des.count {
//            des[i] = 0x00
//        }
//        for i in 0 ..< des.count {
//            des[i] = 0xFF
//        }
//        for i in 0 ..< des.count {
//            des[i] = 0x00
//        }
        
        des.removeAll()
        resDataDic.removeAll()
        Response = [0]
        Response.removeAll()

        return
    }
    
    
    //-----------------------------------------------------------------------------
    
    func bleManagerIsPaired(uuid: UUID, device:[Dictionary<String,Any>]) {

        isPaireduuid = uuid
        isPairedDevice = device
        
        let TempDeviceName:String = String(describing: self.isPairedDevice[0]["device"].unsafelyUnwrapped)
        var deviceName:String = ""
        if TempDeviceName != "" {
            let temp = TempDeviceName.components(separatedBy: ":")
            if temp.count > 0 {
                deviceName = String(temp[0])
            }

        }

        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "직전에 연결했었던 장비가 검색되었다 : " + deviceName, Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "직전에 연결했었던 장비가 검색되었다 : " + deviceName, Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        
        bleSendNotification(define.IsPaired)
    }
    
    func bleManagerPowerOff() {

        bleState = define.TargetDeviceState.BLENOCONNECT
        if (blePrintState != define.PrintDeviceState.CATUSEPRINT) {
            blePrintState = define.PrintDeviceState.BLENOPRINT
        }
        
        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 종료", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 종료", Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        
        bleClear()
        bleSendNotification(define.PowerOff)
    }
    
    func bleManagerScanFail() {

        bleState = define.TargetDeviceState.BLENOCONNECT
        if (blePrintState != define.PrintDeviceState.CATUSEPRINT) {
            blePrintState = define.PrintDeviceState.BLENOPRINT
        }
        
        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 검색 실패", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 검색 실패", Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        
        bleClear()
        bleSendNotification(define.ScanFail)
    }
    
    // 사용안함
    func bleManagerNotification(info: String) {
        print("BLE:\(info)")
    }
    
    // 사용안함
    func bleManagerUpdateDevices(devices: [[String: Any]]) {

        self.devices = devices
        bleSendNotification(define.UpdateDevices)
    }
    
    func bleManagerScanSuccess() {
        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 검색 성공", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 검색 성공", Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        bleSendNotification(define.ScanSuccess)
    }
    
    func bleManagerConnectStart() {
        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 시작", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 시작", Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        bleSendNotification(define.ConnectStart)
    }
    
    func bleManagerConnectSuccess(name: String, uuid: String) {

        bleState = define.TargetDeviceState.BLECONNECTED
        if name.contains("C100") {
            if (blePrintState != define.PrintDeviceState.CATUSEPRINT) {
                blePrintState = define.PrintDeviceState.BLENOPRINT

            }
        } else if name.contains(define.bleNameKwang) {
            if (blePrintState != define.PrintDeviceState.CATUSEPRINT) {
                blePrintState = define.PrintDeviceState.BLENOPRINT
            }
        } else {
            if (blePrintState != define.PrintDeviceState.CATUSEPRINT) {
                blePrintState = define.PrintDeviceState.BLEUSEPRINT
                Setting.shared.setDefaultUserData(_data: define.PRINTBLE, _key: define.PRINTDEVICE)
            }
//            blePrintState = define.PrintDeviceState.BLEUSEPRINT
//            Setting.shared.setDefaultUserData(_data: define.PRINTBLE, _key: define.PRINTDEVICE)
        }

        mBleConnectedName = name
        mBleConnectedUUID = uuid
        
        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 성공 : " + mBleConnectedName, Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 성공 : " + mBleConnectedName, Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        
        bleSendNotification(define.ConnectSuccess)
    }
    
    func bleManagerConnectFail() {

        bleState = define.TargetDeviceState.BLENOCONNECT
        if (blePrintState != define.PrintDeviceState.CATUSEPRINT) {
            blePrintState = define.PrintDeviceState.BLENOPRINT
        }
        
        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 실패", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 실패", Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        
        bleClear()
        bleSendNotification(define.ConnectFail)
    }
    
    func bleManagerConnectTimeOut() {

        bleState = define.TargetDeviceState.BLENOCONNECT
        if (blePrintState != define.PrintDeviceState.CATUSEPRINT) {
            blePrintState = define.PrintDeviceState.BLENOPRINT
        }
        
        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 타임아웃 실패", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 타임아웃 실패", Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        
        bleClear()
        bleSendNotification(define.ConnectTimeOut)
    }
    
    func bleManagerDisconnect() {

        bleState = define.TargetDeviceState.BLENOCONNECT
        if (blePrintState != define.PrintDeviceState.CATUSEPRINT) {
            blePrintState = define.PrintDeviceState.BLENOPRINT
        }
        
        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 해제", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 연결 해제", Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        
        bleClear()
        bleSendNotification(define.Disconnect)
    }
    
    func bleManagerIsConnected() {

        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 이미 연결 중입니다", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "블루투스 이미 연결 중입니다", Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        
        bleSendNotification(define.IsConnected)
    }
    
    // 사용안함
    func bleManagerSend(_data: [UInt8]) {

        bleSendNotification(define.Send)
    }
    
    func bleManagerWriteComplete(data: Data?) {
        mSendLastData = [UInt8](data!)

        debugPrint("App -> Device Complete :", Utils.UInt8ArrayToHexCode(_value: mSendLastData,_option: true))
        
        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "쓰기 성공", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "쓰기 성공", Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        
        bleSendNotification(define.SendComplete)
    }
    
    func bleManagerPairingFail() {

        bleState = define.TargetDeviceState.BLENOCONNECT
        if (blePrintState != define.PrintDeviceState.CATUSEPRINT) {
            blePrintState = define.PrintDeviceState.BLENOPRINT
        }
        
        if Utils.getIsBT() {
            LogFile.instance.InsertLog("BLE_Status : " + "페어링 실패", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID));
        } else {
            LogFile.instance.InsertLog("BLE_Status : " + "페어링 실패", Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID))
        }
        
        bleClear()
        bleSendNotification(define.PairingKeyFail)
    }
    
    /**
     ble 를 노티를 만들어서 각 뷰,클레스에서 노티를 등록하면 ble 관련 메세지를 받아볼 수 있다
     */
    func bleSendNotification(_ status: String) {
        let detailStatus = ["Status": status]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BLEStatus"), object: self, userInfo: detailStatus)
    }

    /**
     ble connect 함수
     */
    func bleConnect()
    {
        //blemanager 에 검색할 장비를 저장해두고 메니저를 초기화 한후 해당 장비가 있는지 스캔한다
        BLEManager.setDetectDevices(devices: [
                                        DeviceInfo(name: define.bleName, service: define.bleService, rxserial: define.bleRxSerial, txserial: define.bleTxSerial),
                                        DeviceInfo(name: define.bleNameNew, service: define.bleServiceNew, rxserial: define.bleRxSerialNew, txserial: define.bleTxSerialNew),
                                        DeviceInfo(name: define.bleNameZoa, service: define.bleServiceZoa, rxserial: define.bleRxSerialZoa, txserial: define.bleTxSerialZoa),
                                        DeviceInfo(name: define.bleNameKwang, service: define.bleServiceKwang, rxserial: define.bleRxSerialKwang, txserial: define.bleTxSerialKwang),
                                        DeviceInfo(name: define.bleNameKMPC, service: define.bleServiceKMPC, rxserial: define.bleRxSerialKMPC, txserial: define.bleTxSerialKMPC) ])
        manager.delegate = self
        if manager.manager == nil {
            manager.managerInit()
        } else {
            manager.scan()
        }
    }
    
    //ble 연결이 해제되었을 때 설정된 값들을 지운다
    func bleClear() {
        mKocesCode = ""
        mAppCode = ""
        mModelNumber = ""
        mModelVersion = ""
        mSerialNumber = ""
        devices.removeAll()
        devices = [[String: Any]]()
        mBleConnectedName = ""
        mBleConnectedUUID = ""
    }
    
    //데이터를 보내기 전에 ble가 정상적으로 연결중인지 체크한다
    func bleIsConnected() -> Bool {
        manager.delegate = self
        if manager.manager == nil {
            bleClear()
            return false
        }
        return manager.isConnected
    }
    
    //ble 연결을 재시도한다(1회만)
    func bleReConnected() {
//        if !bleIsConnected() {
//            if BleConnectCound == 0 {
//                BleConnectCound += 1
//
//                bleClear()
//                manager.disconnect()
//                bleConnect()
//            } else {
//                BleConnectCound = 0
//                bleClear()
//                manager.disconnect()
//            }
//            return
//        }
        
        BleConnectCound = 0
    }
    
    
//    func scan()
//    {
//        
//        if manager. == BLEManager.CBManagerState.poweredOn
//        {
//            self.devices = [UUID:Dictionary<String,Any>]()
//            manager.scanForPeripherals(withServices: nil, options: nil)
//            return
//        }
//
//        delegate?.bleManagerNotification(info: "Bluetooth not avaliable.")
//    }
    
    /**
     무결성 검증 결과 Sqlite 저장하는 함수
     */
    func setVeritySqliteRecord(_date:String, _result:String) -> Bool {
    
        return true
    }
    /**
     무결성 검증 결과 가져오는 함수
     */
    func getVeritySqliteRecord() -> [verityValue] {
        
        let ResultData:[verityValue] = Array()
        
        return ResultData
    }
    
    struct verityValue {
        var date:String
        var result:String
    }
    
    /// ble 장치에 데이터 쓰는 함수
    /// - Parameter data: UInt8 Array 타입
    @discardableResult
    func bleManagerWrite(Data data:[UInt8]) -> Bool
    {
        if data.count == 0 { return false }
        let reqData = Data(data)
        
        return self.manager.write(data: reqData, name: mBleConnectedName)
    }
//    //전문 처리 보내는 부분
//    //아래의 _delegate: 에서 올라오는 델리게이트를 이곳에서 등록해준다
//    var tcplinstener:cmdListenerDelegate?
//    
//    //그리고 아래 전처리를 받는 곳에서 결과값을 tcplinstener?.onResult(tcpStatus: tcpStatus.sucess, Result: resDataDic)
//    //이처럼 해서 넘겨준다. 그러면 보낸 곳에서 이것에 대해 처리를 받을 곳을 정하면 끝난다
//    func bleDeviceInit(_vanCode:String,_delegate:cmdListenerDelegate) {
//        var temp:[UInt8] = Command.GetVerity()
//        Command.init()
//        
//        let sentCount = self.manager.write(data: Data(temp))
//    }
    
    
    //전문 처리 받는 부분
    //등록된 델리게이트로 전문 처리가 끝난 데이터를 보내준다
    func bleManagerReceive(data: [UInt8]) {
//        let strRes:String = Utils.UInt8ArrayToHexCode(_value: data, _option: true)
//        debugPrint(strRes)
        mReceivedData += data
        
        //펌웨어 업데이트의 특이한 프로토콜 때문에 이 부분을 추가 한다.
        //2021-06-23 kim.jy
        //data.count 가 2개 이상이어야 한다. 만일 갯수가 모자르면 에러가 발생한다
        //2021-09-07 shin.jw
        if data.count > 2 {
            if data == [0x10,0x10,0x10] {
                bleSendNotification(define.Receive)
                mReceiveDataSize = 0
                mReceivedData = []
                return
            }
        }
        //펌웨어 업데이트의 특이한 프로토콜 때문에 이 부분을 추가 한다.
        //2021-06-23 kim.jy
        //data.count 가 2개 이상이어야 한다. 만일 갯수가 모자르면 에러가 발생한다
        //2021-09-07 shin.jw
        if data.count > 2 {
            if data[0...2] == [0x06,0x06,0x06] {
                bleSendNotification(define.Receive)
                mReceiveDataSize = 0
                mReceivedData = []
                return
            }
        }
        
        let MinHeadSize = 4
        if mReceiveDataSize == 0 && mReceivedData[0] == Command.STX && mReceivedData.count > MinHeadSize  {
            mReceiveDataSize = Utils.UInt8ArrayToInt(_value: Array(data[1...2])) + MinHeadSize
        }
        //펌웨어 업데이트의 특이한 프로토콜 때문에 이 부분을 추가 한다.
        //2020-06-23 kim.jy
        if mReceivedData.count > 5 && mReceivedData[0] == Command.STX && mReceivedData[5] == Command.FS {
            mReceiveDataSize =  getRecvFirmwareDataSize(Size: [UInt8](mReceivedData[1...4])) + 7
        }
        
        if mReceivedData.count == mReceiveDataSize && mReceiveDataSize > 0 {

//            debugPrint("device -> App :", Utils.UInt8ArrayToHexCode(_value: mReceivedData,_option: true))
            bleSendNotification(define.Receive)
            resbleDataPaser(resData: mReceivedData)
            //아래 코드는 사용 여부 협의 필요함. 2020-01-27
//            if bleListener != nil {
//                bleListener?.onResult(bleResult: mReceivedData)
//            }
            
            //리시버 초기화

                mReceiveDataSize = 0
                mReceivedData = []


        } else {
//            debugPrint("수신데이터 이상 발생 확인 필요 func bleManagerReceive(data: [UInt8]) 검사")
        }

    }
    
    func resbleDataPaser(resData _resData:[UInt8])
    {
        switch _resData[3] {
        case Command.CMD_IC_RES:
            if mPaySdk.mPrivateBusinessType != 0 {
                /** log ble 단말기에 데이터 받기 */
                LogFile.instance.InsertLog("BLE -> BLE 현금결제 App", Tid: PaySdk.instance.mTid, TimeStamp: true);
                LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: _resData), Tid: PaySdk.instance.mTid);
                mPaySdk.Res_CashRecipt(ResData: _resData, CashOrMsrCheck: false)
            } else {
                if mPaySdk.mPointTrdType == Command.CMD_MEMBER_USE_REQ ||
                    mPaySdk.mPointTrdType == Command.CMD_MEMBER_CANCEL_REQ ||
                    mPaySdk.mPointTrdType == Command.CMD_MEMBER_SEARCH_REQ {
                    /** log ble 단말기에 데이터 받기 */
                    LogFile.instance.InsertLog("BLE -> BLE 멤버십결제 App", Tid: PaySdk.instance.mTid, TimeStamp: true);
                    LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: _resData), Tid: PaySdk.instance.mTid);
                    mPaySdk.Res_Member(ResData: _resData, CashOrMsrCheck: false)
                } else if mPaySdk.mPointTrdType == Command.CMD_POINT_USE_REQ ||
                            mPaySdk.mPointTrdType == Command.CMD_POINT_EARN_REQ ||
                            mPaySdk.mPointTrdType == Command.CMD_POINT_USE_CANCEL_REQ ||
                            mPaySdk.mPointTrdType == Command.CMD_POINT_EARN_CANCEL_REQ ||
                            mPaySdk.mPointTrdType == Command.CMD_POINT_SEARCH_REQ {
                    /** log ble 단말기에 데이터 받기 */
                    LogFile.instance.InsertLog("BLE -> BLE 포인트결제 App", Tid: PaySdk.instance.mTid, TimeStamp: true);
                    LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: _resData), Tid: PaySdk.instance.mTid);
                    mPaySdk.Res_Point(ResData: _resData, CashOrMsrCheck: false)
                } else {
                    /** log ble 단말기에 데이터 받기 */
                    LogFile.instance.InsertLog("BLE -> BLE 신용결제 App", Tid: PaySdk.instance.mTid, TimeStamp: true);
                    LogFile.instance.InsertLog(Utils.UInt8ArrayToHex16Code(_value: _resData), Tid: PaySdk.instance.mTid);
                    mPaySdk.Res_Credit(_res: _resData)
                }
            }
            break
        case Command.CMD_PRINT_RES:
            var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
            if _resData[4] == 0x30 {
                resDataDic["Message"] = NSString("프린트를 완료하였습니다") as String
                printListener?.onPrintResult(printStatus: .OK, printResult: resDataDic)
            } else if _resData[4] == 0x31 {
                resDataDic["Message"] = NSString("용지 없음(프린터 커버 열림)으로 프린트를 실패하였습니다") as String
                printListener?.onPrintResult(printStatus: .FAIL, printResult: resDataDic)
            } else if _resData[4] == 0x32 {
                resDataDic["Message"] = NSString("배터리 부족으로 프린트를 실패하였습니다") as String
                printListener?.onPrintResult(printStatus: .FAIL, printResult: resDataDic)
            } else {
                resDataDic["Message"] = NSString("프린트를 실패하였습니다") as String
                printListener?.onPrintResult(printStatus: .FAIL, printResult: resDataDic)
            }
        case Command.CMD_POSINFO_RES:
            var spt:Int = 4
            let TmIcNo = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 15]))
            Setting.shared.setDefaultUserData(_data: TmIcNo, _key: define.APP_ID)
            spt += 32
            let serialNumber = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 9]))
            spt += 10
            let version = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 4]))
            spt += 5
            let key = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 1]))
            /** 시리얼번호 저장 가맹점등록다운로드 안된 상태에서 시리얼번호 저장하지 않음 */
//                    Setting.shared.setDefaultUserData(_data: serialNumber, _key: define.STORE_SERIAL)
            mKocesCode = define.KOCES_ID
            mAppCode = define.KOCES_APP_ID
            mModelNumber = TmIcNo
            mSerialNumber = serialNumber
            mModelVersion = version //version
         
            break
        default:
            break
        }
    }
    // ========================================= 거래 전 사전 체크 사항 ================================================ //
    func ChecklistBeforeTrading() -> String {
        //가맹점 등록 여부
        if mSetting.getDefaultUserData(_key: define.STORE_TID) == "" { return getStringPlist(Key: "err_msg_no_regist_store") }

        //가맹점 등록 여부
        if mSetting.getDefaultUserData(_key: define.STORE_BSN) == "" { return getStringPlist(Key: "err_msg_no_regist_store") }
        
        //가맹점 등록 여부
        if mSetting.getDefaultUserData(_key: define.STORE_SERIAL) == "" { return getStringPlist(Key: "err_msg_no_regist_store") }
        
        //세금 설정 여부 세금설정을 하지 않았더라도 기본 디폴트 값으로 진행한다
        //if mSetting.getDefaultUserData(_key: define.VAT_USE) == "" { return getStringPlist(Key: "err_msg_no_setting_tax") }
        if mSetting.getDefaultUserData(_key: define.TAX_VAT_USE) == "" { return getStringPlist(Key: "err_msg_no_setting_tax") }
        return ""
    }
    
    func getStringPlist(Key _key:String) -> String {
        StringPlist![_key] as! String
    }
    
    
    // ======================================== 데이터 통신 관련 함수 구현 ============================================== //

    /// 장치에 esc 보낸다
    func SendESC()
    {

        let Data: [UInt8] = [Command.ESC, Command.ESC, Command.ESC, Command.ESC, Command.ESC]
        if bleManagerWrite(Data: Data) {

        }
//        if bleManagerWrite(Data: Command.SendCommand(Command: Command.ESC)) {
//
//        }
    }
    /// 장치에 ack 보낸다
    func SendACK()
    {

        if bleManagerWrite(Data: Command.SendCommand(Command: Command.ACK)) {
            
        }
    }
    /// 장치에 nak 보낸다
    func SendNAK()
    {

        if bleManagerWrite(Data: Command.SendCommand(Command: Command.NAK)) {
            
        }
    }
    /// 장치에 eot 보낸다
    func SendEOT()
    {

        if bleManagerWrite(Data: Command.SendCommand(Command: Command.EOT)) {
            
        }
    }
    /// 장치초기화
    func DeviceInit(VanCode _vancode:String)
    {

        if !bleManagerWrite(Data: Command.DeviceInit(VanCode: _vancode)) {
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
    /// 장비 정보 요청
    /// - Parameter _Date: "yyyyMMddHHmmss"
    func GetDeviceInfo(Date _Date:String) {

        if !bleManagerWrite(Data: Command.GetSystemInfo(Date: _Date)) {
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
    /// 장치 무결성 검사
    func GetVerity(){

        if !bleManagerWrite(Data: Command.GetVerity()) {
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")
        }
    }
    
    /// 장치에 보안키 관련 업데이트 준비 요청
    func KeyDownload_Ready() {

        if !bleManagerWrite(Data: Command.KeyDownload_Ready()) {
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
    
    /// 장치에 보안키 업데이트
    func KeyDownload_Update(Time _time:String ,Data _data:[UInt8]) {

        if !bleManagerWrite(Data: Command.KeyDownload_Update(Time: _time, Data: _data)) {
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
    ///신용
    func BleCredit(Type _type:String,Money _money:String,Date _date:String,UsePad _usePad:String,CashIC _cashIC:String,PrintCount _printCount:String,
                      SignType _signType:String,MinPasswd _minPasswd:String,MaxPasswd _MaxPasswd:String,WorkingKeyIndex _workingKeyIndex:String,WorkingKey _workingkey:String,CashICRnd _cashICRnd:String) {
        /** log ble 단말기에 데이터 전송 */
        LogFile.instance.InsertLog("BLE 신용결제 App -> BLE", Tid: PaySdk.instance.mTid, TimeStamp: true);
        if !bleManagerWrite(Data: Command.Credit(Type: _type, Money: _money, Date: _date, UsePad: _usePad, CashIC: _cashIC, PrintCount: _printCount, SignType: _signType, MinPasswd: _minPasswd, MaxPasswd: _MaxPasswd, WorkingKeyIndex: _workingKeyIndex, WorkingKey: _workingkey, CashICRnd: _cashICRnd)) {
            //쓰기 실패 시
            BlePayNotConnected()
        }
    }
    ///현금
    func BleCash(Type _type:String,Money _money:String,Date _date:String,UsePad _usePad:String,CashIC _cashIC:String,PrintCount _printCount:String,
              SignType _signType:String,MinPasswd _minPasswd:String,MaxPasswd _MaxPasswd:String,WorkingKeyIndex _workingKeyIndex:String,WorkingKey _workingkey:String,CashICRnd _cashICRnd:String) {
        /** log ble 단말기에 데이터 전송 */
        LogFile.instance.InsertLog("BLE 현금결제 App -> BLE", Tid: PaySdk.instance.mTid, TimeStamp: true);
        if !bleManagerWrite(Data: Command.Credit(Type: _type, Money: _money, Date: _date, UsePad: _usePad, CashIC: _cashIC, PrintCount: _printCount, SignType: _signType, MinPasswd: _minPasswd, MaxPasswd: _MaxPasswd, WorkingKeyIndex: _workingKeyIndex, WorkingKey: _workingkey, CashICRnd: _cashICRnd)) {
            //쓰기 실패 시
            BlePayNotConnected()
        }
    }
        
    func BlePrinter(내용 _Contents:String,CallbackListener _linstener:PrintResultDelegate) {
        printListener = _linstener
        
        if mBleConnectedName.contains(define.bleNameZoa) || mBleConnectedName.contains(define.bleNameKMPC) {
            if !bleManagerWrite(Data: Command.Print(_Contents: Utils.hangultoUint8(str: _Contents))) {
                var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
                resDataDic["Message"] = NSString("프린트를 실패(BLE쓰기실패)하였습니다") as String
                printListener?.onPrintResult(printStatus: .OK, printResult: resDataDic)
            }
//            let _p:[UInt8] = [
//                0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x1B ,0x21 ,0x20 ,0xC7 ,0xF6 ,0xB1 ,0xDD ,0xBD ,0xC2 ,0xC0 ,0xCE ,0x1B ,0x21 ,0x00 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x0A ,0x4E ,0x6F ,0x2E ,0x30 ,0x30 ,0x30 ,0x30 ,0x31 ,0x37 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x32 ,0x33 ,0x2F ,0x30 ,0x37 ,0x2F ,0x33 ,0x31 ,0x20 ,0x31 ,0x35 ,0x3A ,0x31 ,0x32 ,0x3A ,0x31 ,0x33 ,0x0A ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x0A ,0xB0 ,0xA1 ,0xB8 ,0xCD ,0xC1 ,0xA1 ,0xB8 ,0xED ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x31 ,0x33 ,0x31 ,0x32 ,0x34 ,0x31 ,0x33 ,0x0A ,0xBB ,0xE7 ,0xBE ,0xF7 ,0xC0 ,0xDA ,0xB9 ,0xF8 ,0xC8 ,0xA3 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x32 ,0x31 ,0x34 ,0x2D ,0x38 ,0x36 ,0x2D ,0x33 ,0x31 ,0x39 ,0x31 ,0x37 ,0x0A ,0xB4 ,0xDC ,0xB8 ,0xBB ,0xB1 ,0xE2 ,0x49 ,0x44 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x2A ,0x2A ,0x2A ,0x30 ,0x30 ,0x30 ,0x30 ,0x39 ,0x30 ,0x30 ,0x0A ,0xB4 ,0xEB ,0xC7 ,0xA5 ,0xC0 ,0xDA ,0xB8 ,0xED ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0xB1 ,0xE8 ,0xC0 ,0xE7 ,0xBF ,0xF8 ,0x0A ,0xBF ,0xAC ,0xB6 ,0xF4 ,0xC3 ,0xB3 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x31 ,0x32 ,0x33 ,0x31 ,0x32 ,0x33 ,0x31 ,0x32 ,0x33 ,0x31 ,0x32 ,0x33 ,0x0A ,0xC1 ,0xD6 ,0xBC ,0xD2 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0xBC ,0xAD ,0xBF ,0xEF ,0xC6 ,0xAF ,0xBA ,0xB0 ,0xBD ,0xC3 ,0xB0 ,0xAD ,0xB3 ,0xB2 ,0xB1 ,0xB8 ,0xBB ,0xEF ,0xBC ,0xBA ,0xB5 ,0xBF ,0x31 ,0x35 ,0x39 ,0x2D ,0x31 ,0xC6 ,0xAE ,0xB7 ,0xB9 ,0xC0 ,0xCC ,0xB5 ,0xE5 ,0xC5 ,0xB8 ,0xBF ,0xF6 ,0x0A ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x0A ,0xBD ,0xC2 ,0xC0 ,0xCE ,0xC0 ,0xCF ,0xBD ,0xC3 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x32 ,0x33 ,0x2F ,0x30 ,0x37 ,0x2F ,0x33 ,0x31 ,0x20 ,0x31 ,0x35 ,0x3A ,0x31 ,0x32 ,0x3A ,0x31 ,0x33 ,0x0A ,0xB0 ,0xED ,0xB0 ,0xB4 ,0xB9 ,0xF8 ,0xC8 ,0xA3 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x34 ,0x35 ,0x37 ,0x39 ,0x30 ,0x36 ,0x2A ,0x2A ,0x2A ,0x2A ,0x2A ,0x2A ,0x36 ,0x34 ,0x33 ,0x2A ,0x0A ,0xBD ,0xC2 ,0xC0 ,0xCE ,0xB9 ,0xF8 ,0xC8 ,0xA3 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x31 ,0x33 ,0x30 ,0x35 ,0x34 ,0x32 ,0x38 ,0x30 ,0x32 ,0x0A ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x0A ,0xB0 ,0xF8 ,0xB1 ,0xDE ,0xB0 ,0xA1 ,0xBE ,0xD7 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x39 ,0x31 ,0x33 ,0xBF ,0xF8 ,0x0A ,0xBA ,0xCE ,0xB0 ,0xA1 ,0xBC ,0xBC ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x39 ,0x31 ,0xBF ,0xF8 ,0x0A ,0xBA ,0xC0 ,0xBB ,0xE7 ,0xB7 ,0xE1 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x30 ,0xBF ,0xF8 ,0x0A ,0xBA ,0xF1 ,0xB0 ,0xFA ,0xBC ,0xBC ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x30 ,0xBF ,0xF8 ,0x0A ,0x1B ,0x21 ,0x20 ,0xB0 ,0xE1 ,0xC1 ,0xA6 ,0xB1 ,0xDD ,0xBE ,0xD7 ,0x1B ,0x21 ,0x00 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x1B ,0x21 ,0x20 ,0x31 ,0x2C ,0x30 ,0x30 ,0x34 ,0xBF ,0xF8 ,0x1B ,0x21 ,0x00 ,0x0A ,0xC8 ,0xDE ,0xB4 ,0xEB ,0xC0 ,0xFC ,0xC8 ,0xAD ,0x2C ,0x20 ,0xC4 ,0xAB ,0xB5 ,0xE5 ,0xB9 ,0xF8 ,0xC8 ,0xA3 ,0xB4 ,0xC2 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x68 ,0x74 ,0x74 ,0x70 ,0x3A ,0x2F ,0x2F ,0x68 ,0x6F ,0x6D ,0x65 ,0x74 ,0x61 ,0x78 ,0x2E ,0x67 ,0x6F ,0x2E ,0x6B ,0x72 ,0x20 ,0xBF ,0xA1 ,0x20 ,0x20 ,0xB5 ,0xEE ,0xB7 ,0xCF ,0x21 ,0x20 ,0xB9 ,0xAE ,0xC0 ,0xC7 ,0x3A ,0x20 ,0x31 ,0x32 ,0x36 ,0x2D ,0x31 ,0x2D ,0x31 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x20 ,0x0A ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x2D ,0x20 ,0x0A
//            ]
//            if !bleManagerWrite(Data: Command.Print(_Contents: Array(_Contents.utf8))) {
//                var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
//                resDataDic["Message"] = NSString("프린트를 실패(BLE쓰기실패)하였습니다") as String
//                printListener?.onPrintResult(printStatus: .OK, printResult: resDataDic)
//            }
            
        } else {
            if !bleManagerWrite(Data: Command.Print(_Contents: Array(_Contents.utf8))) {
                var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
                resDataDic["Message"] = NSString("프린트를 실패(BLE쓰기실패)하였습니다") as String
                printListener?.onPrintResult(printStatus: .OK, printResult: resDataDic)
            }
        }

    }
    
    func BlePrintInit() {
        bleManagerWrite(Data: Command.PrintInit())
    }
    
    func BlePayNotConnected() {
        var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
        resDataDic["Message"] = NSString("BLE장치 쓰기에 실패하였습니다") as String
        PaySdk.instance.paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
    }

    //ble 전원연결 유지시간 설정 5분 10분 상시유지
    func BlePowerManager(유지시간 _stay:define.BlePowerManager) {

        if !bleManagerWrite(Data: Command.PowerManager(_Content: Array(arrayLiteral: _stay.rawValue))) {

        }
    }
    
    //ble 전원종료
    func BlePowerOff() {

        if !bleManagerWrite(Data: Command.PowerOff()) {

        }
    }
    
    //KOCES_SPEC TMS UPDATE START
    func BLEauthenticatoin_req(type: String) {
        if !bleManagerWrite(Data: Command.mutual_authenticatoin_req(_type: type)) {
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
    
    func BLEauthenticatoin_result_req(_date:[UInt8],_multipadAuth:[UInt8], _multipadSerial:[UInt8], _code:[UInt8], _resMsg:[UInt8], _key:[UInt8], _dataCount:[UInt8], _protocol:[UInt8], _Addr:[UInt8], _port:[UInt8], _id:[UInt8], _passwd:[UInt8], _ver:[UInt8], _verDesc:[UInt8], _fn:[UInt8], _fnSize:[UInt8], _fnCheckType:[UInt8], _fnChecksum:[UInt8], _dscrKey:[UInt8]) {
        if !bleManagerWrite(Data: Command.authenticatoin_result_req(_date: _date, _multipadAuth: _multipadAuth, _multipadSerial: _multipadSerial, _code: _code, _resMsg: _resMsg, _key: _key, _dataCount: _dataCount, _protocol: _protocol, _Addr: _Addr, _port: _port, _id: _id, _passwd: _passwd, _ver: _ver, _verDesc: _verDesc, _fn: _fn, _fnSize: _fnSize, _fnCheckType: _fnCheckType, _fnChecksum: _fnChecksum, _dscrKey: _dscrKey)) {
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
    
    /**
     *  업데이트 파일전송 (PC -> BLE)
     * @param _type 요청데이타구분 4 Char 0001:최신펌웨어, 0003:EMV Key
     * @param _dataLength 데이터 총 크기
     * @param _sendDataSize 전송중인 데이터 크기
     * @param _data 데이터
     * @return
     */
    func BLEupdatefile_transfer_req( _type:String, _dataLength:String, _sendDataSize:String, _defaultSize:Int, _data:[UInt8])
    {
        if !bleManagerWrite(Data: Command.updatefile_transfer_req(_type: _type, _dataLength: _dataLength, _sendDataSize: _sendDataSize, _defaultSize: _defaultSize, _data: _data)) {
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }

    }
    
    //KOCES_SPEC TMS UPDATE END
    
    func BleFirmwareUpdateReady() {
        if !bleManagerWrite(Data: Command.FirmwareUpgradeReady()) {
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
    
    func BleFirmwareUpdateStart() {
        if !bleManagerWrite(Data: Command.FirmwareUpgradeStart()) {
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
    
    func BleFirmwareUpdateStart2() {
        if !bleManagerWrite(Data: Command.FirmwareUpgradeStart2()){
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
    
    func BleFirmwareFileSize(Size size:Int) {
        if !bleManagerWrite(Data: Command.FirmwareFileSize(filesize: size)){
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
        
    func BleFirmwareFileData(Data data:[UInt8]){
        if !bleManagerWrite(Data: Command.FirmwareData(data: data)){
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
        
    func BleFirmwareComplete(){
        if !bleManagerWrite(Data: Command.FirmwareComplete()){
            Utils.customAlertBoxInit(Title: "장치쓰기", Message: "BLE장치 쓰기에 실패하였습니다", LoadingBar: false, GetButton: "확인")

        }
    }
    func getRecvFirmwareDataSize(Size size:[UInt8]) -> Int {
        guard let str = String(bytes: size, encoding: .utf8) else {
            return 0
        }
        let total:Int = Int(str) ?? 0
        
        return total
    }
    
    //=========================================================== 프린터 파서 ========================================================================
    func PrintParser(파싱할프린트내용 _Contents:String) -> String {
        let Center:[UInt8] = [ 0x1B, 0x61, 0x31 ]
        let Left:[UInt8] = [ 0x1B, 0x61, 0x30 ]
        let Right:[UInt8] = [ 0x1B, 0x61, 0x32 ]
        let BoldStart:[UInt8] = [ 0x1B, 0x21, 0x20 ]
        let BoldEnd:[UInt8] = [ 0x1B, 0x21, 0x00 ]
        
        var cont:String = _Contents.replacingOccurrences(of: "___LF___", with: "\n")
        cont = cont.replacingOccurrences(of: "Font_LF", with: "\n")
        let StrArr = cont.split(separator: "\n")
        
        var UInt8Array:Array<[UInt8]> = Array()
        
        for n in StrArr {
            let n1 = n.replacingOccurrences(of: "__JYCE__", with: Utils.UInt8ArrayToStr(UInt8Array: Center))
            let n2 = n1.replacingOccurrences(of: "__JYLE__", with: Utils.UInt8ArrayToStr(UInt8Array: Left))
            let n3 = n2.replacingOccurrences(of: "__JYRI__", with: Utils.UInt8ArrayToStr(UInt8Array: Right))
            let n4 = n3.replacingOccurrences(of: "__JYBE__", with: Utils.UInt8ArrayToStr(UInt8Array: BoldEnd))
            var n5 = n4.replacingOccurrences(of: "__JYBS__", with: Utils.UInt8ArrayToStr(UInt8Array: BoldStart))
            n5 = n5.replacingOccurrences(of: define.PInit, with: "")
            n5 = n5.replacingOccurrences(of: define.PFont_HT, with: "")
            n5 = n5.replacingOccurrences(of: define.PFont_LF, with: "")
            
            n5 = n5.replacingOccurrences(of: define.PFont_CR, with: "")
            n5 = n5.replacingOccurrences(of: define.PLogo_Print, with: "")
            n5 = n5.replacingOccurrences(of: define.PCut_print, with: "")
            n5 = n5.replacingOccurrences(of: define.PMoney_Tong, with: "")
            n5 = n5.replacingOccurrences(of: define.PPaper_up, with: "")
            if n5.contains(define.PPaper_up) {
                n5 = n5.replacingOccurrences(of: define.PPaper_up, with: "")
                n5.removeFirst(); n5.removeFirst(); n5.removeFirst(); n5.removeFirst();
            }
            n5 = n5.replacingOccurrences(of: define.PPaper_up, with: "")
            n5 = n5.replacingOccurrences(of: define.PFont_Sort_L, with: Utils.UInt8ArrayToStr(UInt8Array: Left))
            n5 = n5.replacingOccurrences(of: define.PFont_Sort_C, with: Utils.UInt8ArrayToStr(UInt8Array: Center))
            n5 = n5.replacingOccurrences(of: define.PFont_Sort_R, with: Utils.UInt8ArrayToStr(UInt8Array: Right))
            n5 = n5.replacingOccurrences(of: define.PFont_Default, with: Utils.UInt8ArrayToStr(UInt8Array: BoldEnd))
            n5 = n5.replacingOccurrences(of: define.PFont_Size_H, with: "")
            n5 = n5.replacingOccurrences(of: define.PFont_Size_W, with: "")
            n5 = n5.replacingOccurrences(of: define.PFont_Size_B, with: Utils.UInt8ArrayToStr(UInt8Array: BoldStart))
            n5 = n5.replacingOccurrences(of: define.PFont_Bold_0, with: "")
            n5 = n5.replacingOccurrences(of: define.PFont_Bold_1, with: "")
            n5 = n5.replacingOccurrences(of: define.PFont_DS_0, with: "")
            n5 = n5.replacingOccurrences(of: define.PFont_DS_1, with: "")
            n5 = n5.replacingOccurrences(of: define.PFont_Udline_0, with: "")
            n5 = n5.replacingOccurrences(of: define.PFont_Udline_1, with: "")
            if n5.contains(define.PBar_Print_1) {
                n5 = n5.replacingOccurrences(of: define.PBar_Print_1, with: "")
                n5.removeFirst(); n5.removeFirst(); n5.removeFirst(); n5.removeFirst();
//                var _range = n5.range(of: define.PBar_Print_1)!
//                var _index = _range.upperBound
//                n5.remove(at:  String.Index(encodedOffset: _index.hashValue + 1))
            }
//            n5 = n5.replacingOccurrences(of: define.PBar_Print_1, with: "")
            if n5.contains(define.PBar_Print_2) {
                n5 = n5.replacingOccurrences(of: define.PBar_Print_2, with: "")
                n5.removeFirst(); n5.removeFirst(); n5.removeFirst(); n5.removeFirst();
            }
//            n5 = n5.replacingOccurrences(of: define.PBar_Print_2, with: "")
            if n5.contains(define.PBar_Print_3) {
                n5 = n5.replacingOccurrences(of: define.PBar_Print_3, with: "")
                n5.removeFirst(); n5.removeFirst(); n5.removeFirst(); n5.removeFirst();
            }
//            n5 = n5.replacingOccurrences(of: define.PBar_Print_3, with: "")
            if n5.contains(define.PBarH_Size) {
                n5 = n5.replacingOccurrences(of: define.PBarH_Size, with: "")
                n5.removeFirst(); n5.removeFirst(); n5.removeFirst(); n5.removeFirst();
            }
//            n5 = n5.replacingOccurrences(of: define.PBarH_Size, with: "")
            if n5.contains(define.PBarW_Size) {
                n5 = n5.replacingOccurrences(of: define.PBarW_Size, with: "")
                n5.removeFirst(); n5.removeFirst(); n5.removeFirst(); n5.removeFirst();
            }
//            n5 = n5.replacingOccurrences(of: define.PBarW_Size, with: "")
            n5 = n5.replacingOccurrences(of: define.PBar_Position_1, with: "")
            n5 = n5.replacingOccurrences(of: define.PBar_Position_2, with: "")
            n5 = n5.replacingOccurrences(of: define.PBar_Position_3, with: "")
            var temp:[UInt8] = Array(n5.utf8)
            
            temp.append(0x0A)
            
            UInt8Array.append(temp)
        }
        
        var last:[UInt8] = Array()
        
        for n in UInt8Array{
            last += n
        }
        
        return Utils.UInt8ArrayToStr(UInt8Array: last)
   
    }
    
    
}
