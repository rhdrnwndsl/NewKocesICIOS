//
//  CashICCatController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2021/07/28.
//

import Foundation
import UIKit
import SwiftUI

class CashICCatController: UIViewController {
    enum Target:Int {
        case Buy
        case Cancel
        case Search
        case BuySearch
        case CancelSearch
    }
    
    let mTaxCalc = TaxCalculator.Instance
    var catlistener:CatResult?
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var mCatSdk:CatSdk = CatSdk.instance
    
    var mInputMoney:Int = 0 //텍스트필드에 입력된 값
    var mTotalMoney:Int = 0     //결제금액
    var mMoney:Int = 0      //공급가액
    var mTaxMoney:Int = 0     //세금
    var mSvcMoney:Int = 0   //봉사료
    var mTxfMoney:Int = 0   //비과세

    @IBOutlet weak var mCashICType: UISegmentedControl! //현금IC업무구분 구매.C10,환불.C20,잔액조회.C30,구매조회.C40,환불조회.C50
    
    @IBOutlet weak var mCashTradeView: UIStackView! //구매시활용되는 뷰
    //
    @IBOutlet var mCashTxtFieldMoney: UITextField!                //결제금액
    @IBOutlet var mCashTxtFieldTaxFree: UITextField!             //비과세
    @IBOutlet weak var mCashTxtMoney: UILabel!                  //공급가액
    
    @IBOutlet weak var mCashTxtFieldSvc: UITextField!
    @IBOutlet weak var lbl_tax: UILabel!
    @IBOutlet weak var lbl_svc: UILabel!
    @IBOutlet weak var lbl_Total: UILabel!
    @IBOutlet weak var mStackView_Money: UIStackView!   //금액 입력 스택뷰
    @IBOutlet weak var mStackView_Txf: UIStackView!  //비과세 입력 스택뷰
    @IBOutlet weak var mStackView_Svc: UIStackView!  //봉사료 입력 스텍뷰
    //
    
    @IBOutlet weak var mCashCancelTradeView: UIStackView!   //환불시활용되는 뷰
    //
    @IBOutlet weak var mAuDatePicker: UIDatePicker! //원거래일자
    @IBOutlet weak var mAuNumber: UITextField!  //원승인번호
    @IBOutlet weak var mCancelMoney: UITextField!   //취소,조회금액
    //
    
    @IBOutlet weak var mSimpleStackView: UIStackView!   //간소화거래옵션 스택뷰. 구매거래시만사용하지만 일단 보이지않게 수정
    @IBOutlet weak var mSimpleType: UISwitch!   //간소화거래여부. 0일반거래(off) 1간소화거래(on)
    
    @IBOutlet weak var mCardDataStackView: UIStackView! //무카드취소 스택뷰. 환불거래시만사용
    @IBOutlet weak var mCardDataType: UISwitch! //무카드취소. 0일반가맹점(off) 1특약가맹점(on)
    
    var isTouch = "Money"   //금액입력, 비과세입력, 봉사료입력 중 하나
    @IBOutlet weak var numberPad: NumberPad!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
        Clear()
        InitRes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func Clear() {
//        mCashTxtFieldMoney.text = ""
//        mCashTxtFieldTaxFree.text = ""
//        mCashTxtFieldSvc.text = ""
//        lbl_tax.text = "0"
//        lbl_svc.text = "0"
//        lbl_Total.text = "0"
        mAuNumber.text = ""
//        mCancelMoney.text = ""
        mSimpleType.isOn = false
        mCardDataType.isOn = false
        mAuDatePicker.date = Date()
    }
    
