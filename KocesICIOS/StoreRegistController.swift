//
//  StoreRegistController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 3/6/24.
//

import Foundation
import UIKit

class StoreRegistController: UIViewController {
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var listener: TcpResult?
    let mSqlite:sqlite = sqlite.instance
    @IBOutlet var mTidTextField: UITextField!   //Tid
    @IBOutlet var mBsnTextField: UITextField!   //사업자번호
    @IBOutlet var mSerialTextField: UITextField!    //시리얼번호
    @IBOutlet var mBtnResistStore: JButton!
    //로딩 메세지박스
    var alertLoading = UIAlertController()

    @IBOutlet weak var mMultiStoreUse: UISwitch!    //복수가맹점사용유무 off=단일. on=복수
    
    var countAck: Int = 0
    
    let CharMaxLength = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //사인뷰 테스트를 위해 여기서 해본다
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        initRes()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        //등록된 노티 전체 제거
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func didBle(_ notification: Notification) {
        guard let bleStatus: String = notification.userInfo?["Status"] as? String else { return }
        switch bleStatus {
        case define.IsPaired:   //직전에 연결했었던 장비를 스캔하였을 때
            //장치 이름만 추출 하기 2020-03-08 kim.jy
            let TempDeviceName:String = String(describing: self.mKocesSdk.isPairedDevice[0]["device"].unsafelyUnwrapped)
            var deviceName:String = ""
            if TempDeviceName != "" {
                let temp = TempDeviceName.components(separatedBy: ":")
                if temp.count > 0 {
                    deviceName = String(temp[0])
                }

            }


            print(deviceName)
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

                        blealert.addAction(UIAlertAction(title: deviceName , style: .default, handler: { (Action) in
                            let uuid = device["uuid"] as! UUID
                            self.AlertLoadingBox(title: "잠시만 기다려 주세요")
                            self.mKocesSdk.manager.connect(uuid: uuid)
                        }))
                    }
                    let button = UIAlertAction(title: "취소", style: .default, handler: {(action) in
                        self.AlertBox(title: "장치연결취소", message: "장치 연결을 종료하였습니다", text: "확인")
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
                DispatchQueue.main.async{ [self] in
                    mKocesSdk.GetVerity()   //연결에 성공하면 자동으로 무결성검사 시작
                }
            }
            break
        case define.ConnectFail:
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "장치연결실패", message: "장치연결에 실패하였습니다. 연결을 다시 시도해 주십시오", text: "확인")
            }
            break
        case define.ConnectTimeOut:
            print("BLE_Status :", bleStatus)
            let alertFail = UIAlertController(title: "연결에 실패하였습니다", message: "장치연결에 실패하였습니다. 아이폰설정으로 이동하여 등록된 블루투스 리더기를 제거해 주십시오", preferredStyle: .alert)
            let failOK = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
          
