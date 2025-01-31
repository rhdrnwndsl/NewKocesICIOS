//
//  TaxController.swift
//  osxapp
//
//  Created by 金載龍 on 2021/02/19.
//

import Foundation
import UIKit

/// 세금 설정 화면
class TaxController: UIViewController {
    let mSetting:Setting = Setting.shared
    let mKocesSdk:KocesSdk = KocesSdk.instance
    let mTaxCalc:TaxCalculator = TaxCalculator.Instance
    @IBOutlet weak var Swt_VatOnOff: UISwitch!  //부가서 적용 스위치
    @IBOutlet weak var seg_VatMethod: UISegmentedControl!   //부가세 방식
    @IBOutlet weak var Seg_VatInclude: UISegmentedControl!
    @IBOutlet weak var Txt_VatValue: UITextField!
    @IBOutlet weak var StackView_Vat: UIStackView!      //부가세 설정 부분 스택뷰
    @IBOutlet weak var StackView_Txf: UIStackView!      //비과세 관련 포함, 미포함
    @IBOutlet weak var Swt_SvcOnOff: UISwitch!
    @IBOutlet weak var seg_SvcInclude: UISegmentedControl!  //봉사료 포함여부
    @IBOutlet weak var seg_SvcMethod: UISegmentedControl!   //봉사료 방법
    @IBOutlet weak var Txt_SvcValue: UITextField!
    @IBOutlet weak var StackView_Svc: UIStackView!  //봉사료 세부 설정 그룹
    @IBOutlet weak var seg_TxfInclude: UISegmentedControl!  //비과세 포함 여부

