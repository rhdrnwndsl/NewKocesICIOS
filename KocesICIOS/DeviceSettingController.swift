//
//  NetworkSettingController.swift
//  osxapp
//
//  Created by 신진우 on 2021/01/07.
//

import UIKit

class DeviceSettingController: UIViewController, UIScrollViewDelegate {

    let mKocesSdk:KocesSdk = KocesSdk.instance

    
    @IBOutlet weak var mModelVersion: JLabel!
    @IBOutlet weak var mSerialNumber: JLabel!
    @IBOutlet weak var mModelNumber: JLabel!
    @IBOutlet weak var mBtnBle: JButton!
    @IBOutlet weak var seg_changeMode: UISegmentedControl!
    @IBOutlet weak var mStackBle: UIStackView!  //ble stack view group
    @IBOutlet weak var mStackCat: UIStackView!  //ble statck view cat
    @IBOutlet weak var mCatIP: UITextField!
    @IBOutlet weak var mCatPort: UITextField!
    @IBOutlet weak var mSegInfoPowerManager: UISegmentedControl!
    
    @IBOutlet weak var mSegQrManager: UISegmentedControl!
    
    
    @IBOutlet weak var mPrintDeviceSegment: UISegmentedControl!
    @IBOutlet weak var mStackPrintBle: UIStackView!
    @IBOutlet weak var mBleState: UILabel!
    @IBOutlet weak var mBleModelNumber: UILabel!
    @IBOutlet weak var mBlePrintUse: UILabel!
    @IBOutlet weak var mStackPrintCat: UIStackView!
    @IBOutlet weak var mPrintIp: UITextField!
    @IBOutlet weak var mPrintPort: UITextField!
    
    var printlistener: PrintResult?
    let mSqlite:sqlite = sqlite.instance
    var tcplistener: TcpResult?
    var countAck: Int = 0
    var keyUpdateCount:Int = 0
    var keyUpdateResultFail:Int = 0
    
    var keyDownloadCount: Int = 0

    //장치 설정 메뉴
    let menuArray = ["장치 설정","무결성 검사","키 다운로드","펌웨어 업데이트"]
    
    //로딩 메세지박스
    var alertLoading = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initSetting()
        initStackViewBleCat()   //설정이 BLE 인지 CAT인지 표시
        if !mKocesSdk.mModelNumber.isEmpty {
            mModelNumber.text = mKocesSdk.mModelNumber
        }
        if !mKocesSdk.mSerialNumber.isEmpty {
            mSerialNumber.text = mKocesSdk.mSerialNumber
        }
        if !mKocesSdk.mModelVersion.isEmpty {
            mModelVersion.text = mKocesSdk.mModelVersion
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)
        

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func dismissMyKeyboard(){
           view.endEditing(true)
    }
    
