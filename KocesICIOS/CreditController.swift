//
//  CreditController.swift
//  osxapp
//
//  Created by 金載龍 on 2020/12/29.
//
import UIKit
import SwiftUI
class CreditController: UIViewController, UIViewControllerTransitioningDelegate {
    // A로부터 전달받을 클로저 (결과값 타입은 String 예시)
    var onDismiss: ((_ _Tid:String,_ _money:String,_ _tax:Int,_ _serviceCharge:Int,_ _txf:Int,_ _installment:String,
                     _ _cancelInfo:String,_ _mchData:String,_ _kocesTradeCode:String,_ _compCode:String,
                     _ _mStoreName:String, _ _mStoreAddr:String,_ _mStoreNumber:String,_ _mStorePhone:String,_ _mStoreOwner:String) -> Void)?
    
    var mpaySdk:PaySdk = PaySdk()
    var mKocesSdk:KocesSdk = KocesSdk.instance
    var mCatSdk:CatSdk = CatSdk.instance
    let mTaxCalc = TaxCalculator.Instance
    var paylistener: payResult?
    var catlistener:CatResult?

    @IBOutlet var mCreditTxtFieldMoney: UITextField!    //결제 금액
    @IBOutlet weak var mCreditMoney: UILabel!   //공급가액

    @IBOutlet weak var mCreditTxtTax: UILabel!
    @IBOutlet weak var mCreditTxtSvc: UILabel!  //봉사료
    @IBOutlet weak var mCreditTxtTotalMoney: UILabel!   //결제금액
    
    @IBOutlet var mCreditTxtFieldTaxFree: UITextField!  //비과세
    @IBOutlet weak var mCreditTxtFieldSvc: UITextField!
    
    @IBOutlet weak var mStackView_Money: UIStackView!   //금액 입력 스택뷰
    @IBOutlet weak var mStackView_Txf: UIStackView! //비과세 입력 스택뷰
    @IBOutlet weak var mStack_Svc: UIStackView!     //봉사료 스택뷰
    @IBOutlet var mCreditTxtFieldInstallMent: UITextField!  //할부개월
    @IBOutlet var mCreditInstallMentGroup: UIStackView!     //할부개월
  
    @IBOutlet var mCreditInstallMentMenu: UISegmentedControl!   //일시불 or 할부
 
    var isTouch = "Money"   //금액입력, 비과세입력, 봉사료입력 중 하나
    var mTotalMoney:Int = 0      //결제 금액
    var mMoney:Int = 0  //공급가액
    var mTaxMoney:Int = 0       //세금
    var mSvcMoney:Int = 0   //봉사료
    var mTaxFreeMoney:Int = 0   //비과세
    var mInstallMent:Int = 0    //할부개월
    let mInstallMentArray = ["2","3","4","5","6","7","8","9","10",
                             "11","12","13","14","15","16","17","18","19","20",
                             "21","22","23","24","25","26","27","28","29","30",
                             "31","32","33","34","35","36","37","38","39","40",
                             "41","42","43","44","45","46","47","48","49","50",
                             "51","52","53","54","55","56","57","58","59","60",
                             "61","62","63","64","65","66","67","68","69","70",
                             "71","72","73","74","75","76","77","78","79","80",
                             "81","82","83","84","85","86","87","88","89","90",
                             "91","92","93","94","95","96","97","98","99"]
    
    @IBOutlet weak var numberPad: NumberPad!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
        initRes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func exitButtonTapped() {
        // 모달로 present된 경우 dismiss 처리
        dismiss(animated: true, completion: nil)
    }
    
