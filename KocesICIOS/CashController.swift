//  CashController.swift
//  osxapp
//
//  Created by 金載龍 on 2020/12/29.
//

import UIKit
import SwiftUI
class CashController: UIViewController {
    enum Target:Int {
        case Person
        case Business
        case myself
    }

    var mpaySdk:PaySdk = PaySdk.instance
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var mCatSdk:CatSdk = CatSdk.instance
    let mTaxCalc = TaxCalculator.Instance
    var paylistener: payResult?
    var catlistener:CatResult?
  
    var CharMaxLength:Int = 8   //초기값은 입력 가능한 금액 최대 단위 000,000,00 최대 천만 단위
    var mCashReciptTarget:Int = Target.Person.rawValue   //초기 설정은 개인로 한다.
    var mInputMoney:Int = 0 //텍스트필드에 입력된 값
    var mTotalMoney:Int = 0     //결제금액
    var mMoney:Int = 0      //공급가액
    var mTaxMoney:Int = 0     //세금
    var mSvcMoney:Int = 0   //봉사료
    var mTxfMoney:Int = 0   //비과세
    
    @IBOutlet var mCashTxtFieldMoney: UITextField!                //결제금액
    @IBOutlet var mCashTxtFieldTaxFree: UITextField!             //비과세
    @IBOutlet weak var mCashTxtMoney: UILabel!                  //공급가액
    
    @IBOutlet weak var mCashTxtFieldSvc: UITextField!
    @IBOutlet weak var lbl_tax: UILabel!
    @IBOutlet weak var lbl_svc: UILabel!
    @IBOutlet weak var lbl_Total: UILabel!
    @IBOutlet weak var mStackView_Money: UIStackView!   //금액 입력 스택뷰
    @IBOutlet weak var StackView_Txf: UIStackView!  //비과세 입력 스택뷰
    @IBOutlet weak var StackView_Svc: UIStackView!  //봉사료 입력 스텍뷰
    
    @IBOutlet var mCashSegTarget: UISegmentedControl!       //현금영수증: 개인 or 사업자 or 자진발급
//    @IBOutlet weak var mCashMentMenu: UISegmentedControl!       //결제 or 취소 or 거래고유키취소
//    @IBOutlet weak var mCashCancelMenu: UISegmentedControl!     //일반취소 or 오류발급취소 or 기타취소
    @IBOutlet var mCashTextFieldNumber: UITextField!        //사업자번호 또는 전화번호 입력란
    @IBOutlet var InputNumberGroup: UIStackView!            //사업자번호 또는 전화번호 입력란
    @IBOutlet var mCashBtnOK: UIButton!
    
    @IBOutlet weak var mMsrCheckGroup: UIStackView!         //현금영수증 체크박스 스택뷰
    @IBOutlet var mCashMsrCheckBox: UISwitch!               //현금영수증: 번호입력인지 카드인지 체크
    
    @IBOutlet weak var mMultiStoreUse: UISwitch!    //복수가맹점 사용여부 isOn = 사용. 아니면 사용안하고 대표가맹점TID로 진행
    
    
    var mCanCelInfo:String = "" //취소정보  취소구분(1) + 원거래일자(6) + 원승인번호(12)
    var mCancelReason:String = "" //취소사유    '1' : 거래취소, '2' : 오류발급, '3' : 기타
    
    let mCashTargetArray = [ "개인","사업자","자진발급" ]
    