    @IBAction func changed_device_setting(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        switch sender.selectedSegmentIndex {
        case 0:
            mStackPrintBle.isHidden = false
            mStackPrintBle.alpha = 1.0
            mStackPrintCat.isHidden = true
            mStackPrintCat.alpha = 0.0
            
            if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                mBleState.text = "연결중"
                if !mKocesSdk.mModelNumber.isEmpty {
                    mBleModelNumber.text = mKocesSdk.mModelNumber
                } else {
                    mBleModelNumber.text = ""
                }
                if mKocesSdk.mModelNumber.contains("C100") {
                    mBlePrintUse.text =  "프린트 사용 불가"
                } else if mKocesSdk.mModelNumber.contains(define.bleNameKwang) {
                    mBlePrintUse.text =  "프린트 사용 불가"
                } else {
                    mBlePrintUse.text =  "프린트 사용 가능"
                }
                    
            } else {
                mBleState.text = "연결 장비 없음"
                mBleModelNumber.text = ""
                mBlePrintUse.text =  ""
            }

            
            break
        case 1:
            mStackPrintBle.isHidden = true
            mStackPrintBle.alpha = 0.0
            mStackPrintCat.isHidden = false
            mStackPrintCat.alpha = 1.0
            
            mPrintIp.text = Setting.shared.getDefaultUserData(_key: define.CAT_PRINT_SERVER_IP)
            mPrintPort.text = Setting.shared.getDefaultUserData(_key: define.CAT_PRINT_SERVER_PORT)
            break
        default:
            break
        }
    }
    
    //프린터장비 저장
    @IBAction func clicked_btn_Save(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }

        if mPrintDeviceSegment.selectedSegmentIndex == 1 {
            //여기서 캣연동이라고 설정하여도 디스커넥트 되었을 때 노커넥트로 바뀐다.
            mKocesSdk.blePrintState = define.PrintDeviceState.CATUSEPRINT  //cat 연결 되어 있는 상태로 변경한다.
            //어플 기동 할 때 타겟 대상을 결정
            Setting.shared.setDefaultUserData(_data: define.PRINTCAT, _key: define.PRINTDEVICE)
            
            var _ip:String = mPrintIp.text ?? ""
            var _port:String = mPrintPort.text ?? ""
            Setting.shared.setDefaultUserData(_data: _ip, _key: define.CAT_PRINT_SERVER_IP)
            Setting.shared.setDefaultUserData(_data: _port, _key: define.CAT_PRINT_SERVER_PORT)
        } else {
            //여기서 캣연동이라고 설정하여도 디스커넥트 되었을 때 노커넥트로 바뀐다.
            mKocesSdk.blePrintState = define.PrintDeviceState.BLEUSEPRINT  //cat 연결 되어 있는 상태로 변경한다.
            //어플 기동 할 때 타겟 대상을 결정
            Setting.shared.setDefaultUserData(_data: define.PRINTBLE, _key: define.PRINTDEVICE)
    
        }


        AlertBox(title: "성공", message: "설정이 저장되었습니다.", text: "확인")
    }
    
    func initSetting() {
        mModelNumber.text = ""
        mSerialNumber.text = ""
        mModelVersion.text = ""
        CheckBleConnectButtonTitle()
        
        mSegInfoPowerManager.selectedSegmentIndex = (Setting.shared.getDefaultUserData(_key: define.POWER_MANAGER).isEmpty ? 0:Int(Setting.shared.getDefaultUserData(_key: define.POWER_MANAGER)))!
        
        let bar = UIToolbar()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        
        //
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
        //
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
        
        mCatPort.inputAccessoryView = bar
        //
        mCatIP.inputAccessoryView = bar
        
        mPrintIp.inputAccessoryView = bar
        //
        mPrintPort.inputAccessoryView = bar
        //
        //여기서 부터 커스텀 키보드 테스트
//        let ipkb = Bundle.main.loadNibNamed("IPKeyBoard", owner: nil, options: nil)
//        guard let IPKeyboard = ipkb?.first as? IPKeyBoard else {return}
//        mCatIP.inputView = IPKeyboard
//        IPKeyboard
        
        /** 최초 설정 시에는 해당 데이터를 기본값으로 지정한다 */
        if Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_IP) == ""
        {
            Setting.shared.setDefaultUserData(_data: "192.168.0.100", _key: define.CAT_SERVER_IP)
        }
        if Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_PORT) == ""
        {
            Setting.shared.setDefaultUserData(_data: "9100", _key: define.CAT_SERVER_PORT)
        }
        
        /** Qr 리더기에서 Qr을 읽을지 카메라를 부를지 설정한다 0=카메라 1=cat */
        mSegQrManager.selectedSegmentIndex = Int(Setting.shared.getDefaultUserData(_key: define.QR_CAT_CAMERA))!
        
        
        printDefaultSet()
        
    }
    
    func printDefaultSet() {
        if Setting.shared.getDefaultUserData(_key: define.PRINTDEVICE).isEmpty ||
            Setting.shared.getDefaultUserData(_key: define.PRINTDEVICE) == define.PRINTCAT {
            mPrintDeviceSegment.selectedSegmentIndex = 1
        } else {
            mPrintDeviceSegment.selectedSegmentIndex = 0
        }
        switch mPrintDeviceSegment.selectedSegmentIndex {
        case 0:
            mStackPrintBle.isHidden = false
            mStackPrintBle.alpha = 1.0
            mStackPrintCat.isHidden = true
            mStackPrintCat.alpha = 0.0
            
            if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                mBleState.text = "연결중"
                if !mKocesSdk.mModelNumber.isEmpty {
                    mBleModelNumber.text = mKocesSdk.mModelNumber
                } else {
                    mBleModelNumber.text = ""
                }
                if mKocesSdk.mModelNumber.contains("C100") {
                    mBlePrintUse.text =  "프린트 사용 불가"
                } else if mKocesSdk.mModelNumber.contains(define.bleNameKwang) {
                    mBlePrintUse.text =  "프린트 사용 불가"
                } else {
                    mBlePrintUse.text =  "프린트 사용 가능"
                }
                    
            } else {
                mBleState.text = "연결 장비 없음"
                mBleModelNumber.text = ""
                mBlePrintUse.text =  ""
            }

            break
        case 1:
            mStackPrintBle.isHidden = true
            mStackPrintBle.alpha = 0.0
            mStackPrintCat.isHidden = false
            mStackPrintCat.alpha = 1.0
            var _ip = Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_IP)
            var _port = Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_PORT)
