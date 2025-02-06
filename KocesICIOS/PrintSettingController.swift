//
//  PrintSettingController.swift
//  osxapp
//
//  Created by 신진우 on 2021/03/25.
//

import Foundation
import UIKit

class PrintSettingController:UIViewController {

    @IBOutlet weak var mPrintCustomerSegment: UISegmentedControl!
    @IBOutlet weak var mPrintLowLabelSegment: UISegmentedControl!
    @IBOutlet weak var mTxtPrintLowLavel: UITextView!

    @IBOutlet weak var mPrintUseCheckView: UIStackView!
    
    
    @IBOutlet weak var mPrintAdAutoSegment: UISegmentedControl!
    
    @IBOutlet weak var mPrintAdAutoView: UIStackView!
    
    
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var printlistener: PrintResult?
    var listener: TcpResult?
    //로딩 메세지박스
    var alertLoading = UIAlertController()

    var scanTimeout:Timer?       //프린트시 타임아웃

    let mCatSdk:CatSdk = CatSdk.instance
    var catlistener:CatResult?

    //데이터 저장
    @IBAction func clicked_btn_Save(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }

        PrintSave()
    }
    
    func PrintSave() {
        //로컬에 데이터 저장
        let _lowlavel:String = mTxtPrintLowLavel.text ?? ""
        if mPrintCustomerSegment.selectedSegmentIndex == 1 {
            Setting.shared.setDefaultUserData(_data: "PRINT_CUSTOMER", _key: define.PRINT_CUSTOMER)
        } else {
            Setting.shared.setDefaultUserData(_data: "PRINT_NONE", _key: define.PRINT_CUSTOMER)
        }

        if mPrintLowLabelSegment.selectedSegmentIndex == 1 {
            Setting.shared.setDefaultUserData(_data: _lowlavel, _key: define.PRINT_LOWLAVEL)
        } else {
            Setting.shared.setDefaultUserData(_data: "", _key: define.PRINT_LOWLAVEL)
            mTxtPrintLowLavel.text = ""
        }
        
        //프린트를 자동으로할건지 수동으로 할건지 처리
        if mPrintAdAutoSegment.selectedSegmentIndex == 1 {
            //자동설정
            Setting.shared.setDefaultUserData(_data: define.PRINT_AD_AUTO, _key: define.PRINT_AD_AUTO)
            mTxtPrintLowLavel.isEditable = false
        } else {
            //수동설정
            Setting.shared.setDefaultUserData(_data: "", _key: define.PRINT_AD_AUTO)
            mTxtPrintLowLavel.isEditable = true
        }
        
        AlertBox(title: "성공", message: "설정이 저장되었습니다.", text: "확인")
    }
    
    //프린트테스트
    @IBAction func clicked_btn_Text(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        testPrint()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)
        initView()
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
    
    @objc func didBle(_ notification: Notification) {
        guard let bleStatus: String = notification.userInfo?["Status"] as? String else { return }
        switch bleStatus {

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
 
        default:
            break
        }
        
    }
    
    func initView() {
        if Setting.shared.getDefaultUserData(_key: define.PRINT_CUSTOMER) == "PRINT_NONE" {
            mPrintCustomerSegment.selectedSegmentIndex = 0
        }
        else {
            mPrintCustomerSegment.selectedSegmentIndex = 1
        }

        if Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL).isEmpty {
            mPrintLowLabelSegment.selectedSegmentIndex = 0
            mPrintUseCheckView.isHidden = true
            mPrintUseCheckView.alpha = 0.0
        }
        else {
            mPrintLowLabelSegment.selectedSegmentIndex = 1
            mPrintUseCheckView.isHidden = false
            mPrintUseCheckView.alpha = 1.0
        }
        
        mTxtPrintLowLavel.layer.borderColor = define.layout_border_lightgrey.cgColor
        mTxtPrintLowLavel.layer.borderWidth = 1
        if Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL).isEmpty || Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL) == "" {
            mTxtPrintLowLavel.text = ""
        } else {
            mTxtPrintLowLavel.text = Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL)
        }
        
        //프린트를 자동으로할건지 수동으로 할건지 처리
        if Setting.shared.getDefaultUserData(_key: define.PRINT_AD_AUTO).isEmpty ||
            Setting.shared.getDefaultUserData(_key: define.PRINT_AD_AUTO) == "" {
            //수동설정
            mPrintAdAutoSegment.selectedSegmentIndex = 0
            mTxtPrintLowLavel.isEditable = true
            
            mPrintAdAutoView.isHidden = true
            mPrintAdAutoView.alpha = 0.0
            
        } else {
            //자동설정
            mPrintAdAutoSegment.selectedSegmentIndex = 1
            mTxtPrintLowLavel.isEditable = false
            
            mPrintAdAutoView.isHidden = false
            mPrintAdAutoView.alpha = 1.0
        }
        
   
        let bar = UIToolbar()
                
        //새로운 버튼을 만든다
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        
        //
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
        //
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
        mTxtPrintLowLavel.inputAccessoryView = bar
        
        listener = TcpResult()
        listener?.delegate = self
    }
    
    @objc func dismissMyKeyboard(){
           view.endEditing(true)
       }
    
    func testPrint() {
        
        if mKocesSdk.blePrintState == define.PrintDeviceState.BLENOPRINT {
            AlertBox(title: "BLE 프린트 테스트", message: "프린트 가능한 BLE 장비를 연결해 주세요", text: "확인")
            return
        }
        
        //cat 연동일 경우
        else if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
            let _catMsg = Utils.CheckPrintCatPortIP()
            if _catMsg != "" {
                AlertBox(title: "BLE 프린트 테스트", message: _catMsg, text: "확인")
                return
            }
        } else {
            if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                AlertBox(title: "BLE 프린트 테스트", message: "연결이 되어 있지 않습니다. 연결 후 실행 해 주세요", text: "확인")
                return
            }
            
