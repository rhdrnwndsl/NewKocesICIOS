//
//  CreditCancelController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2021/07/28.
//

import Foundation
import UIKit
import SwiftUI

class CreditCancelController: UIViewController {
    
    var mpaySdk:PaySdk = PaySdk.instance
    var mCatSdk:CatSdk = CatSdk.instance
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var paylistener: payResult = payResult()
    var catlistener: CatResult = CatResult()
    
    @IBOutlet weak var mAudatePicker: UIDatePicker!
    @IBOutlet weak var mAuNumber: UITextField!
    @IBOutlet weak var mMoney: UITextField!
    
    var isTouch = "Money"   //금액입력, 원승인번호입력 중 하나
    
    @IBOutlet weak var numberPad: NumberPad!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
        InitRes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func InitRes() {
        //네비게이션 바의 배경색 rgb 변경
        UISetting.navigationTitleSetting(navigationBar: navigationController?.navigationBar ?? UINavigationBar())

        mAuNumber.keyboardType = .numberPad
        mMoney.keyboardType = .numberPad
//        let bar = UIToolbar()
//                
//        //새로운 버튼을 만든다 키보드 닫기 버튼을 만든다.
//        let doneBtn = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(dismissMyKeyboard))
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        bar.items = [flexSpace, flexSpace, doneBtn]
//        bar.sizeToFit()
//                
//        mAuNumber.inputAccessoryView = bar
//        mMoney.inputAccessoryView = bar
//        
//        mMoney.addTarget(self, action: #selector(self.CreditTextFieldDidChange(_:)), for: .editingChanged)    //금액이 변동된 경우에 처리
        
        numberPad.delegate = self
        numberPad.emptyKeyBackgroundColor = .clear
        
        isTouch = "Money"
        mMoney.backgroundColor = .white
        mAuNumber.backgroundColor = define.grey
        
    }
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func clicked_money(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Money"
        mAuNumber.backgroundColor = define.grey
        mMoney.backgroundColor = .white
        sender.resignFirstResponder()
    }
    
    @IBAction func clicked_txf(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "AuNumber"
        mAuNumber.backgroundColor = .white
        mMoney.backgroundColor = define.grey
        sender.resignFirstResponder()
    }
    
    /// 금액텍스트필드 값 변경시 호출 되는 함수
    /// - Parameter textField: mCreditTxtFieldMoney
    func CreditTextFieldDidChange(_ textField: UITextField) {
        let money:Int = Int(mMoney.text!.replacingOccurrences(of: ",", with: "")) ?? 0

        mMoney.text = Utils.PrintMoney(Money: String(money))
    }
    
    func clicked_btn_cancel() {
  
        if mAuNumber.text == "" {
            AlertBox(title: "에러", message: "원승인번호를 입력하세요", text: "확인" )
            return
        }
        
        if mMoney.text == "" {
            AlertBox(title: "에러", message: "취소금액을 입력하세요", text: "확인" )
            return
        }
        
        mpaySdk.Clear()
        mpaySdk = PaySdk.instance
        mCatSdk.Clear()
        mCatSdk = CatSdk.instance
        paylistener = payResult()
        paylistener.delegate = self
        catlistener = CatResult()
        catlistener.delegate = self
        
        //여기서 부터 신용결제 프로세스를 진행한다
        if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
            CreditCancel()
        } else if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            if Utils.CheckCatPortIP() != "" {
                AlertBox(title: "에러", message: Utils.CheckCatPortIP(), text: "확인" )
                return
            }
            catlistener = CatResult()
            catlistener.delegate = self
            