//            Setting.shared.setDefaultUserData(_data: _ip, _key: define.CAT_PRINT_SERVER_IP)
//            Setting.shared.setDefaultUserData(_data: _port, _key: define.CAT_PRINT_SERVER_PORT)
            mPrintIp.text = Setting.shared.getDefaultUserData(_key: define.CAT_PRINT_SERVER_IP)
            mPrintPort.text = Setting.shared.getDefaultUserData(_key: define.CAT_PRINT_SERVER_PORT)
            break
        default:
            break
        }
    }
    
    @objc func didBle(_ notification: Notification) {
        guard let bleStatus: String = notification.userInfo?["Status"] as? String else { return }
        switch bleStatus {
        case define.IsPaired:   //직전에 연결했었던 장비를 스캔하였을 때
            // 검색할 때 띄웠던 로딩박스를 지운다
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

            print("BLE_Status :", bleStatus)
            
            break
        case define.ScanSuccess:    //다른 장비를 스캔하였을 때
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                var message:String = "연결 가능한 목록입니다"
                if self.mKocesSdk.manager.devices.count == 0 {
                    message = "연결 가능한 디바이스가 존재하지 않습니다"
                }
                let blealert = UIAlertController(title: "리더기연결", message: message, preferredStyle: .alert)
                if self.mKocesSdk.manager.devices.count == 0 {
                    let button = UIAlertAction(title: "확인", style: .default)
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
//                        blealert.addAction(UIAlertAction(title: String(describing: device["device"].unsafelyUnwrapped) , style: .default, handler: { (Action) in
//                            let uuid = device["uuid"] as! UUID
//                            self.AlertLoadingBox(title: "잠시만 기다려 주세요")
//                            self.mKocesSdk.manager.connect(uuid: uuid)
//                        }))
                        blealert.addAction(UIAlertAction(title: deviceName , style: .default, handler: { (Action) in
                            let uuid = device["uuid"] as! UUID
                            self.AlertLoadingBox(title: "잠시만 기다려 주세요")
                            self.mKocesSdk.manager.connect(uuid: uuid)
                        }))
                    }
                    let button = UIAlertAction(title: "취소", style: .default, handler: {(action) in
                        AlertBox(title: "장치연결취소", message: "장치 연결을 종료하였습니다", text: "확인")
                    })
                    blealert.addAction(button)
                }
                self.present(blealert, animated: true, completion: nil)
            }
            print("BLE_Status :", bleStatus)
            
            break
        case define.ConnectSuccess:
            print("BLE_Status :", bleStatus)
            
            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
            
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertLoadingBox(title: "무결성 검사를 진행합니다. 잠시만 기다려 주세요")
                DispatchQueue.main.async { [self] in
                    mKocesSdk.GetVerity()   //연결에 성공하면 자동으로 무결성검사 시작
                }
            }
            break
        case define.ConnectFail:
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "장치연결실패", message: "장치연결에 실패하였습니다. 연결을 다시 시도해 주십시오", text: "확인")
                initSetting()
            }
            break
        case define.ConnectTimeOut:
            print("BLE_Status :", bleStatus)
            let alertFail = UIAlertController(title: "연결에 실패하였습니다", message: "장치연결에 실패하였습니다. 아이폰설정으로 이동하여 등록된 블루투스 리더기를 제거해 주십시오", preferredStyle: .alert)
            let failOK = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
          
            let failCancel = UIAlertAction(title: "취소", style: .default, handler: {(action) in
                self.initSetting()
            })
            alertFail.addAction(failCancel)
            alertFail.addAction(failOK)
            alertLoading.dismiss(animated: true){ [self] in
                self.present(alertFail, animated: true, completion: nil)
            }
            break

        case define.ScanFail:
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "장치검색실패", message: "장치검색에 실패하였습니다", text: "확인")
                initSetting()
            }
            break
        case define.PowerOff:
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "블루투스불가", message: "BLE 사용 할 수 없는 모델입니다", text: "확인")
                initSetting()
            }
            break
        case define.Disconnect:
            print("BLE_Status :", bleStatus)
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "장치연결해제", message: "장치가 끊어졌습니다", text: "확인")
                initSetting()
                UserDefaults.standard.setValue("", forKey: define.LAST_CONNECT_DEVICE)
                
                //만일 ble 연동이었다가 캣연동으로 바꿔서 디스커넥트 되었다면 여기서 캣 연동으로 바꿔준다
                if seg_changeMode.selectedSegmentIndex == 1 {
                    mKocesSdk.bleState = define.TargetDeviceState.CATCONNECTED
                }
            }
            break
        case define.PairingKeyFail:
            print("BLE_Status :", bleStatus)
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "페어링실패", message: "핀번호 오류", text: "확인")
                initSetting()
                UserDefaults.standard.setValue("", forKey: define.LAST_CONNECT_DEVICE)

            }
            break
        case define.SendComplete:
            //정상적으로 모두 보냄