    func InitRes() {
        //네비게이션 바의 배경색 rgb 변경
        UISetting.navigationTitleSetting(navigationBar: navigationController?.navigationBar ?? UINavigationBar())
        
        mCashTxtFieldTaxFree.placeholder = "금액을 입력해주세요"
//        mCashTxtFieldTaxFree.text = ""
        mCashTxtFieldMoney.keyboardType = .numberPad
        mCashTxtFieldTaxFree.keyboardType = .numberPad
        mCashTxtFieldSvc.keyboardType = .numberPad
        mCancelMoney.keyboardType = .numberPad
        mAuNumber.keyboardType = .numberPad
        
        mCashTxtFieldSvc.textAlignment = .right
        
//        let bar = UIToolbar()
//                
//        //새로운 버튼을 만든다
//        let doneBtn = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(dismissMyKeyboard))
//        
//        //
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//                
//        //
//        bar.items = [flexSpace, flexSpace, doneBtn]
//        bar.sizeToFit()
//                
//        mCashTxtFieldMoney.inputAccessoryView = bar
//        mCashTxtFieldTaxFree.inputAccessoryView = bar
//        mCancelMoney.inputAccessoryView = bar
//        mAuNumber.inputAccessoryView = bar
//        mCashTxtFieldSvc.inputAccessoryView = bar
//        
//        mCashTxtFieldMoney.addTarget(self, action: #selector(self.CashTextFieldDidChange(_:)), for: .editingChanged)    //금액이 변동된 경우에 처리
//        mCashTxtFieldTaxFree.addTarget(self, action: #selector(self.CashTextFieldDidChange(_:)), for: .editingChanged)    //금액이 변동된 경우에 처리
//        mCashTxtFieldSvc.addTarget(self, action: #selector(self.CashTextFieldDidChange(_:)), for: .editingChanged)    //금액이 변동된 경우에 처리
//        mCancelMoney.addTarget(self, action: #selector(self.CashCancelTextFieldDidChange(_:)), for: .editingChanged)    //금액이 변동된 경우에 처리
        
        numberPad.delegate = self
        numberPad.emptyKeyBackgroundColor = .clear
        
        
        //초기셋팅값은 현금IC타입 = 구매. 취소시 사용될 뷰는 디저블시킨다
        mCashICType.selectedSegmentIndex = 0
        mCashCancelTradeView.isHidden = true
        mCashCancelTradeView.alpha = 0.0
        mCashTradeView.isHidden = false
        mCashTradeView.alpha = 1.0
        mSimpleStackView.isHidden = false
        mSimpleStackView.alpha = 1.0
        mCardDataStackView.isHidden = true
        mCardDataStackView.alpha = 0.0
        
        //간소화버튼선택안되도록 막음(나중에 수정)(
//        mSimpleStackView.isHidden = true
//        mSimpleStackView.alpha = 0.0
        
        mCatSdk.Clear()
        mCatSdk = CatSdk.instance
        catlistener = CatResult()
        catlistener?.delegate = self
        
        if mTaxCalc.mApplySvc != TaxCalculator.TAXParameter.Use {
            mStackView_Svc.isHidden = true
            mStackView_Svc.alpha = 0.0

        }else{
            mStackView_Svc.isHidden = false
            mStackView_Svc.alpha = 1.0
            
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
                mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                mCashTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
            }
        }
        