//            if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
//                if Utils.CheckCatPortIP() != "" {
//                    AlertBox(title: "CAT 프린트 테스트", message: Utils.CheckCatPortIP(), text: "확인")
//                    return
//                }
//               
//            }
            
            if !Utils.PrintDeviceCheck().isEmpty {
                AlertBox(title: "BLE 프린트 테스트", message: "출력 가능 장비 없음", text: "확인")
                return
            }
        }
        
        
        
        if Setting.shared.getDefaultUserData(_key: define.PRINT_CUSTOMER) == "PRINT_NONE" {
            AlertBox(title: "BLE 프린트 테스트", message: "출력 옵션에 출력 가능 옵션(고객용)이 설정되지 않았습니다", text: "확인")
            return
        }

        //검색될 때까지 로딩메세지박스를 띄운다
//        AlertLoadingBox(title: "잠시만 기다려 주세요")
        Utils.printAlertBox(Title: "프린트 출력중입니다", LoadingBar: true, GetButton: "")
        printTimeOut()
        let 왼쪽 = define.PLEFT
        let 중앙 = define.PCENTER
        let 오른쪽 = define.PRIGHT
        let 엔터 = define.PENTER
//        var Contents:[String] = Array()
        
        let _p:[UInt8] = [
        0x32, 0x30, 0x32, 0x34, 0x31, 0x32, 0x32, 0x37, 0x39, 0x35, 0x31, 0x30, 0x35, 0xE2, 0x80, 0xAF, 0x41, 0x4D
        ]
        
        var str = (Utils.PrintCenter(Center: "< 테 스 트 >") + define.PENTER)
        str += Utils.UInt8ArrayToStr(UInt8Array: _p) + 엔터
        str += 오른쪽 + " 한국신용카드결제(주) " + 엔터
        str += dddd(_bold: " 신용매출 ") + 엔터
        str += Setting.shared.getDefaultUserData(_key: define.STORE_NAME) + 엔터
        str += Setting.shared.getDefaultUserData(_key: define.STORE_OWNER) + 엔터
        str += "사업자 번호 :" + Setting.shared.getDefaultUserData(_key: define.STORE_BSN) + 엔터
        str += "TEL: " + Setting.shared.getDefaultUserData(_key: define.STORE_PHONE) + 엔터
        str += Setting.shared.getDefaultUserData(_key: define.STORE_ADDR) + 엔터
        str += String.init(repeating: "-", count: 48)
        str += "TID: " + Setting.shared.getDefaultUserData(_key: define.STORE_TID) + 엔터
//        str += "카드종류 : " + dddd(_bold: " 하나카드 " ) + 엔터
//        str += "카드번호 : 9410-00**-****-****" + 엔터
//        str += "거래일시 : 2021/02/23 00:00:00 (일시불)" + 엔터
        str += String.init(repeating: "=", count: 48)

        if !Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL).isEmpty {
            str += (Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL) + define.PENTER)
        }
        let prtStr = mKocesSdk.PrintParser(파싱할프린트내용: str)
        catlistener = CatResult()
        catlistener?.delegate = self
        DispatchQueue.global().asyncAfter(deadline: .now() + 1){ [self] in
            if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
                mCatSdk.Print(파싱할프린트내용: prtStr, CompletionCallback: catlistener?.delegate! as! CatResultDelegate)
            } else if mKocesSdk.blePrintState == define.PrintDeviceState.BLEUSEPRINT {
                BlePrinter(내용: prtStr)
            } else {
                if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                    BlePrinter(내용: prtStr)
                } else if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.Print(파싱할프린트내용: prtStr, CompletionCallback: catlistener?.delegate! as! CatResultDelegate)
                }
            }
        }
    }

    
    @IBAction func clicked_seg_print_use(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        switch sender.selectedSegmentIndex {
        case 0:
            //미사용
            mPrintUseCheckView.isHidden = true
            mPrintUseCheckView.alpha = 0.0
            break
        case 1:
            //사용
            mPrintUseCheckView.isHidden = false
            mPrintUseCheckView.alpha = 1.0
            break
        default:
            break
        }
    }
    
    @IBAction func clicked_seg_auto(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        switch sender.selectedSegmentIndex {
        case 0:
            //수동설정
            mTxtPrintLowLavel.isEditable = true
            
            mPrintAdAutoView.isHidden = true
            mPrintAdAutoView.alpha = 0.0
            break
        case 1:
            //자동설정
            mTxtPrintLowLavel.isEditable = false
            
            mPrintAdAutoView.isHidden = false
            mPrintAdAutoView.alpha = 1.0
            break
        default:
            break
        }
    }
    
    @IBAction func clicked_btn_ad_download(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        //검색될 때까지 로딩메세지박스를 띄운다
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        //정상적으로 가맹점다운로드를 진행한다
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
            
            AdDownload()
        }
    }
    
    func AdDownload()
    {
        listener = TcpResult()
        listener?.delegate = self
        /** log : Original App 가맹점다운로드 시작*/
        if Utils.getIsBT() {
            if Setting.shared.getDefaultUserData(_key: define.STORE_TID) == "" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                    alertLoading.dismiss(animated: false){ [self] in
                        AlertBox(title: "광고 다운로드", message: "먼저 가맹점 설정을 진행해 주십시오", text: "확인")
                    }
                }
                return
            }
            