//                print("BLE_Status :", bleStatus)
            break
        case define.Receive:
            var resData:[UInt8] = mKocesSdk.mReceivedData

            if resData[3] == Command.ACK && countAck == 0 {
                if (mKocesSdk.mBleConnectedName.contains(define.bleName) || mKocesSdk.mBleConnectedName.contains(define.bleNameNew)) {
                    debugPrint("ACK 데이터 버림")
                    countAck += 1
                    return
                } else {
//                    debugPrint("ACK 데이터 버림")
//                    countAck += 1
//                    return
                }

            }
            
            countAck = 0
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                switch resData[3] {
                case Command.CMD_POSINFO_RES:
                    var spt:Int = 4
                    let TmIcNo = Utils.UInt8ArrayToStr(UInt8Array: Array(resData[spt...spt + 15]))
                    Setting.shared.setDefaultUserData(_data: TmIcNo, _key: define.APP_ID)
                    spt += 32
                    let serialNumber = Utils.UInt8ArrayToStr(UInt8Array: Array(resData[spt...spt + 9]))
                    spt += 10
                    let version = Utils.UInt8ArrayToStr(UInt8Array: Array(resData[spt...spt + 4]))
                    spt += 5
                    let key = Utils.UInt8ArrayToStr(UInt8Array: Array(resData[spt...spt + 1]))

                    /** 시리얼번호 저장 가맹점등록다운로드 안된 상태에서 시리얼번호 저장하지 않음 */
//                    Setting.shared.setDefaultUserData(_data: serialNumber, _key: define.STORE_SERIAL)
                    mKocesSdk.mKocesCode = define.KOCES_ID
                    mKocesSdk.mAppCode = define.KOCES_APP_ID
                    mKocesSdk.mModelNumber = TmIcNo
                    mKocesSdk.mSerialNumber = serialNumber
                    mKocesSdk.mModelVersion = version //version
                    
                    mModelNumber.text = TmIcNo
                    mSerialNumber.text = serialNumber
                    mModelVersion.text = version
                    
                    if mKocesSdk.mBleConnectedName.contains("C100") {

                    } else if mKocesSdk.mBleConnectedName.contains(define.bleNameKwang) {

                    } else {
                   
                    }
                    printDefaultSet()
                    if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                        AlertBox(title: "무결성검증실패", message: "리더기 무결성 검증실패 제조사A/S요망", text: "확인")
                        return
                    }
                    
                    if keyUpdateCount == 0 {
                        CheckBleConnectButtonTitle()
                        if key != "00" {
//                            AlertBox(title: "장치정보", message: "키 갱신이 필요합니다", text: "확인")
                            let alertReceive = UIAlertController(title: "장치정보", message: "키 갱신이 필요합니다", preferredStyle: .alert)
                            let receiveBtn = UIAlertAction(title: "확인", style: .default, handler: { [self](action) in
                                mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                                
                                self.mKocesSdk.KeyDownload_Ready()

                            })
                            alertReceive.addAction(receiveBtn)
                            present(alertReceive, animated: true, completion: nil)
                        } else {
//                            let alertController = UIAlertController(title: "무결성검사", message: "무결성검사가 정상입니다", preferredStyle: UIAlertController.Style.alert)
//                            let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
//                             
//                            }
//                            alertController.addAction(okButton)
//                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else {
                        mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                        
                        keyUpdateCount = 0
                        mKocesSdk.KeyDownload_Ready()
                    }
                    break
                case Command.CMD_KEYUPDATE_READY_RES:
                    var spt:Int = 4
                    var authNumber = Utils.UInt8ArrayToStr(UInt8Array: Array(resData[spt...spt + 31]))
                    spt += 32
                    var keydata:[UInt8] = Array(resData[spt...spt+127])
                    spt += 128
                    var result = Utils.UInt8ArrayToStr(UInt8Array: Array(resData[spt...spt + 1]))
                    debugPrint(authNumber)
                    debugPrint(keydata)
                    debugPrint(result)
                    //서버에 키 요청
                    if result == "00" {
                        AlertLoadingBox(title: "서버에 키를 요청중입니다")
                        KeyDownload(KeyCheckData: keydata)
                    } else {
                        mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                        
                        keyUpdateResultFail += 1
                        if keyUpdateResultFail == 2 {
                            keyUpdateResultFail = 0
                            AlertBox(title: "키갱신", message: "보안키 갱신 생성 결과 비정상", text: "확인")
                            return
                        }
                        mKocesSdk.KeyDownload_Ready()
                    }
                  
                    
                    //사용한 데이터 초기화
                    authNumber = ""
                    keydata = [0]
                    keydata.removeAll()
                    result = ""
                    resData = [0]
                    resData.removeAll()
                    break
                case Command.CMD_PRINT_RES:
//                    if resData[4] != 0x30 {
//                        AlertBox(title: "에러", message: Command.Check_Print_Result_Code(Res: resData[4]), text: "확인")
//                    }
                    break
                case Command.ACK:
                    keyUpdateResultFail = 0
                    AlertBox(title: "결과", message: "키 다운로드 완료 되었습니다.", text: "확인")
                    break
                case Command.NAK:
//                    AlertBox(title: "결과", message: "NAK 올라온다", text: "확인")
                    mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                    
                    keyUpdateResultFail += 1
                    if keyUpdateResultFail == 2 {
                        keyUpdateResultFail = 0
                        AlertBox(title: "키갱신", message: "보안키 갱신 생성 결과 비정상", text: "확인")
                        return
                    }
                    keyUpdateCount = 0
                    mKocesSdk.KeyDownload_Ready()
                    break
                case Command.CMD_VERITY_RES:
                    //무결성검사가 정상인지 아닌지를 체크하여 메세지박스로 표시한다
                    var _resultMessage:String = ""
                    switch resData[4...5] {
                    case [0x30,0x30]:
                        _resultMessage = "무결성검사가 정상입니다"
                        mKocesSdk.mVerityCheck = define.VerityMethod.Success.rawValue
                        mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "0", Result: "0")
                        //정상
                        break
                    case [0x30,0x31]:
                        _resultMessage = "리더기 무결성 검증실패 제조사A/S요망"
                        mKocesSdk.mVerityCheck = define.VerityMethod.Fail.rawValue
                        mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "1", Result: "1")
                        //실패
                        break
                    case [0x30,0x32]:
                        _resultMessage = "리더기 무결성 검증실패 제조사A/S요망"
                        mKocesSdk.mVerityCheck = define.VerityMethod.Fail.rawValue
                        mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "1", Result: "1")
                        //FK검증실패
                        break
                    default:
                        break
                    }
                    
                    mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                    
                    mKocesSdk.GetDeviceInfo(Date: Utils.getDate(format: "yyyyMMddHHmmss"))
                   
                    break
                default:
                    break
                }
            }
            break

        default:
            break
        }
        
    }
    /// ble,cat 연결 선택 세그먼트
    @IBAction func mSegment_Changed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mStackBle.isHidden = false
            mStackBle.alpha = 1.0
            mStackCat.isHidden = true
            mStackCat.alpha = 0.0
            mKocesSdk.bleState = define.TargetDeviceState.BLENOCONNECT  //장치를 끊어진 상태로 처리하고 ble 연결을 종료 시킨다.
            mKocesSdk.manager.disconnect()
            Setting.shared.setDefaultUserData(_data: define.TAGETBLE, _key: define.TARGETDEVICE)    //어플 기동 할 때 타겟 대상을 결정
            
            printDefaultSet()
            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETBLE {
                var _checkCount = 0
                /** 0 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key.contains(define.STORE_TID) {
                        if (value as! String) != "" {
                            if key == "STORE_TID" ||  key == "STORE_TID0"{
                                _checkCount = 1
                            }
                        }
                    }
                }
                
                if _checkCount == 0 {
                    Setting.shared.setDefaultUserData(_data: "", _key: define.MULTI_STORE)
                    return
                }
                _checkCount = 0
                
                /** 1 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "STORE_TID1"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 2 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "STORE_TID2"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 3 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "STORE_TID3"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 4 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "STORE_TID4"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 5 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "STORE_TID5"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 6 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "STORE_TID6"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 7 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "STORE_TID7"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 8 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "STORE_TID8"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 9 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "STORE_TID9"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 10 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "STORE_TID10"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }
                
                if _checkCount == 1 {
                    Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                } else {
                    Setting.shared.setDefaultUserData(_data: "", _key: define.MULTI_STORE)
                }
            }
            break
        case 1:
            mStackBle.isHidden = true
            mStackBle.alpha = 0.0
            mStackCat.isHidden = false
            mStackCat.alpha = 1.0
            
            //여기서 캣연동이라고 설정하여도 디스커넥트 되었을 때 노커넥트로 바뀐다.
            mKocesSdk.bleState = define.TargetDeviceState.CATCONNECTED  //cat 연결 되어 있는 상태로 변경한다.
            mKocesSdk.manager.disconnect()
            Setting.shared.setDefaultUserData(_data: define.TAGETCAT, _key: define.TARGETDEVICE)    //어플 기동 할 때 타겟 대상을 결정
            mCatIP.text = Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_IP)
            mCatPort.text = Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_PORT)
            
            printDefaultSet()
            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                var _checkCount = 0
                /** 0 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key.contains(define.CAT_STORE_TID) {
                        if (value as! String) != "" {
                            if key == "CAT_STORE_TID" ||  key == "CAT_STORE_TID0"{
                                _checkCount = 1
                            }
                        }
                    }
                }
                
                if _checkCount == 0 {
                    Setting.shared.setDefaultUserData(_data: "", _key: define.MULTI_STORE)
                    return
                }
                _checkCount = 0
                
                /** 1 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "CAT_STORE_TID1"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }
                
                /** 2 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "CAT_STORE_TID2"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 3 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "CAT_STORE_TID3"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 4 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "CAT_STORE_TID4"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 5 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "CAT_STORE_TID5"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 6 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "CAT_STORE_TID6"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 7 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "CAT_STORE_TID7"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 8 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "CAT_STORE_TID8"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 9 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "CAT_STORE_TID9"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }

                /** 10 */
                for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                    if key == "CAT_STORE_TID10"{
                        if (value as! String) != "" {
                            _checkCount = 1
                        }
                    }
                }
                
                if _checkCount == 1 {
                    Setting.shared.setDefaultUserData(_data: "on", _key: define.MULTI_STORE)
                } else {
                    Setting.shared.setDefaultUserData(_data: "", _key: define.MULTI_STORE)
                }
            }
            break
        default:
            printDefaultSet()
            break
        }

        
    }
    /// ble 연결 버튼 타이틀 및 색상을 변경 한다.
    func CheckBleConnectButtonTitle()
    {
        if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
            mBtnBle.Title(타이틀: "BLE 해제",설정색상: "jwRed")
        } else {
            mBtnBle.Title(타이틀: "BLE 연결",설정색상: "jwWhite")
        }
    }
    
    /// ble 스캔 버튼 클릭 검색이 완료되면 메세지박스를 띄워서 연결할 장비를 클릭한다
    @IBAction func bleScan_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
            AlertLoadingBox(title: "잠시만 기다려 주세요")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                mKocesSdk.manager.disconnect()
            }
        } else if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
            //검색될 때까지 로딩메세지박스를 띄운다
            AlertLoadingBox(title: "잠시만 기다려 주세요")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                mKocesSdk.bleConnect()
            }
        } else {
            AlertBox(title: "CAT/BLE 에러", message: "현재 디바이스를 CAT 으로 셋팅되어 있습니다", text: "확인")
        }

      
    }
    
    @IBAction func selected_seg_power(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func clicked_btn_savepower(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        if KocesSdk.instance.bleState != define.TargetDeviceState.BLECONNECTED {
            AlertBox(title: "전원관리", message: "BLE 단말기가 연결되어 있지 않습니다.", text: "확인")
            return
        }
        
        Setting.shared.setDefaultUserData(_data: String(mSegInfoPowerManager.selectedSegmentIndex), _key: define.POWER_MANAGER)
        var blePower = ""
        var bleManager:define.BlePowerManager = define.BlePowerManager.FiveMinute
        switch mSegInfoPowerManager.selectedSegmentIndex {
        case 0:
            blePower = "5분"
            bleManager = define.BlePowerManager.FiveMinute
            break
        case 1:
            blePower = "10분"
            bleManager = define.BlePowerManager.TenMinute
            break
        case 2:
            blePower = "상시유지"
            bleManager = define.BlePowerManager.AllWays
            break
        default:
            break
        }
        KocesSdk.instance.BlePowerManager(유지시간: bleManager)
        AlertBox(title: "전원관리", message: "단말기 전원 유지 시간은 " + blePower + " 입니다.", text: "확인")
    }

    
    //키 업데이트 메뉴 표시
    @IBAction func keyUpdate_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
            AlertBox(title: "키갱신 요청", message: "연결이 되어 있지 않습니다. 연결 후 실행 해 주세요", text: "확인")
            return
        }