            CatCancel()
        } else {
            AlertBox(title: "에러", message: "연결 가능한 단말기가 존재하지 않습니다", text: "확인" )
        }
    }
    
    
    func CatCancel() {
        //캣신용취소
        let money:Int = Int((mMoney.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
        let dateFormat = DateFormatter()    //코드상에 표현될 날짜의 포맷
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyyyMMdd"
        if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
            TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](BSN,TID,NUM,PHONE,OWNER,ADDR) in
                if TID == "" {
                    AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                    return
                }
                mCatSdk.PayCredit(TID: TID, 거래금액: String(money), 세금: "0", 봉사료: "0", 비과세: "0", 원거래일자: dateFormat.string(from: mAudatePicker.date), 원승인번호: (mAuNumber.text ?? ""), 코세스거래고유번호: "", 할부: "0", 취소: true, 가맹점데이터: "", 여유필드: "", StoreName: BSN, StoreAddr: ADDR, StoreNumber: NUM, StorePhone: PHONE, StoreOwner: OWNER,CompletionCallback: catlistener.delegate!)
            }
            return
        }
        //여기에 캣으로 보낼전문 구성
        mCatSdk.PayCredit(TID: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID), 거래금액: String(money), 세금: "0", 봉사료: "0", 비과세: "0", 원거래일자: dateFormat.string(from: mAudatePicker.date), 원승인번호: (mAuNumber.text ?? ""), 코세스거래고유번호: "", 할부: "0", 취소: true, 가맹점데이터: "", 여유필드: "", StoreName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME), StoreAddr: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR), StoreNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN), StorePhone: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE), StoreOwner: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER),CompletionCallback: catlistener.delegate!)
    }
    
    func CreditCancel() {
        //ble장치가 연결 되어 있는지 없는지 확인 한다.
        if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
            let controller = Utils.topMostViewController()
            let alert = UIAlertController(title: "에러", message: mKocesSdk.getStringPlist(Key: "err_msg_no_connected_device"), preferredStyle: UIAlertController.Style.alert)
            let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(btnOk)
            controller?.present(alert, animated: true, completion: nil)
            return
        }
        
        //cat 연동일 경우
        if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
            if Utils.CheckCatPortIP() != "" {
                let controller = Utils.topMostViewController()
                let alert = UIAlertController(title: "에러", message: Utils.CheckCatPortIP(), preferredStyle: UIAlertController.Style.alert)
                let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(btnOk)
                controller?.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
            if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                
                let controller = Utils.topMostViewController()
                let alert = UIAlertController(title: "에러", message: "리더기 무결성 검증실패 제조사A/S요망.", preferredStyle: UIAlertController.Style.alert)
                let btnOk = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(btnOk)
                controller?.present(alert, animated: true, completion: nil)
                return
            }
        }
        paylistener = payResult()
        paylistener.delegate = self
        let dateFormat = DateFormatter()    //코드상에 표현될 날짜의 포맷
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyMMdd"

        let mAuNo:String = (mAuNumber.text ?? "")
        let mCanCelInfo = "0" + dateFormat.string(from: mAudatePicker.date) + mAuNo
        let money:Int = Int((mMoney.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
        var _tid:String = Setting.shared.getDefaultUserData(_key: define.STORE_TID)
        
        if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
            TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](BSN,TID,NUM,PHONE,OWNER,ADDR) in
                if TID == "" {
                    AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                    return
                }
                _tid = TID
                mpaySdk.CreditIC(Tid: _tid, Money: String(money), Tax: 0, ServiceCharge: 0, TaxFree: 0, InstallMent: "0", OriDate: dateFormat.string(from: mAudatePicker.date) + "000000", CancenInfo: mCanCelInfo, mchData: "", KocesTreadeCode: "", CompCode: "", SignDraw: "1", FallBackUse: "0",payLinstener: paylistener.delegate!,StoreName: BSN,StoreAddr: ADDR,StoreNumber: NUM,StorePhone: PHONE,StoreOwner: OWNER)
            }
            return
        }
        mpaySdk.CreditIC(Tid: _tid, Money: String(money), Tax: 0, ServiceCharge: 0, TaxFree: 0, InstallMent: "0", OriDate: dateFormat.string(from: mAudatePicker.date) + "000000", CancenInfo: mCanCelInfo, mchData: "", KocesTreadeCode: "", CompCode: "", SignDraw: "1", FallBackUse: "0",payLinstener: paylistener.delegate!,StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
    }

}

extension CreditCancelController : UITabBarControllerDelegate, PayResultDelegate, CatResultDelegate, UITextFieldDelegate {
    