    func setupNavigationBar() {
        // 왼쪽에 커스텀 백 버튼 생성: "chevron.backward" 이미지 + "BACK" 텍스트
        let backButton = UIButton(type: .system)
        if let backImage = UIImage(systemName: "chevron.backward") {
            backButton.setImage(backImage, for: .normal)
        }
        // 이미지와 텍스트 사이에 약간의 공백을 주기 위해 앞에 공백 추가
        backButton.setTitle(" Back", for: .normal)
        
        // 아이콘과 텍스트 모두 흰색으로 설정
        backButton.tintColor = define.txt_blue
        backButton.setTitleColor(define.txt_blue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        // 크기 조정
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        // 커스텀 버튼을 좌측 바 버튼 아이템으로 설정
        let leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        // 중앙 타이틀 설정
        navigationItem.title = "카드결제"
        
        // 네비게이션바의 배경 및 타이틀 색상 설정 (모든 텍스트 흰색, 배경 검정)
        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = .black
            navBar.backgroundColor = .black
            navBar.tintColor = .white
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
  
    func initRes(){
        // 앱 UI 설정값에 따라 분기처리
        let appUISetting = Setting.shared.getDefaultUserData(_key: define.APP_UI_CHECK)
        if appUISetting == define.UIMethod.Product.rawValue {
            setupNavigationBar()
        } else {
            //네비게이션 바의 배경색 rgb 변경
            UISetting.navigationTitleSetting(navigationBar: navigationController?.navigationBar ?? UINavigationBar())
        }
//        mCreditTxtFieldMoney.text = ""
        mCreditTxtFieldMoney.placeholder = "금액을 입력해주세요"
        mCreditTxtFieldTaxFree.placeholder = "금액을 입력해주세요"
//        mCreditTxtFieldTaxFree.text = ""
        createInstallMentTargetPickerView()
        dismissPickerView()
        mCreditTxtFieldInstallMent.tintColor = .clear
        mCreditTxtFieldInstallMent.textAlignment = .right
        mCreditTxtFieldMoney.textAlignment = .right
        mCreditTxtFieldTaxFree.textAlignment = .right
        mCreditTxtFieldSvc.textAlignment = .right   //봉사료 필드 입력값 오른쪽 정렬
        mCreditInstallMentGroup.alpha = 0.0
        mCreditInstallMentMenu.selectedSegmentIndex = 0


        numberPad.delegate = self
        numberPad.emptyKeyBackgroundColor = .clear

        //봉사료를 사용하지 않는 경우 봉사료 항목을 숨긴다.
        if mTaxCalc.mApplySvc != TaxCalculator.TAXParameter.Use {
            mStack_Svc.isHidden = true
            mStack_Svc.alpha = 0.0
        }
        else{
            mStack_Svc.isHidden = false
            mStack_Svc.alpha = 1.0
            
            //봉사료 수동 입력의 경우
            if mTaxCalc.mSvcMethod == TaxCalculator.TAXParameter.Auto {
                mCreditTxtFieldSvc.isHidden = true
                mCreditTxtFieldSvc.alpha = 0.0
                mCreditTxtSvc.isHidden = false
                mCreditTxtSvc.alpha = 1.0
            }
            else{
                mCreditTxtFieldSvc.isHidden = false
                mCreditTxtFieldSvc.alpha = 1.0
                mCreditTxtSvc.isHidden = true
                mCreditTxtSvc.alpha = 0.0
                isTouch = "Svc"
                mCreditTxtFieldSvc.backgroundColor = .white
                mCreditTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                mCreditTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
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
            mCreditTxtFieldTaxFree.backgroundColor = .white
            mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
            mCreditTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
        }
        
        //부가세 미설정시 금액 입력이 보이지 않게 처리 한다. 비과세만 입력가능 2021-07-21 kim.jy
        if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use {
            mStackView_Money.isHidden = true
            mStackView_Money.alpha = 0.0
        }else{
            mStackView_Money.isHidden = false
            mStackView_Money.alpha = 1.0
            isTouch = "Money"
            mCreditTxtFieldMoney.backgroundColor = .white
            mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
            mCreditTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
        }
    }
   

    @IBAction func clicked_money(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Money"
        mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
        mCreditTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
        mCreditTxtFieldMoney.backgroundColor = .white
        sender.resignFirstResponder()
    }
    
    @IBAction func clicked_txf(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Txf"
        mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
        mCreditTxtFieldTaxFree.backgroundColor = .white
        mCreditTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
        sender.resignFirstResponder()
    }
    
    @IBAction func clicked_svc(_ sender: UITextField, forEvent event: UIEvent) {
        isTouch = "Svc"
        mCreditTxtFieldSvc.backgroundColor = .white
        mCreditTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
        mCreditTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
        sender.resignFirstResponder()
    }
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    
    func CreditTextFieldDidChange(_ textField: UITextField) {
        let money:Int = Int(mCreditTxtFieldMoney.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        var _taxFree:String = mCreditTxtFieldTaxFree.text!.replacingOccurrences(of: ",", with: "")
        mTaxFreeMoney = Int(mCreditTxtFieldTaxFree.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        var serviceCharge:Int = 0
        
        ///봉사료를 사용하고 수동입력의 경우에 입력을 받아서 처리 한다.
        if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use && mTaxCalc.mSvcMethod == TaxCalculator.TAXParameter.Manual{
            if mCreditTxtFieldSvc.text == nil{
                serviceCharge = 0
            }else{
                serviceCharge = Int(mCreditTxtFieldSvc.text!.replacingOccurrences(of: ",", with: "")) ?? 0
            }
        }
        //2021-07-21 kim.jy 부가세 사용의 경우 금액이 10원 이하면 리턴
//        if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
//            if (money + mTaxFreeMoney) < 1 {
//
//                return
//            }
//        }else{
//            if mTaxFreeMoney < 1 {
//                
//                return
//            }
//        }
        //if money < 10 { return } //입력 금액이 10원 보다 적은 경우
        
        textField.text = Utils.PrintMoney(Money: textField.text!.replacingOccurrences(of: ",", with: ""))
        let tax:[String:Int] = mTaxCalc.TaxCalc(금액: money,비과세금액: mTaxFreeMoney, 봉사료: serviceCharge, BleUse: mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED ? true:false )
        mMoney = tax["Money"]!
        mTaxMoney = tax["VAT"]!
        mSvcMoney = tax["SVC"]!
        mTaxFreeMoney = tax["TXF"]!

        mTotalMoney = mMoney + mTaxMoney + mSvcMoney
        mCreditTxtTotalMoney.text = Utils.PrintMoney(Money: "\(mTotalMoney)")
        if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
            mTotalMoney = mMoney + mTaxMoney + mSvcMoney + mTaxFreeMoney
            mCreditTxtTotalMoney.text = Utils.PrintMoney(Money: "\(mTotalMoney)")
        }
        mCreditMoney.text = Utils.PrintMoney(Money: "\(mMoney)")
        mCreditTxtTax.text = Utils.PrintMoney(Money: "\(mTaxMoney)")
        //if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use {
            mCreditTxtSvc.text = Utils.PrintMoney(Money: "\(mSvcMoney)")
        //}
        if mTaxFreeMoney == 0 && _taxFree.isEmpty {
            mCreditTxtFieldTaxFree.text = ""
        } else {
            mCreditTxtFieldTaxFree.text = Utils.PrintMoney(Money: "\(mTaxFreeMoney)")
        }
        /** 화면상에 표시되는 공급가액 금액을 CAT 처럼 맞추기 위해 일부러 한번 더 한다 */
        let tax2:[String:Int] = mTaxCalc.TaxCalc(금액: money,비과세금액: mTaxFreeMoney, 봉사료: serviceCharge, BleUse: false )
        mCreditMoney.text = Utils.PrintMoney(Money: "\(tax2["Money"]!)")
    }
 
    
    @IBAction func SelectedInstallMentMenu(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            mCreditInstallMentGroup.isHidden = true
            mCreditInstallMentGroup.alpha = 0.0
        }
        else
        {
            getMoney()
            //2020-06-21 할부 최소 금액은 원금을 기준으로 한다. 비과세를 빼서 계산 하지 않는다. kim.jy
            //2022-02-21 할부 최소 금액은 총거래금액을 기준으로 한다. 비과세를 빼서 계산 하지 않는다. sjw
            if (mTotalMoney) >= Int(Setting.shared.getDefaultUserData(_key: define.INSTALLMENT_MINVALUE))! {
            //if (mTotalMoney - mTaxFreeMoney) > Setting.shared.InstallMentMinimum {
            mCreditInstallMentGroup.isHidden = false
            mCreditInstallMentGroup.alpha = 1.0
            }
            else
            {
                AlertBox(title: "에러", message: "할부 최소금액은 \(Setting.shared.getDefaultUserData(_key: define.INSTALLMENT_MINVALUE))원 이상입니다.", text: "확인" )
                sender.selectedSegmentIndex = 0
            }
        }
    }
    
    func dismissPickerView() {
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector (CreditController.HidePickerView))
            toolBar.setItems([button], animated: true)
            toolBar.isUserInteractionEnabled = true
        mCreditTxtFieldInstallMent.inputAccessoryView = toolBar
    }
    
    /**
     금액 설정해서 체크 해야 할게 많아서 금액만 가져오는 부분 따로 처리
     */
    func getMoney(){
        mTotalMoney = Int(mCreditTxtTotalMoney.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        mTaxFreeMoney = Int(mCreditTxtFieldTaxFree.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        mTaxMoney = Int(mCreditTxtTax.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        mSvcMoney = Int(mCreditTxtSvc.text!.replacingOccurrences(of: ",", with: "")) ?? 0  //강제로 숫자만 입력하게 되어 있지만 MAC에서 강제로 영문이나 기타 문자등을 입력한 경우에 대비하여 옆에 같이 처리 한다
        mInstallMent = mCreditInstallMentMenu.selectedSegmentIndex == 1 ? Int(mCreditTxtFieldInstallMent.text!) ?? 0 : 0 //할부설정의 경우에만 할부 개월 수를 설정한다.
    }
    
    /**
     금액설정이 정상적인지를 체크한다
     */
    func checkMoneyValue() -> Bool {
        getMoney()

        if (mTotalMoney + mTaxFreeMoney) < 10 {
            AlertBox(title: "에러", message: mKocesSdk.getStringPlist(Key: "err_main_input_value_less_than_0"), text: "확인" )
            return false
        }
       
        //나쁜 의도로 할부 설정을 하고 나서 금액을 수정해서 신용결제를 요청하는 경우가 발생할 수 있기 때문에
//        if (mTotalMoney - mTaxFreeMoney) <= Setting.shared.InstallMentMinimum && mCreditInstallMentMenu.selectedSegmentIndex == 1 {
//            //이런 경우를 의도적으로 만들면 나쁜 사람
//            AlertBox(title: "에러", message: "할부 최소금액은 \(Setting.shared.InstallMentMinimum + 1)원 이상입니다.", text: "확인" )
//            return false
//        }
        //2020-06-21 할부 최소 금액은 원금을 기준으로 한다. kim.jy
        if (mTotalMoney) < Int(Setting.shared.getDefaultUserData(_key: define.INSTALLMENT_MINVALUE))! && mCreditInstallMentMenu.selectedSegmentIndex == 1 {
            //이런 경우를 의도적으로 만들면 나쁜 사람
            AlertBox(title: "에러", message: "할부 최소금액은 \(Int(Setting.shared.getDefaultUserData(_key: define.INSTALLMENT_MINVALUE))!)원 이상입니다.", text: "확인" )
            return false
        }
        
        //아이폰,아이패드 터치외에 키보드를 사용하여 입력하는 경우 이상한 문자의 겨우 getMoney()에서 처리 비과세 - 의 경우 처리
        if mTaxFreeMoney < 0 {
            AlertBox(title: "에러", message: "비과세는 마이너스 금액 사용불가\n경우에 따라서는 거래 정지", text: "확인" )
            return false
        }
        
        //jiw 추가. 세금, 봉사료의 합이 원금을 넘을 수 없다
        
//        if (mTotalMoney - mTaxMoney - mSvcMoney) < 0 && mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
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

extension CreditController: PayResultDelegate,CatResultDelegate {
    func onPaymentResult(payTitle _status: payStatus, payResult _message: Dictionary<String, String>) {
        // 카드애니메이션뷰 컨트롤러가 여전히 떠있으니 해당 뷰를 지운다
        Utils.CardAnimationViewControllerClear()
        
        var _totalString:String = ""    //메세지
        var _title:String = "[카드거래]"          //타이틀
        var keyCount:Int = 0
        switch _message["TrdType"] {
        case Command.CMD_IC_OK_RES:
            _title = "[카드거래]"
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
            _title = "[카드거래]"
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
                var _msg = _message["Message"] ?? _message["ERROR"] ?? "거래실패"
                if _msg.replacingOccurrences(of: " ", with: "") == "" {
                    _msg = "응답 데이터 이상"
                }
                let alertController = UIAlertController(title: _title, message: _msg, preferredStyle: UIAlertController.Style.alert)
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
    

    
    func startPayment(Tid _Tid:String,Money _money:String,Tax _tax:Int,ServiceCharge _serviceCharge:Int,TaxFree _txf:Int,InstallMent _installment:String,
                      CancenInfo _cancelInfo:String,mchData _mchData:String,KocesTreadeCode _kocesTradeCode:String,CompCode _compCode:String,
                      StoreName _mStoreName:String, StoreAddr _mStoreAddr:String,StoreNumber _mStoreNumber:String,StorePhone _mStorePhone:String,StoreOwner _mStoreOwner:String) {
        let appUISetting = Setting.shared.getDefaultUserData(_key: define.APP_UI_CHECK)
        if appUISetting == define.UIMethod.Product.rawValue {
            let result = "B에서 전달한 결과값"
            onDismiss?( _Tid, _money, _tax, _serviceCharge, _txf, _installment,
                        _cancelInfo, _mchData, _kocesTradeCode, _compCode,
                        _mStoreName,  _mStoreAddr, _mStoreNumber, _mStorePhone, _mStoreOwner)
            dismiss(animated: true, completion: nil)
            return
        }
        
        paylistener = payResult()
        paylistener?.delegate = self

        mpaySdk.CreditIC(Tid: _Tid, Money: _money, Tax: _tax, ServiceCharge: _serviceCharge, TaxFree: _txf, InstallMent: _installment, OriDate: "", CancenInfo: _cancelInfo, mchData: _mchData, KocesTreadeCode: _kocesTradeCode, CompCode: _compCode, SignDraw: "1", FallBackUse: "0",payLinstener: paylistener?.delegate! as! PayResultDelegate,StoreName: _mStoreName,StoreAddr: _mStoreAddr,StoreNumber: _mStoreNumber,StorePhone: _mStorePhone,StoreOwner: _mStoreOwner)
        
       
    }

    func onResult(CatState _state: payStatus, Result _message: Dictionary<String, String>) {
        Utils.CatAnimationViewInitClear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if _state == .OK {
                let alertController = UIAlertController(title: "[CAT카드거래]", message: "거래가 정상적으로 완료되었습니다", preferredStyle: UIAlertController.Style.alert)
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
                let alertController = UIAlertController(title: "[CAT카드거래]", message: _msg, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
                    self.tabBarController?.delegate = self
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }
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
                if (mCreditTxtFieldMoney.text!.isEmpty) {
                    //만일 텍스트가 비어있다면?
                    isTouch = "Money"
                    mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                    mCreditTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                    mCreditTxtFieldMoney.backgroundColor = .white
                    return
                }
            }
            
            //만약에 부가세 방법이 자동인 경우에는 비과세 입력 필드를 표시 하지 않는다.
            if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use || mTaxCalc.mVatMethod != TaxCalculator.TAXParameter.Auto {
                //비과세을 사용
                if (mCreditTxtFieldTaxFree.text!.isEmpty) {
                    //만일 텍스트가 비어있다면?
                    isTouch = "Txf"
                    mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                    mCreditTxtFieldTaxFree.backgroundColor = .white
                    mCreditTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
                    return
                }
            }

            if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use {
                //봉사료을 사용
                
                if mTaxCalc.mSvcMethod != TaxCalculator.TAXParameter.Auto {
                    //봉사료 수동 입력의 경우
                    if (mCreditTxtFieldSvc.text!.isEmpty) {
                        //만일 텍스트가 비어있다면?
                        isTouch = "Svc"
                        mCreditTxtFieldSvc.backgroundColor = .white
                        mCreditTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                        mCreditTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
                        return
                    }
                }

            }

        } else {
            //부가세 미설정시 금액 입력이 보이지 않게 처리 한다. 비과세만 입력가능 2021-07-21 kim.jy
            if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                //금액입력을 사용
                if (mCreditTxtFieldMoney.text!.isEmpty) {
                    //만일 텍스트가 비어있다면?
                    isTouch = "Money"
                    mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                    mCreditTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                    mCreditTxtFieldMoney.backgroundColor = .white
                    return
                }
            }
            
            //만약에 부가세 방법이 자동인 경우에는 비과세 입력 필드를 표시 하지 않는다.
            if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use || mTaxCalc.mVatMethod != TaxCalculator.TAXParameter.Auto {
                //비과세을 사용
                if (mCreditTxtFieldTaxFree.text!.isEmpty) {
                    if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                        isTouch = "Money"
                        mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                        mCreditTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                        mCreditTxtFieldMoney.backgroundColor = .white
                        return
                    }
                    //만일 텍스트가 비어있다면?
                    isTouch = "Txf"
                    mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                    mCreditTxtFieldTaxFree.backgroundColor = .white
                    mCreditTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
                    return
                }
            }
            
            if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use {
                //봉사료을 사용
                
                if mTaxCalc.mSvcMethod != TaxCalculator.TAXParameter.Auto {
                    //봉사료 수동 입력의 경우
                    if (mCreditTxtFieldSvc.text!.isEmpty) {
                        if mTaxCalc.mApplyVat != TaxCalculator.TAXParameter.Use || mTaxCalc.mVatMethod != TaxCalculator.TAXParameter.Auto {
                            //만일 텍스트가 비어있다면?
                            isTouch = "Txf"
                            mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                            mCreditTxtFieldTaxFree.backgroundColor = .white
                            mCreditTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
                            return
                        }
                        
                        if mTaxCalc.mApplyVat == TaxCalculator.TAXParameter.Use {
                            isTouch = "Money"
                            mCreditTxtFieldSvc.backgroundColor = define.layout_border_lightgrey
                            mCreditTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                            mCreditTxtFieldMoney.backgroundColor = .white
                            return
                        }
                        
                        //만일 텍스트가 비어있다면?
                        isTouch = "Svc"
                        mCreditTxtFieldSvc.backgroundColor = .white
                        mCreditTxtFieldTaxFree.backgroundColor = define.layout_border_lightgrey
                        mCreditTxtFieldMoney.backgroundColor = define.layout_border_lightgrey
                        return
                    }
                }

            }

        }
       
        isTouch = ""

    }

}

extension CreditController:UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITabBarControllerDelegate{
    //탭바로 다른 탭 이동시 네비게이션은 초기로 이동한다
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }


    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mInstallMentArray.count
    }


    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mInstallMentArray[row]
    }


    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        mCreditTxtFieldInstallMent.text = mInstallMentArray[row]
    }
    
    func createInstallMentTargetPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        mCreditTxtFieldInstallMent.inputView = pickerView
        mCreditTxtFieldInstallMent.text = mInstallMentArray[0]
    }
    
    @objc func HidePickerView()
    {
        mCreditTxtFieldInstallMent.resignFirstResponder()
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
                if Utils.getIsCAT() {
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
extension CreditController: NumberPadDelegate {
    func keyPressed(key: NumberKey?) {
        guard let number = key else {
            return
        }

        switch number {
        case .delete:
            switch isTouch {
            case "Money":
                guard !(mCreditTxtFieldMoney.text?.isEmpty ?? true) else {
                    mCreditTxtFieldMoney.text = ""
                    TxtUpdate(IsNext: false)
                    return
                }
                mCreditTxtFieldMoney.text?.removeLast()
                if mCreditTxtFieldMoney.text!.isEmpty {
                    TxtUpdate(IsNext: false)
                }
                CreditTextFieldDidChange(mCreditTxtFieldMoney)
                break
            case "Txf":
                guard !(mCreditTxtFieldTaxFree.text?.isEmpty ?? true) else {
                    mCreditTxtFieldTaxFree.text = ""
                    TxtUpdate(IsNext: false)
                    return
                }
                mCreditTxtFieldTaxFree.text?.removeLast()
                if mCreditTxtFieldTaxFree.text!.isEmpty {
                    TxtUpdate(IsNext: false)
                }
                CreditTextFieldDidChange(mCreditTxtFieldTaxFree)
                break
            case "Svc":
                guard !(mCreditTxtFieldSvc.text?.isEmpty ?? true) else {
                    mCreditTxtFieldSvc.text = ""
                    TxtUpdate(IsNext: false)
                    return
                }
                mCreditTxtFieldSvc.text?.removeLast()
                if mCreditTxtFieldSvc.text!.isEmpty {
                    TxtUpdate(IsNext: false)
                }
                CreditTextFieldDidChange(mCreditTxtFieldSvc)
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
            default:
                break
            }
            let alert = UIAlertController(title: "Custom NumberPad Event",
                                          message: "\(mCreditTxtFieldMoney.text ?? "") Send Number", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .clear:
            switch isTouch {
            case "Money":
                guard !(mCreditTxtFieldMoney.text?.isEmpty ?? true) else {
                    return
                }
                mCreditTxtFieldMoney.text = ""
                TxtUpdate(IsNext: false)
                CreditTextFieldDidChange(mCreditTxtFieldMoney)
                return
            case "Txf":
                guard !(mCreditTxtFieldTaxFree.text?.isEmpty ?? true) else {
                    return
                }
                mCreditTxtFieldTaxFree.text = ""
                TxtUpdate(IsNext: false)
                CreditTextFieldDidChange(mCreditTxtFieldTaxFree)
                return
            case "Svc":
                guard !(mCreditTxtFieldSvc.text?.isEmpty ?? true) else {
                    return
                }
                mCreditTxtFieldSvc.text = ""
                TxtUpdate(IsNext: false)
                CreditTextFieldDidChange(mCreditTxtFieldSvc)
                return
            default:
                break
            }
  
            break
        case .key00:
            switch isTouch {
            case "Money":
                mCreditTxtFieldMoney.text?.append("00")
                break
            case "Txf":
                mCreditTxtFieldTaxFree.text?.append("00")
                break
            case "Svc":
                mCreditTxtFieldSvc.text?.append("00")
                break
            default:
                break
            }
  
            break
        case .key010:
            switch isTouch {
            case "Money":
                mCreditTxtFieldMoney.text?.append("010")
                break
            case "Txf":
                mCreditTxtFieldTaxFree.text?.append("010")
                break
            case "Svc":
                mCreditTxtFieldSvc.text?.append("010")
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
            default:
                break
            }
            
            if isTouch != "" {
                return
            }
            
            mpaySdk.Clear()
            mpaySdk = PaySdk.instance
            mCatSdk.Clear()
            mCatSdk = CatSdk.instance
            paylistener = payResult()
            paylistener?.delegate = self
            catlistener = CatResult()
            catlistener?.delegate = self
            
            var _tid:String = Setting.shared.getDefaultUserData(_key: define.STORE_TID)
            mTaxFreeMoney = Int((mCreditTxtFieldTaxFree.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
            let money:Int = Int((mCreditTxtFieldMoney.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
            var serviceCharge:Int = 0
            if mTaxCalc.mApplySvc == TaxCalculator.TAXParameter.Use && mTaxCalc.mSvcMethod == TaxCalculator.TAXParameter.Manual {
                serviceCharge = Int((mCreditTxtFieldSvc.text?.replacingOccurrences(of: ",", with: ""))!) ?? 0
            }
            let tax:[String:Int]  = mTaxCalc.TaxCalc(금액: money,비과세금액: mTaxFreeMoney, 봉사료: serviceCharge, BleUse: mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED ? false:true )
            let mMoney:Int = tax["Money"]!
            mTaxMoney = tax["VAT"]!
            mSvcMoney = tax["SVC"]!
            mTaxFreeMoney = tax["TXF"]!
            //여기서 부터 신용결제 프로세스를 진행한다
            if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
    //            if mMultiStoreUse.isOn {
                if Setting.shared.getDefaultUserData(_key: define.MULTI_STORE) != "" {
                    TidAlertBox(title: "거래하실 가맹점을 선택해 주세요") { [self](BSN,TID,NUM,PHONE,OWNER,ADDR) in
                        if TID == "" {
                            AlertBox(title: "거래를 종료합니다.", message: "", text: "확인")
                            return
                        }
                        _tid = TID
    //                    let creditMoney = Utils.leftPad(str: String(mMoney), fillChar: "0", length: 10)
                        let creditMoney = String(mMoney)
                        startPayment(Tid: _tid, Money: creditMoney, Tax: mTaxMoney, ServiceCharge: mSvcMoney, TaxFree: mTaxFreeMoney, InstallMent: String(mInstallMent), CancenInfo: "", mchData: "", KocesTreadeCode: "", CompCode: "",StoreName: BSN,StoreAddr: ADDR,StoreNumber: NUM,StorePhone: PHONE,StoreOwner: OWNER)
                    }
                    return
                }
                //                    let creditMoney = Utils.leftPad(str: String(mMoney), fillChar: "0", length: 10)
                                    let creditMoney = String(mMoney)
                startPayment(Tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID), Money: creditMoney, Tax: mTaxMoney, ServiceCharge: mSvcMoney, TaxFree: mTaxFreeMoney, InstallMent: String(mInstallMent), CancenInfo: "", mchData: "", KocesTreadeCode: "", CompCode: "",StoreName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME),StoreAddr: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR),StoreNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN),StorePhone: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE),StoreOwner: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
            } else if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
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
    //                    let creditMoney = Utils.leftPad(str: String(mMoney), fillChar: "0", length: 10)
                        mCatSdk.PayCredit(TID: _tid, 거래금액: String(mMoney), 세금: String(mTaxMoney), 봉사료: String(mSvcMoney), 비과세: String(mTaxFreeMoney), 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: String(mInstallMent), 취소: false, 가맹점데이터: "", 여유필드: "", StoreName: BSN, StoreAddr: ADDR, StoreNumber: NUM, StorePhone: PHONE, StoreOwner: OWNER,CompletionCallback: catlistener?.delegate! as! CatResultDelegate)
                    }
                    return
                }
                mCatSdk.PayCredit(TID: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID), 거래금액: String(mMoney), 세금: String(mTaxMoney), 봉사료: String(mSvcMoney), 비과세: String(mTaxFreeMoney), 원거래일자: "", 원승인번호: "", 코세스거래고유번호: "", 할부: String(mInstallMent), 취소: false, 가맹점데이터: "", 여유필드: "", StoreName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME), StoreAddr: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR), StoreNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN), StorePhone: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE), StoreOwner: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER),CompletionCallback: catlistener?.delegate! as! CatResultDelegate)
            } else {
                AlertBox(title: "에러", message: "연결 가능한 단말기가 존재하지 않습니다", text: "확인" )
            }
            return
        default:
            switch isTouch {
            case "Money":
                mCreditTxtFieldMoney.text?.append("\(number.rawValue)")
                break
            case "Txf":
                mCreditTxtFieldTaxFree.text?.append("\(number.rawValue)")
                break
            case "Svc":
                mCreditTxtFieldSvc.text?.append("\(number.rawValue)")
                break
            default:
                break
            }
    
        }
        
        switch isTouch {
        case "Money":
            CreditTextFieldDidChange(mCreditTxtFieldMoney)
            break
        case "Txf":
            CreditTextFieldDidChange(mCreditTxtFieldTaxFree)
            break
        case "Svc":
            CreditTextFieldDidChange(mCreditTxtFieldSvc)
            break
        default:
            break
        }
 
    }
}