            let failCancel = UIAlertAction(title: "취소", style: .default, handler: {(action) in
                
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
            }
            break
        case define.PowerOff:
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "블루투스불가", message: "BLE 사용 할 수 없는 모델입니다", text: "확인")
            }
            break
        case define.Disconnect:
            print("BLE_Status :", bleStatus)
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "장치차단", message: "장치가 끊어졌습니다", text: "확인")
            }
            break
        case define.PairingKeyFail:
            print("BLE_Status :", bleStatus)
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "페어링실패", message: "핀번호 오류", text: "확인")
            }
            break
        case define.Receive:
            let resData:[UInt8] = mKocesSdk.mReceivedData

            if resData[3] == Command.ACK && countAck == 0 {
                if (mKocesSdk.mBleConnectedName.contains(define.bleName) || mKocesSdk.mBleConnectedName.contains(define.bleNameNew)) {
                    debugPrint("ACK 데이터 버림")
                    countAck += 1
                    return
                } else {
 
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
                    mKocesSdk.mKocesCode = define.KOCES_ID
                    mKocesSdk.mAppCode = define.KOCES_APP_ID
                    mKocesSdk.mModelNumber = TmIcNo
                    mKocesSdk.mSerialNumber = serialNumber
                    mKocesSdk.mModelVersion = version //version
                    /** 시리얼번호 저장 */
                    //Setting.shared.setDefaultUserData(_data: serialNumber, _key: define.STORE_SERIAL) //가맹점 등록이 완료 되지 않은 상태에서 시리얼 저장 안함.
                    mSerialTextField.text = serialNumber
                    
                    if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                        AlertBox(title: "무결성검증실패", message: "리더기 무결성 검증실패 제조사A/S요망", text: "확인")
                        return
                    }
                    
                    if key != "00" {
                        AlertBox(title: "장치정보", message: "키 갱신이 필요합니다", text: "확인")
                    } else {
//                        let alertController = UIAlertController(title: "무결성검사", message: "무결성검사가 정상입니다", preferredStyle: UIAlertController.Style.alert)
//                        let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
//
//                        }
//                        alertController.addAction(okButton)
//                        self.present(alertController, animated: true, completion: nil)
                    }
                  
                    break
                case Command.NAK:
                    AlertBox(title: "결과", message: "장치 오류. 연결 해제 후, 다시 연결을 시도해 주세요.", text: "확인")
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
                    print(_resultMessage)
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
    
    func initRes(){
        mTidTextField.delegate = self
        mBsnTextField.delegate = self
        mSerialTextField.delegate = self
        
        mTidTextField.text = ""
        mBsnTextField.text = ""
        mSerialTextField.text = ""
        
        //새로운 버튼을 만든다 키보드 닫기 버튼을 만든다.
        let bar = UIToolbar()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
                
        mTidTextField.inputAccessoryView = bar
        mBsnTextField.inputAccessoryView = bar
        mSerialTextField.inputAccessoryView = bar

//        setStoreInfo()
        mTidTextField.text = Setting.shared.getDefaultUserData(_key: define.STORE_TID) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_TID)
        
        if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
            mMultiStoreUse.setOn(true, animated: false)
        } else {
            mMultiStoreUse.setOn(false, animated: false)
        }
    }
    
    /**
     복수가맹점 사용 유무
     */
    @IBAction func switch_multistore_use(_ sender: UISwitch) {
        if sender.isOn {
            Setting.shared.setDefaultUserData(_data: sender.isOn.description, _key: define.MULTI_STORE)
        } else {
            Setting.shared.setDefaultUserData(_data: "", _key: define.MULTI_STORE)
        }
    }
    
    /**
     BLE 장치 시리얼 읽어 오는 함수
     */
    @IBAction func resistStoreClicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        //검색될 때까지 로딩메세지박스를 띄운다
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        //정상적으로 가맹점다운로드를 진행한다
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
            if mBsnTextField.text == "" || mSerialTextField.text == "" || mTidTextField.text == "" {
                alertLoading.dismiss(animated: false){ [self] in
                    AlertBox(title: "가맹점 다운로드", message: "입력필드의 값이 입력되지 않았습니다.", text: "확인")
                }
                return
            }
            
            StoreDownload()
        }

    }
    
    //장치정보를 요청한다.
    @IBAction func clicked_getDeviceInfo(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        //검색될 때까지 로딩메세지박스를 띄운다
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED && mKocesSdk.mVerityCheck == define.VerityMethod.Success.rawValue {
            //정상적으로 가맹점다운로드를 진행한다
            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                mKocesSdk.GetDeviceInfo(Date: Utils.getDate(format: "yyyyMMddHHmmss"))
            }
        } else if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED && mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
            //블루투스는 연결되어 있지만 무결성검사가 정상적이지 않으므로 먼저 무결성검사를 진행한다
            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                mKocesSdk.GetVerity()
            }
        } else if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
            //블루투스가 연결되어 있지 않으므로 블루투스연결을 먼저 시도한다
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                mKocesSdk.bleConnect()
            }
        } else {
            alertLoading.dismiss(animated: true) {
                self.AlertBox(title: "CAT/BLE 에러", message: "현재 디바이스를 CAT 으로 셋팅되어 있습니다", text: "확인")
            }
        }
    }
    
    @objc func dismissMyKeyboard(){
           view.endEditing(true)
    }
    
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

