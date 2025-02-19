//
//  OrderViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/17/25.
//

import Foundation
import UIKit
import SwiftUI

class OrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PayResultDelegate, UITabBarControllerDelegate {
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
                    self.tabBarController?.delegate = self
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }
        
        }
    }
    
    
    // MARK: - Data (외부에서 전달받음)
    var basketItems: [BasketItem] = [] // ProductHomeViewController에서 전달받은 장바구니 항목들
    
    // MARK: - UI Components
    
    // 전체 좌우 컨테이너
    private let leftContainer = UIView()
    private let rightContainer = UIView()
    // 좌측 영역을 상단(70%)과 하단(30%)으로 분할
    private let leftTopContainer = UIView()
    private let leftBottomContainer = UIView()
    // 우측 영역을 상단(70%)과 하단(30%)으로 분할
    private let rightTopContainer = UIView()
    private let rightBottomContainer = UIView()
    
    // 세금 계산을 위한
    var taxResult:[String:Int] = [:]  //결과값
    let mTaxCalc = TaxCalculator.Instance
    
    var mpaySdk:PaySdk = PaySdk()
    var mKocesSdk:KocesSdk = KocesSdk.instance
    var mCatSdk:CatSdk = CatSdk.instance
    var paylistener: payResult?
    var catlistener:CatResult?
    
    // 좌측 상단: 선택 상품 목록 (테이블뷰)
    private let productTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // 좌측 하단: 요약 정보 (회색 배경)
    private let summaryContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // 요약 정보 레이블들
    private let supplyLabel = OrderViewController.createSummaryRow(labelText: "공급가액", valueText: "")
    private let taxLabel = OrderViewController.createSummaryRow(labelText: "세금", valueText: "")
    private let untaxedLabel = OrderViewController.createSummaryRow(labelText: "비과세", valueText: "")
    private let serviceLabel = OrderViewController.createSummaryRow(labelText: "봉사료", valueText: "")
    private let totalLabel = OrderViewController.createSummaryRow(labelText: "총액", valueText: "")
    
    // 우측 상단: 결제금액 영역 (회색 배경)
    private let paymentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let paymentLeftLabel: UILabel = {
        let label = UILabel()
        label.text = "결제금액"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let paymentValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0원"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 우측 하단: 결제방식 영역
    private let paymentMethodTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "결제방식"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let paymentButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let paymentMethodButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let cardButton: UIButton = OrderViewController.createPaymentButton(title: "카드결제")
    private let cashButton: UIButton = OrderViewController.createPaymentButton(title: "현금결제")
    private let easyButton: UIButton = OrderViewController.createPaymentButton(title: "간편결제")
    private let otherButton: UIButton = OrderViewController.createPaymentButton(title: "기타결제")
    
    // 구분 라인 (좌우 영역 사이)
    private let verticalDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 예시 데이터 (실제 데이터는 ProductHomeViewController에서 전달)
//        if basketItems.isEmpty {
//            basketItems = [
//                BasketItem(product: Product(id: 1, name: "상품A", price: 10000), quantity: 2),
//                BasketItem(product: Product(id: 2, name: "상품B", price: 20000), quantity: 1),
//                BasketItem(product: Product(id: 3, name: "상품C", price: 15000), quantity: 3)
//            ]
//        }
        
        setupLayout()
        productTableView.dataSource = self
        productTableView.delegate = self
        
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateSummary()
    }
    
    // MARK: - Layout Setup
    private func setupLayout() {
        // 전체 좌우 컨테이너를 추가 (leftContainer, rightContainer, 그리고 가운데 구분 라인)
        view.addSubview(leftContainer)
        view.addSubview(rightContainer)
        view.addSubview(verticalDivider)
        leftContainer.translatesAutoresizingMaskIntoConstraints = false
        rightContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftContainer.topAnchor.constraint(equalTo: view.topAnchor),
            leftContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            
            rightContainer.topAnchor.constraint(equalTo: view.topAnchor),
            rightContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            
            verticalDivider.widthAnchor.constraint(equalToConstant: 1),
            verticalDivider.topAnchor.constraint(equalTo: view.topAnchor),
            verticalDivider.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            verticalDivider.leadingAnchor.constraint(equalTo: leftContainer.trailingAnchor)
        ])
        
        // 좌측 영역 내부: 분할 (상단과 하단)
        let leftVerticalStack = UIStackView(arrangedSubviews: [leftTopContainer, leftBottomContainer])
        leftVerticalStack.axis = .vertical
        leftVerticalStack.spacing = 1 // 구분 언더라인 역할
        leftVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        leftContainer.addSubview(leftVerticalStack)
        NSLayoutConstraint.activate([
            leftVerticalStack.topAnchor.constraint(equalTo: leftContainer.topAnchor),
            leftVerticalStack.leadingAnchor.constraint(equalTo: leftContainer.leadingAnchor),
            leftVerticalStack.trailingAnchor.constraint(equalTo: leftContainer.trailingAnchor),
            leftVerticalStack.bottomAnchor.constraint(equalTo: leftContainer.bottomAnchor)
        ])
        // 상단: 70%, 하단: 30%
        leftTopContainer.heightAnchor.constraint(equalTo: leftVerticalStack.heightAnchor, multiplier: 0.7).isActive = true
        
        // 좌측 상단: 상품 목록 테이블뷰
        leftTopContainer.addSubview(productTableView)
        NSLayoutConstraint.activate([
            productTableView.topAnchor.constraint(equalTo: leftTopContainer.topAnchor),
            productTableView.leadingAnchor.constraint(equalTo: leftTopContainer.leadingAnchor),
            productTableView.trailingAnchor.constraint(equalTo: leftTopContainer.trailingAnchor),
            productTableView.bottomAnchor.constraint(equalTo: leftTopContainer.bottomAnchor)
        ])
        
        // 좌측 상단과 하단 사이 언더라인
        let leftSeparator = UIView()
        leftSeparator.backgroundColor = .lightGray
        leftSeparator.translatesAutoresizingMaskIntoConstraints = false
        leftVerticalStack.insertArrangedSubview(leftSeparator, at: 1)
        leftSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // 좌측 하단: 요약 정보 (회색 배경 컨테이너)
        leftBottomContainer.addSubview(summaryContainer)
        NSLayoutConstraint.activate([
            summaryContainer.topAnchor.constraint(equalTo: leftBottomContainer.topAnchor, constant: 10),
            summaryContainer.leadingAnchor.constraint(equalTo: leftBottomContainer.leadingAnchor, constant: 10),
            summaryContainer.trailingAnchor.constraint(equalTo: leftBottomContainer.trailingAnchor, constant: -10),
            summaryContainer.bottomAnchor.constraint(equalTo: leftBottomContainer.bottomAnchor, constant: -10)
        ])
        // summaryContainer 내부: 수직 스택뷰로 각 행 배치