//        if Setting.shared.getDefaultUserData(_key: define.STORE_TID).isEmpty {
//            AlertBox(title: "키갱신 요청", message: "저장된 Tid 가 없습니다. 가맹점 다운로드를 진행해 주세요", text: "확인")
//            return
//        }
//
//        if Setting.shared.getDefaultUserData(_key: define.STORE_BSN).isEmpty {
//            AlertBox(title: "키갱신 요청", message: "저장된 사업자번호 가 없습니다. 가맹점 다운로드를 진행해 주세요", text: "확인")
//            return
//        }
//
//        if Setting.shared.getDefaultUserData(_key: define.STORE_SERIAL).isEmpty {
//            AlertBox(title: "키갱신 요청", message: "저장된 시리얼번호 가 없습니다. 가맹점 다운로드를 진행해 주세요", text: "확인")
//            return
//        }
        
        mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        //검색될 때까지 로딩메세지박스를 띄운다
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        //장치정보에서 시리얼정보를 가져와서 하지 않고 그냥 여기서 시리얼정보를 요청해서 한다. 따로 장치정보버튼누르고 키업데이트버튼 누를 필요 없다
        keyUpdateCount += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
            mKocesSdk.GetDeviceInfo(Date: Utils.getDate(format: "yyyyMMddHHmmss"))
        }
        