        //만약에 부가세 방법이 자동인 경우에는 비과세 입력 필드를 표시 하지 않는다.
        if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use && mTaxCalc.mVatMethod == TaxCalculator.TAXParameter.Auto {
            mStackView_Txf.isHidden = true
            mStackView_Txf.alpha = 0.0
        }
        else{
            mStackView_Txf.isHidden = false
            mStackView_Txf.alpha = 1.0
            isTouch = "Txf"
            mCashTxtFieldTaxFree.backgroundColor = .white
            mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
            mCashTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
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
            mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
            mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
        }
        
        
        mCancelMoney.backgroundColor = define.layout_border_lightgrey
        mAuNumber.backgroundColor = define.layout_border_lightgrey
        
    }
    
    @IBAction func clicked_money(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Money"
        mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
        mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
        mCashTxtFieldMoney.backgroundColor = .white
        sender.resignFirstResponder()
    }
    
    @IBAction func clicked_txf(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Txf"
        mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
        mCashTxtFieldTaxFree.backgroundColor = .white
        mCashTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
        sender.resignFirstResponder()
    }
    
    @IBAction func clicked_svc(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Svc"
        mCashTxtFieldSvc.backgroundColor = .white
        mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
        mCashTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
        sender.resignFirstResponder()
    }
    
    @IBAction func clicked_cancelmoney(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "CancelMoney"
        mAuNumber.backgroundColor = define.layout_border_lightgrey
        mCancelMoney.backgroundColor = .white
        sender.resignFirstResponder()
    }
    
    @IBAction func clicked_aunum(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "AuNumber"
        mAuNumber.backgroundColor = .white
        mCancelMoney.backgroundColor = define.layout_border_lightgrey
        sender.resignFirstResponder()
    }
    
    func CashCancelTextFieldDidChange(_ textField: UITextField) {
        let money:Int = Int(mCancelMoney.text!.replacingOccurrences(of: ",", with: "")) ?? 0

        mCancelMoney.text = Utils.PrintMoney(Money: String(money))
    }
    
    /// 금액텍스트필드 값 변경시 호출 되는 함수
    /// - Parameter textField: mCashTxtFieldMoney
    func CashTextFieldDidChange(_ textField: UITextField) {
        let cash:Int = Int(mCashTxtFieldMoney.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        var _taxFree:String = mCashTxtFieldTaxFree.text!.replacingOccurrences(of: ",", with: "")
        mTxfMoney = Int(mCashTxtFieldTaxFree.text!.replacingOccurrences(of: ",", with: "")) ?? 0
//        //2021-07-21 kim.jy 부가세 사용의 경우 금액이 10원 이하면 리턴
//        if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
//            if (cash + txf) < 10 {
//                return
//            }
//        }else{
//            if txf < 10 {return}
//        }
        
        //if cash < 10 { return } //입력 금액이 10원 보다 적은 경우
        
        //봉사료가 수동 입력인 경우에 입력값 처리
        var serviceCharge:Int = 0
        if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use && mTaxCalc.mSvcMethod == TaxCalculator.TAXParameter.Manual {
            serviceCharge = Int(mCashTxtFieldSvc.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        }
        let tax:[String:Int] = mTaxCalc.TaxCalc(금액: cash,비과세금액: mTxfMoney, 봉사료: serviceCharge, BleUse: mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED ? false:true )
        mMoney = tax["Money"]!
        mTaxMoney = tax["VAT"]!
        mSvcMoney = tax["SVC"]!
        mTxfMoney = tax["TXF"]!
        textField.text = Utils.PrintMoney(Money: textField.text!.replacingOccurrences(of: ",", with: ""))
        mTotalMoney = mMoney + mTaxMoney + mSvcMoney
        mCashTxtMoney.text = Utils.PrintMoney(Money: "\(mMoney)")
        lbl_Total.text = Utils.PrintMoney(Money: "\(mTotalMoney)")
        if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
            mTotalMoney = mMoney + mTaxMoney + mSvcMoney + mTxfMoney
            lbl_Total.text = Utils.PrintMoney(Money: "\(mTotalMoney)")
        }
        lbl_tax.text = Utils.PrintMoney(Money: "\(mTaxMoney)")
        lbl_svc.text = Utils.PrintMoney(Money: "\(mSvcMoney)")
        
        if mTxfMoney == 0 && _taxFree.isEmpty {
            mCashTxtFieldTaxFree.text = ""
        } else {
            mCashTxtFieldTaxFree.text = Utils.PrintMoney(Money: "\(mTxfMoney)")
        }
        
   
        
        /** 화면상에 표시되는 공급가액 금액을 CAT 처럼 맞추기 위해 일부러 한번 더 한다 */
        let tax2:[String:Int] = mTaxCalc.TaxCalc(금액: cash,비과세금액: mTxfMoney, 봉사료: serviceCharge, BleUse: false )
        mCashTxtMoney.text = Utils.PrintMoney(Money: "\(tax2["Money"]!)")
        
    }
    @objc func dismissMyKeyboard(){
           view.endEditing(true)
       }
    
    //현금IC 업무구분 0구매.C10 1환불.C20 2잔액조회.C30 3구매조회.C40 4환불조회.C50
    @IBAction func segment_cashIC_type(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case Target.Buy.rawValue:
            mCashCancelTradeView.isHidden = true
            mCashCancelTradeView.alpha = 0.0
            mCashTradeView.isHidden = false
            mCashTradeView.alpha = 1.0
            mSimpleStackView.isHidden = false
            mSimpleStackView.alpha = 1.0
            mCardDataStackView.isHidden = true
            mCardDataStackView.alpha = 0.0
            
            if isTouch == "CancelMoney" || isTouch == "AuNumber" {
                isTouch = "Money"
                mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                mCashTxtFieldMoney.backgroundColor = .white
            }
            
            //간소화버튼선택안되도록 막음(나중에 수정)(
//            mSimpleStackView.isHidden = true
//            mSimpleStackView.alpha = 0.0
            break
        case Target.Cancel.rawValue:
            mCashCancelTradeView.isHidden = false
            mCashCancelTradeView.alpha = 1.0
            mCashTradeView.isHidden = true
            mCashTradeView.alpha = 0.0
            mSimpleStackView.isHidden = true
            mSimpleStackView.alpha = 0.0
            mCardDataStackView.isHidden = false
            mCardDataStackView.alpha = 1.0
            break
        case Target.Search.rawValue:
            mCashCancelTradeView.isHidden = true
            mCashCancelTradeView.alpha = 0.0
            mCashTradeView.isHidden = true
            mCashTradeView.alpha = 0.0
            mSimpleStackView.isHidden = true
            mSimpleStackView.alpha = 0.0
            mCardDataStackView.isHidden = true
            mCardDataStackView.alpha = 0.0
            break
        case Target.BuySearch.rawValue:
            mCashCancelTradeView.isHidden = false
            mCashCancelTradeView.alpha = 1.0
            
            mCashTradeView.isHidden = true
            mCashTradeView.alpha = 0.0
            mSimpleStackView.isHidden = true
            mSimpleStackView.alpha = 0.0
            mCardDataStackView.isHidden = true
            mCardDataStackView.alpha = 0.0
            
            if isTouch == "Money" || isTouch == "Txf" || isTouch == "Svc" {
                isTouch = "CancelMoney"
                mAuNumber.backgroundColor = define.layout_border_lightgrey
                mCancelMoney.backgroundColor = .white
            }
            break
        case Target.CancelSearch.rawValue:
            mCashCancelTradeView.isHidden = false
            mCashCancelTradeView.alpha = 1.0
            mCashTradeView.isHidden = true
            mCashTradeView.alpha = 0.0
            mSimpleStackView.isHidden = true
            mSimpleStackView.alpha = 0.0
            mCardDataStackView.isHidden = true
            mCardDataStackView.alpha = 0.0
            
            if isTouch == "Money" || isTouch == "Txf" || isTouch == "Svc" {
                isTouch = "CancelMoney"
                mAuNumber.backgroundColor = define.layout_border_lightgrey
                mCancelMoney.backgroundColor = .white
            }
            break
        default:
            break
        }
    }
    
    func clicked_btn_cashIC() {
//        let touch: UITouch = (event.allTouches?.first)!
//        if (touch.tapCount != 1) {
//            // do action.
//            return
//        }
        
        switch mCashICType.selectedSegmentIndex {
        case Target.Buy.rawValue:
            //에러 상황에 대한 처리
            if !checkMoneyValue() {
                return
            }
            
            //봉사료가 수동 입력인 경우에 입력값 처리
            var serviceCharge:Int = 0
            if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use && mTaxCalc.mSvcMethod == TaxCalculator.TAXParameter.Manual {
                serviceCharge = Int(mCashTxtFieldSvc.text!.replacingOccurrences(of: ",", with: "")) ?? 0
            }
            let tax:[String:Int] = mTaxCalc.TaxCalc(금액: mInputMoney,비과세금액: mTxfMoney, 봉사료: serviceCharge, BleUse: mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED ? false:true )
            mMoney = tax["Money"]!
            mTaxMoney = tax["VAT"]!
            mSvcMoney = tax["SVC"]!
            mTxfMoney = tax["TXF"]!
            
            if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](NAME,TID,BSN,PHONE,OWNER,ADDR) in
                    if TID == "" {
                        AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                        return
                    }
                    CashIC_Buy(TID: TID, StoreName: NAME, StoreAddr: ADDR, StoreNumber: BSN, StorePhone: PHONE, StoreOwner: OWNER)
                }
                return
            }
            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                CashIC_Buy(TID: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID),
                           StoreName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME),
                           StoreAddr: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR),
                           StoreNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN),
                           StorePhone: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE),
                           StoreOwner: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER))
            } else {
                CashIC_Buy(TID: Setting.shared.getDefaultUserData(_key: define.STORE_TID),
                           StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),
                           StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),
                           StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),
                           StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),
                           StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
            }
      
            break
        case Target.Cancel.rawValue:
            if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](NAME,TID,BSN,PHONE,OWNER,ADDR) in
                    if TID == "" {
                        AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                        return
                    }
                    CashIC_Cancel(TID: TID, StoreName: NAME, StoreAddr: ADDR, StoreNumber: BSN, StorePhone: PHONE, StoreOwner: OWNER)
                }
                return
            }
            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                CashIC_Cancel(TID: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID),
                           StoreName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME),
                           StoreAddr: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR),
                           StoreNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN),
                           StorePhone: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE),
                           StoreOwner: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER))
            } else {
                CashIC_Cancel(TID: Setting.shared.getDefaultUserData(_key: define.STORE_TID),
                           StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),
                           StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),
                           StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),
                           StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),
                           StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
            }

            break
        case Target.Search.rawValue:
            if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](NAME,TID,BSN,PHONE,OWNER,ADDR) in
                    if TID == "" {
                        AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                        return
                    }
                    CashIC_Search(TID: TID, StoreName: NAME, StoreAddr: ADDR, StoreNumber: BSN, StorePhone: PHONE, StoreOwner: OWNER)
                }
                return
            }
            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                CashIC_Search(TID: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID),
                           StoreName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME),
                           StoreAddr: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR),
                           StoreNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN),
                           StorePhone: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE),
                           StoreOwner: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER))
            } else {
                CashIC_Search(TID: Setting.shared.getDefaultUserData(_key: define.STORE_TID),
                           StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),
                           StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),
                           StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),
                           StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),
                           StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
            }
            break
        case Target.BuySearch.rawValue:
            if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](NAME,TID,BSN,PHONE,OWNER,ADDR) in
                    if TID == "" {
                        AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                        return
                    }
                    CashIC_BuySearch(TID: TID, StoreName: NAME, StoreAddr: ADDR, StoreNumber: BSN, StorePhone: PHONE, StoreOwner: OWNER)
                }
                return
            }
            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                CashIC_BuySearch(TID: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID),
                           StoreName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME),
                           StoreAddr: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR),
                           StoreNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN),
                           StorePhone: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE),
                           StoreOwner: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER))
            } else {
                CashIC_BuySearch(TID: Setting.shared.getDefaultUserData(_key: define.STORE_TID),
                           StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),
                           StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),
                           StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),
                           StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),
                           StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
            }
            break
        case Target.CancelSearch.rawValue:
            if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](NAME,TID,BSN,PHONE,OWNER,ADDR) in
                    if TID == "" {
                        AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                        return
                    }
                    CashIC_CancelSearch(TID: TID, StoreName: NAME, StoreAddr: ADDR, StoreNumber: BSN, StorePhone: PHONE, StoreOwner: OWNER)
                }
                return
            }
            if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                CashIC_CancelSearch(TID: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID),
                           StoreName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME),
                           StoreAddr: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR),
                           StoreNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN),
                           StorePhone: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE),
                           StoreOwner: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER))
            } else {
                CashIC_CancelSearch(TID: Setting.shared.getDefaultUserData(_key: define.STORE_TID),
                           StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),
                           StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),
                           StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),
                           StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),
                           StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
            }
            break
        default:
            break
        }
    }
    
    func CashIC_Buy(TID _tid:String, StoreName _storeName:String,StoreAddr _storeAddr:String,
                    StoreNumber _storeNumber:String,StorePhone _storePhone:String,StoreOwner _storeOwner:String) {
        mCatSdk.CashIC(업무구분: define.CashICBusinessClassification.Buy, TID: _tid, 거래금액: String(mMoney), 세금: String(mTaxMoney), 봉사료: String(mSvcMoney), 비과세: String(mTxfMoney), 원거래일자: "", 원승인번호: "", 간소화거래여부: mSimpleType.isOn == true ? "1":"0", 카드정보수록여부: "0", 취소: false, 가맹점데이터: "", 여유필드: "", StoreName: _storeName, StoreAddr: _storeAddr, StoreNumber: _storeNumber, StorePhone: _storePhone, StoreOwner: _storeOwner,CompletionCallback: catlistener?.delegate as! CatResultDelegate)
    }
    
    func CashIC_Cancel(TID _tid:String, StoreName _storeName:String,StoreAddr _storeAddr:String,
                       StoreNumber _storeNumber:String,StorePhone _storePhone:String,StoreOwner _storeOwner:String) {
        let money:Int = Int((mCancelMoney.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
        let dateFormat = DateFormatter()    //코드상에 표현될 날짜의 포맷
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyMMdd"
        mCatSdk.CashIC(업무구분: define.CashICBusinessClassification.Cancel, TID: _tid, 거래금액: String(money), 세금: "0", 봉사료: "0", 비과세: "0", 원거래일자: dateFormat.string(from: mAuDatePicker.date), 원승인번호: Utils.rightPad(str: (mAuNumber.text ?? "").replacingOccurrences(of: " ", with: ""), fillChar: " ", length: 13), 간소화거래여부: "0", 카드정보수록여부: mCardDataType.isOn == true ? "1":"0", 취소: true, 가맹점데이터: "", 여유필드: "", StoreName: _storeName, StoreAddr: _storeAddr, StoreNumber: _storeNumber, StorePhone: _storePhone, StoreOwner: _storeOwner,CompletionCallback: catlistener?.delegate as! CatResultDelegate)
    }
    
    func CashIC_Search(TID _tid:String, StoreName _storeName:String,StoreAddr _storeAddr:String,
                       StoreNumber _storeNumber:String,StorePhone _storePhone:String,StoreOwner _storeOwner:String) {
        mCatSdk.CashIC(업무구분: define.CashICBusinessClassification.Search, TID: _tid, 거래금액: "0", 세금: "0", 봉사료: "0", 비과세: "0", 원거래일자: "", 원승인번호: "", 간소화거래여부: "0", 카드정보수록여부: "0", 취소: false, 가맹점데이터: "", 여유필드: "", StoreName: _storeName, StoreAddr: _storeAddr, StoreNumber: _storeNumber, StorePhone: _storePhone, StoreOwner: _storeOwner,CompletionCallback: catlistener?.delegate as! CatResultDelegate)
    }
    
    func CashIC_BuySearch(TID _tid:String, StoreName _storeName:String,StoreAddr _storeAddr:String,
                          StoreNumber _storeNumber:String,StorePhone _storePhone:String,StoreOwner _storeOwner:String) {
        let money:Int = Int((mCancelMoney.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
        let dateFormat = DateFormatter()    //코드상에 표현될 날짜의 포맷
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyMMdd"
        mCatSdk.CashIC(업무구분: define.CashICBusinessClassification.BuySearch, TID: _tid, 거래금액: String(money), 세금: "0", 봉사료: "0", 비과세: "0", 원거래일자: dateFormat.string(from: mAuDatePicker.date), 원승인번호: Utils.rightPad(str: (mAuNumber.text ?? "").replacingOccurrences(of: " ", with: ""), fillChar: " ", length: 13), 간소화거래여부: "0", 카드정보수록여부: "0", 취소: false, 가맹점데이터: "", 여유필드: "",StoreName: _storeName, StoreAddr: _storeAddr, StoreNumber: _storeNumber, StorePhone: _storePhone, StoreOwner: _storeOwner, CompletionCallback: catlistener?.delegate as! CatResultDelegate)
    }
    
    func CashIC_CancelSearch(TID _tid:String, StoreName _storeName:String,StoreAddr _storeAddr:String,
                             StoreNumber _storeNumber:String,StorePhone _storePhone:String,StoreOwner _storeOwner:String) {
        let money:Int = Int((mCancelMoney.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
        let dateFormat = DateFormatter()    //코드상에 표현될 날짜의 포맷
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyMMdd"
        mCatSdk.CashIC(업무구분: define.CashICBusinessClassification.CancelSearch, TID: _tid, 거래금액: String(money), 세금: "0", 봉사료: "0", 비과세: "0", 원거래일자: dateFormat.string(from: mAuDatePicker.date), 원승인번호: Utils.rightPad(str: (mAuNumber.text ?? "").replacingOccurrences(of: " ", with: ""), fillChar: " ", length: 13), 간소화거래여부: "0", 카드정보수록여부: "0", 취소: false, 가맹점데이터: "", 여유필드: "",StoreName: _storeName, StoreAddr: _storeAddr, StoreNumber: _storeNumber, StorePhone: _storePhone, StoreOwner: _storeOwner, CompletionCallback: catlistener?.delegate as! CatResultDelegate)
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
    
}

extension CashICCatController : UITabBarControllerDelegate, CatResultDelegate {
    func onResult(CatState _state: payStatus, Result _message: Dictionary<String, String>) {
        Utils.CatAnimationViewInitClear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if _state == .OK {
                var _msg = ""
                var _title = ""
                var _cardNo = _message["CardNo"] ?? ""
                var _auNo = _message["AuNo"] ?? ""
                switch _message["ResponseNo"] {
                case "C15" :
                    _title = "현금IC 구매거래"
                    for mes in _message {
                        _msg = _msg + mes.key + " : " + mes.value + "\n"
                    }
                    break
                case "C25" :
                    _title = "현금IC 환불거래"
                    for mes in _message {
                        _msg = _msg + mes.key + " : " + mes.value + "\n"
                    }
                    break
                case "C35" :
                    _title = "현금IC 잔액조회"
                    _msg = "잔액 : " + Utils.PrintMoney(Money: String(Int(_message["ServeMoney"] ?? "0") ?? 0))
                    if _cardNo != "" {
                        _msg += "\n" + "계좌번호 : " + _cardNo
                    }
                    if _auNo != "" {
                        _msg += "\n" + "승인번호 : " + _auNo
                    }
                    break
                case "C45" :
                    _title = "현금IC 구매조회"
                    _msg = _message["Message"] ?? "거래실패"
                    if _cardNo != "" {
                        _msg += "\n" + "계좌번호 : " + _cardNo
                    }
                    if _auNo != "" {
                        _msg += "\n" + "승인번호 : " + _auNo
                    }
                    break
                case "C55" :
                    _title = "현금IC 환불조회"
                    _msg = _message["Message"] ?? "거래실패"
                    if _cardNo != "" {
                        _msg += "\n" + "계좌번호 : " + _cardNo
                    }
                    if _auNo != "" {
                        _msg += "\n" + "승인번호 : " + _auNo
                    }
                    break
                default :
                    _title = "현금IC 거래오류"
                    for mes in _message {
                        _msg = _msg + mes.key + " : " + mes.value + "\n"
                    }
                    break
                }
               
                let alertController = UIAlertController(title: _title, message: _msg, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
                    self.tabBarController?.delegate = self
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            } else {
                var _msg = ""
                var _title = ""
                switch _message["ResponseNo"] {
                case "C15" :
                    _title = "[현금IC 구매거래]"
                    break
                case "C25" :
                    _title = "[현금IC 환불거래]"
                    break
                case "C35" :
                    _title = "[현금IC 잔액조회]"
                    break
                case "C45" :
                    _title = "[현금IC 구매조회]"
                    break
                case "C55" :
                    _title = "[현금IC 환불조회]"
                    break
                default :
                    _title = "[현금IC 거래오류]"
                    for mes in _message {
                        _msg = _msg + mes.key + " : " + mes.value + "\n"
                    }
                    break
                }
                
                var _tmpmsg = _message["Message"] ?? _message["ERROR"] ?? "거래실패"
                if _tmpmsg.replacingOccurrences(of: " ", with: "") == "" {
                    _tmpmsg = "응답 데이터 이상"
                }
                let alertController = UIAlertController(title: _title, message: _tmpmsg, preferredStyle: UIAlertController.Style.alert)
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
    
    func TidAlertBox(title _title:String, callback: @escaping (_ NAME:String, _ TID:String, _ BSN:String, _ PHONE:String, _ OWNER:String, _ ADDR:String)->Void) {

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
    
    /**
     금액 입력 후 다음 입력이 있는지 처리
     isNext = true ok버튼누름. 다음 입력할 거 찾아야서 isMoney="" 값을 넣어야함.
     isNext = false 일 경우에는 이전 입력할 거 찾아서 isMoney="" 값을 넣어야함.
     위 두개의 다른점은 다음 찾을 거의 우선순위임
     */
    func TxtBuyUpdate(IsNext isNext:Bool) {
        if isNext {
            //부가세 미설정시 금액 입력이 보이지 않게 처리 한다. 비과세만 입력가능 2021-07-21 kim.jy
            if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                //금액입력을 사용
                if (mCashTxtFieldMoney.text!.isEmpty) {
                    //만일 텍스트가 비어있다면?
                    isTouch = "Money"
                    mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                    mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
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
                    mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                    mCashTxtFieldTaxFree.backgroundColor = .white
                    mCashTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
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
                        mCashTxtFieldSvc.backgroundColor = .white
                        mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                        mCashTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
                        return
                    }
                }

            }

        } else {
            //부가세 미설정시 금액 입력이 보이지 않게 처리 한다. 비과세만 입력가능 2021-07-21 kim.jy
            if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                //금액입력을 사용
                if (mCashTxtFieldMoney.text!.isEmpty) {
                    //만일 텍스트가 비어있다면?
                    isTouch = "Money"
                    mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                    mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                    mCashTxtFieldMoney.backgroundColor = .white
                    return
                }
            }
            
            //만약에 부가세 방법이 자동인 경우에는 비과세 입력 필드를 표시 하지 않는다.
            if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use || mTaxCalc.mVatMethod != TaxCalculator.TAXParameter.Auto {
                //비과세을 사용
                if (mCashTxtFieldTaxFree.text!.isEmpty) {
                    if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                        isTouch = "Money"
                        mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                        mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                        mCashTxtFieldMoney.backgroundColor = .white
                        return
                    }
                    //만일 텍스트가 비어있다면?
                    isTouch = "Txf"
                    mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                    mCashTxtFieldTaxFree.backgroundColor = .white
                    mCashTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
                    return
                }
            }
            
            if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use {
                //봉사료을 사용
                
                if mTaxCalc.mSvcMethod != TaxCalculator.TAXParameter.Auto {
                    //봉사료 수동 입력의 경우
                    if (mCashTxtFieldSvc.text!.isEmpty) {
                        if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use || mTaxCalc.mVatMethod != TaxCalculator.TAXParameter.Auto {
                            //만일 텍스트가 비어있다면?
                            isTouch = "Txf"
                            mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                            mCashTxtFieldTaxFree.backgroundColor = .white
                            mCashTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
                            return
                        }
                        
                        if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                            isTouch = "Money"
                            mCashTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                            mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                            mCashTxtFieldMoney.backgroundColor = .white
                            return
                        }
                        
                        //만일 텍스트가 비어있다면?
                        isTouch = "Svc"
                        mCashTxtFieldSvc.backgroundColor = .white
                        mCashTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                        mCashTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
                        return
                    }
                }

            }

        }
       
        isTouch = ""

    }
    
    func TxtSearchUpdate(IsNext isNext:Bool) {
        if isNext {
            //금액입력을 사용
            if (mCancelMoney.text!.isEmpty) {
                //만일 텍스트가 비어있다면?
                isTouch = "CancelMoney"
                mAuNumber.backgroundColor = define.layout_border_lightgrey
                mCancelMoney.backgroundColor = .white
                return
            }
            
            //비과세을 사용
            if (mAuNumber.text!.isEmpty) {
                //만일 텍스트가 비어있다면?
                isTouch = "AuNumber"
                mAuNumber.backgroundColor = .white
                mCancelMoney.backgroundColor = define.layout_border_lightgrey
                return
            }

        } else {

//            if (mMoney.text!.isEmpty) {
//                //만일 텍스트가 비어있다면?
//                isTouch = "Money"
//                mAuNumber.backgroundColor = define.layout_border_lightgrey
//                mMoney.backgroundColor = .white
//                return
//            }
//
            //비과세을 사용
            if (mAuNumber.text!.isEmpty) {
                //만일 텍스트가 비어있다면?
                //금액입력을 사용
                if (isTouch != "CancelMoney") {
                    isTouch = "CancelMoney"
                    mAuNumber.backgroundColor = define.layout_border_lightgrey
                    mCancelMoney.backgroundColor = .white
                    return
                }
                return
            }

        }
       
        isTouch = ""

    }
}
extension CashICCatController: NumberPadDelegate {
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
                    TxtBuyUpdate(IsNext: false)
                    return
                }
                mCashTxtFieldMoney.text?.removeLast()
                if mCashTxtFieldMoney.text!.isEmpty {
                    TxtBuyUpdate(IsNext: false)
                }
                CashTextFieldDidChange(mCashTxtFieldMoney)
                break
            case "Txf":
                guard !(mCashTxtFieldTaxFree.text?.isEmpty ?? true) else {
                    mCashTxtFieldTaxFree.text = ""
                    TxtBuyUpdate(IsNext: false)
                    return
                }
                mCashTxtFieldTaxFree.text?.removeLast()
                if mCashTxtFieldTaxFree.text!.isEmpty {
                    TxtBuyUpdate(IsNext: false)
                }
                CashTextFieldDidChange(mCashTxtFieldTaxFree)
                break
            case "Svc":
                guard !(mCashTxtFieldSvc.text?.isEmpty ?? true) else {
                    mCashTxtFieldSvc.text = ""
                    TxtBuyUpdate(IsNext: false)
                    return
                }
                mCashTxtFieldSvc.text?.removeLast()
                if mCashTxtFieldSvc.text!.isEmpty {
                    TxtBuyUpdate(IsNext: false)
                }
                CashTextFieldDidChange(mCashTxtFieldSvc)
                break
            case "CancelMoney":
                guard !(mCancelMoney.text?.isEmpty ?? true) else {
                    mCancelMoney.text = ""
                    TxtSearchUpdate(IsNext: false)
                    return
                }
                mCancelMoney.text?.removeLast()
                if mCancelMoney.text!.isEmpty {
                    TxtSearchUpdate(IsNext: false)
                }
                break
            case "AuNumber":
                guard !(mAuNumber.text?.isEmpty ?? true) else {
                    mAuNumber.text = ""
                    TxtSearchUpdate(IsNext: false)
                    return
                }
                mAuNumber.text?.removeLast()
                if mAuNumber.text!.isEmpty {
                    TxtSearchUpdate(IsNext: false)
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
            case "CancelMoney":
                break
            case "AuNumber":
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
                TxtBuyUpdate(IsNext: false)
                CashTextFieldDidChange(mCashTxtFieldMoney)
                return
            case "Txf":
                guard !(mCashTxtFieldTaxFree.text?.isEmpty ?? true) else {
                    return
                }
                mCashTxtFieldTaxFree.text = ""
                TxtBuyUpdate(IsNext: false)
                CashTextFieldDidChange(mCashTxtFieldTaxFree)
                return
            case "Svc":
                guard !(mCashTxtFieldSvc.text?.isEmpty ?? true) else {
                    return
                }
                mCashTxtFieldSvc.text = ""
                TxtBuyUpdate(IsNext: false)
                CashTextFieldDidChange(mCashTxtFieldSvc)
                return
            case "CancelMoney":
                guard !(mCancelMoney.text?.isEmpty ?? true) else {
                    return
                }
                mCancelMoney.text = ""
                TxtSearchUpdate(IsNext: false)
                return
            case "AuNumber":
                guard !(mAuNumber.text?.isEmpty ?? true) else {
                    return
                }
                mAuNumber.text = ""
                TxtSearchUpdate(IsNext: false)
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
            case "CancelMoney":
                mCancelMoney.text?.append("00")
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
                mCashTxtFieldMoney.text?.append("010")
                break
            case "Txf":
                mCashTxtFieldTaxFree.text?.append("010")
                break
            case "Svc":
                mCashTxtFieldSvc.text?.append("010")
                break
            case "CancelMoney":
                mCancelMoney.text?.append("010")
                break
            case "AuNumber":
                mAuNumber.text?.append("010")
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
                TxtBuyUpdate(IsNext: true)
                break
            case "Txf":
                TxtBuyUpdate(IsNext: true)
                break
            case "Svc":
                TxtBuyUpdate(IsNext: true)
                break
            case "CancelMoney":
                TxtSearchUpdate(IsNext: true)
                break
            case "AuNumber":
                TxtSearchUpdate(IsNext: true)
                break
            default:
                break
            }
            
            if isTouch != "" {
                return
            }
            
            clicked_btn_cashIC()
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
            case "CancelMoney":
                mCancelMoney.text?.append("\(number.rawValue)")
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
            CashTextFieldDidChange(mCashTxtFieldMoney)
            break
        case "Txf":
            CashTextFieldDidChange(mCashTxtFieldTaxFree)
            break
        case "Svc":
            CashTextFieldDidChange(mCashTxtFieldSvc)
            break
        case "CancelMoney":
            break
        case "AuNumber":
            break
        default:
            break
        }
 
    }
}