//            LogFile.instance.InsertLog("********** OriginalApp Service **********", Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID), TimeStamp: true)
            
            mKocesSdk.AdDownload(Command: Command.CMD_AD_DOWNLOAD_REQ, Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID), Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", 광고출력구분: "0", 문자출력구분: "0", 문자출력길이: "099", 문자출력라인: "09", 이미지출력포맷: "   ", 이미지출력가로사이즈: "0000", 이미지출력세로사이즈: "0000", PosData: "", CallbackListener: listener?.delegate as! TcpResultDelegate)

        } else {
            if Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID) == "" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                    alertLoading.dismiss(animated: false){ [self] in
                        AlertBox(title: "광고 다운로드", message: "먼저 가맹점 설정을 진행해 주십시오", text: "확인")
                    }
                }
                return
            }
            

            mKocesSdk.AdDownload(Command: Command.CMD_AD_DOWNLOAD_REQ, Tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID), Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", 광고출력구분: "0", 문자출력구분: "0", 문자출력길이: "099", 문자출력라인: "09", 이미지출력포맷: "   ", 이미지출력가로사이즈: "0000", 이미지출력세로사이즈: "0000", PosData: "", CallbackListener: listener?.delegate as! TcpResultDelegate)
        }


    }
    
    func dddd(_bold:String) -> String {
        return define.PBOLDSTART + _bold + define.PBOLDEND
        //return  _bold
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
    
    func printTimeOut() {
        self.scanTimeout = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false, block: { timer in
            var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
            resDataDic["Message"] = NSString("프린트를 실패(타임아웃)하였습니다") as String
            self.onPrintResult(printStatus: .OK, printResult: resDataDic)
            self.scanTimeout?.invalidate()
            self.scanTimeout = nil
        })
    }
}

extension PrintSettingController: PrintResultDelegate, CatResultDelegate, TcpResultDelegate {
    func onDirectResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>, DirectData _directData: Dictionary<String, String>) {
        print(_result)
    }
    
    func onKeyResult(tcpStatus _status: tcpStatus, Result _result: [UInt8], DicResult _dicresult: Dictionary<String, String>) {
        print(_result)
    }
    
    
    func onResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>) {
        print(_result)
        alertLoading.dismiss(animated: true) { [self] in
            if _result["AnsCode"] == "0000" {
                AlertBox(title: "결과", message: "광고문구 다운로드를 완료하였습니다", text: "확인")
                Setting.shared.setDefaultUserData(_data: _result["AdInfoData"] ?? "", _key: define.PRINT_LOWLAVEL)
                mTxtPrintLowLavel.text = Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL)
                
                PrintSave()
            }
            else
            {
                AlertBox(title: "에러", message: " 응답코드: \(_result["AnsCode"] ?? "") \n \(_result["Message"] ?? "") ", text: "확인")
            }
        }

    }
    
    func onResult(CatState _state:payStatus,Result _message:Dictionary<String,String>) {
        self.scanTimeout?.invalidate()
        self.scanTimeout = nil
        Utils.customAlertBoxClear()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "프린트결과", message: _message["Message"] ?? "프린트에 실패하였습니다", text: "확인")
            }
        }
    }
    
    func BlePrinter(내용 _Contents:String) {
        mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        printlistener = PrintResult()
        printlistener?.delegate = self
        mKocesSdk.BlePrinter(내용: _Contents, CallbackListener: printlistener?.delegate as! PrintResultDelegate)
    }
    
    func onPrintResult(printStatus _status: printStatus, printResult _result: Dictionary<String, String>) {
        self.scanTimeout?.invalidate()
        self.scanTimeout = nil
        Utils.customAlertBoxClear()

        if (_result["Message"] ?? "").contains("완료") {
            
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "프린트결과", message: _result["Message"] ?? "프린트에 실패하였습니다", text: "확인")
            }
        }

    }
}