//        var supply = basketItems.reduce(0) { $0 + ((Int($1.product.) ?? 0) * $1.quantity) }
        let summaryStack = UIStackView(arrangedSubviews: [supplyLabel, taxLabel, untaxedLabel, serviceLabel, totalLabel])
        summaryStack.axis = .vertical
        summaryStack.spacing = 5
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        summaryContainer.addSubview(summaryStack)
        NSLayoutConstraint.activate([
            summaryStack.topAnchor.constraint(equalTo: summaryContainer.topAnchor, constant: 10),
            summaryStack.leadingAnchor.constraint(equalTo: summaryContainer.leadingAnchor, constant: 10),
            summaryStack.trailingAnchor.constraint(equalTo: summaryContainer.trailingAnchor, constant: -10),
            summaryStack.bottomAnchor.constraint(equalTo: summaryContainer.bottomAnchor, constant: -10)
        ])
        
        // 우측 영역 내부: 분할 (상단, 하단)
        let rightVerticalStack = UIStackView(arrangedSubviews: [rightTopContainer, rightBottomContainer])
        rightVerticalStack.axis = .vertical
        rightVerticalStack.spacing = 1
        rightVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        rightContainer.addSubview(rightVerticalStack)
        NSLayoutConstraint.activate([
            rightVerticalStack.topAnchor.constraint(equalTo: rightContainer.topAnchor),
            rightVerticalStack.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor),
            rightVerticalStack.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor),
            rightVerticalStack.bottomAnchor.constraint(equalTo: rightContainer.bottomAnchor)
        ])
        rightTopContainer.heightAnchor.constraint(equalTo: rightVerticalStack.heightAnchor, multiplier: 0.7).isActive = true
        
        // 우측 상단: 결제금액 영역 (회색 배경)
        let paymentContainer = UIView()
        paymentContainer.backgroundColor = UIColor.systemGray5
        paymentContainer.layer.cornerRadius = 8
        paymentContainer.clipsToBounds = true
        paymentContainer.translatesAutoresizingMaskIntoConstraints = false
        rightTopContainer.addSubview(paymentContainer)
        NSLayoutConstraint.activate([
            paymentContainer.topAnchor.constraint(equalTo: rightTopContainer.topAnchor, constant: 10),
            paymentContainer.leadingAnchor.constraint(equalTo: rightTopContainer.leadingAnchor, constant: 10),
            paymentContainer.trailingAnchor.constraint(equalTo: rightTopContainer.trailingAnchor, constant: -10),
            paymentContainer.bottomAnchor.constraint(equalTo: rightTopContainer.bottomAnchor, constant: -10)
        ])
        // 내부: "결제금액" 좌측, 값 우측
        paymentContainer.addSubview(paymentLeftLabel)
        paymentContainer.addSubview(paymentValueLabel)
        NSLayoutConstraint.activate([
            paymentLeftLabel.topAnchor.constraint(equalTo: paymentContainer.topAnchor, constant: 10),
            paymentLeftLabel.leadingAnchor.constraint(equalTo: paymentContainer.leadingAnchor, constant: 10),
            paymentLeftLabel.bottomAnchor.constraint(equalTo: paymentContainer.bottomAnchor, constant: -10),
            
            paymentValueLabel.topAnchor.constraint(equalTo: paymentContainer.topAnchor, constant: 10),
            paymentValueLabel.trailingAnchor.constraint(equalTo: paymentContainer.trailingAnchor, constant: -10),
            paymentValueLabel.bottomAnchor.constraint(equalTo: paymentContainer.bottomAnchor, constant: -10)
        ])
        
        // 우측 하단: 결제방식 영역
        // 상단에 "결제방식" 레이블
        let paymentMethodTitleLabel = UILabel()
        paymentMethodTitleLabel.text = "결제방식"
        paymentMethodTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        paymentMethodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rightBottomContainer.addSubview(paymentMethodTitleLabel)
        NSLayoutConstraint.activate([
            paymentMethodTitleLabel.topAnchor.constraint(equalTo: rightBottomContainer.topAnchor, constant: 10),
            paymentMethodTitleLabel.leadingAnchor.constraint(equalTo: rightBottomContainer.leadingAnchor, constant: 10),
            paymentMethodTitleLabel.trailingAnchor.constraint(equalTo: rightBottomContainer.trailingAnchor, constant: -10)
        ])
        // 아래에 4개의 결제 버튼을 담은 수평 스택뷰
        paymentMethodButtonStack.addArrangedSubview(cardButton)
        paymentMethodButtonStack.addArrangedSubview(cashButton)
        paymentMethodButtonStack.addArrangedSubview(easyButton)
        paymentMethodButtonStack.addArrangedSubview(otherButton)
        rightBottomContainer.addSubview(paymentMethodButtonStack)
        NSLayoutConstraint.activate([
            paymentMethodButtonStack.topAnchor.constraint(equalTo: paymentMethodTitleLabel.bottomAnchor, constant: 10),
            paymentMethodButtonStack.leadingAnchor.constraint(equalTo: rightBottomContainer.leadingAnchor, constant: 10),
            paymentMethodButtonStack.trailingAnchor.constraint(equalTo: rightBottomContainer.trailingAnchor, constant: -10),
            paymentMethodButtonStack.heightAnchor.constraint(equalToConstant: 40),
            paymentMethodButtonStack.bottomAnchor.constraint(lessThanOrEqualTo: rightBottomContainer.bottomAnchor, constant: -10)
        ])
        
        // 버튼 액션 연결 (예시)
        cardButton.addTarget(self, action: #selector(cardButtonTapped), for: .touchUpInside)
        cashButton.addTarget(self, action: #selector(cashButtonTapped), for: .touchUpInside)
        easyButton.addTarget(self, action: #selector(easyButtonTapped), for: .touchUpInside)
        otherButton.addTarget(self, action: #selector(otherButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Summary Helper
    static func createSummaryRow(labelText: String, valueText: String) -> UIView {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 10
        hStack.distribution = .fillProportionally
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = valueText
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        hStack.addArrangedSubview(label)
        hStack.addArrangedSubview(valueLabel)
        return hStack
    }
    
    // MARK: - Payment Button Helper
    static func createPaymentButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - Payment Button Actions
    @objc func cardButtonTapped() {
        print("카드결제 버튼 클릭")
        let storyboard:UIStoryboard? = getStoryBoard()
//        let controller = (storyboard!.instantiateViewController(identifier: "CreditController")) as CreditController
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "CreditController") as? CreditController else { return }
              
              // B가 dismiss될 때 호출될 클로저 설정
        controller.onDismiss = { [self] tid, money, tax, serviceCharge, txf, installment, cancelInfo, mchData, kocesTradeCode, compCode, mStoreName, mStoreAddr, mStoreNumber, mStorePhone, mStoreOwner in
            // 전달받은 값을 사용하여 필요한 작업을 수행합니다.
            print("TID: \(tid)")
            print("Money: \(money)")
            print("Tax: \(tax)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.paylistener = payResult()
                paylistener?.delegate = self
                // ... 나머지 값들 처리
                mpaySdk.CreditIC(Tid: tid, Money: money, Tax: tax, ServiceCharge: serviceCharge, TaxFree: txf, InstallMent: installment, OriDate: "", CancenInfo: cancelInfo, mchData: mchData, KocesTreadeCode: kocesTradeCode, CompCode: compCode, SignDraw: "1", FallBackUse: "0",payLinstener: paylistener?.delegate! as! PayResultDelegate,StoreName: mStoreName,StoreAddr: mStoreAddr,StoreNumber: mStoreNumber,StorePhone: mStorePhone,StoreOwner: mStoreOwner)
            }
          
        }
   
        // 모달 내비게이션 컨트롤러로 감싸서 내비게이션 바를 사용할 수 있게 함
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .formSheet
        navController.transitioningDelegate = controller  // 또는 별도로 지정
        self.present(navController, animated: true, completion: nil)
    }
    @objc func cashButtonTapped() {
        print("현금결제 버튼 클릭")
        let storyboard:UIStoryboard? = getStoryBoard()
        let controller = (storyboard!.instantiateViewController(identifier: "CashController")) as CashController
        // 모달 내비게이션 컨트롤러로 감싸서 내비게이션 바를 사용할 수 있게 함
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .automatic
        navController.transitioningDelegate = controller  // 또는 별도로 지정
        self.present(navController, animated: true, completion: nil)
    }
    @objc func easyButtonTapped() {
        print("간편결제 버튼 클릭")
        let storyboard:UIStoryboard? = getStoryBoard()
        let controller = (storyboard!.instantiateViewController(identifier: "EasyPayController")) as EasyPayController
        // 모달 내비게이션 컨트롤러로 감싸서 내비게이션 바를 사용할 수 있게 함
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .automatic
        navController.transitioningDelegate = controller  // 또는 별도로 지정
        self.present(navController, animated: true, completion: nil)
    }
    @objc func otherButtonTapped() {
        print("기타결제 버튼 클릭")
    }
    
    func getStoryBoard() -> UIStoryboard? {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            return UIStoryboard(name: "pad", bundle: Bundle.main)
        }
    }
    
    // MARK: - Total 계산 및 UI 업데이트
    func updateSummary() {
        //계산을 위한 값
        var _total:Int = 0
        var _money:Int = 0
        var _txf:Int = 0
        var _svc:Int = 0
        var _vat:Int = 0
        
        //계산하여 나온 값
        var conMoney:Int = 0
        var conMoney2:Int = 0
        var conTXF:Int = 0
        var conSVC:Int = 0
        var conVAT:Int = 0
        
        // 각 상품들 갯수 및 총 갯수
        var _count = 0
        var _totalCount = 0
        
        //금액 계산
        var taxvalue:[String:Int]
        // 화면상에 표시되는 공급가액 금액을 CAT 처럼 맞추기 위해 일부러 한번 더 한다
        var taxvalue2:[String:Int]
        
        let _deviceCheck:Bool = Utils.getIsCAT() ? false:true

        for i in 0..<basketItems.count {
            var n = basketItems[i].product
            var quantity = basketItems[i].quantity
            if basketItems[i].product.useVAT == 0 {
                // 과세
                _money = n.price * quantity
                _svc = (Int(n.svcWon) ?? 0) * quantity
                _vat = (Int(n.vatWon) ?? 0) * quantity
                taxvalue = mTaxCalc.TaxCalcProduct(금액: _money, 비과세금액: 0, 봉사료액: _svc, 봉사료자동수동: n.autoSVC, 부가세자동수동: n.autoVAT, 봉사료율: n.svcRate, 부가세율: n.vatRate, 봉사료포함미포함: n.includeSVC, 부가세포함미포함: n.includeVAT, 봉사료사용미사용: n.useSVC, 부가세사용미사용: n.useVAT, 부가세액: _vat, BleUse: _deviceCheck)
                conMoney += taxvalue["Money"] ?? 0
                conVAT += taxvalue["VAT"] ?? 0
                conSVC += taxvalue["SVC"] ?? 0
                conTXF += taxvalue["TXF"] ?? 0
                    
                taxvalue2 = mTaxCalc.TaxCalcProduct(금액: _money, 비과세금액: 0, 봉사료액: _svc, 봉사료자동수동: n.autoSVC, 부가세자동수동: n.autoVAT, 봉사료율: n.svcRate, 부가세율: n.vatRate, 봉사료포함미포함: n.includeSVC, 부가세포함미포함: n.includeVAT, 봉사료사용미사용: n.useSVC, 부가세사용미사용: n.useVAT, 부가세액: _vat, BleUse: _deviceCheck)
                   
                /** 화면상에 표시되는 공급가액 금액을 CAT 처럼 맞추기 위해 일부러 한번 더 한다 */
                taxvalue2  = mTaxCalc.TaxCalcProduct(금액: _money, 비과세금액: 0, 봉사료액: _svc, 봉사료자동수동: n.autoSVC, 부가세자동수동: n.autoVAT, 봉사료율: n.svcRate, 부가세율: n.vatRate, 봉사료포함미포함: n.includeSVC, 부가세포함미포함: n.includeVAT, 봉사료사용미사용: n.useSVC, 부가세사용미사용: n.useVAT, 부가세액: _vat, BleUse: false)

                conMoney2 += taxvalue2["Money"] ?? 0
            } else {
                // 비과세
                _txf = n.price * quantity
                _svc = (Int(n.svcWon) ?? 0) * quantity
                _vat = (Int(n.vatWon) ?? 0) * quantity
                taxvalue = mTaxCalc.TaxCalcProduct(금액: 0, 비과세금액: _txf, 봉사료액: _svc, 봉사료자동수동: n.autoSVC, 부가세자동수동: n.autoVAT, 봉사료율: n.svcRate, 부가세율: n.vatRate, 봉사료포함미포함: n.includeSVC, 부가세포함미포함: n.includeVAT, 봉사료사용미사용: n.useSVC, 부가세사용미사용: n.useVAT, 부가세액: _vat, BleUse: _deviceCheck)
                conMoney += taxvalue["Money"] ?? 0
                conVAT += taxvalue["VAT"] ?? 0
                conSVC += taxvalue["SVC"] ?? 0
                conTXF += taxvalue["TXF"] ?? 0
    
            }
            
            _count = _count + 1
            _totalCount = _totalCount + quantity
        }
        
        // 각 summary row의 value는 자식 뷰에 포함된 UILabel을 찾아 업데이트할 수 있는데,
        // 여기서는 summaryContainer 내에 있는 summaryStack의 각 row의 두번째 label의 text를 업데이트하는 방식으로 처리합니다.
        // (실제 구현에서는 별도의 IBOutlet 또는 태그를 활용할 수 있습니다.)
        // 예시로 summaryContainer의 서브뷰들을 업데이트하는 코드는 생략합니다.
        
        // 예시 계산식 (실제 계산 로직에 따라 수정)
        let supply = basketItems.reduce(0) { $0 + ($1.product.price * $1.quantity) }
        let tax = Int(Double(supply) * 0.1)
        let untaxed = 0
        let service = Int(Double(supply) * 0.05)
        let total = _deviceCheck ? String(conMoney + conVAT + conSVC):String(conMoney + conVAT + conSVC + conTXF)

        // 각 summary row의 두 번째 라벨 업데이트
        updateSummaryRow(supplyLabel, with: "\(conMoney2)원")
        updateSummaryRow(taxLabel, with: "\(conVAT)원")
        updateSummaryRow(untaxedLabel, with: "\(conTXF)원")
        updateSummaryRow(serviceLabel, with: "\(conSVC)원")
        updateSummaryRow(totalLabel, with: "\(total)원")
        // 결제금액은 총합과 동일하게 처리 (예시)
        paymentValueLabel.text = "\(total)원"
        
        taxResult = [:]
        taxResult["Money"] = conMoney
        taxResult["VAT"] = conVAT
        taxResult["SVC"] = conSVC
        taxResult["TXF"] = conTXF
    }
    
    /// summary row (UIStackView)에서 두 번째 자식 UILabel을 찾아 text를 업데이트하는 헬퍼 함수
    func updateSummaryRow(_ rowView: UIView, with text: String) {
        if let stack = rowView as? UIStackView, stack.arrangedSubviews.count >= 2,
           let valueLabel = stack.arrangedSubviews[1] as? UILabel {
            valueLabel.text = text
        }
    }
    
    // MARK: - UITableViewDataSource & Delegate (Left Top: 상품 목록)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basketItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let item = basketItems[indexPath.row]
        cell.textLabel?.text = "\(item.product.name)    \(item.quantity)    \(item.product.price)원"
        return cell
    }
}

