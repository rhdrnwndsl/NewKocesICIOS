//
//  firmwareController.swift
//  osxapp
//
//  Created by 金載龍 on 2021/02/23.
//

import Foundation
import UIKit
import SwiftSocket
import Socket

/**
 펌웨어 업데이트 커맨드
 펌웨어 업데이트 준비 커맨드 : 0x4A
 펌웨어 파일 전송 커맨드 : 0x4B


 펌웨어 업데이트 FLOW
     단말기 정보 요청 ->  단말기 정보 전달
     서버로 Firmware 다운 요청 ->  앱으로 파일 전송
     단말기로 업데이트 준비 요청 ->    응답
     CONNECT SERVER 전송 ->   {0x05,0x05,0x05} 전송
     파일 사이즈 전송
     파일 전송 ->   응답
     완료 시 까지 반복
     전송완료 시 완료메시지 전송
         단말기 종료


 유의 사항
 펌웨어 업데이트 시 응답은 { 0x06,0x06,0x06} 으로 받는다.
 파일전송 및 Complete 메시지는 서버에서 내려온 상태 그래도 전송한다.
 펌웨어 파일 전송 완료 후 Complete 메시지를 전송해주면 단말기가 잠시 후 “삐비빅” 소리와 함께 자동으로 종료된다.


 */
class firmwareController: UIViewController {
    
    enum firmwareUpdateProcesStep:Int {
        case none = 0
        case ready = 1
        case fileDown = 2
        case fileDownComplete = 3
        case bleUpdateReady = 4
        case bleUpdateStart = 5
        case bleUpdateSize = 6
        case bleSendData = 7
        case bleUpdateComplete = 8
    }
    
    let mKocesSdk:KocesSdk  = KocesSdk.instance
    var countAck: Int = 0
    var tcplinstener:TcpResultDelegate?

    var mSwiftSocket:TCPClient?
    var iSocket:TCPClient?
    var iSocket2:TCPClient?
    var iTcpSocket:TcpSocket = TcpSocket()
    var iTcpSocket2:TcpSocket = TcpSocket()
    var mDeviceSN:String = ""
    var mTmIcNo:String = ""
    var mVersion:String = ""
    var mKey:String = ""
    var mFileName:String = ""
    var mFileSize:Int = 0
    var mFirmwareUpdateStat = firmwareUpdateProcesStep.none
    var mFirmWareData:[UInt8] = Array()
    @IBOutlet weak var mlbl_Status: UILabel!
    @IBOutlet weak var mlbl_ProcessPercent: UILabel!
    @IBOutlet weak var mProgressview: UIProgressView!
    var mCheckProcessing:Bool = false   //버튼을 눌러서 진행 시키는 동안에는 버튼을 눌러서 반응 없게 한다.
    