    @IBOutlet weak var Txt_InstallmentValue: UITextField!   //할부 최소 금액
    @IBOutlet weak var txt_UnsignedSetMoney: UITextField! //무셔명 설정 금액
    @IBOutlet weak var Btn_TaxSave: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyBoard()
    }
    
    @objc func dismissMyKeyboard(){
           view.endEditing(true)
    }
    
    func setKeyBoard()
    {
        let bar = UIToolbar()
                
        //새로운 버튼을 만든다 키보드 닫기 버튼을 만든다.
        let doneBtn = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
                
        Txt_VatValue.inputAccessoryView = bar
        Txt_SvcValue.inputAccessoryView = bar
        Txt_InstallmentValue.inputAccessoryView = bar
        
        txt_UnsignedSetMoney.inputAccessoryView = bar   //무셔명텍스트박스입력시 완료 버튼 추가
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //초기값 설정 하기
        initRes()
        
    }
    
    /// 화면 초기값 설정
    func initRes()
    {

        let TaxEnum = TaxCalculator.TAXParameter.self
        
        /// 부가세 정보 읽어서 UI 화면 설정 하는 부분
        if mTaxCalc.mApplyVat == TaxEnum.Use { //부가세 적용
            
            Swt_VatOnOff.isOn = true    //부가세 스위치온상태
            StackView_Vat.isHidden = false
            StackView_Vat.alpha = 1.0
            
            Seg_VatInclude.selectedSegmentIndex = mTaxCalc.mIncludeVat==TaxEnum.Included ? 0 : 1    //부가세포함 여부 설정
            switch mTaxCalc.mVatMethod {        //부가세 방식 설정
            case TaxEnum.Auto:
                seg_VatMethod.selectedSegmentIndex = 0
                break
            case TaxEnum.Integrated:
                seg_VatMethod.selectedSegmentIndex = 1
                break
            default:
                break
            }
            Txt_VatValue.text = String(mTaxCalc.mVatRate)
            
        } else {
            Swt_VatOnOff.isOn = false
            StackView_Vat.isHidden = true
            StackView_Vat.alpha = 0.0
        }
        
        //부가세 방법이을 정보 읽어서 비과세 UI 화면 설정 하는 부분
        if mTaxCalc.mVatMethod != TaxEnum.Integrated {
            //2021-07-21 kim.jy 비과세는 현재 미포함으로만 처리 하기 때문에 비과세 포함 항목은 표시 하지 않는다.
            StackView_Txf.isHidden = true
            StackView_Txf.alpha = 0.0
        }
        else{
            StackView_Txf.isHidden = true
            StackView_Txf.alpha = 0.0
        }
        
        /// 봉사료 정보 읽어서 UI 화면 설정 하는 부분
        if mTaxCalc.mApplySvc == TaxEnum.Use { //봉사료 적용
            Swt_SvcOnOff.isOn = true
            StackView_Svc.isHidden = false
            StackView_Svc.alpha = 1.0
            seg_SvcInclude.selectedSegmentIndex = mTaxCalc.mIncludeSvc == TaxEnum.Included ? 0 : 1  //봉사료 포함, 미포함
            seg_SvcMethod.selectedSegmentIndex = mTaxCalc.mSvcMethod == TaxEnum.Auto ? 0 : 1        //봉사료 입력 여부 자동,수동 설정
            
            
        } else {
            Swt_SvcOnOff.isOn = false
            StackView_Svc.isHidden = true
            StackView_Svc.alpha = 0.0

        }
        ///비과세 설정을 읽어서 UI 화면에 설정
        if mTaxCalc.mIncludeTxf == TaxEnum.Included {
            seg_TxfInclude.selectedSegmentIndex = 0
        }else{
            seg_TxfInclude.selectedSegmentIndex = 1
        }
        
        Txt_VatValue.text = "\(mTaxCalc.mVatRate)"
        Txt_SvcValue.text = "\(mTaxCalc.mSvcRate)"
        
        ///할부 금액 설정 및 UI 화면 설정 부분
        let instval:String = String(Int(mSetting.getDefaultUserData(_key: define.INSTALLMENT_MINVALUE))! / 10000)
        Txt_InstallmentValue.text = instval
        
        ///무서명 금액 UI 설정 부분
        let unsigedMinMoney:String = String(Int(mSetting.getDefaultUserData(_key: define.UNSIGNED_SETMONEY))! / 10000)
        txt_UnsignedSetMoney.text = unsigedMinMoney
    }
        //
    
    /// 부가세 적용 버튼이 변경된 경우
    /// - Parameter sender: switch sender
    @IBAction func Changed_UseVat(_ sender: UISwitch) {
        if Swt_VatOnOff.isOn {
            StackView_Vat.isHidden = false
            StackView_Vat.alpha = 1.0
        }else{
            StackView_Vat.isHidden = true
            StackView_Vat.alpha = 0.0
        }
    }
    
    /// 봉사료 적용 버튼이 변경된 경우
    /// - Parameter sender: switch sender
    @IBAction func Changed_UseSvc(_ sender: UISwitch) {
        if Swt_SvcOnOff.isOn {
            StackView_Svc.isHidden = false
            StackView_Svc.alpha = 1.0
        }else{
            StackView_Svc.isHidden = true
            StackView_Svc.alpha = 0.0
        }
    }
    @IBAction func Changed_VatMethod(_ sender: UISegmentedControl) {
        //2021-07-21 kim.jy
        //비과세는 무조건 미포함이기 때문에 비과세 관련 항목은 화면에 표시 하지 않는다.
        if seg_VatMethod.selectedSegmentIndex == 0 {
            StackView_Txf.isHidden = true
            StackView_Txf.alpha = 0.0
            
        }else{
            StackView_Txf.isHidden = true
            StackView_Txf.alpha = 0.0
        }
    }
    @IBAction func TaxSave_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        if !CheckValue() { return }
        SaveTaxSetting()
    }
    
    func CheckValue() -> Bool {
        //부가세 입력 데이터가 숫자가 아닌 경우 검사
        if Txt_VatValue.text!.isEmpty || Txt_SvcValue.text!.isEmpty || Txt_InstallmentValue.text!.isEmpty {
            AlertBox(title: "에러", message:mKocesSdk.getStringPlist(Key: "err_msg_empty_value"), text: "확인")
            return false
        }
        
        // ====================== 봉사료 검사 ======================== //
        if Swt_SvcOnOff.isOn {  //봉사료 사용의 경우
            let svcvalue:[UInt8] = Array(Txt_SvcValue.text!.utf8)
            
            //봉사료 숫자가 2자리를 넘는 경우
            if svcvalue.count > 2 || svcvalue[0] == 0x30 {
                AlertBox(title: "에러",message: "봉사료는 1~99까지 입력 가능 합니다", text: "확인")
                return false
            }
            
            //봉사료 숫자가 아닌 문자가 있는 경우
            for n in svcvalue{
                if 0x30 > n || n > 0x39 {
                    AlertBox(title: "에러",message: "봉사료는 1~99까지 입력 가능 합니다", text: "확인")
                    return false
                }
            }
        }
        

        
        
        // ====================== 할부 검사 =======================================
        let Instvalue:[UInt8] = Array(Txt_InstallmentValue.text!.utf8)
        
        //할부 최소 금액에 문자가 입력된 경우
        for n in Instvalue{
            if 0x30 > n || n > 0x39 {
                AlertBox(title: "에러",message: "금액은 숫자로 입력 해야 합니다", text: "확인")
                return false
            }
        }
        
        //할부 최소 금액이 5만원 보다 작은 경우
//        if Int(Txt_InstallmentValue.text!)! < 50000 {
//            AlertBox(title: "에러",message: "할부 최소 금액은 50000 원 이상 입니다", text: "확인")
//            return false
//        }
        
        // ====================== 무서명 금액 검사 =======================================
        let Signvalue:[UInt8] = Array(txt_UnsignedSetMoney.text!.utf8)
        
        //무서명 금액에 문자가 입력된 경우
        for n in Signvalue{
            if 0x30 > n || n > 0x39 {
                AlertBox(title: "에러",message: "금액은 숫자로 입력 해야 합니다", text: "확인")
                return false
            }
        }
        
        return true
        
    }
    
    func SaveTaxSetting()
    {
        let TaxEnum = TaxCalculator.TAXParameter.self
        
        mTaxCalc.setTaxOption(부가세적용: Swt_VatOnOff.isOn == true ? TaxEnum.Use:TaxEnum.Unused,
                              부가세방식: seg_VatMethod.selectedSegmentIndex == 0 ? TaxEnum.Auto:TaxEnum.Integrated ,
                              부가세포함여부: Seg_VatInclude.selectedSegmentIndex == 0 ? TaxEnum.Included:TaxEnum.NotIncluded ,
                              부가세: Int(Txt_VatValue.text ?? "0") ?? 0,
                              봉사료적용: Swt_SvcOnOff.isOn == true ? TaxEnum.Use:TaxEnum.Unused ,
                              봉사료포함여부: seg_SvcInclude.selectedSegmentIndex == 0 ? TaxEnum.Included:TaxEnum.NotIncluded ,
                              봉사료자동수동: seg_SvcMethod.selectedSegmentIndex == 0 ? TaxEnum.Auto:TaxEnum.Manual ,
                              봉사료율: Int(Txt_SvcValue.text ?? "0") ?? 0,
                              비과세포함여부: seg_TxfInclude.selectedSegmentIndex == 0 ? TaxEnum.Included:TaxEnum.NotIncluded  )
        //할부 최소 금액 저장
        let _insMoney:Int = Int(Txt_InstallmentValue.text!)! * 10000
        mSetting.setDefaultUserData(_data: String(_insMoney), _key: define.INSTALLMENT_MINVALUE)
        
        //무서명 설정금액 저장
        let _signMoney:Int = Int(txt_UnsignedSetMoney.text!)! * 10000
        mSetting.setDefaultUserData(_data: String(_signMoney), _key: define.UNSIGNED_SETMONEY)
        
        
        
        AlertBox(title: "저장", message: "세금 설정을 저장 하였습니다", text: "확인")
    }
    
    func AlertBox(title : String, message : String, text : String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            return self.present(alertController, animated: true, completion: nil)
        }
}