    /**
     금액 입력 후 다음 입력이 있는지 처리
     isNext = true ok버튼누름. 다음 입력할 거 찾아야서 isMoney="" 값을 넣어야함.
     isNext = false 일 경우에는 이전 입력할 거 찾아서 isMoney="" 값을 넣어야함.
     위 두개의 다른점은 다음 찾을 거의 우선순위임
     */
    func TxtUpdate(IsNext isNext:Bool) {
        if isNext {
            //금액입력을 사용
            if (mMoney.text!.isEmpty) {
                //만일 텍스트가 비어있다면?
                isTouch = "Money"
                mAuNumber.backgroundColor = define.grey
                mMoney.backgroundColor = .white
                return
            }
            
            //비과세을 사용
            if (mAuNumber.text!.isEmpty) {
                //만일 텍스트가 비어있다면?
                isTouch = "AuNumber"
                mAuNumber.backgroundColor = .white
                mMoney.backgroundColor = define.grey
                return
            }
            
            
        } else {

//            if (mMoney.text!.isEmpty) {
//                //만일 텍스트가 비어있다면?
//                isTouch = "Money"
//                mAuNumber.backgroundColor = define.grey
//                mMoney.backgroundColor = .white
//                return
//            }
//            
            //비과세을 사용
            if (mAuNumber.text!.isEmpty) {
                //만일 텍스트가 비어있다면?
                //금액입력을 사용
                if (isTouch == "AuNumber") {
                    isTouch = "Money"
                    mAuNumber.backgroundColor = define.grey
                    mMoney.backgroundColor = .white
                    return
                }
                return
            }
        }
       
        isTouch = ""

    }
    