    //로딩 메세지박스
    var alertLoading = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)  //화면을 내렸을 때 처리
        Clear()
        self.mProgressview.setProgress(0, animated: false)
        mlbl_Status.text = "펌웨어 업데이트를 진행하십시오"
        mlbl_ProcessPercent.text = "0 %"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        //등록된 노티 전체 제거
        NotificationCenter.default.removeObserver(self)
    }
    
    func Clear() {
        //이전정보를 모두 초기화 시킨다.
        mDeviceSN = ""
        mTmIcNo = ""
        mVersion = ""
        mKey = ""
        mFileName = ""
        mFileSize = 0
        mFirmwareUpdateStat = firmwareUpdateProcesStep.none //버튼이 눌렸기 때문에 초기 ble 업데이트 상태를 초기화 한다.
        mFirmWareData.removeAll()   //펌웨어 데이터를 받을 변수를 초기화 한다.
        self.mProgressview.trackTintColor = .lightGray
        self.mProgressview.progressTintColor = .systemBlue

    }

    @IBAction func clicked_firmware(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        //장치 연결 상태 확인
        if mKocesSdk.bleState != define.TargetDeviceState.BLECONNECTED {
            finishProcessing(Result: false, Message: mKocesSdk.getStringPlist(Key: "err_msg_no_connected_device"))
            return
        }
        
        AlertLoadingBox(title: "업데이트 진행 중입니다.")
        //이전정보를 모두 초기화 시킨다.
        Clear()
        //앱 업데이트 중 화면 자동꺼짐 방지 2021-09-10 by.jiw
        UIApplication.shared.isIdleTimerDisabled = true
        mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        mKocesSdk.GetDeviceInfo(Date: Utils.getDate(format: "yyyyMMddHHmmss") )
        
    }

    @objc func appMovedToBackground() {
        TcpDisConnect()
        if mlbl_Status.text != "펌웨어 업데이트 완료" {
            mlbl_Status.text = "펌웨어 업데이트 실패"
            finishProcessing(Result: false, Message: "펌웨어 업데이트에 실패하였습니다")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
            mKocesSdk.manager.disconnect()
        }
    }
    
    @objc func didBle(_ notification: Notification) {
        guard let bleStatus: String = notification.userInfo?["Status"] as? String else { return }
        // 검색할 때 띄웠던 로딩박스를 지운다

            switch bleStatus {
            case define.Receive:
                let resData:[UInt8] = mKocesSdk.mReceivedData
                responseData(_resData: resData)
                
                break
            case define.Disconnect:
                finishProcessing(Result: false, Message: "장치가 끊어졌습니다")
                break
            case define.PowerOff:
                finishProcessing(Result: false, Message: "BLE 장치를 사용 할 수 없습니다")
                break
            default:
                break
            }

    }

    
    /// 장치에서 올라온 응답을 표시 한다.
    /// - Parameter _resData: <#_resData description#>
    func responseData(_resData:[UInt8])
    {
        if (mKocesSdk.mBleConnectedName.contains(define.bleName) ||
            mKocesSdk.mBleConnectedName.contains(define.bleNameNew)) {
            
            if _resData == [0x10, 0x10, 0x10] {
                if mFirmwareUpdateStat != firmwareUpdateProcesStep.bleUpdateComplete {
                    debugPrint("장치와 연결 끊어짐")
                    mlbl_Status.text = "펌웨어 업데이트 기능이 종료"
                    finishProcessing(Result: false, Message: "펌웨어 업데이트 기능을 종료합니다")
                }
                return
            }

            switch mFirmwareUpdateStat {
            case .none:
                if _resData.count < 4 {
                    return
                }
                
                if _resData[3] == Command.ACK && countAck == 0 {
                    if (mKocesSdk.mBleConnectedName.contains(define.bleNameZoa) ||
                        mKocesSdk.mBleConnectedName.contains(define.bleNameKwang)) {
                        
                    } else {
                        debugPrint("ACK 데이터 버림")
                        countAck += 1
                        return
                    }
                }
                
                countAck = 0
                switch _resData[3]  {
                case Command.CMD_POSINFO_RES:
                    var spt:Int = 4
                    mTmIcNo = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 15]))
                    spt += 32
                    mDeviceSN = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 9]))
                    spt += 10
                    mVersion = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 4]))
                    spt += 5
                    mKey = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 1]))
                    
                    getFirmwareConfigFile()
                    break
                default:
                    break
                }
                break
                
            case .ready:        //ble 장치에 준비를 요청 한다.
                if _resData[3] == Command.ACK{  return  } //이때까지 필요 없이 " 0x02 0x00 0x02 0x06 0x03 0x07" 올라온다.
                if _resData.count > 6 && _resData[3] == Command.CMD_FIRMWARE_READY_REQ {
                    bleUpdateStart()
                }
                else{
                    mlbl_Status.text = mKocesSdk.getStringPlist(Key: "err_firmware_send_ready")
                    finishProcessing(Result: false, Message: mKocesSdk.getStringPlist(Key: "err_firmware_send_ready"))
                }
                break
                
            case .bleUpdateStart:
                if Array(_resData[6...13]) == [UInt8](Array("FileSize".utf8)){
                    bleUpdateSendFileSize()
                }
                break
            case .bleUpdateSize:
                if Array(_resData[0...2]) == [Command.ACK,Command.ACK,Command.ACK] {
                    debugPrint("bleUpdateSize => ")
                    bleUpdateSendData()
                }
                break
            case .bleSendData:
                if _resData == [Command.ACK,Command.ACK,Command.ACK] {
                    debugPrint("bleSendData => ")
                    bleUpdateSendData()
                }
                break
            case.bleUpdateComplete:
                if _resData.count > 3 {
                    if Array(_resData[6...13]) == [UInt8](Array("Complete".utf8)){
                        debugPrint("FirmwareComplete")          //SendData()
                        mlbl_Status.text = "펌웨어 업데이트 완료"
                        finishProcessing(Result: true, Message: "펌웨어 업데이트를 정상적으로 완료했습니다. 잠시 후 BLE 장비의 연결을 종료합니다.")
                    }
                }
                break
            default:
                break
            }
        } else {
            //일반적인 KOCES SPEC
            switch _resData[3]  {
            case Command.ACK:
                debugPrint("App -> firmwareServer : Receive ACK")
                finishProcessing(Result: false, Message: "(Config)펌웨어 서버에 데이터 수신에 실패하였습니다")
                break
            case Command.NAK:
                debugPrint("App -> firmwareServer : Receive NAK")
                finishProcessing(Result: false, Message: "(Config)펌웨어 서버에 데이터 수신에 실패하였습니다")
                break
            case Command.CMD_MUTUAL_AUTHENTICATION_RES:
                if _resData.count < 220 {
                    debugPrint("App -> firmwareServer : Receive 데이터 길이값 이상")
                    finishProcessing(Result: false, Message: "(Config)데이터 길이값 이상")
                    return
                }
                var parseData:[UInt8] = _resData
                
                parseData.remove(at: 0) //STX + 길이 + CommandID 삭제
                var rng = 2 //데이터를 짜르기 위한 범위
                parseData.removeSubrange(0..<rng) //길이
                parseData.remove(at: 0) //CommandID
                rng = 32
                multipadAuthNum =  Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);  //멀티패드인증번호
                rng = 10
                multipadSerialNum = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);  //멀티패드시리얼번호
                rng = 4
                var revDataType : String = String(bytes: Array(parseData[0..<rng]), encoding: .utf8) ?? "";
                parseData.removeSubrange(0..<rng)  //요청데이타구분 0001:최신펌웨어, 0003:EMV Key
                if revDataType == "" {
                    debugPrint("App -> firmwareServer : Receive 요청데이타구분 미수신")
                    finishProcessing(Result: false, Message: "(Config)요청데이타구분 미수신")
                    return
                }
                rng = 90
                var data : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);  //보안키
                rng = 38
                var tmp : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);  //보안키에서 뒤에 버리는 부분
                rng = 10
                var emvKey : String = String(bytes: Array(parseData[0..<rng]), encoding: .utf8) ?? "";
                parseData.removeSubrange(0..<rng)  //EMV Key
                if emvKey == "" {
                    debugPrint("App -> firmwareServer : Receive emvKey 미수신")
                    finishProcessing(Result: false, Message: "(Config)emvKey 미수신")
                    return
                }
                rng = 2
                var tmsUpdateCheck : [UInt8] = Array(parseData[0..<rng]);
                parseData.removeSubrange(0..<rng);  //TMS 업데이트 가능 여부
                if (tmsUpdateCheck[0] == 0x30 && tmsUpdateCheck[1] == 0x30) {

                } else if (tmsUpdateCheck[0] == 0x00 && tmsUpdateCheck[1] == 0x00) {

                } else if (tmsUpdateCheck[0] == 0x20 && tmsUpdateCheck[1] == 0x20) {

                } else {
                    debugPrint("App -> firmwareServer : Receive 업데이트 불가 제품입니다")
                    finishProcessing(Result: false, Message: "(Config)업데이트 불가 제품입니다")
                    return;
                }

                TMS_Data_Down_Info(revDataType: revDataType, multipadSerialNum: multipadSerialNum, data: data)
                break
            case Command.CMD_POSINFO_RES:
                var spt:Int = 4
                mTmIcNo = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 15]))
                spt += 32
                mDeviceSN = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 9]))
                spt += 10
                mVersion = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 4]))
                spt += 5
                mKey = Utils.UInt8ArrayToStr(UInt8Array: Array(_resData[spt...spt + 1]))
                
                BLEauthenticatoin_req(type: "0001")
                break
            case Command.CMD_MUTUAL_AUTHENTICATION_RESULT_RES:
                debugPrint("App -> firmwareServer : Receive CMD_MUTUAL_AUTHENTICATION_RESULT_RES")
                if Ans_Cd != "0000" {
                    finishProcessing(Result: false, Message: "펌웨어실패: " + Ans_Cd + "," + message)
                    return
                }
                
                var parseData:[UInt8] = _resData
                
                parseData.remove(at: 0) //STX + 길이 + CommandID 삭제
                var rng = 2 //데이터를 짜르기 위한 범위
                parseData.removeSubrange(0..<rng) //길이
                parseData.remove(at: 0) //CommandID
                rng = 2
                var _response : [UInt8] =  Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng) //응답결과
                rng = 20
                var _message : [UInt8] =  Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng) //메세지
                var response : String = Utils.UInt8ArrayToStr(UInt8Array: _response)
                var _tmpmessage : String = Utils.utf8toHangul(str: _message)
                if response != "00" {
                    finishProcessing(Result: false, Message: "펌웨어실패: " + response + "," + _tmpmessage)
                    return
                }
                
                rng = 16
                var _fileDecKey : [UInt8] =  Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng) //파일 복호화 키
                var _fileDecKeyTemp : [UInt8] =  Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng) ///파일 복호화 키 남은 부분은 버린다
                mAesKey = _fileDecKey;
                rng = 10
                var _updateSize : [UInt8] =  Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng) //업데이트 크기
                var size_tmp : String = Utils.UInt8ArrayToStr(UInt8Array: _updateSize)
                size_tmp = size_tmp.replacingOccurrences(of: " ", with: "")
                defaultSize = Int(size_tmp) ?? 1024
                
//                rng = 128
//                var _secKey : [UInt8] =  Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng) //보안키
//                parseData.remove(at: 0) //etx
//                parseData.remove(at: 0) //lrc
               
                
                debugPrint("App -> firmwareServer : Receive CMD_MUTUAL_AUTHENTICATION_RESULT_RES")
                
//                var url = URL(string: "ftp://" + User_ID + ":" + Password + "@" + Addr + ":" + "3600" +  File_Path_Name)

                var url = URL(string: "ftp://" + User_ID + ":" + Password + "@" + Addr + ":" + "3600" + File_Path_Name)

                connectFTP()

                break
            case Command.CMD_SEND_UPDATE_DATA_RES:
                mUpdateFirst = 1
                debugPrint("App -> firmwareServer : Receive CMD_SEND_UPDATE_DATA_RES")
                DispatchQueue.main.async { [self] in
                    var parseData:[UInt8] = _resData
                    parseData.remove(at: 0) //STX + 길이 + CommandID 삭제
                    var rng = 2 //데이터를 짜르기 위한 범위
                    parseData.removeSubrange(0..<rng) //길이
                    parseData.remove(at: 0) //CommandID
                    rng = 2
                    var _response : [UInt8] =  Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng) //응답결과
                    var stringResponse = Utils.UInt8ArrayToStr(UInt8Array: _response)
                    rng = 20
                    var _message : [UInt8] =  Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng) //정상 : 정상처리, 실패 : 실패사유
                    var stringMessage = Utils.utf8toHangul(str: _message)
                    if stringResponse == "01" {
                        //실패
                        finishProcessing(Result: false, Message: "펌웨어 업데이트실패: " + stringMessage)
                        return
                    }
                    rng = 2
                    parseData.removeSubrange(0..<rng) //lrc etx
                    if (mUpdateFirst == 0) {
                        TMS_Update_File_Send_loop(_b: AllFile)
                    } else {
                        if (recentSize < updateSize && !AllFile.isEmpty) {
                            TMS_Update_File_Send_loop(_b: AllFile)
                            
                        } else {
                            //완료
                            mUpdateFirst = 0
                            mlbl_Status.text = "펌웨어 업데이트 완료"
                            finishProcessing(Result: true, Message: "펌웨어 업데이트를 정상적으로 완료했습니다. 잠시 후 BLE 장비의 연결을 종료합니다.")
                            
                        }
                    }
                }
                return