//        mKocesSdk.KeyDownload_Ready()
    }
    
    //무결성 검사 페이지 표시
    @IBAction func VerityMenu_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        guard let verityVC = self.storyboard?.instantiateViewController(withIdentifier: "VerityVC") else {
            return
        }
        NotificationCenter.default.removeObserver(self)
//        verityVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//        self.present(verityVC, animated: true)
        navigationController?.pushViewController(verityVC, animated: true)
    }

    ///범웨어 업데이트 버튼 클릭
    @IBAction func firmwareUpdate_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
            AlertBox(title: "펌웨어", message: mKocesSdk.getStringPlist(Key: "err_msg_no_connected_device"), text: "확인")
            return
        }
        
        if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
            AlertBox(title: "펌웨어", message: "CAT 연동장비 입니다", text: "확인")
            return
        }
        
        guard let firmwareVC = self.storyboard?.instantiateViewController(identifier: "firmwareController") as? firmwareController  else {
            return
        }
        NotificationCenter.default.removeObserver(self)
   //     firmwareVC.modalPresentationStyle = .fullScreen
 //       self.present(firmwareVC, animated: true, completion: nil)
        navigationController?.pushViewController(firmwareVC, animated: true)
    }
    
    @IBAction func SaveCatIP_Clicked(_ sender: JButton, forEvent event: UIEvent) {
        if mCatIP.text?.count == 0 || mCatPort.text?.count == 0 {
            AlertBox(title: "에러", message:mKocesSdk.getStringPlist(Key: "err_msg_empty_value") , text: "확인")
            return
        }
        
        
        
        //테스트를 위해서 구체적인 에러 조건은 나중에 체크 한다.
        Setting.shared.setDefaultUserData(_data: mCatIP.text!, _key: define.CAT_SERVER_IP)
        Setting.shared.setDefaultUserData(_data: mCatPort.text!, _key: define.CAT_SERVER_PORT)
        
        if mSegQrManager.selectedSegmentIndex == 0 {
            Setting.shared.setDefaultUserData(_data: "0", _key: define.QR_CAT_CAMERA)
        } else {
            Setting.shared.setDefaultUserData(_data: "1", _key: define.QR_CAT_CAMERA)
        }
        
        //프린트 설정 추가. 만일 bleuse 가 아닐경우에는 프린트를 cat으로 바꾼다
//        if mKocesSdk.blePrintState != define.PrintDeviceState.BLEUSEPRINT {
            Setting.shared.setDefaultUserData(_data: define.PRINTCAT, _key: define.PRINTDEVICE)
            
        if Setting.shared.getDefaultUserData(_key: define.CAT_PRINT_SERVER_IP) == "" {
            Setting.shared.setDefaultUserData(_data: mCatIP.text!, _key: define.CAT_PRINT_SERVER_IP)
            Setting.shared.setDefaultUserData(_data: mCatPort.text!, _key: define.CAT_PRINT_SERVER_PORT)
        }
            mKocesSdk.blePrintState = define.PrintDeviceState.CATUSEPRINT
//        }

        
        AlertBox(title: "저장",message:mKocesSdk.getStringPlist(Key: "txt_save_cat_ipAddr") , text: "확인")
        
        printDefaultSet()
    }
    
    func dddd(_bold:String) -> String {
        return define.PBOLDSTART + _bold + define.PBOLDEND
        //return  _bold
    }
    //임시코드 삭제 필요
    //문자발송 테스트
    