    func onPaymentResult(payTitle _status: payStatus, payResult _message: Dictionary<String, String>) {
        // 카드애니메이션뷰 컨트롤러가 여전히 떠있으니 해당 뷰를 지운다
        Utils.CardAnimationViewControllerClear()
        
        var _totalString:String = ""    //메세지
        var _title:String = "신용[불가]"          //타이틀
        var keyCount:Int = 0
        switch _message["TrdType"] {
        case Command.CMD_IC_OK_RES:
            _title = "신용[거래]"
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "\n"
                }
                keyCount += 1
            }
            break
        case Command.CMD_IC_CANCEL_RES:
            _title = "신용[취소]"
            for (key,value) in _message {
                if _message.count - 1 == keyCount {
                    _totalString += key + "=" + value
                }
                else{
                    _totalString += key + "=" + value + "\n"
                }
                keyCount += 1
            }
            break
        default:
            break
        }
        
        
        if _status == .OK {
//                Utils.customAlertBoxInit(Title: _title, Message: _totalString , LoadingBar: false, GetButton: "확인")
            let controller = UIHostingController(rootView: ReceiptSwiftUI())
            controller.rootView.setData(영수증데이터: sqlite.instance.getTradeLastData(), 뷰컨트롤러: "신용", 전표번호: String(sqlite.instance.getTradeList().count))
            navigationController?.pushViewController(controller, animated: true)
        }
        else {
       
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                var _tmpmsg = _message["Message"] ?? _message["ERROR"] ?? "거래실패"
                if _tmpmsg.replacingOccurrences(of: " ", with: "") == "" {
                    _tmpmsg = "응답 데이터 이상"
                }
                let alertController = UIAlertController(title: _title, message: _tmpmsg, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
//                    self.navigationController?.popViewController(animated: false)
                    self.tabBarController?.delegate = self
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
//                Utils.customAlertBoxInit(Title: _title, Message: _message["Message"] ?? _message["ERROR"] ?? "거래실패", LoadingBar: false, GetButton: "확인")
            }
        
        }
    }
    
    func onResult(CatState _state: payStatus, Result _message: Dictionary<String, String>) {
        Utils.CatAnimationViewInitClear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if _state == .OK {
                let alertController = UIAlertController(title: "CAT신용거래", message: "거래가 정상적으로 완료되었습니다", preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
                    self.tabBarController?.delegate = self
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            } else {
                var _tmpmsg = _message["Message"] ?? _message["ERROR"] ?? "거래실패"
                if _tmpmsg.replacingOccurrences(of: " ", with: "") == "" {
                    _tmpmsg = "응답 데이터 이상"
                }
                let alertController = UIAlertController(title: "CAT신용거래", message: _tmpmsg, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
                    self.tabBarController?.delegate = self
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //탭바로 다른 탭 이동시 네비게이션은 초기로 이동한다
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let mainVC = navigationController?.viewControllers.first(where: { $0 is MainViewController}) as? MainViewController else { return }

        self.navigationController?.popToViewController(mainVC, animated: true)
    }
    
    func AlertBox(title : String, message : String, text : String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            return self.present(alertController, animated: true, completion: nil)
        }
    
    func TidAlertBox(title _title:String, callback: @escaping (_ BSN:String, _ TID:String, _ NUM:String, _ PHONE:String, _ OWNER:String, _ ADDR:String)->Void) {

        let alertController = UIAlertController(title: _title, message: nil, preferredStyle: .alert)
        
        let widthConstraints = alertController.view.constraints.filter({ return $0.firstAttribute == .width })
        alertController.view.removeConstraints(widthConstraints)
        // Here you can enter any width that you want
        let newWidth = UIScreen.main.bounds.width * 0.90
        // Adding constraint for alert base view
        let widthConstraint = NSLayoutConstraint(item: alertController.view,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: newWidth)
        alertController.view.addConstraint(widthConstraint)
        let firstContainer = alertController.view.subviews[0]
        // Finding first child width constraint
        let constraint = firstContainer.constraints.filter({ return $0.firstAttribute == .width && $0.secondItem == nil })
        firstContainer.removeConstraints(constraint)
        // And replacing with new constraint equal to alert.view width constraint that we setup earlier
        alertController.view.addConstraint(NSLayoutConstraint(item: firstContainer,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: alertController.view,
                                                        attribute: .width,
                                                        multiplier: 1.0,
                                                        constant: 0))
        // Same for the second child with width constraint with 998 priority
        let innerBackground = firstContainer.subviews[0]
        let innerConstraints = innerBackground.constraints.filter({ return $0.firstAttribute == .width && $0.secondItem == nil })
        innerBackground.removeConstraints(innerConstraints)
        firstContainer.addConstraint(NSLayoutConstraint(item: innerBackground,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: firstContainer,
                                                        attribute: .width,
                                                        multiplier: 1.0,
                                                        constant: 0))
        var _tid0:String = ""
        var _store0:String = ""
        var _num0:String = ""
        var _phone0:String = ""
        var _owner0:String = ""
        var _addr0:String = ""
        var _tid1:String = ""
        var _store1:String = ""
        var _num1:String = ""
        var _phone1:String = ""
        var _owner1:String = ""
        var _addr1:String = ""
        var _tid2:String = ""
        var _store2:String = ""
        var _num2:String = ""
        var _phone2:String = ""
        var _owner2:String = ""
        var _addr2:String = ""
        var _tid3:String = ""
        var _store3:String = ""
        var _num3:String = ""
        var _phone3:String = ""
        var _owner3:String = ""
        var _addr3:String = ""
        var _tid4:String = ""
        var _store4:String = ""
        var _num4:String = ""
        var _phone4:String = ""
        var _owner4:String = ""
        var _addr4:String = ""
        var _tid5:String = ""
        var _store5:String = ""
        var _num5:String = ""
        var _phone5:String = ""
        var _owner5:String = ""
        var _addr5:String = ""
        
        var _tid6:String = ""
        var _store6:String = ""
        var _num6:String = ""
        var _phone6:String = ""
        var _owner6:String = ""
        var _addr6:String = ""
        
        var _tid7:String = ""
        var _store7:String = ""
        var _num7:String = ""
        var _phone7:String = ""
        var _owner7:String = ""
        var _addr7:String = ""
        
        var _tid8:String = ""
        var _store8:String = ""
        var _num8:String = ""
        var _phone8:String = ""
        var _owner8:String = ""
        var _addr8:String = ""
        
        var _tid9:String = ""
        var _store9:String = ""
        var _num9:String = ""
        var _phone9:String = ""
        var _owner9:String = ""
        var _addr9:String = ""
        
        var _tid10:String = ""
        var _store10:String = ""
        var _num10:String = ""
        var _phone10:String = ""
        var _owner10:String = ""
        var _addr10:String = ""
        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.contains(define.STORE_TID) {
                if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                    if key == define.CAT_STORE_TID {
                        if (value as! String) != "" {
                            _tid0 = value as! String
                            _store0 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME) != "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME).replacingOccurrences(of: " ", with: ""):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "0").replacingOccurrences(of: " ", with: "")
                            _num0 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN) != "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN).replacingOccurrences(of: " ", with: ""):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "0").replacingOccurrences(of: " ", with: "")
                            _phone0 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE) != "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE).replacingOccurrences(of: " ", with: ""):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "0").replacingOccurrences(of: " ", with: "")
                            _owner0 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER) != "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER).replacingOccurrences(of: " ", with: ""):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "0").replacingOccurrences(of: " ", with: "")
                            _addr0 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR) != "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "0")
                            
                        }
                    } else if key == define.CAT_STORE_TID + "1" {
                        if (value as! String) != "" {
                            _tid1 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store1 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "1").replacingOccurrences(of: " ", with: "")
                            _num1 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "1").replacingOccurrences(of: " ", with: "")
                            _phone1 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "1").replacingOccurrences(of: " ", with: "")
                            _owner1 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "1").replacingOccurrences(of: " ", with: "")
                            _addr1 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "1")
                        }
                    } else if key == define.CAT_STORE_TID + "2" {
                        if (value as! String) != "" {
                            _tid2 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store2 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "2").replacingOccurrences(of: " ", with: "")
                            _num2 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "2").replacingOccurrences(of: " ", with: "")
                            _phone2 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "2").replacingOccurrences(of: " ", with: "")
                            _owner2 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "2").replacingOccurrences(of: " ", with: "")
                            _addr2 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "2")
                        }
                    } else if key == define.CAT_STORE_TID + "3" {
                        if (value as! String) != "" {
                            _tid3 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store3 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "3").replacingOccurrences(of: " ", with: "")
                            _num3 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "3").replacingOccurrences(of: " ", with: "")
                            _phone3 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "3").replacingOccurrences(of: " ", with: "")
                            _owner3 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "3").replacingOccurrences(of: " ", with: "")
                            _addr3 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "3")
                        }
                    } else if key == define.CAT_STORE_TID + "4" {
                        if (value as! String) != "" {
                            _tid4 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store4 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "4").replacingOccurrences(of: " ", with: "")
                            _num4 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "4").replacingOccurrences(of: " ", with: "")
                            _phone4 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "4").replacingOccurrences(of: " ", with: "")
                            _owner4 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "4").replacingOccurrences(of: " ", with: "")
                            _addr4 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "4")
                        }
                    } else if key == define.CAT_STORE_TID + "5" {
                        if (value as! String) != "" {
                            _tid5 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store5 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "5").replacingOccurrences(of: " ", with: "")
                            _num5 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "5").replacingOccurrences(of: " ", with: "")
                            _phone5 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "5").replacingOccurrences(of: " ", with: "")
                            _owner5 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "5").replacingOccurrences(of: " ", with: "")
                            _addr5 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "5")
                        }
                    } else if key == define.CAT_STORE_TID + "6" {
                        if (value as! String) != "" {
                            _tid6 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store6 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "6").replacingOccurrences(of: " ", with: "")
                            _num6 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "6").replacingOccurrences(of: " ", with: "")
                            _phone6 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "6").replacingOccurrences(of: " ", with: "")
                            _owner6 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "6").replacingOccurrences(of: " ", with: "")
                            _addr6 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "6")
                        }
                    } else if key == define.CAT_STORE_TID + "7" {
                        if (value as! String) != "" {
                            _tid7 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store7 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "7").replacingOccurrences(of: " ", with: "")
                            _num7 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "7").replacingOccurrences(of: " ", with: "")
                            _phone7 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "7").replacingOccurrences(of: " ", with: "")
                            _owner7 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "7").replacingOccurrences(of: " ", with: "")
                            _addr7 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "7")
                        }
                    } else if key == define.CAT_STORE_TID + "8" {
                        if (value as! String) != "" {
                            _tid8 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store8 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "8").replacingOccurrences(of: " ", with: "")
                            _num8 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "8").replacingOccurrences(of: " ", with: "")
                            _phone8 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "8").replacingOccurrences(of: " ", with: "")
                            _owner8 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "8").replacingOccurrences(of: " ", with: "")
                            _addr8 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "8")
                        }
                    } else if key == define.CAT_STORE_TID + "9" {
                        if (value as! String) != "" {
                            _tid9 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store9 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "9").replacingOccurrences(of: " ", with: "")
                            _num9 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "9").replacingOccurrences(of: " ", with: "")
                            _phone9 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "9").replacingOccurrences(of: " ", with: "")
                            _owner9 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "9").replacingOccurrences(of: " ", with: "")
                            _addr9 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "9")
                        }
                    } else if key == define.CAT_STORE_TID + "10" {
                        if (value as! String) != "" {
                            _tid10 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store10 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "10").replacingOccurrences(of: " ", with: "")
                            _num10 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "10").replacingOccurrences(of: " ", with: "")
                            _phone10 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "10").replacingOccurrences(of: " ", with: "")
                            _owner10 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "10").replacingOccurrences(of: " ", with: "")
                            _addr10 = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "10")
                        }
                    }
                } else {
                    if key == define.STORE_TID {
                        if (value as! String) != "" {
                            _tid0 = value as! String
                            _store0 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME) != "" ? Setting.shared.getDefaultUserData(_key: define.STORE_NAME).replacingOccurrences(of: " ", with: ""):Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "0").replacingOccurrences(of: " ", with: "")
                            _num0 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN) != "" ? Setting.shared.getDefaultUserData(_key: define.STORE_BSN).replacingOccurrences(of: " ", with: ""):Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "0").replacingOccurrences(of: " ", with: "")
                            _phone0 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE) != "" ? Setting.shared.getDefaultUserData(_key: define.STORE_PHONE).replacingOccurrences(of: " ", with: ""):Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "0").replacingOccurrences(of: " ", with: "")
                            _owner0 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER) != "" ? Setting.shared.getDefaultUserData(_key: define.STORE_OWNER).replacingOccurrences(of: " ", with: ""):Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "0").replacingOccurrences(of: " ", with: "")
                            _addr0 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR) != "" ? Setting.shared.getDefaultUserData(_key: define.STORE_ADDR):Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "0")
                        }
                    } else if key == define.STORE_TID + "1" {
                        if (value as! String) != "" {
                            _tid1 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store1 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "1").replacingOccurrences(of: " ", with: "")
                            _num1 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "1").replacingOccurrences(of: " ", with: "")
                            _phone1 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "1").replacingOccurrences(of: " ", with: "")
                            _owner1 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "1").replacingOccurrences(of: " ", with: "")
                            _addr1 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "1")
                        }
                    } else if key == define.STORE_TID + "2" {
                        if (value as! String) != "" {
                            _tid2 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store2 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "2").replacingOccurrences(of: " ", with: "")
                            _num2 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "2").replacingOccurrences(of: " ", with: "")
                            _phone2 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "2").replacingOccurrences(of: " ", with: "")
                            _owner2 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "2").replacingOccurrences(of: " ", with: "")
                            _addr2 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "2")
                        }
                    } else if key == define.STORE_TID + "3" {
                        if (value as! String) != "" {
                            _tid3 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store3 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "3").replacingOccurrences(of: " ", with: "")
                            _num3 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "3").replacingOccurrences(of: " ", with: "")
                            _phone3 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "3").replacingOccurrences(of: " ", with: "")
                            _owner3 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "3").replacingOccurrences(of: " ", with: "")
                            _addr3 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "3")
                        }
                    } else if key == define.STORE_TID + "4" {
                        if (value as! String) != "" {
                            _tid4 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store4 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "4").replacingOccurrences(of: " ", with: "")
                            _num4 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "4").replacingOccurrences(of: " ", with: "")
                            _phone4 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "4").replacingOccurrences(of: " ", with: "")
                            _owner4 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "4").replacingOccurrences(of: " ", with: "")
                            _addr4 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "4")
                        }
                    } else if key == define.STORE_TID + "5" {
                        if (value as! String) != "" {
                            _tid5 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store5 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "5").replacingOccurrences(of: " ", with: "")
                            _num5 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "5").replacingOccurrences(of: " ", with: "")
                            _phone5 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "5").replacingOccurrences(of: " ", with: "")
                            _owner5 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "5").replacingOccurrences(of: " ", with: "")
                            _addr5 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "5")
                        }
                    } else if key == define.STORE_TID + "6" {
                        if (value as! String) != "" {
                            _tid6 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store6 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "6").replacingOccurrences(of: " ", with: "")
                            _num6 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "6").replacingOccurrences(of: " ", with: "")
                            _phone6 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "6").replacingOccurrences(of: " ", with: "")
                            _owner6 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "6").replacingOccurrences(of: " ", with: "")
                            _addr6 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "6")
                        }
                    } else if key == define.STORE_TID + "7" {
                        if (value as! String) != "" {
                            _tid7 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store7 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "7").replacingOccurrences(of: " ", with: "")
                            _num7 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "7").replacingOccurrences(of: " ", with: "")
                            _phone7 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "7").replacingOccurrences(of: " ", with: "")
                            _owner7 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "7").replacingOccurrences(of: " ", with: "")
                            _addr7 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "7")
                        }
                    } else if key == define.STORE_TID + "8" {
                        if (value as! String) != "" {
                            _tid8 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store8 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "8").replacingOccurrences(of: " ", with: "")
                            _num8 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "8").replacingOccurrences(of: " ", with: "")
                            _phone8 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "8").replacingOccurrences(of: " ", with: "")
                            _owner8 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "8").replacingOccurrences(of: " ", with: "")
                            _addr8 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "8")
                        }
                    } else if key == define.STORE_TID + "9" {
                        if (value as! String) != "" {
                            _tid9 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store9 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "9").replacingOccurrences(of: " ", with: "")
                            _num9 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "9").replacingOccurrences(of: " ", with: "")
                            _phone9 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "9").replacingOccurrences(of: " ", with: "")
                            _owner9 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "9").replacingOccurrences(of: " ", with: "")
                            _addr9 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "9")
                        }
                    } else if key == define.STORE_TID + "10" {
                        if (value as! String) != "" {
                            _tid10 = (value as! String).replacingOccurrences(of: " ", with: "")
                            _store10 = Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "10").replacingOccurrences(of: " ", with: "")
                            _num10 = Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "10").replacingOccurrences(of: " ", with: "")
                            _phone10 = Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "10").replacingOccurrences(of: " ", with: "")
                            _owner10 = Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "10").replacingOccurrences(of: " ", with: "")
                            _addr10 = Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "10")
                        }
                    }
                }
                
            }
        }

        if _tid0 != "" {
            let ok0 = UIAlertAction(title:  "1. " + _store0 + ", " + _tid0, style: .default, handler: { (Action) in
                callback(_store0,_tid0,_num0,_phone0,_owner0,_addr0)
            })
            ok0.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok0)
        }
        
        if _tid1 != "" {
            let ok1 = UIAlertAction(title: "2. " + _store1 + ", " + _tid1 , style: .default, handler: { (Action) in
                callback(_store1,_tid1,_num1,_phone1,_owner1,_addr1)
            })
            ok1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok1)
        }
        
        if _tid2 != "" {
            let ok2 = UIAlertAction(title: "3. " + _store2 + ", " + _tid2 , style: .default, handler: { (Action) in
                callback(_store2,_tid2,_num2,_phone2,_owner2,_addr2)
            })
            ok2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok2)
        }
        
        if _tid3 != "" {
            let ok3 = UIAlertAction(title: "4. " + _store3 + ", " + _tid3 , style: .default, handler: { (Action) in
                callback(_store3,_tid3,_num3,_phone3,_owner3,_addr3)
            })
            ok3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok3)
        }
        
        if _tid4 != "" {
            let ok4 = UIAlertAction(title: "5. " + _store4 + ", " + _tid4 , style: .default, handler: { (Action) in
                callback(_store4,_tid4,_num4,_phone4,_owner4,_addr4)
            })
            ok4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok4)
        }
        
        if _tid5 != "" {
            let ok5 = UIAlertAction(title: "6. " + _store5 + ", " + _tid5 , style: .default, handler: { (Action) in
                callback(_store5,_tid5,_num5,_phone5,_owner5,_addr5)
            })
            ok5.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok5)
        }
        
        if _tid6 != "" {
            let ok6 = UIAlertAction(title: "7. " + _store6 + ", " + _tid6 , style: .default, handler: { (Action) in
                callback(_store6,_tid6,_num6,_phone6,_owner6,_addr6)
            })
            ok6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok6)
        }
        
        if _tid7 != "" {
            let ok7 = UIAlertAction(title: "8. " + _store7 + ", " + _tid7 , style: .default, handler: { (Action) in
                callback(_store7,_tid7,_num7,_phone7,_owner7,_addr7)
            })
            ok7.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok7)
        }
        
        if _tid8 != "" {
            let ok8 = UIAlertAction(title: "9. " + _store8 + ", " + _tid8 , style: .default, handler: { (Action) in
                callback(_store8,_tid8,_num8,_phone8,_owner8,_addr8)
            })
            ok8.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok8)
        }
        
        if _tid9 != "" {
            let ok9 = UIAlertAction(title: "10. " + _store9 + ", " + _tid9 , style: .default, handler: { (Action) in
                callback(_store9,_tid9,_num9,_phone9,_owner9,_addr9)
            })
            ok9.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok9)
        }
        
        if _tid10 != "" {
            let ok10 = UIAlertAction(title: "11. " + _store10 + ", " + _tid10 , style: .default, handler: { (Action) in
                callback(_store10,_tid10,_num10,_phone10,_owner10,_addr10)
            })
            ok10.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alertController.addAction(ok10)
        }
        
        let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: { (Action) in
            callback("","","","","","")
        })