//                TMS_Update_File_Send_loop(_b: AllFile)
                
                return;
            default:
                break
            }
        }
    }

    func connectFTP() {
        do {
//            let mySocket = try Socket.create()
//            var _my: () = try mySocket.connect(to: Addr, port: Int32(Port)!)
//            var _tmp : String = "USER " + User_ID + "\r\n"
//            try mySocket.write(from: _tmp)
//            var answer = try mySocket.readString()
//            print(answer)
//
//            _tmp = "PASS " + Password + "\r\n"
//            try mySocket.write(from: _tmp)
//            answer = try mySocket.readString()
//            print(answer)
//
//            _tmp = "PASV " + "\r\n"
//            try mySocket.write(from: _tmp)
//            answer = try mySocket.readString()
//            print(answer)
//            var editedAnswer = String(answer!.dropFirst(26))
//            editedAnswer = editedAnswer.replacingOccurrences(of: ")", with: "")
//            editedAnswer = editedAnswer.replacingOccurrences(of: "(", with: "")
//            editedAnswer = editedAnswer.replacingOccurrences(of: ",", with: ".")
//            editedAnswer = String(editedAnswer.dropLast())
//            let cmps = editedAnswer.components(separatedBy: ".")
//
//            let dataHost:String = cmps[0] + "." + cmps[1] + "." + cmps[2] + "." + cmps[3]
//            let dataPort:Int = ((Int(cmps[4]))!<<8) + Int(cmps[5])!
//
//            print("dataHost: \(dataHost), dataPort: \(dataPort)")
//            Addr = dataHost
//            Port = String(dataPort)
//
//            let mySocket2 = try Socket.create()
//            var _my2: () = try mySocket2.connect(to: Addr, port: Int32(Port)!)
//
//            _tmp = "CWD " + "/firmware" + "\r\n"
//            try mySocket.write(from: _tmp)
//            answer = try mySocket.readString()
//            print(answer)
//
//            _tmp = "TYPE " + "I" + "\r\n"
//            try mySocket.write(from: _tmp)
//            answer = try mySocket.readString()
//
//            _tmp = "TMS2 " + File_Path_Name.substring(시작: 10) + "\r\n"
//            try mySocket.write(from: _tmp)
//            answer = try mySocket.readString()
//            print(answer)
//            var dataV = Data()
//            while(true) {
//                var body = NSMutableData()
//                var answer2 = try mySocket2.read(into: body)
//                if (answer2 <= 0) {
//                    break
//                } else {
//                    let _data = NSData(bytes: body.mutableBytes, length: answer2)
//                    dataV += _data
//                }
//                print(answer2)
//            }
//            print(dataV.count)
//            TMS_Update_File_Send_First(_b: Array(dataV))
            
            
            
            iSocket = TCPClient.init(address: Addr, port: Int32(Port)!)
            guard let client = iSocket  else {
                return
            }

            switch client.connect(timeout: 5) {
            case .success:
                debugPrint("SwiftSocket Connect Success")
                break
            case .failure(let error):
                debugPrint("SwiftSocket Connect Error : ", error)
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Config)FTP 서버 연결에 실패하였습니다")
                return
            }

            var resData: [UInt8] = TcpRead(Client: iSocket!)
            debugPrint("SwiftSocket receive resData : ", Utils.utf8toHangul(str: resData))

            var _tmp : String = "USER " + User_ID + "\r\n"
            if !TcpSend(Data: _tmp.data(using: .utf8)!, Client: iSocket!) {
                debugPrint("App -> firmwareServer : Send Fail")
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Config)FTP 서버 로그인에 실패하였습니다")
                return
            }

            resData = TcpRead(Client: iSocket!)
            debugPrint("SwiftSocket receive resData : ", Utils.utf8toHangul(str: resData))

            _tmp = "PASS " + Password + "\r\n"
            if !TcpSend(Data: _tmp.data(using: .utf8)!, Client: iSocket!) {
                debugPrint("App -> firmwareServer : Send Fail")
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Config)FTP 서버 로그인에 실패하였습니다")
                return
            }

            resData = TcpRead(Client: iSocket!)
            debugPrint("SwiftSocket receive resData : ", Utils.utf8toHangul(str: resData))

            _tmp = "PASV " + "\r\n"
            if !TcpSend(Data: _tmp.data(using: .utf8)!, Client: iSocket!) {
                debugPrint("App -> firmwareServer : Send Fail")
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Config)FTP 서버 PASV 설정에 실패하였습니다")
                return
            }

            resData = TcpRead(Client: iSocket!)
            debugPrint("SwiftSocket receive resData : ", Utils.utf8toHangul(str: resData))

            var pasv2Answer = Utils.utf8toHangul(str: resData)
            var editedAnswer = String(pasv2Answer.dropFirst(26))
            editedAnswer = editedAnswer.replacingOccurrences(of: ")", with: "")
            editedAnswer = editedAnswer.replacingOccurrences(of: "(", with: "")
            editedAnswer = editedAnswer.replacingOccurrences(of: ",", with: ".")
            editedAnswer = String(editedAnswer.dropLast())
            let cmps = editedAnswer.components(separatedBy: ".")

            let dataHost:String = cmps[0] + "." + cmps[1] + "." + cmps[2] + "." + cmps[3]
            let dataPort:Int = ((Int(cmps[4]))!<<8) + Int(cmps[5])!

            print("dataHost: \(dataHost), dataPort: \(dataPort)")
            Addr = dataHost
            Port = String(dataPort)
            
            _tmp = "TYPE I" + "\r\n"
            if !TcpSend(Data: _tmp.data(using: .utf8)!, Client: iSocket!) {
                debugPrint("App -> firmwareServer : Send Fail")
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Config)FTP 서버 PASV 설정에 실패하였습니다")
                return
            }

            resData = TcpRead(Client: iSocket!)
            debugPrint("SwiftSocket receive resData : ", Utils.utf8toHangul(str: resData))

            _tmp = "TMS2 " + File_Path_Name + "\r\n"
            var data = Data()
            if !TcpSend(Data: _tmp.data(using: .utf8)!, Client: iSocket!) {
                debugPrint("App -> firmwareServer : Send Fail")
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Config)FTP TMS2 파일 읽기에 실패하였습니다")
                return
            }

//            resData = TcpRead(Client: iSocket!)
//            debugPrint("SwiftSocket receive resData : ", Utils.utf8toHangul(str: resData))

            iSocket2 = TCPClient.init(address: Addr, port: Int32(Port)!)
            guard let client = iSocket2  else {
                return
            }

            switch client.connect(timeout: 5) {
            case .success:
                debugPrint("SwiftSocket Connect Success")
                break
            case .failure(let error):
                debugPrint("SwiftSocket Connect Error : ", error)
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Config)FTP PASV 서버 연결에 실패하였습니다")
                return
            }

            var _check : Bool = true
            var _data :[UInt8] = []
            while (_check) {
                guard let response = iSocket2!.read(150, timeout: 30) else {
                    _check = false
                    break
                }

                if (response == nil || response.isEmpty || response.count < 1) {
                    _check = false
                    break
                }
                debugPrint(Utils.UInt8ArrayToHexCode(_value: response, _option: true))
                _data += response
            }
            
            
            var parseData : [UInt8] = _data;