//    @IBAction func temp_sendMMS(_ sender: UIButton) {
//        let MsgSender:mms = mms.instance
//        let phoneNumber:String = temp_Txf_Phone.text!
//        let contents:String = temp_Txf_contents.text!
//
//        let result:Bool =  MsgSender.sendMeesage(대상전화번호: phoneNumber, 내용: contents, UIControllerView: self)
//
//        if !result {
//            AlertBox(title: "에러", message: "문자 발송 실패", text: "확인")
//        }
//
//    }
    
    /// 화면설정시 BLE의 경우와 CAT 경우로 나눠서 작동하는 부분을 설정한다.
    func initStackViewBleCat()
    {
        
        if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
            mStackBle.isHidden = true
            mStackBle.alpha = 0.0
            mStackCat.isHidden = false
            mStackCat.alpha = 1.0
            seg_changeMode.selectedSegmentIndex = 1
            
            mCatIP.text = Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_IP)
            mCatPort.text = Setting.shared.getDefaultUserData(_key: define.CAT_SERVER_PORT)
            
        }
        else
        {
            mStackBle.isHidden = false
            mStackBle.alpha = 1.0
            mStackCat.isHidden = true
            mStackCat.alpha = 0.0
            seg_changeMode.selectedSegmentIndex  = 0
        }
    }
    
    ///경고 박스
    func AlertBox(title : String, message : String, text : String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            return self.present(alertController, animated: true, completion: nil)
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


///tcp 데이터 수신
extension DeviceSettingController: TcpResultDelegate, CustomAlertDelegate {
    func onDirectResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>, DirectData _directData: Dictionary<String, String>) {
        debugPrint("앱투앱/웹투앱에서만 사용")
    }
    
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

    func KeyDownload(KeyCheckData _data:[UInt8])
    {
        tcplistener = TcpResult()
        tcplistener?.delegate = self
        
        var _testID = Setting.shared.getDefaultUserData(_key: define.STORE_TID)
        if _testID == "" {
            _testID = define.TEST_TID
        }
        /** D10 가맹점다운로드 D20 키갱신시 사용 */
        mKocesSdk.KeyDownload(Command: "D20", Tid: _testID, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", Length: "0128", PosCheckData: _data, BSN: Setting.shared.getDefaultUserData(_key: define.STORE_BSN), Serial: Setting.shared.getDefaultUserData(_key: define.STORE_SERIAL), PosData: "", MacAddr: Utils.getKeyChainUUID(),CallbackListener: tcplistener?.delegate as! TcpResultDelegate)
        

    }
    
    /** 키갱신시 사용 */
    func onKeyResult(tcpStatus _status: tcpStatus, Result _result: [UInt8], DicResult _dicresult: Dictionary<String, String>) {
        print(_result)
        var _data = _result
        mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        mKocesSdk.KeyDownload_Update(Time: "20" + _dicresult["TrdDate"]!, Data: _data)
        
        //단말기 키 업데이트 시 마지막 처리
        _data = [0]
        _data.removeAll()
    }

    func onResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>) {

        if keyDownloadCount == 0 {
            if _result["TrdType"] == "D25" || _result["TrdType"] == "D20" {
                keyDownloadCount += 1
                var _date = _result["TrdDate"] == nil ? Utils.getDate(format: "yyyyMMddHHmmss"):"20" + _result["TrdDate"]!
                mKocesSdk.KeyDownload_Update(Time: _date, Data: [UInt8]())
                return
            }
        }
        keyDownloadCount = 0
        alertLoading.dismiss(animated: true) { [self] in
            if _result["AnsCode"] == "0000" {
                AlertBox(title: "결과", message: "키 다운로드 완료 되었습니다.", text: "확인")
                
            }
            else
            {
                AlertBox(title: "에러", message: " 응답코드: \(_result["AnsCode"] ?? "") \n \(_result["Message"] ?? "") ", text: "확인")
            }
        }
        let _key = _result["HardwareKey"] ?? ""
        //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
        Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (_result["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
//        if !_key.isEmpty {
//            Utils.setPosKeyChainUUIDtoBase64(PosKeyChain: _key)
//        }
    }
}