//        cancel.setValue(messageAttrString, forKey: "attributedMessage")
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
}
extension CreditCancelController: NumberPadDelegate {
    func keyPressed(key: NumberKey?) {
        guard let number = key else {
            return
        }

        switch number {
        case .delete:
            switch isTouch {
            case "Money":
                guard !(mMoney.text?.isEmpty ?? true) else {
                    mMoney.text = ""
                    TxtUpdate(IsNext: false)
                    return
                }
                mMoney.text?.removeLast()
                if mMoney.text!.isEmpty {
                    TxtUpdate(IsNext: false)
                }
                CreditTextFieldDidChange(mMoney)
                break
            case "AuNumber":
                guard !(mAuNumber.text?.isEmpty ?? true) else {
                    mAuNumber.text = ""
                    TxtUpdate(IsNext: false)
                    return
                }
                mAuNumber.text?.removeLast()
                if mAuNumber.text!.isEmpty {
                    TxtUpdate(IsNext: false)
                }
        
                break
            default:
                break
            }
            break
        case .custom:
            switch isTouch {
            case "Money":
                break
            case "AuNumber":
                break
            default:
                break
            }
            let alert = UIAlertController(title: "Custom NumberPad Event",
                                          message: "\(mMoney.text ?? "") Send Number", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .clear:
            switch isTouch {
            case "Money":
                guard !(mMoney.text?.isEmpty ?? true) else {
                    return
                }
                mMoney.text = ""
                TxtUpdate(IsNext: false)
                CreditTextFieldDidChange(mMoney)
                return
            case "AuNumber":
                guard !(mAuNumber.text?.isEmpty ?? true) else {
                    return
                }
                mAuNumber.text = ""
                TxtUpdate(IsNext: false)
                return
            default:
                break
            }
  
            break
        case .key00:
            switch isTouch {
            case "Money":
                mMoney.text?.append("00")
                break
            case "AuNumber":
                mAuNumber.text?.append("00")
                break
            default:
                break
            }
  
            break
        case .key010:
            switch isTouch {
            case "Money":
                mMoney.text?.append("010")
                break
            case "AuNumber":
                mAuNumber.text?.append("010")
                break
            default:
                break
            }
   
            break
        case .keyok:
            
            switch isTouch {
            case "Money":
                TxtUpdate(IsNext: true)
                break
            case "AuNumber":
                TxtUpdate(IsNext: true)
                break
            default:
                break
            }
            
            if isTouch != "" {
                return
            }
            
            clicked_btn_cancel()
            return
        default:
            switch isTouch {
            case "Money":
                mMoney.text?.append("\(number.rawValue)")
                break
            case "AuNumber":
                mAuNumber.text?.append("\(number.rawValue)")
                break
            default:
                break
            }
    
        }
        
        switch isTouch {
        case "Money":
            CreditTextFieldDidChange(mMoney)
            break
        case "AuNumber":
            break
        default:
            break
        }
 
    }
}