//
//            var rng = 2048 //데이터를 짜르기 위한 범위
//            parseData.removeSubrange(0..<parseData.count - rng) //STX(1) 전문총길이(4) 거래전문번호(4) 필드구분자정의(4) fs(1)
            
            if parseData.isEmpty {
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Config)FTP TMS2 파일 읽기에 실패하였습니다")
                return
            }
            
            debugPrint("SwiftSocket AllData : " + String(parseData.count))
            var _data2 : [UInt8] = try Aes.decrypt(_key: mAesKey, encoded: parseData)
            var _ddd : [UInt8] = []
            var _ddd2 : [UInt8] = []
            for i in 0 ..< 200 {
                _ddd.append(parseData[i])
                _ddd2.append(_data2[i])
            }
            debugPrint(Utils.UInt8ArrayToHexCode(_value: _ddd, _option: true))
            debugPrint(Utils.UInt8ArrayToHexCode(_value: _ddd2, _option: true))
//            debugPrint(Utils.UInt8ArrayToHexCode(_value: _data2, _option: false))

            TMS_Update_File_Send_First(_b: _data2)
        } catch let error {
            print("Error reported by connection at  \(error)")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)펌웨어 업데이트에 실패하였습니다 : " + error.localizedDescription)
            return
        }
    }

    //KOCES_SPEC TMS UPDATE START
    var mPercent : Int = 0;
    var updateSize : Int = 0; //총 업데이트 할 사이즈
    var recentSize : Int = 0; //현재까지 업데이트 한 사이즈
    var defaultSize : Int = 1024; //데이터를 한번에 보내는 기본사이즈.
    var multipadAuthNum : [UInt8] = []
    var multipadSerialNum : [UInt8] = []
    var mAesKey : [UInt8] = []
    var mEesKey : [UInt8] = []
    var type = ""; var tid = ""; var version = ""; var serialNum = ""; var Ans_Cd = ""; var message = "";
    var Secu_Key = ""; var Token_cs_Path = ""; var Data_Cnt = ""; var ProtocolT = ""; var Addr = "";
    var Port = ""; var User_ID = ""; var Password = ""; var Data_Type = ""; var Data_Desc = "";
    var File_Path_Name = ""; var File_Size = ""; var Check_Sum_Type = ""; var File_Check_Sum = "";
    var File_Encrypt_key = ""; var Response_Time = "";
    var AllFile :[UInt8] = []   //업데이트할 전체파일
    var mUpdateFirst : Int = 0; // 0 = first, 1 = second_Loop
    func BLEauthenticatoin_req(type: String) {
        mKocesSdk.BLEauthenticatoin_req(type: type)
    }
    
    func TMS_Data_Down_Info (revDataType : String, multipadSerialNum : [UInt8], data : [UInt8]) {
        if !ConenctFirmwareServer(_koces: true) {
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)서버 접속에 실패하였습니다")
            return
        }
        
        var CheckEnqData: [UInt8] = TcpRead(Client: mSwiftSocket!)
        
        if CheckEnqData.count == 0 || CheckEnqData[0] != Command.ENQ {
            //다시한번 받아서 enq 가 안올라온다면 연결이 정상적으로 안된 것이니 연결을 끊는다
            CheckEnqData = TcpRead(Client: mSwiftSocket!)
            if CheckEnqData.count == 0 || CheckEnqData[0] != Command.ENQ {
                // 연결이 되지 않았다
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Config)ENQ 데이터 수신에 실패하였습니다")
                let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                return debugPrint("펌웨어 서버에서 ENQ안 옮")
            }
        }
        
        var sendData:[UInt8] = Array()
        
        sendData = Command.TCP_TMSDownInfo(_Command: "9240", _Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID), _swVer: mVersion, _serialNum: multipadSerialNum, _dataType: revDataType, _secKey: data)
        debugPrint("TMS_Data_Down_Info Send :", Utils.UInt8ArrayToHexCode(_value: sendData,_option: true))
        if !TcpSend(Data: Data(sendData), Client: mSwiftSocket!) {
            debugPrint("App -> firmwareServer : Send Fail")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)펌웨어 서버에 데이터 전송 실패하였습니다")
            return
        }
        
        
        var resData: [UInt8] = TcpRead(Client: mSwiftSocket!)
        var b : [UInt8] = []
        var _receiveCheck : Bool = true
        while(_receiveCheck) {
            if (resData == nil) {
                _receiveCheck = false;
                break
            }
            else if (resData.count <= 0) {
                _receiveCheck = false;
                break
            }
            else if (resData[0] == Command.NAK) {
                _receiveCheck = false;
                break
            }
            b = resData;
            var _re : Int = -1;
            
            for i in 0 ..< b.count {
                if b[i] == Command.STX {
                    _re = i
                    break
                }
            }
            
            if _re > 0  {
                for i in 0 ... _re {
                    b.removeFirst()
                }
            }
            
            if b.count > 400 && _re != -1 {
                _receiveCheck = false;
                break
            } else {
                resData = TcpRead(Client: mSwiftSocket!)
                debugPrint("TMS_Data_Down_Info -> Receive :", Utils.UInt8ArrayToHexCode(_value: resData,_option: true))
            }

        }

        if (b == nil) {
            debugPrint("App -> firmwareServer : Receive nil")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)펌웨어 서버에 데이터 수신에 실패하였습니다")
            return;
        }
        if (b.count <= 0) {
            debugPrint("App -> firmwareServer : Receive 0")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)펌웨어 서버에 데이터 수신에 실패하였습니다")
            return;
        }
        if (b[0] == Command.NAK) {
            debugPrint("App -> firmwareServer : Receive NAK")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)펌웨어 서버에 데이터 수신에 실패하였습니다")
            return;
        }
        
        debugPrint("TMS_Data_Down_Info -> Receive :", Utils.UInt8ArrayToHexCode(_value: b,_option: true))
        
        var parseData : [UInt8] = b;

        var rng = 14 //데이터를 짜르기 위한 범위
        parseData.removeSubrange(0..<rng) //STX(1) 전문총길이(4) 거래전문번호(4) 필드구분자정의(4) fs(1)
        rng = 1
        var _type : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);//유무선구분
        rng = 10
        var _tid : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //단말기ID
        rng = 5
        var _version : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);//유무선구분
        rng = 10
        var _serialNum : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);//유무선구분
        parseData.remove(at: 0) //fs
        rng = 4
        var _Ans_Cd : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);//유무선구분
        parseData.remove(at: 0) //fs
        rng = 80
        var _message : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);//유무선구분
        parseData.remove(at: 0) //fs
        rng = 0
        for i in 0 ..< parseData.count {
            if parseData[i] == Command.FS {
                rng = i
                break
            }
        }
        var _Secu_Key : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);
        parseData.remove(at: 0) //fs
        rng = 0
        for i in 0 ..< parseData.count {
            if parseData[i] == Command.FS {
                rng = i
                break
            }
        }
        var _Token_cs_Path : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng);
        parseData.remove(at: 0) //fs
        rng = 4
        var _Data_Cnt : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //데이터 개수
        if (_Data_Cnt == nil) {
            debugPrint("App -> firmwareServer : Receive 펌웨어실패: 데이터 개수가 없습니다")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)펌웨어실패: 데이터 개수가 없습니다")
            return;
        } else if (_Data_Cnt[0] == 0x30 && _Data_Cnt[1] == 48 && _Data_Cnt[2] == 48 && _Data_Cnt[3] == 48) {
            debugPrint("App -> firmwareServer : Receive 펌웨어실패: 데이터 개수가 없습니다")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)펌웨어실패: 데이터 개수가 없습니다")
            return;
        }
        parseData.remove(at: 0) //fs
        rng = 5
        var _Protocol : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //전송 프로토콜
        parseData.remove(at: 0) //gs
        rng = 0
        for i in 0 ..< parseData.count {
            if parseData[i] == 0x1D {
                rng = i
                break
            }
        }
        var _Addr : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //전송다운로드서버주소프로토콜
        parseData.remove(at: 0) //gs
        rng = 5
        var _Port : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //다운로드서버포트
        parseData.remove(at: 0) //gs
        rng = 0
        for i in 0 ..< parseData.count {
            if parseData[i] == 0x1D {
                rng = i
                break
            }
        }
        var _User_ID : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //계정번호
        parseData.remove(at: 0) //gs
        rng = 0
        for i in 0 ..< parseData.count {
            if parseData[i] == 0x1D {
                rng = i
                break
            }
        }
        var _Password : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //계정비밀번호
        parseData.remove(at: 0) //gs
        rng = 5
        var _Data_Type : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //버전 및 데이터 구분
        parseData.remove(at: 0) //gs
        rng = 0
        for i in 0 ..< parseData.count {
            if parseData[i] == 0x1D {
                rng = i
                break
            }
        }
        var _Data_Desc : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //버전(데이터) 설명
        parseData.remove(at: 0) //gs
        rng = 0
        for i in 0 ..< parseData.count {
            if parseData[i] == 0x1D {
                rng = i
                break
            }
        }
        var _File_Path_Name : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //파일명
        parseData.remove(at: 0) //gs
        rng = 10
        var _File_Size : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //파일크기
        parseData.remove(at: 0) //gs
        rng = 5
        var _Check_Sum_Type : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //파일체크방식
        parseData.remove(at: 0) //gs
        rng = 64
        var _File_Check_Sum : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //파일 체크섬
        var _checkKey : [UInt8] = String(bytes: _File_Check_Sum, encoding: .ascii)!.toHexBytes()!
        parseData.remove(at: 0) //gs
        rng = 32
        var _File_Encrypt_key : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //파일 암호화 키
        var _encKey : [UInt8] = (String(bytes: _File_Encrypt_key, encoding: .utf8)?.toHexBytes())!
        mEesKey = _encKey;
        parseData.remove(at: 0) //fs
        rng = 14
        var _Response_Time : [UInt8] = Array(parseData[0..<rng]); parseData.removeSubrange(0..<rng); //응답시간
        parseData.remove(at: 0) //etx
        parseData.remove(at: 0) //lrc
        
        Data_Type = Utils.utf8toHangul(str: _Data_Type);
        Data_Desc = Utils.utf8toHangul(str: _Data_Desc);
        
        File_Path_Name = Utils.utf8toHangul(str: _File_Path_Name);
        File_Size = Utils.utf8toHangul(str: _File_Size);
        Check_Sum_Type = Utils.utf8toHangul(str: _Check_Sum_Type);
        File_Check_Sum = Utils.utf8toHangul(str: _File_Check_Sum);
        File_Encrypt_key = Utils.utf8toHangul(str: _File_Encrypt_key);
        Response_Time = Utils.utf8toHangul(str: _Response_Time);

        type = Utils.utf8toHangul(str: _type);
        tid = Utils.utf8toHangul(str: _tid);
        version = Utils.utf8toHangul(str: _version);
        serialNum = Utils.utf8toHangul(str: _serialNum);
        Ans_Cd = Utils.utf8toHangul(str: _Ans_Cd);
        message = Utils.utf8toHangul(str: _message);
        Secu_Key = Utils.UInt8ArrayToStr(UInt8Array: _Secu_Key);
        Token_cs_Path = Utils.utf8toHangul(str: _Token_cs_Path);
        Data_Cnt = Utils.utf8toHangul(str: _Data_Cnt);
        ProtocolT = Utils.utf8toHangul(str: _Protocol);
        Addr = Utils.utf8toHangul(str: _Addr);
        Port = Utils.utf8toHangul(str: _Port);
        User_ID = Utils.utf8toHangul(str: _User_ID);
        Password = Utils.utf8toHangul(str: _Password);
        