    var isTouch = "Money"   //금액입력, 비과세입력, 봉사료입력 중 하나
    @IBOutlet weak var numberPad: NumberPad!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
        initRes()
    }
    
    func initRes()
    {
        //네비게이션 바의 배경색 rgb 변경
        UISetting.navigationTitleSetting(navigationBar: navigationController?.navigationBar ?? UINavigationBar())

        mCashTxtFieldTaxFree.placeholder = "금액을 입력해주세요"
//        mCashTxtFieldTaxFree.text = ""
        
//        mCashTxtFieldMoney.keyboardType = .numberPad
//        mCashTextFieldNumber.keyboardType = .numberPad
//        mCashTxtFieldTaxFree.keyboardType = .numberPad
//        mCashTxtFieldSvc.keyboardType = .numberPad
        
        mCashTxtFieldSvc.textAlignment = .right
        mCashTxtFieldMoney.textAlignment = .right
        mCashTextFieldNumber.textAlignment = .right
        mCashTxtFieldTaxFree.textAlignment = .right
//        TxtFieldUnderLineType()
        
        mCashTxtFieldMoney.delegate = self
        mCashTextFieldNumber.delegate = self
        mCashTxtFieldTaxFree.delegate = self
        
        mCashTextFieldNumber.text = ""  //항상 번호 입력란은 초기화 한다.
        
        numberPad.delegate = self
        numberPad.emptyKeyBackgroundColor = .clear
        
        paylistener = payResult()
        paylistener?.delegate = self
      
        if mTaxCalc.mApplySvc != TaxCalculator.TAXParameter.Use {
            StackView_Svc.isHidden = true
            StackView_Svc.alpha = 0.0

        }else{
            StackView_Svc.isHidden = false
            StackView_Svc.alpha = 1.0
            
            if mTaxCalc.mSvcMethod == TaxCalculator.TAXParameter.Auto {
                mCashTxtFieldSvc.isHidden = true
                mCashTxtFieldSvc.alpha = 0.0
                lbl_svc.isHidden = false
                lbl_svc.alpha = 1.0
            }
            else{
                mCashTxtFieldSvc.isHidden = false
                mCashTxtFieldSvc.alpha = 1.0
                lbl_svc.isHidden = true
                lbl_svc.alpha = 0.0
                isTouch = "Svc"
                mCashTxtFieldSvc.backgroundColor = .white
                mCashTxtFieldTaxFree.backgroundColor = define.grey
                mCashTxtFieldMoney.backgroundColor = define.grey
                mCashTextFieldNumber.backgroundColor = define.grey
            }
        }
        //만약에 부가세 방법이 자동인 경우에는 비과세 입력 필드를 표시 하지 않는다.
        if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use && mTaxCalc.mVatMethod == TaxCalculator.TAXParameter.Auto {
            StackView_Txf.isHidden = true
            StackView_Txf.alpha = 0.0
        }
        else{
            StackView_Txf.isHidden = false
            StackView_Txf.alpha = 1.0
            isTouch = "Txf"
            mCashTxtFieldTaxFree.backgroundColor = .white
            mCashTxtFieldSvc.backgroundColor = define.grey
            mCashTxtFieldMoney.backgroundColor = define.grey
            mCashTextFieldNumber.backgroundColor = define.grey
        }
        //부가세 미설정시 금액 입력이 보이지 않게 처리 한다. 비과세만 입력가능 2021-07-21 kim.jy
        if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use {
            mStackView_Money.isHidden = true
            mStackView_Money.alpha = 0.0
        }else{
            mStackView_Money.isHidden = false
            mStackView_Money.alpha = 1.0
            isTouch = "Money"
            mCashTxtFieldMoney.backgroundColor = .white
            mCashTxtFieldSvc.backgroundColor = define.grey
            mCashTxtFieldTaxFree.backgroundColor = define.grey
            mCashTextFieldNumber.backgroundColor = define.grey
        }
    }
    
    @IBAction func clicked_money(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Money"
        mCashTxtFieldMoney.backgroundColor = .white
        mCashTxtFieldSvc.backgroundColor = define.grey
        mCashTxtFieldTaxFree.backgroundColor = define.grey
        mCashTextFieldNumber.backgroundColor = define.grey
        sender.resignFirstResponder()
    }
    
    @IBAction func clicked_txf(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Txf"
        mCashTxtFieldTaxFree.backgroundColor = .white
        mCashTxtFieldSvc.backgroundColor = define.grey
        mCashTxtFieldMoney.backgroundColor = define.grey
        mCashTextFieldNumber.backgroundColor = define.grey
        sender.resignFirstResponder()
    }
    
    @IBAction func clicked_svc(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Svc"
        mCashTxtFieldSvc.backgroundColor = .white
        mCashTxtFieldTaxFree.backgroundColor = define.grey
        mCashTxtFieldMoney.backgroundColor = define.grey
        mCashTextFieldNumber.backgroundColor = define.grey
        sender.resignFirstResponder()
    }
    
    @IBAction func clicked_number(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Number"
        mCashTextFieldNumber.backgroundColor = .white
        mCashTxtFieldTaxFree.backgroundColor = define.grey
        mCashTxtFieldMoney.backgroundColor = define.grey
        mCashTxtFieldSvc.backgroundColor = define.grey
        sender.resignFirstResponder()
    }
    
    
    /// 금액텍스트필드 값 변경시 호출 되는 함수
    /// - Parameter textField: mCashTxtFieldMoney
    func CashTextFieldDidChange(_ textField: UITextField) {
        let cash:Int = Int(mCashTxtFieldMoney.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        var _taxFree:String = mCashTxtFieldTaxFree.text!.replacingOccurrences(of: ",", with: "")
        mTxfMoney = Int(mCashTxtFieldTaxFree.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        
        //봉사료가 수동 입력인 경우에 입력값 처리
        var serviceCharge:Int = 0
        if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use && mTaxCalc.mSvcMethod == TaxCalculator.TAXParameter.Manual {
            serviceCharge = Int(mCashTxtFieldSvc.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        }
        //2021-07-21 kim.jy 부가세 사용의 경우 금액이 10원 이하면 리턴
//        if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
//            if (cash + txf) < 10 {
//                return
//            }
//        }else{
//            if txf < 10 {return}
//        }
        
        //if cash < 10 { return } //입력 금액이 10원 보다 적은 경우
        
        textField.text = Utils.PrintMoney(Money: textField.text!.replacingOccurrences(of: ",", with: ""))
        let tax:[String:Int] = mTaxCalc.TaxCalc(금액: cash,비과세금액: mTxfMoney, 봉사료: serviceCharge, BleUse: mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED ? false:true )
        mMoney = tax["Money"]!
        mTaxMoney = tax["VAT"]!
        mSvcMoney = tax["SVC"]!
        mTxfMoney = tax["TXF"]!
        
   
       
       
        
       
        mTotalMoney = mMoney + mTaxMoney + mSvcMoney
        lbl_Total.text = Utils.PrintMoney(Money: "\(mTotalMoney)")
        if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
            mTotalMoney = mMoney + mTaxMoney + mSvcMoney + mTxfMoney
            lbl_Total.text = Utils.PrintMoney(Money: "\(mTotalMoney)")
        }
        mCashTxtMoney.text = Utils.PrintMoney(Money: "\(mMoney)")
        lbl_Total.text = Utils.PrintMoney(Money: "\(mTotalMoney)")
        lbl_tax.text = Utils.PrintMoney(Money: "\(mTaxMoney)")
        lbl_svc.text = Utils.PrintMoney(Money: "\(mSvcMoney)")
        if mTxfMoney == 0 && _taxFree.isEmpty {
            mCashTxtFieldTaxFree.text = ""
        } else {
            mCashTxtFieldTaxFree.text = Utils.PrintMoney(Money: "\(mTxfMoney)")
        }
//        mCashTxtFieldTaxFree.text = Utils.PrintMoney(Money: "\(mTxfMoney)")
        
        /** 화면상에 표시되는 공급가액 금액을 CAT 처럼 맞추기 위해 일부러 한번 더 한다 */
        let tax2:[String:Int] = mTaxCalc.TaxCalc(금액: cash,비과세금액: mTxfMoney, 봉사료: serviceCharge, BleUse: false )
        mCashTxtMoney.text = Utils.PrintMoney(Money: "\(tax2["Money"]!)")
        
    }
    @objc func dismissMyKeyboard(){
           view.endEditing(true)
       }
    
    @IBAction func UseCard(_ sender: UISwitch) {
        
        //번호 입력 텍스트 박스 숨기기
        if sender.isOn {
            InputNumberGroup.isHidden = true
            InputNumberGroup.alpha = 0.0
        }
        else
        {
            InputNumberGroup.isHidden = false
            InputNumberGroup.alpha = 1.0
            
        }
    }
    /**
     현금영수증 발행 대상을 바꾸는 UISegmentedControl 컨트롤을 사용시
     */
    @IBAction func TargetSelected(_ sender: UISegmentedControl) {
        mCashReciptTarget = sender.selectedSegmentIndex
        //현금 영수증 발행 대상을 바꾸는 경우에
        mCashTextFieldNumber.text = ""
        if sender.selectedSegmentIndex == 2 {
            //자진발급일 경우
//            mCashMsrCheckBox.setOn(false, animated: false)
            mMsrCheckGroup.isHidden = true
            mMsrCheckGroup.alpha = 0.0
            InputNumberGroup.isHidden = true
            InputNumberGroup.alpha = 0.0
        } else {
            mMsrCheckGroup.isHidden = false
            mMsrCheckGroup.alpha = 1.0
            if !mCashMsrCheckBox.isOn {
                InputNumberGroup.isHidden = false
                InputNumberGroup.alpha = 1.0
            }
            
        }
    }

    @IBAction func CashBtn_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        //에러 상황에 대한 처리 
        if !checkMoneyValue() {
            return
        }
        
        //만일 복수가맹점TID 사용으로 되어있다면
        var _tid:String = Setting.shared.getDefaultUserData(_key: define.STORE_TID)

        //봉사료가 수동 입력인 경우에 입력값 처리
        mTxfMoney = Int((mCashTxtFieldTaxFree.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
        let money:Int = Int((mCashTxtFieldMoney.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
        var serviceCharge:Int = 0
        if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use && mTaxCalc.mSvcMethod == TaxCalculator.TAXParameter.Manual {
            serviceCharge = Int(mCashTxtFieldSvc.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        }
        let tax:[String:Int] = mTaxCalc.TaxCalc(금액: money,비과세금액: mTxfMoney, 봉사료: serviceCharge, BleUse: mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED ? false:true )
        mMoney = tax["Money"]!
        mTaxMoney = tax["VAT"]!
        mSvcMoney = tax["SVC"]!
        mTxfMoney = tax["TXF"]!
        
        mpaySdk.Clear()
        mpaySdk = PaySdk.instance
        mCatSdk.Clear()
        mCatSdk = CatSdk.instance
        paylistener = payResult()
        paylistener?.delegate = self
        catlistener = CatResult()
        catlistener?.delegate = self

        //취소사유    '1' : 거래취소, '2' : 오류발급, '3' : 기타
        //현금영수증 MSR이 아닌 경우에 번호 입력란에 입력 여부를 확인 한다.
        if !mCashMsrCheckBox.isOn {
            if mCashReciptTarget == Target.Person.rawValue {
                if mCashTextFieldNumber.text!.count > 13 {
                    AlertBox(title: "에러", message: "고객번호를 확인해 주세요", text: "확인" )
                    return
                }
                if KocesSdk.instance.bleState != define.TargetDeviceState.CATCONNECTED {
                    if mCashTextFieldNumber.text!.count == 0 {
                        AlertBox(title: "에러", message: "고객번호를 입력해 주세요", text: "확인" )
                        return
                    }
                }
            }else if mCashReciptTarget == Target.Business.rawValue {
                if mCashTextFieldNumber.text!.count > 13 {
                    AlertBox(title: "에러", message: "고객번호를 확인해 주세요", text: "확인" )
                    return
                }
                if KocesSdk.instance.bleState != define.TargetDeviceState.CATCONNECTED {
                    if mCashTextFieldNumber.text!.count == 0 {
                        AlertBox(title: "에러", message: "고객번호를 입력해 주세요", text: "확인" )
                        return
                    }
                }
            }else{  //자진 발급의 경우에 대한 처리 필요
                //만일 현금영수증 자진발급(3)일 경우 자진발급번호로 즉시 거래를 진행한다.결제방법을 카드리더기 선택이거나 입력된 번호가 있더라도 모두 무시하고
                  //자진발급번호(고객번호) "0100001234" 로 진행한다. 신분확인번호(CashNum)"0100001234" 입력방법(KeyYn)"K" 개인/법인(InsYn) 구분:3
                mCashTextFieldNumber.text = "0100001234"
            }

//            if mInputMoney < 10 { return } //입력 금액이 10원 보다 적은 경우
            
            mCancelReason = ""
            
            //cat ble 분기처리. 다이렉트로 서버로 보내느냐 cat 으로 보내느냐이기때문에 ble 연결과는 상관없다
            if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    AlertBox(title: "에러", message: Utils.CheckCatPortIP(), text: "확인" )
                    return
                }
                catlistener = CatResult()
                catlistener?.delegate = self
                if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                    TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](BSN,TID,NUM,PHONE,OWNER,ADDR) in
                        if TID == "" {
                            AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                            return
                        }
                        _tid = TID
                        let Number:String = mCashTextFieldNumber.text ?? ""
                        mCatSdk.CashRecipt(TID: _tid, 거래금액: String(mMoney), 세금: String(mTaxMoney), 봉사료: String(mSvcMoney), 비과세: String(mTxfMoney), 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: "", 고객번호: Number, 개인법인구분: String(mCashReciptTarget+1), 취소: false, 최소사유: "", 가맹점데이터: "", 여유필드: "", StoreName: BSN,StoreAddr: ADDR,StoreNumber: NUM,StorePhone: PHONE,StoreOwner: OWNER,CompletionCallback: catlistener?.delegate as! CatResultDelegate)
                    }
                    return
                }
                //여기에 캣으로 보낼전문 구성
                //2020-05-26 tlswlsdn 위에 보면 다이렉트로 서버요청을 하는(번호입력부분), msr 읽는 부분 두군데에 넣으면 됩니다
                let Number:String = mCashTextFieldNumber.text ?? ""
                mCatSdk.CashRecipt(TID: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID), 거래금액: String(mMoney), 세금: String(mTaxMoney), 봉사료: String(mSvcMoney), 비과세: String(mTxfMoney), 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: "", 고객번호: Number, 개인법인구분: String(mCashReciptTarget+1), 취소: false, 최소사유: "", 가맹점데이터: "", 여유필드: "", StoreName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME), StoreAddr: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR), StoreNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN), StorePhone: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE), StoreOwner: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER),CompletionCallback: catlistener?.delegate as! CatResultDelegate)

            } else {
//                if mMultiStoreUse.isOn {
                if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                    TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](BSN,TID,NUM,PHONE,OWNER,ADDR) in
                        if TID == "" {
                            AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                            return
                        }
                        _tid = TID
                        mpaySdk.CashReciptDirectInput(CancelReason: mCancelReason, Tid: _tid, AuDate: "", AuNo: "", Num: mCashTextFieldNumber.text!, Command: Command.CMD_CASH_RECEIPT_REQ, MchData: "", TrdAmt: String(mMoney), TaxAmt: String(mTaxMoney), SvcAmt: String(mSvcMoney), TaxFreeAmt: String(mTxfMoney), InsYn: String(mCashReciptTarget+1), kocesNumber: "", payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: BSN,StoreAddr: ADDR,StoreNumber: NUM,StorePhone: PHONE,StoreOwner: OWNER)
                    }
                    return
                }
                mpaySdk.CashReciptDirectInput(CancelReason: mCancelReason, Tid: _tid, AuDate: "", AuNo: "", Num: mCashTextFieldNumber.text!, Command: Command.CMD_CASH_RECEIPT_REQ, MchData: "", TrdAmt: String(mMoney), TaxAmt: String(mTaxMoney), SvcAmt: String(mSvcMoney), TaxFreeAmt: String(mTxfMoney), InsYn: String(mCashReciptTarget+1), kocesNumber: "", payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
            }

        }
        else  //Msr을 읽어서 처리 하는 부분
        {
            //리더기를 읽어야 하니 리더기가 설정되어 있는지를 확인한다
            if !CheckBle() {
                return
            }
            mCashTextFieldNumber.text = ""  //번호 입력 초기화
            //BLE에 MSR 요청
       
            mCancelReason = ""
            
            //cat ble 분기처리
            if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
//                if mMultiStoreUse.isOn {
                if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                    TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](BSN,TID,NUM,PHONE,OWNER,ADDR) in
                        if TID == "" {
                            AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                            return
                        }
                        _tid = TID
                        mpaySdk.CashRecipt(Tid: _tid, Money: String(mMoney), Tax: mTaxMoney, ServiceCharge: mSvcMoney, TaxFree: mTxfMoney, PrivateOrBusiness: mCashReciptTarget+1, ReciptIndex: "0000", CancelInfo: "", OriDate: "", InputMethod: "", CancelReason: mCancelReason, ptCardCode: "", ptAcceptNum: "", BusinessData: "", Bangi: "", KocesTradeUnique: "",payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: BSN,StoreAddr: ADDR,StoreNumber: NUM,StorePhone: PHONE,StoreOwner: OWNER)
                    }
                    return
                }
                mpaySdk.CashRecipt(Tid: _tid, Money: String(mMoney), Tax: mTaxMoney, ServiceCharge: mSvcMoney, TaxFree: mTxfMoney, PrivateOrBusiness: mCashReciptTarget+1, ReciptIndex: "0000", CancelInfo: "", OriDate: "", InputMethod: "", CancelReason: mCancelReason, ptCardCode: "", ptAcceptNum: "", BusinessData: "", Bangi: "", KocesTradeUnique: "",payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
            } else if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                if Utils.CheckCatPortIP() != "" {
                    AlertBox(title: "에러", message: Utils.CheckCatPortIP(), text: "확인" )
                    return
                }
                catlistener = CatResult()
                catlistener?.delegate = self
                //여기에 캣으로 보낼전문 구성
                //2020-05-26 tlswlsdn 위에 보면 다이렉트로 서버요청을 하는(번호입력부분), msr 읽는 부분 두군데에 넣으면 됩니다
                let Number:String = mCashTextFieldNumber.text ?? ""

                mCatSdk.CashRecipt(TID: _tid, 거래금액: String(mMoney), 세금: String(mTaxMoney), 봉사료: String(mSvcMoney), 비과세: String(mTxfMoney), 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: "", 고객번호: Number, 개인법인구분: String(mCashReciptTarget+1), 취소: false, 최소사유: "", 가맹점데이터: "", 여유필드: "", StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME), StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR), StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN), StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE), StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER),CompletionCallback: catlistener?.delegate as! CatResultDelegate)
                
            } else {
                AlertBox(title: "에러", message: "연결 가능한 단말기가 존재하지 않습니다", text: "확인" )
            }

        }
    }
    

    /**
     금액 설정해서 체크 해야 할게 많아서 금액만 가져오는 부분 따로 처리
     */
    func getMoney(){
        mInputMoney = Int(mCashTxtFieldMoney.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        mTxfMoney = Int(mCashTxtFieldTaxFree.text!.replacingOccurrences(of: ",", with: "")) ?? 0
    }
    
    /**
     금액설정이 정상적인지를 체크한다
     */
    func checkMoneyValue() -> Bool {
        getMoney()
        
        if mTxfMoney < 0 {      //악의적으로 - 를 넣은 경우
            AlertBox(title: "에러", message: "비과세금액에 마이너스 입력 불가", text: "확인" )
            return false
        }
                
        if mInputMoney < 0 {
            AlertBox(title: "에러", message: "결제 금액에 마이너스 입력 불가", text: "확인" )
            return false
        }

//        if (mInputMoney - mTxfMoney) < 0 {
//            AlertBox(title: "에러", message: "비과세 금액이 원금을 초과 합니다", text: "확인" )
//            return false
//        }
        if (mTotalMoney + mTxfMoney) < 10 {
            AlertBox(title: "에러", message: mKocesSdk.getStringPlist(Key: "err_main_input_value_less_than_0"), text: "확인" )
            return false
        }
        //jiw 추가. 세금, 봉사료의 합이 원금을 넘을 수 없다
//        if (mInputMoney - mTaxMoney - mSvcMoney) < 0 && mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
//            AlertBox(title: "에러", message: "세금및 봉사료가 원금을 초과 합니다", text: "확인" )
//            return false
//        }
        //2020-07-21 kim.jy 부가세 사용, 부가세 방법이 오토의 경우 결제 금액이 10 이하의 경우 에러 발생
        if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use && mTaxCalc.mVatMethod == TaxCalculator.TAXParameter.Auto {
            if mTotalMoney < 10 {
                AlertBox(title: "에러", message: "금액은 10원 이상 입금 해야 합니다.", text: "확인" )
                return false
            }
        }
        return true
    }
    
    func CheckBle() -> Bool {
        //ble 연결되어있지 않다면 들어가는 것을 막는다
        if KocesSdk.instance.bleState == define.TargetDeviceState.BLENOCONNECT {
            AlertBox(title: "에러", message: "BLE 디바이스가 연결 되지 않았습니다 환경설정에서 장치를 검색하십시오", text: "확인" )
            return false
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
            if KocesSdk.instance.mVerityCheck != define.VerityMethod.Success.rawValue{
                AlertBox(title: "에러", message: "리더기 무결성 검증이 정상 완료하지 않았습니다.", text: "확인" )
                return false
            }
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            if Utils.CheckCatPortIP() != "" {
                AlertBox(title: "에러", message: Utils.CheckCatPortIP(), text: "확인" )
                return false
            }
        }
        return true
    }

    
    func AlertBox(title : String, message : String, text : String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
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

extension CashController: PayResultDelegate,CatResultDelegate {
    func onResult(CatState _state: payStatus, Result _message: Dictionary<String, String>) {
        // cat애니메이션뷰 컨트롤러가 여전히 떠있으니 해당 뷰를 지운다
        Utils.CatAnimationViewInitClear()
        // 0=성공, 1=실패
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            if _state == .OK {
                let alertController = UIAlertController(title: "[CAT현금거래]", message: "거래가 정상적으로 완료되었습니다", preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
                    self.tabBarController?.delegate = self
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                var _msg = _message["Message"] ?? _message["ERROR"] ?? "거래실패"
                if _msg.replacingOccurrences(of: " ", with: "") == "" {
                    _msg = "응답 데이터 이상"
                }
                let alertController = UIAlertController(title: "[CAT현금거래]", message: _msg, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
                    self.tabBarController?.delegate = self
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
  
    func onPaymentResult(payTitle _status: payStatus, payResult _message: Dictionary<String, String>) {
        // 카드애니메이션뷰 컨트롤러가 여전히 떠있으니 해당 뷰를 지운다
        Utils.CardAnimationViewControllerClear()
        
        var _totalString:String = ""
        var keyCount:Int = 0
        switch _message["TrdType"] {
        case Command.CMD_CASH_RECEIPT_RES:
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
        case Command.CMD_CASH_RECEIPT_CANCEL_RES:
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
//                Utils.customAlertBoxInit(Title: "현금거래", Message: _totalString, LoadingBar: false, GetButton: "확인")
            let controller = UIHostingController(rootView: ReceiptSwiftUI())
            controller.rootView.setData(영수증데이터: sqlite.instance.getTradeLastData(), 뷰컨트롤러: "현금", 전표번호: String(sqlite.instance.getTradeList().count))
            navigationController?.pushViewController(controller, animated: true)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ [self] in
                var _msg = _message["Message"] ?? _message["ERROR"] ?? "거래실패"
                if _msg.replacingOccurrences(of: " ", with: "") == "" {
                    _msg = "응답 데이터 이상"
                }
                let alertController = UIAlertController(title: "[현금거래]", message: _msg, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
                    //                self.navigationController?.popViewController(animated: false)
                    self.tabBarController?.delegate = self
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }
//            Utils.customAlertBoxInit(Title: "현금거래", Message: _message["Message"] ?? _message["ERROR"] ?? "거래실패", LoadingBar: false, GetButton: "확인")
        }
    }
    
    /**
     금액 입력 후 다음 입력이 있는지 처리
     isNext = true ok버튼누름. 다음 입력할 거 찾아야서 isMoney="" 값을 넣어야함.
     isNext = false 일 경우에는 이전 입력할 거 찾아서 isMoney="" 값을 넣어야함.
     위 두개의 다른점은 다음 찾을 거의 우선순위임
     */
    func TxtUpdate(IsNext isNext:Bool) {
        if isNext {
            //부가세 미설정시 금액 입력이 보이지 않게 처리 한다. 비과세만 입력가능 2021-07-21 kim.jy
            if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                //금액입력을 사용
                if (mCashTxtFieldMoney.text!.isEmpty) {
                    //만일 텍스트가 비어있다면?
                    isTouch = "Money"
                    mCashTextFieldNumber.backgroundColor = define.grey
                    mCashTxtFieldSvc.backgroundColor = define.grey
                    mCashTxtFieldTaxFree.backgroundColor = define.grey
                    mCashTxtFieldMoney.backgroundColor = .white
                    return
                }
            }
            //만약에 부가세 방법이 자동인 경우에는 비과세 입력 필드를 표시 하지 않는다.
            if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use || mTaxCalc.mVatMethod != TaxCalculator.TAXParameter.Auto {
                //비과세을 사용
                if (mCashTxtFieldTaxFree.text!.isEmpty) {
                    //만일 텍스트가 비어있다면?
                    isTouch = "Txf"
                    mCashTextFieldNumber.backgroundColor = define.grey
                    mCashTxtFieldSvc.backgroundColor = define.grey
                    mCashTxtFieldTaxFree.backgroundColor = .white
                    mCashTxtFieldMoney.backgroundColor = define.grey
                    return
                }
            }

            if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use {
                //봉사료을 사용
                
                if mTaxCalc.mSvcMethod != TaxCalculator.TAXParameter.Auto {
                    //봉사료 수동 입력의 경우
                    if (mCashTxtFieldSvc.text!.isEmpty) {
                        //만일 텍스트가 비어있다면?
                        isTouch = "Svc"
                        mCashTextFieldNumber.backgroundColor = define.grey
                        mCashTxtFieldSvc.backgroundColor = .white
                        mCashTxtFieldTaxFree.backgroundColor = define.grey
                        mCashTxtFieldMoney.backgroundColor = define.grey
                        return
                    }
                }

            }
            
            if !InputNumberGroup.isHidden {
                isTouch = "Number"
                mCashTextFieldNumber.backgroundColor = .white
                mCashTxtFieldSvc.backgroundColor = define.grey
                mCashTxtFieldTaxFree.backgroundColor = define.grey
                mCashTxtFieldMoney.backgroundColor = define.grey
                return
            }

        } else {
            //부가세 미설정시 금액 입력이 보이지 않게 처리 한다. 비과세만 입력가능 2021-07-21 kim.jy
            if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                //금액입력을 사용
                if (mCashTxtFieldMoney.text!.isEmpty) {
                    //만일 텍스트가 비어있다면?
                    isTouch = "Money"
                    mCashTextFieldNumber.backgroundColor = define.grey
                    mCashTxtFieldSvc.backgroundColor = define.grey
                    mCashTxtFieldTaxFree.backgroundColor = define.grey
                    mCashTxtFieldMoney.backgroundColor = .white
                    return
                }
            }
            
            //만약에 부가세 방법이 자동인 경우에는 비과세 입력 필드를 표시 하지 않는다.
            if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use || mTaxCalc.mVatMethod != TaxCalculator.TAXParameter.Auto {
                //비과세을 사용
                if (mCashTxtFieldTaxFree.text!.isEmpty) {
                    //만일 텍스트가 비어있다면?
                    if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                        //금액입력을 사용
                        isTouch = "Money"
                        mCashTextFieldNumber.backgroundColor = define.grey
                        mCashTxtFieldSvc.backgroundColor = define.grey
                        mCashTxtFieldTaxFree.backgroundColor = define.grey
                        mCashTxtFieldMoney.backgroundColor = .white
                        return
                    }
                    isTouch = "Txf"
                    mCashTextFieldNumber.backgroundColor = define.grey
                    mCashTxtFieldSvc.backgroundColor = define.grey
                    mCashTxtFieldTaxFree.backgroundColor = .white
                    mCashTxtFieldMoney.backgroundColor = define.grey
                    return
                }
            }

            if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use {
                //봉사료을 사용
                
                if mTaxCalc.mSvcMethod != TaxCalculator.TAXParameter.Auto {
                    //봉사료 수동 입력의 경우
                    if (mCashTxtFieldSvc.text!.isEmpty) {
                        //만일 텍스트가 비어있다면?
                        if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use || mTaxCalc.mVatMethod != TaxCalculator.TAXParameter.Auto {
                            //만일 텍스트가 비어있다면?
                            isTouch = "Txf"
                            mCashTextFieldNumber.backgroundColor = define.grey
                            mCashTxtFieldSvc.backgroundColor = define.grey
                            mCashTxtFieldTaxFree.backgroundColor = .white
                            mCashTxtFieldMoney.backgroundColor = define.grey
                            return
                        }
                        
                        if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                            isTouch = "Money"
                            mCashTextFieldNumber.backgroundColor = define.grey
                            mCashTxtFieldSvc.backgroundColor = define.grey
                            mCashTxtFieldTaxFree.backgroundColor = define.grey
                            mCashTxtFieldMoney.backgroundColor = .white
                            return
                        }
                        isTouch = "Svc"
                        mCashTextFieldNumber.backgroundColor = define.grey
                        mCashTxtFieldSvc.backgroundColor = .white
                        mCashTxtFieldTaxFree.backgroundColor = define.grey
                        mCashTxtFieldMoney.backgroundColor = define.grey
                        return
                    }
                }

            }
            
            
            if isTouch == "Number" {
                
                if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use {
                    //봉사료을 사용
                    
                    if mTaxCalc.mSvcMethod != TaxCalculator.TAXParameter.Auto {
                        //봉사료 수동 입력의 경우
                        isTouch = "Svc"
                        mCashTextFieldNumber.backgroundColor = define.grey
                        mCashTxtFieldSvc.backgroundColor = .white
                        mCashTxtFieldTaxFree.backgroundColor = define.grey
                        mCashTxtFieldMoney.backgroundColor = define.grey
                        return
                    }

                }
                
                //만약에 부가세 방법이 자동인 경우에는 비과세 입력 필드를 표시 하지 않는다.
                if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use || mTaxCalc.mVatMethod != TaxCalculator.TAXParameter.Auto {
                    //비과세을 사용
                    isTouch = "Txf"
                    mCashTextFieldNumber.backgroundColor = define.grey
                    mCashTxtFieldSvc.backgroundColor = define.grey
                    mCashTxtFieldTaxFree.backgroundColor = .white
                    mCashTxtFieldMoney.backgroundColor = define.grey
                    return
                }
                
                if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                    //금액입력을 사용
                    isTouch = "Money"
                    mCashTextFieldNumber.backgroundColor = define.grey
                    mCashTxtFieldSvc.backgroundColor = define.grey
                    mCashTxtFieldTaxFree.backgroundColor = define.grey
                    mCashTxtFieldMoney.backgroundColor = .white
                    return
                }
                
                isTouch = "Number"
                mCashTextFieldNumber.backgroundColor = .white
                mCashTxtFieldSvc.backgroundColor = define.grey
                mCashTxtFieldTaxFree.backgroundColor = define.grey
                mCashTxtFieldMoney.backgroundColor = define.grey
                return
            }

        }
       
        isTouch = ""

    }
    
    
}

extension CashController: UITextFieldDelegate , UITabBarControllerDelegate{
    //탭바로 다른 탭 이동시 네비게이션은 초기로 이동한다
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
        }
    /**
     글자수 제한을 위한 함수
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength:Int = CharMaxLength
        switch textField {
        case mCashTxtFieldMoney:
            maxLength = CharMaxLength
        case mCashTxtFieldTaxFree:
            maxLength = CharMaxLength
        case mCashTextFieldNumber:
            if mCashReciptTarget == Target.Person.rawValue { //개인의 경우
                CharMaxLength = 13
            }
            else if mCashReciptTarget == Target.Business.rawValue {    //사업자의 경우
                CharMaxLength = 13
            }else{  //자진발급의 넣어야 할 코드 차후에 추가
                mCashTextFieldNumber.text = "0100001234"
            }
            maxLength = CharMaxLength
        default:
            break
        }
        let newLength = (textField.text?.count)! + string.count - range.length
                return !(newLength > maxLength)
    }
}

extension CashController : NumberPadDelegate {
    func keyPressed(key: NumberKey?) {
        guard let number = key else {
            return
        }

        switch number {
        case .delete:
            switch isTouch {
            case "Money":
                guard !(mCashTxtFieldMoney.text?.isEmpty ?? true) else {
                    mCashTxtFieldMoney.text = ""
                    TxtUpdate(IsNext: false)
                    return
                }
                mCashTxtFieldMoney.text?.removeLast()
                if mCashTxtFieldMoney.text!.isEmpty {
                    TxtUpdate(IsNext: false)
                }
                CashTextFieldDidChange(mCashTxtFieldMoney)
                break
            case "Txf":
                guard !(mCashTxtFieldTaxFree.text?.isEmpty ?? true) else {
                    mCashTxtFieldTaxFree.text = ""
                    TxtUpdate(IsNext: false)
                    return
                }
                mCashTxtFieldTaxFree.text?.removeLast()
                if mCashTxtFieldTaxFree.text!.isEmpty {
                    TxtUpdate(IsNext: false)
                }
                CashTextFieldDidChange(mCashTxtFieldTaxFree)
                break
            case "Svc":
                guard !(mCashTxtFieldSvc.text?.isEmpty ?? true) else {
                    mCashTxtFieldSvc.text = ""
                    TxtUpdate(IsNext: false)
                    return
                }
                mCashTxtFieldSvc.text?.removeLast()
                if mCashTxtFieldSvc.text!.isEmpty {
                    TxtUpdate(IsNext: false)
                }
                CashTextFieldDidChange(mCashTxtFieldSvc)
                break
            case "Number":
                guard !(mCashTextFieldNumber.text?.isEmpty ?? true) else {
                    mCashTextFieldNumber.text = ""
                    TxtUpdate(IsNext: false)
                    return
                }
                mCashTextFieldNumber.text?.removeLast()
                if mCashTextFieldNumber.text!.isEmpty {
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
            case "Txf":
                break
            case "Svc":
                break
            case "Number":
                break
            default:
                break
            }
            let alert = UIAlertController(title: "Custom NumberPad Event",
                                          message: "\(mCashTxtFieldMoney.text ?? "") Send Number", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .clear:
            switch isTouch {
            case "Money":
                guard !(mCashTxtFieldMoney.text?.isEmpty ?? true) else {
                    return
                }
                mCashTxtFieldMoney.text = ""
                TxtUpdate(IsNext: false)
                CashTextFieldDidChange(mCashTxtFieldMoney)
                return
            case "Txf":
                guard !(mCashTxtFieldTaxFree.text?.isEmpty ?? true) else {
                    return
                }
                mCashTxtFieldTaxFree.text = ""
                TxtUpdate(IsNext: false)
                CashTextFieldDidChange(mCashTxtFieldTaxFree)
                return
            case "Svc":
                guard !(mCashTxtFieldSvc.text?.isEmpty ?? true) else {
                    return
                }
                mCashTxtFieldSvc.text = ""
                TxtUpdate(IsNext: false)
                CashTextFieldDidChange(mCashTxtFieldSvc)
                return
            case "Number":
                guard !(mCashTextFieldNumber.text?.isEmpty ?? true) else {
                    return
                }
                mCashTextFieldNumber.text = ""
                TxtUpdate(IsNext: false)
                return
            default:
                break
            }
  
            break
        case .key00:
            switch isTouch {
            case "Money":
                mCashTxtFieldMoney.text?.append("00")
                break
            case "Txf":
                mCashTxtFieldTaxFree.text?.append("00")
                break
            case "Svc":
                mCashTxtFieldSvc.text?.append("00")
                break
            case "Number":
                mCashTextFieldNumber.text?.append("00")
                break
            default:
                break
            }
  
            break
        case .key010:
            switch isTouch {
            case "Money":
                mCashTxtFieldMoney.text?.append("010")
                break
            case "Txf":
                mCashTxtFieldTaxFree.text?.append("010")
                break
            case "Svc":
                mCashTxtFieldSvc.text?.append("010")
                break
            case "Number":
                mCashTextFieldNumber.text?.append("010")
                break
            default:
                break
            }
   
            break
        case .keyok:
            //에러 상황에 대한 처리
            if !checkMoneyValue() {
                return
            }
            
            switch isTouch {
            case "Money":
                TxtUpdate(IsNext: true)
                break
            case "Txf":
                TxtUpdate(IsNext: true)
                break
            case "Svc":
                TxtUpdate(IsNext: true)
                break
            case "Number":
                TxtUpdate(IsNext: true)
                break
            default:
                break
            }
            
            if isTouch != "" {
                return
            }
            
            //에러 상황에 대한 처리
            if !checkMoneyValue() {
                return
            }
            
            //만일 복수가맹점TID 사용으로 되어있다면
            var _tid:String = Setting.shared.getDefaultUserData(_key: define.STORE_TID)

            //봉사료가 수동 입력인 경우에 입력값 처리
            mTxfMoney = Int((mCashTxtFieldTaxFree.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
            let money:Int = Int((mCashTxtFieldMoney.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
            var serviceCharge:Int = 0
            if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use && mTaxCalc.mSvcMethod == TaxCalculator.TAXParameter.Manual {
                serviceCharge = Int(mCashTxtFieldSvc.text!.replacingOccurrences(of: ",", with: "")) ?? 0
            }
            let tax:[String:Int] = mTaxCalc.TaxCalc(금액: money,비과세금액: mTxfMoney, 봉사료: serviceCharge, BleUse: mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED ? false:true )
            mMoney = tax["Money"]!
            mTaxMoney = tax["VAT"]!
            mSvcMoney = tax["SVC"]!
            mTxfMoney = tax["TXF"]!
            
            mpaySdk.Clear()
            mpaySdk = PaySdk.instance
            mCatSdk.Clear()
            mCatSdk = CatSdk.instance
            paylistener = payResult()
            paylistener?.delegate = self
            catlistener = CatResult()
            catlistener?.delegate = self

            //취소사유    '1' : 거래취소, '2' : 오류발급, '3' : 기타
            //현금영수증 MSR이 아닌 경우에 번호 입력란에 입력 여부를 확인 한다.
            if !mCashMsrCheckBox.isOn {
                if mCashReciptTarget == Target.Person.rawValue {
                    if mCashTextFieldNumber.text!.count > 13 {
                        AlertBox(title: "에러", message: "고객번호를 확인해 주세요", text: "확인" )
                        return
                    }
                    if KocesSdk.instance.bleState != define.TargetDeviceState.CATCONNECTED {
                        if mCashTextFieldNumber.text!.count == 0 {
                            AlertBox(title: "에러", message: "고객번호를 입력해 주세요", text: "확인" )
                            return
                        }
                    }
                }else if mCashReciptTarget == Target.Business.rawValue {
                    if mCashTextFieldNumber.text!.count > 13 {
                        AlertBox(title: "에러", message: "고객번호를 확인해 주세요", text: "확인" )
                        return
                    }
                    if KocesSdk.instance.bleState != define.TargetDeviceState.CATCONNECTED {
                        if mCashTextFieldNumber.text!.count == 0 {
                            AlertBox(title: "에러", message: "고객번호를 입력해 주세요", text: "확인" )
                            return
                        }
                    }
                }else{  //자진 발급의 경우에 대한 처리 필요
                    //만일 현금영수증 자진발급(3)일 경우 자진발급번호로 즉시 거래를 진행한다.결제방법을 카드리더기 선택이거나 입력된 번호가 있더라도 모두 무시하고
                      //자진발급번호(고객번호) "0100001234" 로 진행한다. 신분확인번호(CashNum)"0100001234" 입력방법(KeyYn)"K" 개인/법인(InsYn) 구분:3
                    mCashTextFieldNumber.text = "0100001234"
                }

    //            if mInputMoney < 10 { return } //입력 금액이 10원 보다 적은 경우
                
                mCancelReason = ""
                
                //cat ble 분기처리. 다이렉트로 서버로 보내느냐 cat 으로 보내느냐이기때문에 ble 연결과는 상관없다
                if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                    if Utils.CheckCatPortIP() != "" {
                        AlertBox(title: "에러", message: Utils.CheckCatPortIP(), text: "확인" )
                        return
                    }
                    catlistener = CatResult()
                    catlistener?.delegate = self
                    if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                        TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](BSN,TID,NUM,PHONE,OWNER,ADDR) in
                            if TID == "" {
                                AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                                return
                            }
                            _tid = TID
                            let Number:String = mCashTextFieldNumber.text ?? ""
                            mCatSdk.CashRecipt(TID: _tid, 거래금액: String(mMoney), 세금: String(mTaxMoney), 봉사료: String(mSvcMoney), 비과세: String(mTxfMoney), 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: "", 고객번호: Number, 개인법인구분: String(mCashReciptTarget+1), 취소: false, 최소사유: "", 가맹점데이터: "", 여유필드: "", StoreName: BSN,StoreAddr: ADDR,StoreNumber: NUM,StorePhone: PHONE,StoreOwner: OWNER,CompletionCallback: catlistener?.delegate as! CatResultDelegate)
                        }
                        return
                    }
                    //여기에 캣으로 보낼전문 구성
                    //2020-05-26 tlswlsdn 위에 보면 다이렉트로 서버요청을 하는(번호입력부분), msr 읽는 부분 두군데에 넣으면 됩니다
                    let Number:String = mCashTextFieldNumber.text ?? ""
                    mCatSdk.CashRecipt(TID: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID), 거래금액: String(mMoney), 세금: String(mTaxMoney), 봉사료: String(mSvcMoney), 비과세: String(mTxfMoney), 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: "", 고객번호: Number, 개인법인구분: String(mCashReciptTarget+1), 취소: false, 최소사유: "", 가맹점데이터: "", 여유필드: "", StoreName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME), StoreAddr: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR), StoreNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN), StorePhone: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE), StoreOwner: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER),CompletionCallback: catlistener?.delegate as! CatResultDelegate)

                } else {
    //                if mMultiStoreUse.isOn {
                    if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                        TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](BSN,TID,NUM,PHONE,OWNER,ADDR) in
                            if TID == "" {
                                AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                                return
                            }
                            _tid = TID
                            mpaySdk.CashReciptDirectInput(CancelReason: mCancelReason, Tid: _tid, AuDate: "", AuNo: "", Num: mCashTextFieldNumber.text!, Command: Command.CMD_CASH_RECEIPT_REQ, MchData: "", TrdAmt: String(mMoney), TaxAmt: String(mTaxMoney), SvcAmt: String(mSvcMoney), TaxFreeAmt: String(mTxfMoney), InsYn: String(mCashReciptTarget+1), kocesNumber: "", payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: BSN,StoreAddr: ADDR,StoreNumber: NUM,StorePhone: PHONE,StoreOwner: OWNER)
                        }
                        return
                    }
                    mpaySdk.CashReciptDirectInput(CancelReason: mCancelReason, Tid: _tid, AuDate: "", AuNo: "", Num: mCashTextFieldNumber.text!, Command: Command.CMD_CASH_RECEIPT_REQ, MchData: "", TrdAmt: String(mMoney), TaxAmt: String(mTaxMoney), SvcAmt: String(mSvcMoney), TaxFreeAmt: String(mTxfMoney), InsYn: String(mCashReciptTarget+1), kocesNumber: "", payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
                }

            }
            else  //Msr을 읽어서 처리 하는 부분
            {
                //리더기를 읽어야 하니 리더기가 설정되어 있는지를 확인한다
                if !CheckBle() {
                    return
                }
                mCashTextFieldNumber.text = ""  //번호 입력 초기화
                //BLE에 MSR 요청
           
                mCancelReason = ""
                
                //cat ble 분기처리
                if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
    //                if mMultiStoreUse.isOn {
                    if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                        TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](BSN,TID,NUM,PHONE,OWNER,ADDR) in
                            if TID == "" {
                                AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                                return
                            }
                            _tid = TID
                            mpaySdk.CashRecipt(Tid: _tid, Money: String(mMoney), Tax: mTaxMoney, ServiceCharge: mSvcMoney, TaxFree: mTxfMoney, PrivateOrBusiness: mCashReciptTarget+1, ReciptIndex: "0000", CancelInfo: "", OriDate: "", InputMethod: "", CancelReason: mCancelReason, ptCardCode: "", ptAcceptNum: "", BusinessData: "", Bangi: "", KocesTradeUnique: "",payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: BSN,StoreAddr: ADDR,StoreNumber: NUM,StorePhone: PHONE,StoreOwner: OWNER)
                        }
                        return
                    }
                    mpaySdk.CashRecipt(Tid: _tid, Money: String(mMoney), Tax: mTaxMoney, ServiceCharge: mSvcMoney, TaxFree: mTxfMoney, PrivateOrBusiness: mCashReciptTarget+1, ReciptIndex: "0000", CancelInfo: "", OriDate: "", InputMethod: "", CancelReason: mCancelReason, ptCardCode: "", ptAcceptNum: "", BusinessData: "", Bangi: "", KocesTradeUnique: "",payLinstener: paylistener?.delegate as! PayResultDelegate,StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
                } else if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
                    if Utils.CheckCatPortIP() != "" {
                        AlertBox(title: "에러", message: Utils.CheckCatPortIP(), text: "확인" )
                        return
                    }
                    catlistener = CatResult()
                    catlistener?.delegate = self
                    //여기에 캣으로 보낼전문 구성
                    //2020-05-26 tlswlsdn 위에 보면 다이렉트로 서버요청을 하는(번호입력부분), msr 읽는 부분 두군데에 넣으면 됩니다
                    let Number:String = mCashTextFieldNumber.text ?? ""

                    mCatSdk.CashRecipt(TID: _tid, 거래금액: String(mMoney), 세금: String(mTaxMoney), 봉사료: String(mSvcMoney), 비과세: String(mTxfMoney), 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: "", 고객번호: Number, 개인법인구분: String(mCashReciptTarget+1), 취소: false, 최소사유: "", 가맹점데이터: "", 여유필드: "", StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME), StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR), StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN), StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE), StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER),CompletionCallback: catlistener?.delegate as! CatResultDelegate)
                    
                } else {
                    AlertBox(title: "에러", message: "연결 가능한 단말기가 존재하지 않습니다", text: "확인" )
                }

            }
            return
        default:
            switch isTouch {
            case "Money":
                mCashTxtFieldMoney.text?.append("\(number.rawValue)")
                break
            case "Txf":
                mCashTxtFieldTaxFree.text?.append("\(number.rawValue)")
                break
            case "Svc":
                mCashTxtFieldSvc.text?.append("\(number.rawValue)")
                break
            case "Number":
                mCashTextFieldNumber.text?.append("\(number.rawValue)")
                break
            default:
                break
            }
    
        }
        
        switch isTouch {
        case "Money":
            CashTextFieldDidChange(mCashTxtFieldMoney)
            break
        case "Txf":
            CashTextFieldDidChange(mCashTxtFieldTaxFree)
            break
        case "Svc":
            CashTextFieldDidChange(mCashTxtFieldSvc)
            break
        case "Number":
            break
        default:
            break
        }
 
    }
}