extension StoreRegistController: TcpResultDelegate, UITextFieldDelegate, CustomAlertDelegate
{
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
    
   
    
    func StoreDownload()
    {
        listener = TcpResult()
        listener?.delegate = self

        //기존 정보들을 일단 다 제거 한다.
        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.contains(define.STORE_TID) {
                if key.contains(define.CAT_STORE_TID) {
                    
                } else {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                    KeychainWrapper.standard.removeObject(forKey: keyChainTarget.KocesICIOSPay.rawValue + (value as! String))
                }
          
            }
            if key.contains(define.STORE_BSN) {
                if key.contains(define.CAT_STORE_BSN) {
                    
                } else {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
              
            }
            if key.contains(define.STORE_SERIAL) {
                if key.contains(define.CAT_STORE_SERIAL) {
                    
                } else {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
             
            }
            if key.contains(define.STORE_NAME) {
                if key.contains(define.CAT_STORE_NAME) {
                    
                } else {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
           
            }
            if key.contains(define.STORE_PHONE) {
                if key.contains(define.CAT_STORE_PHONE) {
                    
                } else {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
             
            }
            if key.contains(define.STORE_OWNER) {
                if key.contains(define.CAT_STORE_OWNER) {
                    
                } else {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
      
            }
            if key.contains(define.STORE_ADDR) {
                if key.contains(define.CAT_STORE_ADDR) {
                    
                } else {
                    Setting.shared.setDefaultUserData(_data: "", _key: key)
                }
            
            }
        }
        
        if mMultiStoreUse.isOn {
            Setting.shared.setDefaultUserData(_data: mMultiStoreUse.isOn.description, _key: define.MULTI_STORE)
        } else {
            Setting.shared.setDefaultUserData(_data: "", _key: define.MULTI_STORE)
        }
        
//        mKocesSdk.StoreDownload(Command: mMultiStoreUse.isOn ? "D11":"D10", Tid: mTidTextField.text!, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", Length: "0003", PosCheckData: "MDO", BSN: mBsnTextField.text!, Serial: mSerialTextField.text!, PosData: "", MacAddr: Utils.getKeyChainUUID(), CallbackListener: listener?.delegate as! TcpResultDelegate)
        
        mKocesSdk.StoreDownload(Command: mMultiStoreUse.isOn ? "D12":"D10", Tid: mTidTextField.text!, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", Length: "0003", PosCheckData: "MDO", BSN: mBsnTextField.text!, Serial: mSerialTextField.text!, PosData: "", MacAddr: Utils.getKeyChainUUID(), CallbackListener: listener?.delegate as! TcpResultDelegate)

    }
    
    /** 키갱신시 사용 */
    func onKeyResult(tcpStatus _status: tcpStatus, Result _result: [UInt8], DicResult _dicresult: Dictionary<String, String>) {
        print(_result)
    }

    func onResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>) {

        if _result["AnsCode"] == "0000" {
            //복수가맹점응답일경우
            if _result["TrdType"]! == "D16" || _result["TrdType"]! == "D17" {
                var _msg:String = ""
                var keyCount:Int = 0
                var TermIDCount:Int = 0    //총 몇개의 키를 저장해야 하는지 체크
                for (key,value) in _result {
                    if key.contains("TermID") {
                        TermIDCount += 1
                    }
                    
                    if _result.count - 1 == keyCount {
                        _msg += key + " = " + value
                    }
                    else{
                        _msg += key + " = " + value + "\n"
                    }
                    keyCount += 1
                }
                
                //이게 1개란 소리는 복수가맹점으로 했지만 실제로 복수가맹점데이터 필드에는 데이터가 없었다는 소리다.
                if TermIDCount == 1 {
                    Setting.shared.setDefaultUserData(_data: _result["TermID"]!, _key: define.STORE_TID)
                    Setting.shared.setDefaultUserData(_data: _result["BsnNo"]!, _key: define.STORE_BSN)
                    Setting.shared.setDefaultUserData(_data: mSerialTextField.text!, _key: define.STORE_SERIAL)
                    
                    //가맹점 정보 저장
                    Setting.shared.setDefaultUserData(_data: _result["ShpNm"]!, _key: define.STORE_NAME) //업체명
                    Setting.shared.setDefaultUserData(_data: _result["ShpTel"]!, _key: define.STORE_PHONE) //업체 전화번호
                    Setting.shared.setDefaultUserData(_data: _result["PreNm"]!, _key: define.STORE_OWNER) //업체 대표자명
                    Setting.shared.setDefaultUserData(_data: _result["ShpAdr"]!, _key: define.STORE_ADDR) //업체 주소
                    
                    let _key = _result["HardwareKey"] ?? ""
                    //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
                    Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (_result["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                    mBsnTextField.text = ""
                    mSerialTextField.text = ""
                    
//                    setStoreInfo()
                    alertLoading.dismiss(animated: true){ [self] in
                        AlertBox(title: "결과", message: "가맹점 등록 다운로드가 완료 되었습니다.", text: "확인")
                    }
                    return
                }
                //기본데이터는 업데이트 한다.
                Setting.shared.setDefaultUserData(_data: _result["TermID0"]!, _key: define.STORE_TID)
                Setting.shared.setDefaultUserData(_data: _result["BsnNo0"]!, _key: define.STORE_BSN)
                Setting.shared.setDefaultUserData(_data: mSerialTextField.text!, _key: define.STORE_SERIAL)
                
                //가맹점 정보 저장
                Setting.shared.setDefaultUserData(_data: _result["ShpNm0"]!, _key: define.STORE_NAME) //업체명
                Setting.shared.setDefaultUserData(_data: _result["ShpTel0"]!, _key: define.STORE_PHONE) //업체 전화번호
                Setting.shared.setDefaultUserData(_data: _result["PreNm0"]!, _key: define.STORE_OWNER) //업체 대표자명
                Setting.shared.setDefaultUserData(_data: _result["ShpAdr0"]!, _key: define.STORE_ADDR) //업체 주소
                Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (_result["TermID0"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _result["HardwareKey"] ?? _result["HardwareKey" + (_result["TermID0"] ?? "")] ?? "")
                
                var _key:String = ""
                for i in 0 ..< (TermIDCount - 1) {
                    Setting.shared.setDefaultUserData(_data: _result["TermID" + String(i)]!, _key: define.STORE_TID + String(i))
                    Setting.shared.setDefaultUserData(_data: _result["BsnNo" + String(i)]!, _key: define.STORE_BSN + String(i))
                    Setting.shared.setDefaultUserData(_data: mSerialTextField.text!, _key: define.STORE_SERIAL + String(i))

                    //가맹점 정보 저장
                    Setting.shared.setDefaultUserData(_data: _result["ShpNm" + String(i)]!, _key: define.STORE_NAME + String(i)) //업체명
                    Setting.shared.setDefaultUserData(_data: _result["ShpTel" + String(i)]!, _key: define.STORE_PHONE + String(i)) //업체 전화번호
                    Setting.shared.setDefaultUserData(_data: _result["PreNm" + String(i)]!, _key: define.STORE_OWNER + String(i)) //업체 대표자명
                    Setting.shared.setDefaultUserData(_data: _result["ShpAdr" + String(i)]!, _key: define.STORE_ADDR + String(i)) //업체 주소
                    
                    _key = _result["HardwareKey"] ?? _result["HardwareKey" + (_result["TermID" + String(i)] ?? "")] ?? ""
                    //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
                    Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (_result["TermID" + String(i)] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                }
                mBsnTextField.text = ""
                mSerialTextField.text = ""
                
//                setStoreInfo()
                alertLoading.dismiss(animated: true){ [self] in
//                    AlertBox(title: "결과", message: _msg, text: "확인")
                    AlertBox(title: "결과", message: "가맹점 등록 다운로드가 완료 되었습니다.", text: "확인")
                }
            } else {
                Setting.shared.setDefaultUserData(_data: _result["TermID"]!, _key: define.STORE_TID)
                Setting.shared.setDefaultUserData(_data: _result["BsnNo"]!, _key: define.STORE_BSN)
                Setting.shared.setDefaultUserData(_data: mSerialTextField.text!, _key: define.STORE_SERIAL)
                
                //가맹점 정보 저장
                Setting.shared.setDefaultUserData(_data: _result["ShpNm"]!, _key: define.STORE_NAME) //업체명
                Setting.shared.setDefaultUserData(_data: _result["ShpTel"]!, _key: define.STORE_PHONE) //업체 전화번호
                Setting.shared.setDefaultUserData(_data: _result["PreNm"]!, _key: define.STORE_OWNER) //업체 대표자명
                Setting.shared.setDefaultUserData(_data: _result["ShpAdr"]!, _key: define.STORE_ADDR) //업체 주소
                
                let _key = _result["HardwareKey"] ?? ""
                //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
                Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (_result["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
    //            if !_key.isEmpty {
    //                Utils.setPosKeyChainUUIDtoBase64(PosKeyChain: _key)
    //            }
                mBsnTextField.text = ""
                mSerialTextField.text = ""
                
//                setStoreInfo()
                alertLoading.dismiss(animated: true){ [self] in
                    AlertBox(title: "결과", message: "가맹점 등록 다운로드가 완료 되었습니다.", text: "확인")
                }
            }

        } else {
            
            //기존의 정보를 다 지운다.
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_TID)
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_BSN)
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_SERIAL)
            
            //가맹점 정보 삭제
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_NAME) //업체명
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_PHONE) //업체 전화번호
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_OWNER) //업체 대표자명
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_ADDR) //업체 주소
            
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key.contains(define.STORE_TID) {
                    if key.contains(define.CAT_STORE_TID) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                        KeychainWrapper.standard.removeObject(forKey: keyChainTarget.KocesICIOSPay.rawValue + (value as! String))
                    }
              
                }
                if key.contains(define.STORE_BSN) {
                    if key.contains(define.CAT_STORE_BSN) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                  
                }
                if key.contains(define.STORE_SERIAL) {
                    if key.contains(define.CAT_STORE_SERIAL) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                 
                }
                if key.contains(define.STORE_NAME) {
                    if key.contains(define.CAT_STORE_NAME) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
               
                }
                if key.contains(define.STORE_PHONE) {
                    if key.contains(define.CAT_STORE_PHONE) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                 
                }
                if key.contains(define.STORE_OWNER) {
                    if key.contains(define.CAT_STORE_OWNER) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
          
                }
                if key.contains(define.STORE_ADDR) {
                    if key.contains(define.CAT_STORE_ADDR) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                
                }
            }
            
            mBsnTextField.text = ""
            mSerialTextField.text = ""
            
//            setStoreInfo()
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "결과", message: "가맹점 등록 다운로드를 실패 하였습니다.", text: "확인")
            }
          
            
            
        }

    }

    /**
     글자수 제한을 위한 함수
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength:Int = CharMaxLength
        switch textField {
        case mTidTextField:
            maxLength = CharMaxLength
        case mBsnTextField:
            maxLength = CharMaxLength
        case mSerialTextField:
            maxLength = CharMaxLength
        default:
            break
        }
        let newLength = (textField.text?.count)! + string.count - range.length
                return !(newLength > maxLength)
    }
}