//        var ConvertsignData : String = Secu_Key.toHexBytes()
        var secu : [UInt8] = Secu_Key.toHexBytes()!
        debugPrint("secu :", Utils.UInt8ArrayToHexCode(_value: secu,_option: true))
        debugPrint("secu :", Utils.UInt8ArrayToHexCode(_value: secu,_option: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){ [self] in
            
            mKocesSdk.BLEauthenticatoin_result_req(_date: _Response_Time, _multipadAuth: multipadAuthNum, _multipadSerial: multipadSerialNum, _code: _Ans_Cd, _resMsg: _message, _key: secu, _dataCount: _Data_Cnt, _protocol: _Protocol, _Addr: _Addr, _port: _Port, _id: _User_ID, _passwd: _Password, _ver: _Data_Type, _verDesc: _Data_Desc, _fn: _File_Path_Name, _fnSize: _File_Size, _fnCheckType: _Check_Sum_Type, _fnChecksum: _checkKey, _dscrKey: _encKey)
        }

    }
    
    func TMS_Update_File_Send_First( _b : [UInt8]) {
        updateSize = 0;
        recentSize = 0;
        mUpdateFirst = 0;
        
        var _size : String = String(_b.count)
        updateSize = _b.count;
        
        var rng = defaultSize //데이터를 짜르기 위한 범위
        var b:[UInt8] = Array()
        b = _b
        var _sample : [UInt8] = []
        _sample = Array(b[0..<rng]); b.removeSubrange(0..<rng)
        AllFile = b
        recentSize = defaultSize;
        mPercent = 0;
        self.mProgressview.setProgress(Float(mPercent), animated: true)
        if mPercent < 100 {
            self.mlbl_ProcessPercent.text = String(format: "%.2f", Float(mPercent)) + " %"
        } else {
            self.mlbl_ProcessPercent.text = String(100.00) + " %"
        }
        
        mKocesSdk.BLEupdatefile_transfer_req(_type: "0001", _dataLength: _size, _sendDataSize: String(recentSize), _defaultSize: defaultSize, _data: _sample)
        
    }
    
    func TMS_Update_File_Send_loop( _b : [UInt8]) {
        var b:[UInt8] = Array()
        b = _b
        var _sample:[UInt8] = Array()
        if (b.count < defaultSize) {
            _sample = b
            AllFile = []
        } else {
            _sample = Array(b[0..<defaultSize]); b.removeSubrange(0..<defaultSize)
            AllFile = b
        }

        recentSize += defaultSize;

        var _percent:Int = (Int) (recentSize * 100)/updateSize;
        if (_percent >= 100) {
            _percent = 100;
        }
        mPercent = _percent;
        DispatchQueue.main.async {[self] in
            self.mProgressview.setProgress(Float(mPercent) / Float(100.0), animated: true)
            self.mlbl_ProcessPercent.text = String(format: "%.2f", Float(mPercent)) + " %"
        }

        mKocesSdk.BLEupdatefile_transfer_req(_type: "0001", _dataLength: String(updateSize), _sendDataSize: String(recentSize), _defaultSize: defaultSize, _data: _sample)
        
    }
    
    //KOCES_SPEC TMS UPDATE END
    
    func TcpSend(Data _data:Data, Client _client:TCPClient) -> Bool{
        switch _client.send(data: _data) {
        case .success:
            debugPrint(Utils.UInt8ArrayToHexCode(_value: [UInt8](_data), _option: true))
            return true
        case .failure(let error):
            debugPrint("Swift Socket Data Send Error : ", error)
            return false
        }
    }
    
    func TcpRead(Client _client:TCPClient) -> [UInt8] {
        guard let response = _client.read(1024*1000, timeout: 30) else {
            return []
        }
        debugPrint(Utils.UInt8ArrayToHexCode(_value: response, _option: true))
        return response
    }
    
    func TcpDisConnect() {
        mSwiftSocket?.close()
    }
    
    func getFirmwareConfigFile()
    {
        if !ConenctFirmwareServer() {
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)서버 접속에 실패하였습니다")
            return
        }
        
        var CheckEnqData: [UInt8] = TcpRead(Client: mSwiftSocket!)
        
        if CheckEnqData.count == 0 || CheckEnqData[0] != Command.ENQ {
            //다시한번 받아서 enq 가 안올라온다면 연결이 정상적으로 안된 것이니 연결을 끊는다
            CheckEnqData = TcpRead(Client: mSwiftSocket!)
            if CheckEnqData.count == 0 || CheckEnqData[0] != Command.ENQ {
                // 연결이 되지 않았다
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Config)ENQ 데이터 수신에 실패하였습니다")
                let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                return debugPrint("펌웨어 서버에서 ENQ안 옮")
            }
        }
        
        var sendData:[UInt8] = Array()
        
        sendData.insert(Command.STX, at: 0)
        sendData += Array("0076".utf8)
        sendData.append(Command.FS)
        sendData += Array("Config".utf8)
        sendData.append(Command.FS)
        sendData += Array(Utils.rightPad(str: "KOCES", fillChar: " ", length: 16).utf8)
        //sendData += Array(Utils.rightPad(str: mTmIcNo, fillChar: " ", length: 16).utf8)
        //test code 장빌ㄹ 읽어서 어떻게 조합 할지는 봐야 한다.
        if mTmIcNo.contains("C101P"){   //플러스 모델의 경우 이름이 확인 필요 하다
            sendData += Array(Utils.rightPad(str: "KRE_C101P", fillChar: " ", length: 16).utf8)
        }
        else if mTmIcNo.contains("C101") {
            sendData += Array(Utils.rightPad(str: "KRE_C101", fillChar: " ", length: 16).utf8)
        }
        else if mTmIcNo.contains("C100P") {
            sendData += Array(Utils.rightPad(str: "KRE_C100P", fillChar: " ", length: 16).utf8)
        }
        else if mTmIcNo.contains("C100") {
            sendData += Array(Utils.rightPad(str: "KRE_C100", fillChar: " ", length: 16).utf8)
        }
        else {
            debugPrint("해당하는 장비가 없음")
            finishProcessing(Result: false, Message: "(Config)해당 장비는 펌웨어 업데이트 불가 장비입니다")
            return
        }
        sendData += Array(Utils.rightPad(str: mVersion, fillChar: " ", length: 16).utf8)
        sendData += Array(Utils.rightPad(str: mDeviceSN, fillChar: " ", length: 16).utf8)
        var chucksize:[UInt8] = [0x30,0x30,0x30,0x30]
        sendData += chucksize
        sendData.append(Command.ETX)
        sendData.append(Utils.makeLRC(_data: sendData))
        
        if !TcpSend(Data: Data(sendData), Client: mSwiftSocket!) {
            debugPrint("App -> firmwareServer : Send Fail")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)펌웨어 서버에 데이터 전송 실패하였습니다")
            return
        }
        
        var resData: [UInt8] = TcpRead(Client: mSwiftSocket!)
        debugPrint("firmwareServer -> App :", Utils.UInt8ArrayToHexCode(_value: resData,_option: true))
        if resData.count == 0 {
            debugPrint("firmwareServer -> App : Receive Fail")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)펌웨어 서버에서 보내는 데이터 수신에 실패하였습니다")
            return
        }
        
        resData.remove(at: 0) //remove stx
        var range = 0...3
        let length:String = Utils.utf8toHangul(str: Array(resData[range]))
        resData.removeSubrange(range)
        
        resData.remove(at: 0) //remove fs
        range = 0...5
        let resCode:String = Utils.utf8toHangul(str: Array(resData[range]))
        resData.removeSubrange(range)

        resData.remove(at: 0) //remove fs
        range = 0...(resData.count - 2)
        let listInfo:String = Utils.utf8toHangul(str: Array(resData[range]))
        
        if resCode != "Config" {
            debugPrint("펌웨어 서버 리스트 요청 응답 코드가" + resCode)
            debugPrint("펌웨어 서버 리스트 요청 리스트인포" + listInfo)
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)펌웨어 서버 리스트 요청 응답 코드가 Config 가 아닙니다" + "(" + resCode + ")")
            return
        }
        
        //리스트 길이 구하기
        
        
        range = 0...3
        let FileNameSize:String = Utils.utf8toHangul(str: Array(resData[range]))
        resData.removeSubrange(range)
        if FileNameSize == "0000" { //파일이름 사이즈가 0000 인 경우
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)" + mKocesSdk.getStringPlist(Key: "err_firmware_no_exist_filename"))
            return
        }
        
        range = 0...(Int(FileNameSize)! - 1)
        let temp:[UInt8] = Array(resData[range])    //파일 이름 추출
        var bFn:[UInt8] = Array<UInt8>()
        for n:UInt8 in temp {
            if n != 0x00 {
                if bFn.count == 0 {
                    bFn.insert(n, at: 0)
                }
                else
                {
                    bFn.append(n)
                }
            }
        }
        
        if bFn.count == 0 {     //파일이름이 없고 파일 이름자리가 0x00 인 경우
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)" + mKocesSdk.getStringPlist(Key: "err_firmware_no_exist_filename"))
            return
        }
        let FN:String = Utils.utf8toHangul(str: bFn)    //펌웨어 파일 이름
        //연결 종료 작업 ACK 3bytes
        //recv EOT 4bytes
        //disconnect
        sendData = [Command.ACK,Command.ACK,Command.ACK]
        if !TcpSend(Data: Data(sendData), Client: mSwiftSocket!) {
            debugPrint("App -> firmwareServer : Send [Command.ACK,Command.ACK,Command.ACK] Fail")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Config)데이터 전송에 실패하였습니다(Send Ack*3)")
            return
        }
        //CheckEnqData = [UInt8] (mTcpSocket.recv(buffersize: 4))
        TcpDisConnect()
        
        getFirmwareFileSize(FileName: FN)
        
    }
    ///펌웨어 파일 사이즈 구하기
    func getFirmwareFileSize(FileName fn:String)
    {
        /* 20210503 kim.jy */
        /* 서버에서 펌웨어 파일 사이즈 구하기 */
        if !ConenctFirmwareServer() {
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(FileSize)서버 접속에 실패하였습니다")
            return
        }
        
        var CheckEnqData = TcpRead(Client: mSwiftSocket!)
        
        if CheckEnqData.count == 0 || CheckEnqData[0] != Command.ENQ {
            //다시한번 받아서 enq 가 안올라온다면 연결이 정상적으로 안된 것이니 연결을 끊는다
            CheckEnqData = TcpRead(Client: mSwiftSocket!)
            if CheckEnqData.count == 0 || CheckEnqData[0] != Command.ENQ {
                // 연결이 되지 않았다
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(FileSize)ENQ 수신에 실패하였습니다")
                let responseData: [UInt8] = Array(arrayLiteral: Command.ENQ)
                return debugPrint("펌웨어 서버에서 ENQ안 옮")
            }
        }
        
        //파일 이름만 추출 한다.
        let fnName:[String] = fn.components(separatedBy: "\t")
        mFileName = String(fnName[2])
        
        var sendData:[UInt8] = Array()
        sendData.insert(Command.STX, at: 0)
        let temp_checkfilesizelength:Int = 78 + mFileName.count
        //let temp_checkfilesizelength:Int = 78 + Int(FileNameSize)!
        
        sendData += Utils.StrLengthToUIntArray(value: String(temp_checkfilesizelength), Length: 4)
        sendData.append(Command.FS)
        sendData += Array("FileSize".utf8)
        sendData.append(Command.FS)
        sendData += Array(Utils.rightPad(str: "KOCES", fillChar: " ", length: 16).utf8)
        //sendData += Array(Utils.rightPad(str: mTmIcNo, fillChar: " ", length: 16).utf8)
        //test code 장빌ㄹ 읽어서 어떻게 조합 할지는 봐야 한다.
        if mTmIcNo.contains("C101P") {
            sendData += Array(Utils.rightPad(str: "KRE_C101P", fillChar: " ", length: 16).utf8)
        }
        else if mTmIcNo.contains("C101") {
            sendData += Array(Utils.rightPad(str: "KRE_C101", fillChar: " ", length: 16).utf8)
        }
        else if mTmIcNo.contains("C100P") {
            sendData += Array(Utils.rightPad(str: "KRE_C100P", fillChar: " ", length: 16).utf8)
        }
        else if mTmIcNo.contains("C100") {
            sendData += Array(Utils.rightPad(str: "KRE_C100", fillChar: " ", length: 16).utf8)
        }
        else {
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(FileSize)" + mKocesSdk.getStringPlist(Key: "err_firmware_no_fileSize"))
            return
        }
        sendData += Array(Utils.rightPad(str: mVersion, fillChar: " ", length: 16).utf8)
        sendData += Array(Utils.rightPad(str: mDeviceSN, fillChar: " ", length: 16).utf8)
        let chucksize:[UInt8] = [0x31,0x30,0x32,0x34]
        sendData += chucksize
        sendData += Array(mFileName.utf8)
        sendData.append(Command.ETX)

        sendData.append(Utils.makeLRC(_data: sendData))
        debugPrint("app -> firmwareSever: " + Utils.UInt8ArrayToHexCode(_value: sendData, _option: true))
        debugPrint("app -> firmwareSever: " + Utils.utf8toHangul(str: sendData))
        if !TcpSend(Data: Data(sendData), Client: mSwiftSocket!) {
            debugPrint("App -> firmwareServer : Send Fail")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(FileSize)펌웨어 서버에 데이터 전송을 실패하였습니다")
            return
        }

        
        var resData:[UInt8] = Array()
        resData = TcpRead(Client: mSwiftSocket!)
        debugPrint("firmwareServer -> App :", Utils.UInt8ArrayToHexCode(_value: resData,_option: true))
        debugPrint(Utils.utf8toHangul(str: resData))
        if resData.count == 0 {
            debugPrint("firmwareServer -> App : Receive Fail")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(FileSize)펌웨어 서버에서 보내는 데이터 수신에 실패하였습니다")
            return
        }
        
        sendData = [Command.ACK,Command.ACK,Command.ACK]
        if !TcpSend(Data: Data(sendData), Client: mSwiftSocket!) {
            debugPrint("App -> firmwareServer : Send [Command.ACK,Command.ACK,Command.ACK] Fail")
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(FileSize)펌웨어 서버에 데이터 전송을 실패하였습니다(Send Ack*3)")
            return
        }
        //CheckEnqData = [UInt8] (mTcpSocket.recv(buffersize: 4))
        //mTcpSocket.disconnect()
        
        resData.remove(at: 0)   //STX 제거
        var range = 0...3
        let length:String = Utils.utf8toHangul(str: Array(resData[range]))  //전문 길이
        resData.removeSubrange(range)
    
        resData.remove(at: 0)   //FS 제거
        range = 0...7
        let Command:String = Utils.utf8toHangul(str: Array(resData[range]))
        resData.removeSubrange(range)
        if Command != "FileSize" {
            finishProcessing(Result: false, Message: "(FileSize)" + mKocesSdk.getStringPlist(Key: "err_firmware_no_fileSize"))
            return
        }
        
        resData.remove(at: 0)   //FS 제거
        
        //파일사이즈길이가 10byte로 옮
        range = 0...3
        resData.removeSubrange(range)   //길이 4바이트 제거
          
        range = 0...5   //실제 데이터 길이
        let fileSize:String = Utils.utf8toHangul(str: Array(resData[range]))
        resData.removeSubrange(range)
        debugPrint("펌웨어 파일 사이즈: " + fileSize)
        
        //파일 사이즈 설정
        mFileSize = (fileSize as NSString).integerValue
        DownloadFirmwareFile()
    }
    func DownloadFirmwareFile() {
        
        //STX(1) + Length(4) + FS(1) + "HTMS"(4) + FS(1) + VAN(16) + 모델명(16) + 버젼(16) + 제품번호(16) + Chunk Size(4) +파일명(n) + ETX(1) + LRC(1)
        var sendData:[UInt8] = Array()
        sendData.insert(Command.STX, at: 0)
        let temp_checkfilesizelength:Int = 74 + mFileName.count
        //let temp_checkfilesizelength:Int = 78 + Int(FileNameSize)!
        
        sendData += Utils.StrLengthToUIntArray(value: String(temp_checkfilesizelength), Length: 4)
        sendData.append(Command.FS)
        sendData += Array("HTMS".utf8)
        sendData.append(Command.FS)
        sendData += Array(Utils.rightPad(str: "KOCES", fillChar: " ", length: 16).utf8)
        //sendData += Array(Utils.rightPad(str: mTmIcNo, fillChar: " ", length: 16).utf8)
        //test code 장빌ㄹ 읽어서 어떻게 조합 할지는 봐야 한다.
        if mTmIcNo.contains("C101P"){   //플러스 모델의 경우 이름이 확인 필요 하다
            sendData += Array(Utils.rightPad(str: "KRE_C101P", fillChar: " ", length: 16).utf8)
        }
        else if mTmIcNo.contains("C101") {
            sendData += Array(Utils.rightPad(str: "KRE_C101", fillChar: " ", length: 16).utf8)
        }
        else if mTmIcNo.contains("C100P") {
            sendData += Array(Utils.rightPad(str: "KRE_C100P", fillChar: " ", length: 16).utf8)
        }
        else if mTmIcNo.contains("C100") {
            sendData += Array(Utils.rightPad(str: "KRE_C100", fillChar: " ", length: 16).utf8)
        }
        else {
            TcpDisConnect()
            finishProcessing(Result: false, Message: "(Download)" + mKocesSdk.getStringPlist(Key: "err_firmware_no_fileSize"))
            return
        }
        sendData += Array(Utils.rightPad(str: mVersion, fillChar: " ", length: 16).utf8)
        sendData += Array(Utils.rightPad(str: mDeviceSN, fillChar: " ", length: 16).utf8)
        let chucksize:[UInt8] = [0x31,0x30,0x32,0x34]
        sendData += chucksize
        sendData += Array(mFileName.utf8)
        sendData.append(Command.ETX)
        
        sendData.append(Utils.makeLRC(_data: sendData))
        debugPrint("app -> firmwareSever: " + Utils.UInt8ArrayToHexCode(_value: sendData, _option: true))
        debugPrint("app -> firmwareSever: " + Utils.utf8toHangul(str: sendData))
        
        //여기서 반복적으로 파일을 수신한다.
        
        
        var buffer:[UInt8] = Array()
        while true {
            if !TcpSend(Data: Data(sendData), Client: mSwiftSocket!) {
                debugPrint("App -> firmwareServer : Send Fail")
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Download)펌웨어 서버에 데이터 전송 실패")
                return
            }
            var resData:[UInt8] = Array()
            resData = TcpRead(Client: mSwiftSocket!)
            if resData.count == 0 {
                debugPrint("firmwareServer -> App : Receive Fail")
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Download)펌웨어 서버에서 보낸 데이터 수신 실패")
                return
            }
            
            buffer += resData
            
            
            if (mFileSize - mFirmWareData.count) <= 1024 {
                if buffer.count > 15 && String(bytes: Array(buffer[6...9]), encoding: .utf8) == "HTMS" && String(bytes: Array(buffer[11...14]), encoding: .utf8) != "1024"
                {
                    let lastSize:Int = (String(bytes: Array(buffer[11...14]), encoding: .utf8)! as NSString).integerValue
                    var temp:[UInt8] = Array(buffer[0...(14+lastSize)])
                    temp.removeSubrange(0...14)
                    mFirmWareData += temp
                    temp.removeAll()
                    buffer.removeSubrange(0...(14+lastSize+2))  //헤더부 + 마지막 파일 데이터 + ETX + LRC 삭제
                }
            }
            
            if buffer.count > 1039
            {
                if buffer[0] == Command.STX && String(bytes: Array(buffer[6...9]), encoding: .utf8) == "HTMS"
                {
                    var temp:[UInt8] = Array(buffer[0...1038])
                    buffer.removeSubrange(0...1040)
                    temp.removeSubrange(0...14)
                    mFirmWareData += temp
                    temp.removeAll()
                    debugPrint(String(buffer.count))
                }
            }

            debugPrint("펌웨어수신된 데이터 사이즈: " + String(mFirmWareData.count) + "  파일 총 사이즈: " + String(mFileSize))
            if mFirmWareData.count == mFileSize {
//                finishProcessing()
                buffer.removeSubrange(0...5)    //STX 부터 길이 그리고 FS 까지 삭제
                if String(bytes: Array(buffer[0...7]), encoding: .utf8) == "Complete" {
                    debugPrint("Complete 수신")
                }
                
                mlbl_Status.text = mKocesSdk.getStringPlist(Key: "firmware_download_complete")
                //펌웨어 파일 다운로드 완료
                
                if !TcpSend(Data: Data([Command.ACK,Command.ACK,Command.ACK]), Client: mSwiftSocket!) {
                    debugPrint("App -> firmwareServer : Send [Command.ACK,Command.ACK,Command.ACK] Fail")
                    TcpDisConnect()
                    finishProcessing(Result: false, Message: "(Download)데이터 전송 실패(Send ACK*3)")
                    return
                }
                break
            }
            if !TcpSend(Data: Data([Command.ACK,Command.ACK,Command.ACK]), Client: mSwiftSocket!) {
                debugPrint("App -> firmwareServer : Send [Command.ACK,Command.ACK,Command.ACK] Fail")
                TcpDisConnect()
                finishProcessing(Result: false, Message: "(Download)데이터 전송 실패(Send ACK*3)")
                return
            }
        }
        
        TcpDisConnect()
        
        //여기서부터는 ble 장치로 데이터를 전송 한다.
        bleUpdateReady()
        
    }
    
    /// 펌웨어 서버 접속
    func ConenctFirmwareServer(_koces:Bool = false) -> Bool{
        if _koces {
            var _ip = ""
            if Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_IP).isEmpty {
                _ip = Setting.HOST_STORE_DOWNLOAD_IP
            } else {
                _ip = Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_IP)
            }
            mSwiftSocket = TCPClient.init(address: _ip, port: 10203)
        } else {
            mSwiftSocket = TCPClient.init(address: define.FIRMWARESERVER_IP, port: Int32(define.FIRMWARESERVER_PORT))
        }
//        mSwiftSocket = TCPClient.init(address: define.FIRMWARESERVER_IP, port: Int32(define.FIRMWARESERVER_PORT))

        guard let client = mSwiftSocket  else {
            return false
        }
        
        switch client.connect(timeout: 5) {
        case .success:
            debugPrint("SwiftSocket Connect Success")
            break
        case .failure(let error):
            debugPrint("SwiftSocket Connect Error : ", error)
            return false
        }
        
        return true
    }
    
    ///BLE 장치에 ble 펌웨어 전송 준비를 시작하라고 알린다.
    func bleUpdateReady()
    {
        //내부 상태를 ready상태로 한다.
        mFirmwareUpdateStat = firmwareUpdateProcesStep.ready
        //장치 연결 상태를 확인 한다.
        mlbl_Status.text = mKocesSdk.getStringPlist(Key: "firmware_send_ready")
        mKocesSdk.BleFirmwareUpdateReady()
        
    }
    //장치에 펌웨어 업데이트 하겠다고 통보
    func bleUpdateStart()
    {
        mKocesSdk.BleFirmwareUpdateStart()
        mlbl_Status.text = mKocesSdk.getStringPlist(Key: "firmware_send_start")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.mKocesSdk.BleFirmwareUpdateStart2()
        }
        
        mFirmwareUpdateStat = firmwareUpdateProcesStep.bleUpdateStart
        
    }
    //장치에 펌웨어 업데이트 사이즈 전달
    func bleUpdateSendFileSize()
    {
        debugPrint("bleUpdateSendFileSize mFileSize => ", mFileSize)
        mKocesSdk.BleFirmwareFileSize(Size: mFileSize)
        mFirmwareUpdateStat = firmwareUpdateProcesStep.bleUpdateSize
//        if mTmIcNo.contains("C100P") {
//            bleUpdateSendData()
//        }
    }
    var count = 0
    var tmp = 0
    func bleUpdateSendData()
    {
        mFirmwareUpdateStat = firmwareUpdateProcesStep.bleSendData
        
        if mFirmWareData.count == 0 {
            bleUpdateSendComplete()
            return
        }
        
        debugPrint("mFirmwareData size => ")
        debugPrint(mFirmWareData.count)
        count = mFileSize / 1024
        tmp += 1
        self.mProgressview.setProgress(Float(tmp)/Float(count), animated: true)
        if Float(tmp*100)/Float(count) < 100 {
            self.mlbl_ProcessPercent.text = String(format: "%.2f", Float(tmp*100)/Float(count)) + " %"
        } else {
            self.mlbl_ProcessPercent.text = String(100.00) + " %"
        }
        if mFirmWareData.count > 1023 {
            let range = (0..<1024)
            let d:[UInt8] = Array(mFirmWareData[range])
            mKocesSdk.BleFirmwareFileData(Data: d)
            mFirmWareData.removeSubrange(range)
        }
        else{
            mKocesSdk.BleFirmwareFileData(Data: mFirmWareData)
            mFirmWareData.removeAll()
        }
        
    }
    
    func bleUpdateSendComplete()
    {
        self.mProgressview.setProgress(1, animated: true)
        mKocesSdk.BleFirmwareComplete()
        mFirmwareUpdateStat = firmwareUpdateProcesStep.bleUpdateComplete
        if mTmIcNo.contains("C100") ||
            mTmIcNo.contains("C100P") ||
            mTmIcNo.contains("C101") ||
            mTmIcNo.contains("C101P"){   //플러스 모델의 경우 이름이 확인 필요 하다
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                mlbl_Status.text = "펌웨어 업데이트 완료"
                finishProcessing(Result: true, Message: "펌웨어 업데이트를 정상적으로 완료했습니다. 잠시 후 BLE 장비의 연결을 종료합니다.")
            }
        }
    }
    
    //성공 = true, 실패 = false
    func finishProcessing(Result _result:Bool, Message _message:String) {
        mUpdateFirst = 0
        mFirmwareUpdateStat = firmwareUpdateProcesStep.none
        mlbl_Status.text = _message
        mCheckProcessing = false
        //앱 업데이트 중 화면 자동꺼짐 방지를 완료했으니 해제 2021-09-10 by.jiw
        UIApplication.shared.isIdleTimerDisabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ [self] in
            if _result {
                mProgressview.setProgress(1, animated: true)
            }
            AlertBox(title: "펌웨어 업데이트", message: _message, text: "확인")
        }
    }
    
    func AlertBox(title : String, message : String, text : String) {
        alertLoading.dismiss(animated: true) { [self] in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
        }
            
    }
    
    //로딩 박스
    func AlertLoadingBox(title _title:String) {
        alertLoading = UIAlertController(title: _title, message: nil, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()

        alertLoading.view.addSubview(activityIndicator)
        alertLoading.view.heightAnchor.constraint(equalToConstant: 95).isActive = true

        activityIndicator.centerXAnchor.constraint(equalTo: alertLoading.view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: alertLoading.view.bottomAnchor, constant: -20).isActive = true

        present(alertLoading, animated: true, completion: nil)
    }
}

extension String {
    func toHexBytes() -> [UInt8]? {
            let length = count
            if length & 1 != 0 {
                return nil
            }
            var bytes = [UInt8]()
            bytes.reserveCapacity(length / 2)
            var index = startIndex
            for _ in 0..<length / 2 {
                let nextIndex = self.index(index, offsetBy: 2)
                if let b = UInt8(self[index..<nextIndex], radix: 16) {
                    bytes.append(b)
                } else {
                    return nil
                }
                index = nextIndex
            }
            return bytes
        }
}
