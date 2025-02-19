//
//  ProductModifyViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2/5/25.
//

import Foundation
import UIKit
import SDWebImage
import SDWebImageWebPCoder

class ProductModifyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate  {
    var product: Product?  // 수정할 상품 정보
    
    
    // MARK: - UI Elements
    
    // 상단: 좌측 타이틀, 우측 저장 버튼
    let topBar = UIView()
    let titleLabel = UILabel()
    let saveButton = UIButton(type: .system)
    
    // 좌우 분할 컨테이너 (중앙에 라인)
    let mainContainer = UIView()
    let divider = UIView()
    
    // 왼쪽 스크롤 영역 및 내용 스택뷰
    let leftScrollView = UIScrollView()
    let leftStack = UIStackView()
    
    // 오른쪽 스크롤 영역 및 내용 스택뷰
    let rightScrollView = UIScrollView()
    let rightStack = UIStackView()
    
    // ── 왼쪽 화면 구성 ──
    
    // 1. 상품명
    let productNameLabel = UILabel()
    let productNameTextField = UITextField()
    
    // 2. 상품분류 + 선택버튼 + 선택된 명칭 표시
    let productCategoryLabel = UILabel()
    let productCategoryValueLabel = UILabel()  // 선택된 상품분류명칭 표시
    let selectCategoryButton = UIButton(type: .system)
    // 상품분류 선택에 사용할 예시 리스트
    let classificationList = sqlite.instance.getCategoryList()
    
    // 3. 거래금액
    let transactionAmountLabel = UILabel()
    let transactionAmountTextField = UITextField()
    
    // 4. 과세여부 (스위치)
    let taxableLabel = UILabel()
    let taxableSwitch = UISwitch()
    
    // 5. 부가세방식 (세그먼트: 자동/수동) – taxable일 때만 보임
    let vatModeContainer = UIStackView()
    let vatModeLabel = UILabel()
    let vatModeSegmented = UISegmentedControl(items: ["자동", "수동"])
    
    // 6. 부가세계산방식 (세그먼트: 포함/미포함) – taxable일 때만 보임
    let vatCalcContainer = UIStackView()
    let vatCalcLabel = UILabel()
    let vatCalcSegmented = UISegmentedControl(items: ["포함", "미포함"])
    
    // 7. 부가세율 (텍스트필드) – taxable && (vatMode == 자동)
    let vatRateContainer = UIStackView()
    let vatRateLabel = UILabel()
    let vatRateTextField = UITextField()
    
    // 8. 부가세액 (텍스트필드) – taxable && (vatMode == 수동)
    let vatAmountContainer = UIStackView()
    let vatAmountLabel = UILabel()
    let vatAmountTextField = UITextField()
    
    // 9. 봉사료적용 (스위치)
    let svcableLabel = UILabel()
    let svcableSwitch = UISwitch()
    
    // 10. 봉사료방식 (세그먼트: 자동/수동) – svcable일 때만 보임
    let svcModeContainer = UIStackView()
    let svcModeLabel = UILabel()
    let svcModeSegmented = UISegmentedControl(items: ["자동", "수동"])
    
    // 11. 봉사료계산방식 (세그먼트: 포함/미포함) – svcable일 때만 보임
    let svcCalcContainer = UIStackView()
    let svcCalcLabel = UILabel()
    let svcCalcSegmented = UISegmentedControl(items: ["포함", "미포함"])
    
    // 12. 봉사료율 (텍스트필드) – svcable && (svcMode == 자동)
    let svcRateContainer = UIStackView()
    let svcRateLabel = UILabel()
    let svcRateTextField = UITextField()
    
    // 13. 봉사료액 (텍스트필드) – svcable && (svcMode == 수동)
    let svcAmountContainer = UIStackView()
    let svcAmountLabel = UILabel()
    let svcAmountTextField = UITextField()
    
    // 14. 사용여부 (세그먼트: 사용/미사용)
    let usageLabel = UILabel()
    let usageSegmented = UISegmentedControl(items: ["사용", "미사용"])
    
    
    // ── 오른쪽 화면 구성 ──
    
    // 10. 이미지뷰
    let productImageView = UIImageView()
    
    // 11. 이미지등록 / 이미지제거 버튼 (가운데 좌측에 빈 뷰 포함)
    let imageButtonsContainer = UIStackView()
    let imageButtonSpacer = UIView()
    let registerImageButton = UIButton(type: .system)
    let removeImageButton = UIButton(type: .system)
    
    // 12. 기본이미지사용 (세그먼트: 사용/미사용)
    let defaultImageLabel = UILabel()
    let defaultImageSegmented = UISegmentedControl(items: ["사용", "미사용"])
    
    // 13. 하단 라운드 뷰 내 공급가액, 세금, 비과세, 봉사료, 결제금액
    let pricingContainer = UIView()
    let pricingStack = UIStackView()
    let supplyPriceLabel = UILabel()
    let supplyPriceTextField = UILabel()
    let taxLabel = UILabel()
    let taxTextField = UILabel()
    let nonTaxLabel = UILabel()
    let nonTaxTextField = UILabel()
    let serviceChargeLabel = UILabel()
    let serviceChargeTextField = UILabel()
    let paymentAmountLabel = UILabel()
    let paymentAmountTextField = UILabel()
    
    let mTaxCalc = TaxCalculator.Instance
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // UI 설정
        setupNavigationBar()
        setupTopBar()
        setupMainContainer()
        setupLeftSide()
        setupRightSide()
        
        // 기본값 및 타겟 설정
        setupDefaultData()
        
        // 수정할 상품데이터 설정
        setupModifyData()
    }
    
    @objc private func exitButtonTapped() {
        // 모달로 present된 경우 dismiss 처리
        // 수정 완료 알림을 전송
           NotificationCenter.default.post(name: Notification.Name("ProductModified"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    // 가로 모드 전용
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    // MARK: - Setup UI Methods
    
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
        navigationItem.title = "상품수정"
        
        // 네비게이션바의 배경 및 타이틀 색상 설정 (모든 텍스트 흰색, 배경 검정)
        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = .black
            navBar.backgroundColor = .black
            navBar.tintColor = .white
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
    
    func setupTopBar() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        // 타이틀 레이블
        titleLabel.text = "상품설정"
        titleLabel.font = Utils.getSubTitleFont()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(titleLabel)
        
        // 저장 버튼
        saveButton.setTitle("저장", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 20),
            
            saveButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -20)
        ])
    }
    
    func setupMainContainer() {
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainContainer)
        
        // 좌우 분할: 왼쪽, 오른쪽, 그리고 중앙 divider
        leftScrollView.translatesAutoresizingMaskIntoConstraints = false
        rightScrollView.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .lightGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        mainContainer.addSubview(leftScrollView)
        mainContainer.addSubview(rightScrollView)
        mainContainer.addSubview(divider)
        
        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 왼쪽 스크롤뷰: 전체 너비의 절반 - divider 폭
            leftScrollView.topAnchor.constraint(equalTo: mainContainer.topAnchor),
            leftScrollView.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            leftScrollView.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
            leftScrollView.widthAnchor.constraint(equalTo: mainContainer.widthAnchor, multiplier: 0.5, constant: -1),
            
            // 오른쪽 스크롤뷰
            rightScrollView.topAnchor.constraint(equalTo: mainContainer.topAnchor),
            rightScrollView.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
            rightScrollView.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
            rightScrollView.widthAnchor.constraint(equalTo: mainContainer.widthAnchor, multiplier: 0.5, constant: -1),
            
            // divider: 중앙에 위치
            divider.widthAnchor.constraint(equalToConstant: 2),
            divider.topAnchor.constraint(equalTo: mainContainer.topAnchor),
            divider.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
            divider.centerXAnchor.constraint(equalTo: mainContainer.centerXAnchor)
        ])
    }
    
    func setupLeftSide() {
        leftStack.axis = .vertical
        leftStack.spacing = 15
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftScrollView.addSubview(leftStack)
        
        NSLayoutConstraint.activate([
            leftStack.topAnchor.constraint(equalTo: leftScrollView.topAnchor, constant: 20),
            leftStack.leadingAnchor.constraint(equalTo: leftScrollView.leadingAnchor, constant: 20),
            leftStack.trailingAnchor.constraint(equalTo: leftScrollView.trailingAnchor, constant: -20),
            leftStack.bottomAnchor.constraint(equalTo: leftScrollView.bottomAnchor, constant: -20),
            leftStack.widthAnchor.constraint(equalTo: leftScrollView.widthAnchor, constant: -40)
        ])
        
        // Row 1: 상품명
        let productNameRow = createTextFieldRow(labelText: "상품명", textField: productNameTextField)
        leftStack.addArrangedSubview(productNameRow)
        
        // Row 2: 상품분류
        let categoryRow = UIView()
        categoryRow.translatesAutoresizingMaskIntoConstraints = false
        
        productCategoryLabel.text = "상품분류"
        productCategoryLabel.font = UIFont.systemFont(ofSize: 16)
        productCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryRow.addSubview(productCategoryLabel)
        
        productCategoryValueLabel.text = ""
        productCategoryValueLabel.font = UIFont.systemFont(ofSize: 16)
        productCategoryValueLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryRow.addSubview(productCategoryValueLabel)
        
        selectCategoryButton.setTitle("선택", for: .normal)
        selectCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryRow.addSubview(selectCategoryButton)
        
        NSLayoutConstraint.activate([
            productCategoryLabel.topAnchor.constraint(equalTo: categoryRow.topAnchor),
            productCategoryLabel.leadingAnchor.constraint(equalTo: categoryRow.leadingAnchor),
            productCategoryLabel.widthAnchor.constraint(equalToConstant: 100),
            productCategoryLabel.bottomAnchor.constraint(equalTo: categoryRow.bottomAnchor),
            
            selectCategoryButton.topAnchor.constraint(equalTo: categoryRow.topAnchor),
            selectCategoryButton.trailingAnchor.constraint(equalTo: categoryRow.trailingAnchor),
            selectCategoryButton.widthAnchor.constraint(equalToConstant: 60),
            selectCategoryButton.bottomAnchor.constraint(equalTo: categoryRow.bottomAnchor),
            
            productCategoryValueLabel.centerYAnchor.constraint(equalTo: categoryRow.centerYAnchor),
            productCategoryValueLabel.leadingAnchor.constraint(equalTo: productCategoryLabel.trailingAnchor, constant: 10),
            productCategoryValueLabel.trailingAnchor.constraint(equalTo: selectCategoryButton.leadingAnchor, constant: -10)
        ])
        leftStack.addArrangedSubview(categoryRow)
        
        // Row 3: 거래금액
        let transactionRow = createTextFieldRow(labelText: "거래금액", textField: transactionAmountTextField)
        leftStack.addArrangedSubview(transactionRow)
        
        // Row 4: 과세여부 (라벨 + 스위치)
        let taxableRow = UIView()
        taxableRow.translatesAutoresizingMaskIntoConstraints = false
        
        taxableLabel.text = "과세여부"
        taxableLabel.font = UIFont.systemFont(ofSize: 16)
        taxableLabel.translatesAutoresizingMaskIntoConstraints = false
        taxableRow.addSubview(taxableLabel)
        
        taxableSwitch.translatesAutoresizingMaskIntoConstraints = false
        taxableRow.addSubview(taxableSwitch)
        
        NSLayoutConstraint.activate([
            taxableLabel.topAnchor.constraint(equalTo: taxableRow.topAnchor),
            taxableLabel.leadingAnchor.constraint(equalTo: taxableRow.leadingAnchor),
            taxableLabel.bottomAnchor.constraint(equalTo: taxableRow.bottomAnchor),
            taxableSwitch.centerYAnchor.constraint(equalTo: taxableRow.centerYAnchor),
            taxableSwitch.trailingAnchor.constraint(equalTo: taxableRow.trailingAnchor)
        ])
        leftStack.addArrangedSubview(taxableRow)
        
        // Row 5: 부가세방식 (세그먼트)
        vatModeContainer.axis = .horizontal
        vatModeContainer.spacing = 10
        vatModeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        vatModeLabel.text = "부가세방식"
        vatModeLabel.font = UIFont.systemFont(ofSize: 16)
        vatModeLabel.translatesAutoresizingMaskIntoConstraints = false
        vatModeContainer.addArrangedSubview(vatModeLabel)
        
        vatModeSegmented.translatesAutoresizingMaskIntoConstraints = false
        vatModeContainer.addArrangedSubview(vatModeSegmented)
        leftStack.addArrangedSubview(vatModeContainer)
        
        // Row 6: 부가세계산방식
        vatCalcContainer.axis = .horizontal
        vatCalcContainer.spacing = 10
        vatCalcContainer.translatesAutoresizingMaskIntoConstraints = false
        
        vatCalcLabel.text = "부가세계산방식"
        vatCalcLabel.font = UIFont.systemFont(ofSize: 16)
        vatCalcLabel.translatesAutoresizingMaskIntoConstraints = false
        vatCalcContainer.addArrangedSubview(vatCalcLabel)
        
        vatCalcSegmented.translatesAutoresizingMaskIntoConstraints = false
        vatCalcContainer.addArrangedSubview(vatCalcSegmented)
        leftStack.addArrangedSubview(vatCalcContainer)
        
        // Row 7: 부가세율
        vatRateContainer.axis = .horizontal
        vatRateContainer.spacing = 10
        vatRateContainer.translatesAutoresizingMaskIntoConstraints = false
        
        vatRateLabel.text = "부가세율"
        vatRateLabel.font = UIFont.systemFont(ofSize: 16)
        vatRateLabel.translatesAutoresizingMaskIntoConstraints = false
        vatRateContainer.addArrangedSubview(vatRateLabel)
        
        vatRateTextField.borderStyle = .roundedRect
        vatRateTextField.translatesAutoresizingMaskIntoConstraints = false
        vatRateContainer.addArrangedSubview(vatRateTextField)
        leftStack.addArrangedSubview(vatRateContainer)
        
        // Row 8: 부가세액
        vatAmountContainer.axis = .horizontal
        vatAmountContainer.spacing = 10
        vatAmountContainer.translatesAutoresizingMaskIntoConstraints = false
        
        vatAmountLabel.text = "부가세액"
        vatAmountLabel.font = UIFont.systemFont(ofSize: 16)
        vatAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        vatAmountContainer.addArrangedSubview(vatAmountLabel)
        
        vatAmountTextField.borderStyle = .roundedRect
        vatAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        vatAmountContainer.addArrangedSubview(vatAmountTextField)
        leftStack.addArrangedSubview(vatAmountContainer)
  
        // Row 9: 봉사료적용 (라벨 + 스위치)
        let svcableRow = UIView()
        svcableRow.translatesAutoresizingMaskIntoConstraints = false
        
        svcableLabel.text = "봉사료적용"
        svcableLabel.font = UIFont.systemFont(ofSize: 16)
        svcableLabel.translatesAutoresizingMaskIntoConstraints = false
        svcableRow.addSubview(svcableLabel)
        
        svcableSwitch.translatesAutoresizingMaskIntoConstraints = false
        svcableRow.addSubview(svcableSwitch)
        
        NSLayoutConstraint.activate([
            svcableLabel.topAnchor.constraint(equalTo: svcableRow.topAnchor),
            svcableLabel.leadingAnchor.constraint(equalTo: svcableRow.leadingAnchor),
            svcableLabel.bottomAnchor.constraint(equalTo: svcableRow.bottomAnchor),
            svcableSwitch.centerYAnchor.constraint(equalTo: svcableRow.centerYAnchor),
            svcableSwitch.trailingAnchor.constraint(equalTo: svcableRow.trailingAnchor)
        ])
        leftStack.addArrangedSubview(svcableRow)
        
        // Row 10: 봉사료방식 (세그먼트)
        svcModeContainer.axis = .horizontal
        svcModeContainer.spacing = 10
        svcModeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        svcModeLabel.text = "봉사료방식"
        svcModeLabel.font = UIFont.systemFont(ofSize: 16)
        svcModeLabel.translatesAutoresizingMaskIntoConstraints = false
        svcModeContainer.addArrangedSubview(svcModeLabel)
        
        svcModeSegmented.translatesAutoresizingMaskIntoConstraints = false
        svcModeContainer.addArrangedSubview(svcModeSegmented)
        leftStack.addArrangedSubview(svcModeContainer)
        
        // Row 11: 봉사료계산방식
        svcCalcContainer.axis = .horizontal
        svcCalcContainer.spacing = 10
        svcCalcContainer.translatesAutoresizingMaskIntoConstraints = false
        
        svcCalcLabel.text = "봉사료계산방식"
        svcCalcLabel.font = UIFont.systemFont(ofSize: 16)
        svcCalcLabel.translatesAutoresizingMaskIntoConstraints = false
        svcCalcContainer.addArrangedSubview(svcCalcLabel)
        
        svcCalcSegmented.translatesAutoresizingMaskIntoConstraints = false
        svcCalcContainer.addArrangedSubview(svcCalcSegmented)
        leftStack.addArrangedSubview(svcCalcContainer)
        
        // Row 12: 봉사료율
        svcRateContainer.axis = .horizontal
        svcRateContainer.spacing = 10
        svcRateContainer.translatesAutoresizingMaskIntoConstraints = false
        
        svcRateLabel.text = "봉사료율"
        svcRateLabel.font = UIFont.systemFont(ofSize: 16)
        svcRateLabel.translatesAutoresizingMaskIntoConstraints = false
        svcRateContainer.addArrangedSubview(svcRateLabel)
        
        svcRateTextField.borderStyle = .roundedRect
        svcRateTextField.translatesAutoresizingMaskIntoConstraints = false
        svcRateContainer.addArrangedSubview(svcRateTextField)
        leftStack.addArrangedSubview(svcRateContainer)
        
        // Row 13: 봉사료액
        svcAmountContainer.axis = .horizontal
        svcAmountContainer.spacing = 10
        svcAmountContainer.translatesAutoresizingMaskIntoConstraints = false
        
        svcAmountLabel.text = "봉사료액"
        svcAmountLabel.font = UIFont.systemFont(ofSize: 16)
        svcAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        svcAmountContainer.addArrangedSubview(svcAmountLabel)
        
        svcAmountTextField.borderStyle = .roundedRect
        svcAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        svcAmountContainer.addArrangedSubview(svcAmountTextField)
        leftStack.addArrangedSubview(svcAmountContainer)
 
        // Row 14: 사용여부
        let usageRow = UIView()
        usageRow.translatesAutoresizingMaskIntoConstraints = false
        
        usageLabel.text = "사용여부"
        usageLabel.font = UIFont.systemFont(ofSize: 16)
        usageLabel.translatesAutoresizingMaskIntoConstraints = false
        usageRow.addSubview(usageLabel)
        
        usageSegmented.translatesAutoresizingMaskIntoConstraints = false
        usageRow.addSubview(usageSegmented)
        
        NSLayoutConstraint.activate([
            usageLabel.topAnchor.constraint(equalTo: usageRow.topAnchor),
            usageLabel.leadingAnchor.constraint(equalTo: usageRow.leadingAnchor),
            usageLabel.bottomAnchor.constraint(equalTo: usageRow.bottomAnchor),
            usageSegmented.centerYAnchor.constraint(equalTo: usageRow.centerYAnchor),
            usageSegmented.trailingAnchor.constraint(equalTo: usageRow.trailingAnchor)
        ])
        leftStack.addArrangedSubview(usageRow)
    }
    
    func setupRightSide() {
        rightStack.axis = .vertical
        rightStack.spacing = 15
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightScrollView.addSubview(rightStack)
        
        NSLayoutConstraint.activate([
            rightStack.topAnchor.constraint(equalTo: rightScrollView.topAnchor, constant: 20),
            rightStack.leadingAnchor.constraint(equalTo: rightScrollView.leadingAnchor, constant: 20),
            rightStack.trailingAnchor.constraint(equalTo: rightScrollView.trailingAnchor, constant: -20),
            rightStack.bottomAnchor.constraint(equalTo: rightScrollView.bottomAnchor, constant: -20),
            rightStack.widthAnchor.constraint(equalTo: rightScrollView.widthAnchor, constant: -40)
        ])
        
        // Row 1: 이미지뷰
        productImageView.contentMode = .scaleAspectFit
        productImageView.backgroundColor = .lightGray
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        rightStack.addArrangedSubview(productImageView)
        productImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        // Row 2: 이미지등록 / 이미지제거 버튼 행
        imageButtonsContainer.axis = .horizontal
        imageButtonsContainer.spacing = 10
        imageButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        imageButtonSpacer.translatesAutoresizingMaskIntoConstraints = false
        imageButtonsContainer.addArrangedSubview(imageButtonSpacer)
        
        registerImageButton.setTitle("이미지등록", for: .normal)
        registerImageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButtonsContainer.addArrangedSubview(registerImageButton)
        
        removeImageButton.setTitle("이미지제거", for: .normal)
        removeImageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButtonsContainer.addArrangedSubview(removeImageButton)
        
        rightStack.addArrangedSubview(imageButtonsContainer)
        
        // Row 3: 기본이미지사용
        let defaultImageRow = UIView()
        defaultImageRow.translatesAutoresizingMaskIntoConstraints = false
        
        defaultImageLabel.text = "기본이미지사용"
        defaultImageLabel.font = UIFont.systemFont(ofSize: 16)
        defaultImageLabel.translatesAutoresizingMaskIntoConstraints = false
        defaultImageRow.addSubview(defaultImageLabel)
        
        defaultImageSegmented.translatesAutoresizingMaskIntoConstraints = false
        defaultImageRow.addSubview(defaultImageSegmented)
        
        NSLayoutConstraint.activate([
            defaultImageLabel.topAnchor.constraint(equalTo: defaultImageRow.topAnchor),
            defaultImageLabel.leadingAnchor.constraint(equalTo: defaultImageRow.leadingAnchor),
            defaultImageLabel.bottomAnchor.constraint(equalTo: defaultImageRow.bottomAnchor),
            defaultImageSegmented.centerYAnchor.constraint(equalTo: defaultImageRow.centerYAnchor),
            defaultImageSegmented.trailingAnchor.constraint(equalTo: defaultImageRow.trailingAnchor)
        ])
        rightStack.addArrangedSubview(defaultImageRow)
        
        // Row 4: 라운드 박스 내 가격정보
        pricingContainer.backgroundColor = .white
        pricingContainer.layer.cornerRadius = 8
        pricingContainer.layer.borderWidth = 1
        pricingContainer.layer.borderColor = define.layout_border_lightgrey.cgColor
        pricingContainer.layer.backgroundColor = define.layout_border_lightgrey.cgColor
        pricingContainer.translatesAutoresizingMaskIntoConstraints = false
        rightStack.addArrangedSubview(pricingContainer)
        
        pricingStack.axis = .vertical
        pricingStack.spacing = 10
        pricingStack.translatesAutoresizingMaskIntoConstraints = false
        pricingContainer.addSubview(pricingStack)
        
        NSLayoutConstraint.activate([
            pricingStack.topAnchor.constraint(equalTo: pricingContainer.topAnchor, constant: 10),
            pricingStack.leadingAnchor.constraint(equalTo: pricingContainer.leadingAnchor, constant: 10),
            pricingStack.trailingAnchor.constraint(equalTo: pricingContainer.trailingAnchor, constant: -10),
            pricingStack.bottomAnchor.constraint(equalTo: pricingContainer.bottomAnchor, constant: -10)
        ])
        
        // 공급가액, 세금, 비과세, 봉사료, 결제금액 각 행
        let supplyRow = createRow(labelText: "공급가액", textField: supplyPriceTextField)
        pricingStack.addArrangedSubview(supplyRow)
        
        let taxRow = createRow(labelText: "세금", textField: taxTextField)
        pricingStack.addArrangedSubview(taxRow)
        
        let nonTaxRow = createRow(labelText: "비과세", textField: nonTaxTextField)
        pricingStack.addArrangedSubview(nonTaxRow)
        
        let serviceChargeRow = createRow(labelText: "봉사료", textField: serviceChargeTextField)
        pricingStack.addArrangedSubview(serviceChargeRow)
        
        let paymentRow = createRow(labelText: "결제금액", textField: paymentAmountTextField)
        pricingStack.addArrangedSubview(paymentRow)
    }
    
    func setupDefaultData() {
        taxableSwitch.isOn = true       //부가세는 기본이 사용
        vatModeSegmented.selectedSegmentIndex = 0  // 자동
        vatCalcSegmented.selectedSegmentIndex = 0   // 포함
        updateTaxViewsVisibility()

        svcableSwitch.isOn = false      //봉사료는 기본이 미사용
        svcModeSegmented.selectedSegmentIndex = 0  // 자동
        svcCalcSegmented.selectedSegmentIndex = 0   // 포함
        updateSvcViewsVisibility()
        
        usageSegmented.selectedSegmentIndex = 1 //사용
        defaultImageSegmented.selectedSegmentIndex = 1  //사용
        
        selectCategoryButton.addTarget(self, action: #selector(selectCategoryTapped), for: .touchUpInside)
        taxableSwitch.addTarget(self, action: #selector(taxableSwitchChanged), for: .valueChanged)
        vatModeSegmented.addTarget(self, action: #selector(vatModeChanged), for: .valueChanged)
        svcableSwitch.addTarget(self, action: #selector(svcableSwitchChanged), for: .valueChanged)
        svcModeSegmented.addTarget(self, action: #selector(svcModeChanged), for: .valueChanged)
        registerImageButton.addTarget(self, action: #selector(registerImageTapped), for: .touchUpInside)
        removeImageButton.addTarget(self, action: #selector(removeImageTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // 숫자 전용 입력
        transactionAmountTextField.keyboardType = .numberPad
        vatRateTextField.keyboardType = .numberPad
        vatAmountTextField.keyboardType = .numberPad
        svcRateTextField.keyboardType = .numberPad
        svcAmountTextField.keyboardType = .numberPad
        
        // 금액 및 세액, 세율 변경 시 통계 실시간수정
        transactionAmountTextField.delegate = self
        vatRateTextField.delegate = self
        vatAmountTextField.delegate = self
        svcRateTextField.delegate = self
        svcAmountTextField.delegate = self
        
        // 3. 거래금액
        transactionAmountTextField.text = "0"
        // 7. 부가세율 (텍스트필드) – taxable && (vatMode == 자동)
        vatRateTextField.text = "10"
        // 8. 부가세액 (텍스트필드) – taxable && (vatMode == 수동)
        vatAmountTextField.text = "0"
        // 12. 봉사료율 (텍스트필드) – svcable && (svcMode == 자동)
        svcRateTextField.text = "0"
        // 13. 봉사료액 (텍스트필드) – svcable && (svcMode == 수동)
        svcAmountTextField.text = "0"
        // 토탈금액 합계 처리
        totalMoneyCalcu()
    }
    
    func setupModifyData() {
        productNameTextField.text = product?.name
        productCategoryValueLabel.text = product?.category
        transactionAmountTextField.text = String(product?.price ?? 0)
        taxableSwitch.setOn(product?.useVAT == 0 ? true:false, animated: false)
        vatModeSegmented.selectedSegmentIndex = product?.autoVAT ?? 0
        vatCalcSegmented.selectedSegmentIndex = product?.includeVAT ?? 0
        vatRateTextField.text = String(product?.vatRate ?? 10)
        vatAmountTextField.text = product?.vatWon
        
        svcableSwitch.setOn(product?.useSVC == 0 ? true:false, animated: false)
        svcModeSegmented.selectedSegmentIndex = product?.autoSVC ?? 0
        svcCalcSegmented.selectedSegmentIndex = product?.includeSVC ?? 0
        svcRateTextField.text = String(product?.svcRate ?? 10)
        svcAmountTextField.text = product?.svcWon
        
        usageSegmented.selectedSegmentIndex = product?.isUse ?? 1
//        product?.image
        productImageView.image = product?.image
        
        defaultImageSegmented.selectedSegmentIndex = product?.isImgUse ?? 1
        updateTaxViewsVisibility()
        updateSvcViewsVisibility()
        
        totalMoneyCalcu()
    }
    
    // Helper: 공통 행 생성 (라벨 + 텍스트필드)
    func createTextFieldRow(labelText: String, textField: UITextField) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(textField)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: row.topAnchor),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            label.widthAnchor.constraint(equalToConstant: 100),
            
            textField.topAnchor.constraint(equalTo: row.topAnchor),
            textField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
        return row
    }
    
    func createRow(labelText: String, textField: UILabel) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(textField)
        
        let won = UILabel()
        won.text = "원"
        won.font = UIFont.systemFont(ofSize: 16)
        won.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(won)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: row.topAnchor),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            label.widthAnchor.constraint(equalToConstant: 100),
            
            textField.topAnchor.constraint(equalTo: row.topAnchor),
            textField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
//            textField.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            
            won.topAnchor.constraint(equalTo: row.topAnchor),
            won.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 10),
            won.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            won.widthAnchor.constraint(equalToConstant: 50),
            won.bottomAnchor.constraint(equalTo: row.bottomAnchor),
        ])
        return row
    }
    
    // MARK: - Actions
    
    @objc func taxableSwitchChanged() {
        updateTaxViewsVisibility()
    }
    
    @objc func vatModeChanged() {
        updateTaxViewsVisibility()
    }
    
    @objc func svcableSwitchChanged() {
        updateSvcViewsVisibility()
    }
    
    @objc func svcModeChanged() {
        updateSvcViewsVisibility()
    }
    
    func updateTaxViewsVisibility() {
        let taxable = taxableSwitch.isOn
        vatModeContainer.isHidden = !taxable
        vatCalcContainer.isHidden = !taxable
        if taxable {
            if vatModeSegmented.selectedSegmentIndex == 0 {
                vatRateContainer.isHidden = false
                vatAmountContainer.isHidden = true
            } else {
                vatRateContainer.isHidden = true
                vatAmountContainer.isHidden = false
            }
        } else {
            vatRateContainer.isHidden = true
            vatAmountContainer.isHidden = true
        }
        totalMoneyCalcu()
    }
    
    func updateSvcViewsVisibility() {
        let svcable = svcableSwitch.isOn
        svcModeContainer.isHidden = !svcable
        svcCalcContainer.isHidden = !svcable
        if svcable {
            if svcModeSegmented.selectedSegmentIndex == 0 {
                svcRateContainer.isHidden = false
                svcAmountContainer.isHidden = true
            } else {
                svcRateContainer.isHidden = true
                svcAmountContainer.isHidden = false
            }
        } else {
            svcRateContainer.isHidden = true
            svcAmountContainer.isHidden = true
        }
        totalMoneyCalcu()
    }
    
    private func totalMoneyCalcu() {
        if (transactionAmountTextField.text == nil || transactionAmountTextField.text == ""){
            return
        }
        var _total:Int = 0
        var _money:Int = 0
        var _txf:Int = 0
        
        //금액 계산
        var taxvalue:[String:Int]
        // 화면상에 표시되는 공급가액 금액을 CAT 처럼 맞추기 위해 일부러 한번 더 한다
        var taxvalue2:[String:Int]
        
        if (taxableSwitch.isOn) {
            if transactionAmountTextField.text!.isNumberByRegularExpression {
                _money = Int(transactionAmountTextField.text ?? "0") ?? 0
            } else {
                AlertBox(title: "상품등록 실패", message: "거래금액은 숫자만 입력해 주십시오", text: "확인")
                return
            }
           
        } else {
            _txf = Int(transactionAmountTextField.text ?? "0") ?? 0
        }
    //        private boolean mvatUse = true;         //vat 사용/미사용
    //        private boolean mVatMode = true;        //vat mode auto:true, 통합:false
    //        private boolean mvatInclude = true;     //vat 포함:true 미포함:false
    //        private boolean mSvcUse = false;         //svc 사용/미사용
    //        private boolean msvcMode = true;        //svc mode auto:true, manual:false
    //        private boolean msvcInclude = true;    //svc 포함:true 미포함:false
    //        private int mvatRate = 10;
    //        private int msvcRate = 0;
        let _deviceCheck:Bool = Utils.getIsCAT() ? false:true
       
        var _vatrate:Int = 0
        var _vatwon:Int = 0
        var _svcrate:Int = 0
        var _svcwon:Int = 0
        
        if svcModeSegmented.selectedSegmentIndex == 0 {
            if svcRateTextField.text!.isNumberByRegularExpression {
                _svcrate = Int(svcRateTextField.text ?? "0") ?? 0
            } else {
                AlertBox(title: "상품등록 실패", message: "봉사료율은 숫자만 입력해 주십시오", text: "확인")
                return
            }
           
        } else {
            if svcAmountTextField.text!.isNumberByRegularExpression {
                _svcwon = Int(svcAmountTextField.text ?? "0") ?? 0
            } else {
                AlertBox(title: "상품등록 실패", message: "봉사료액은 숫자만 입력해 주십시오", text: "확인")
                return
            }
       
        }
        
        if vatModeSegmented.selectedSegmentIndex == 0 {
            if vatRateTextField.text!.isNumberByRegularExpression {
                _vatrate = Int(vatRateTextField.text ?? "0") ?? 0
            } else {
                AlertBox(title: "상품등록 실패", message: "부가세율은 숫자만 입력해 주십시오", text: "확인")
                return
            }
        } else {
            if vatAmountTextField.text!.isNumberByRegularExpression {
                _vatwon = Int(vatAmountTextField.text ?? "0") ?? 0
            } else {
                AlertBox(title: "상품등록 실패", message: "부가세액은 숫자만 입력해 주십시오", text: "확인")
                return
            }
        
        }
        
        taxvalue = mTaxCalc.TaxCalcProduct(금액: _money, 비과세금액: _txf, 봉사료액: _svcwon, 봉사료자동수동: svcModeSegmented.selectedSegmentIndex, 부가세자동수동: vatModeSegmented.selectedSegmentIndex, 봉사료율: _svcrate, 부가세율: _vatrate, 봉사료포함미포함: svcCalcSegmented.selectedSegmentIndex, 부가세포함미포함: vatCalcSegmented.selectedSegmentIndex, 봉사료사용미사용: svcableSwitch.isOn ? 0:1, 부가세사용미사용: taxableSwitch.isOn ? 0:1, 부가세액: _vatwon, BleUse: _deviceCheck)
 
        // 화면상에 표시되는 공급가액 금액을 CAT 처럼 맞추기 위해 일부러 한번 더 한다
        taxvalue2 = mTaxCalc.TaxCalcProduct(금액: _money, 비과세금액: _txf, 봉사료액: _svcwon, 봉사료자동수동: svcModeSegmented.selectedSegmentIndex, 부가세자동수동: vatModeSegmented.selectedSegmentIndex, 봉사료율: _svcrate, 부가세율: _vatrate, 봉사료포함미포함: svcCalcSegmented.selectedSegmentIndex, 부가세포함미포함: vatCalcSegmented.selectedSegmentIndex, 봉사료사용미사용: svcableSwitch.isOn ? 0:1, 부가세사용미사용: taxableSwitch.isOn ? 0:1, 부가세액: _vatwon, BleUse: false)

        var conMoney2 = taxvalue2["Money"]!

        var conMoney = taxvalue["Money"]!
        var conVAT = taxvalue["VAT"]!
        var conSVC = taxvalue["SVC"]!
        var conTXF = taxvalue["TXF"]!

//        supplyPriceTextField.text = String(conMoney)
        taxTextField.text = String(conVAT)
        serviceChargeTextField.text = String(conSVC)
        nonTaxTextField.text = String(conTXF)
        paymentAmountTextField.text = _deviceCheck ? String(conMoney + conVAT + conSVC):String(conMoney + conVAT + conSVC + conTXF)

        supplyPriceTextField.text = String(conMoney2)
    }
    
    @objc func selectCategoryTapped() {
        // 팝업창 구현: UIAlertController에 텍스트필드와 분류 리스트 액션 추가
        let alert = UIAlertController(title: "상품분류 선택", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "직접 입력"
        }
        // 리스트 항목 추가 (선택 시 바로 결과 적용)
        for category in classificationList {
            alert.addAction(UIAlertAction(title: category, style: .default, handler: { _ in
                self.productCategoryValueLabel.text = category
            }))
        }
        // 확인 버튼: 텍스트필드 입력값 적용
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self.productCategoryValueLabel.text = text
            }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func registerImageTapped() {
        let alert = UIAlertController(title: "이미지 선택", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "카메라", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "갤러리", style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func removeImageTapped() {
        productImageView.image = nil
    }
    
    @objc func saveButtonTapped() {
        // 저장 처리 (입력 값 검증 등)
        print("저장 버튼 눌림")
        let tid = Utils.getIsCAT() ?
        Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID) :
        Setting.shared.getDefaultUserData(_key: define.STORE_TID)
        let tableNo = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
        let pCode = product?.code ?? ""
        if pCode == "" {
            AlertBox(title: "상품수정 실패", message: "상품코드 에러. 수정 할 상품을 다시 선택해 주십시오", text: "확인")
            return
        }
        let pSeq = tid +
        Utils.leftPad(str: tableNo, fillChar: "0", length: 3) +
        Utils.leftPad(str: pCode, fillChar: "0", length: 5)
                        
   
        guard let pName = productNameTextField.text else {
            AlertBox(title: "상품수정 실패", message: "상품명을 입력해 주십시오", text: "확인")
            return
        }
        guard let pCategory = productCategoryValueLabel.text else {
            AlertBox(title: "상품수정 실패", message: "상품분류을 입력해 주십시오", text: "확인")
            return
        }
        guard let pPrice = transactionAmountTextField.text else {
            AlertBox(title: "상품수정 실패", message: "거래금액을 입력해 주십시오", text: "확인")
            return
        }
        if !pPrice.isNumberByRegularExpression {
            AlertBox(title: "상품수정 실패", message: "거래금액은 숫자만 입력해 주십시오", text: "확인")
            return
        }
        guard let pVatRate = vatRateTextField.text else {
            AlertBox(title: "상품수정 실패", message: "부가세율을 정상적으로 입력해 주십시오", text: "확인")
            return
        }
        if !pVatRate.isNumberByRegularExpression {
            AlertBox(title: "상품수정 실패", message: "부가세율은 숫자만 입력해 주십시오", text: "확인")
            return
        }
        guard let pVatWon = vatAmountTextField.text else {
            AlertBox(title: "상품수정 실패", message: "부가세액을 정상적으로 입력해 주십시오", text: "확인")
            return
        }
        if !pVatWon.isNumberByRegularExpression {
            AlertBox(title: "상품수정 실패", message: "부가세액을 숫자만 입력해 주십시오", text: "확인")
            return
        }
        guard let pSvcRate = svcRateTextField.text else {
            AlertBox(title: "상품수정 실패", message: "봉사료율을 정상적으로 입력해 주십시오", text: "확인")
            return
        }
        if !pSvcRate.isNumberByRegularExpression {
            AlertBox(title: "상품수정 실패", message: "봉사료율을 숫자만 입력해 주십시오", text: "확인")
            return
        }
        guard let pSvcWon = svcAmountTextField.text else {
            AlertBox(title: "상품수정 실패", message: "봉사료액을 정상적으로 입력해 주십시오", text: "확인")
            return
        }
        if !pSvcWon.isNumberByRegularExpression {
            AlertBox(title: "상품수정 실패", message: "봉사료액을 숫자만 입력해 주십시오", text: "확인")
            return
        }
        guard let pTotalPrice = paymentAmountTextField.text else {
            AlertBox(title: "상품수정 실패", message: "결제금액 합계가 정상적이지 않습니다. 금액 설정을 다시 해주십시오", text: "확인")
            return
        }
        if !pTotalPrice.isNumberByRegularExpression {
            AlertBox(title: "상품수정 실패", message: "결제금액 합계가 숫자만 입력해 주십시오", text: "확인")
            return
        }
        if Int(pVatRate) ?? 0 > 50 {
            AlertBox(title: "상품수정 실패", message: "부가세율은 50%를 넘을 수 없습니다", text: "확인")
            return
        }
        if Int(pSvcRate) ?? 0 > 50 {
            AlertBox(title: "상품수정 실패", message: "봉사료율은 50%를 넘을 수 없습니다", text: "확인")
            return
        }
        
        let pDate = Utils.getDate(format: "yyyy-MM-dd HH:mm:ss")
        let pBarcode = ""
        let pUse = usageSegmented.selectedSegmentIndex
     
        let pImgUrl = ""
        let pBitmapString = bitmapImage()

        let pUseVat = taxableSwitch.isOn ? 0:1
        let pAutoVat = vatModeSegmented.selectedSegmentIndex
        let pIncludeVat = vatCalcSegmented.selectedSegmentIndex

        let pUseSvc = svcableSwitch.isOn ? 0:1
        let pAutoSvc = svcModeSegmented.selectedSegmentIndex
        let pIncludeSvc = svcCalcSegmented.selectedSegmentIndex
       
  
        let pIsImgUse = defaultImageSegmented.selectedSegmentIndex
        
        let result = sqlite.instance.updateProductInfo(tid: tid, productSeq: pSeq, tableNo: Int(tableNo)!, pname: pName, pcategory: pCategory, price: pPrice, pdate: pDate, barcode: pBarcode, isUse: pUse, imgUrl: pImgUrl, imgBitmapString: pBitmapString, useVAT: pUseVat, autoVAT: pAutoVat, includeVAT: pIncludeVat, vatRate: Int(pVatRate)!, vatWon: pVatWon, useSVC: pUseSvc, autoSVC: pAutoSvc, includeSVC: pIncludeSvc, svcRate: Int(pSvcRate)!, svcWon: pSvcWon, totalPrice: pTotalPrice, isImgUse: pIsImgUse)
        if result {
            KocesSdk.instance.setProductData(seq: pSeq)
        }
        
        AlertBox(title: result ? "상품수정 성공":"상품수정 실패", message: result ? "상품을 수정하였습니다":"상품수정에 실패하였습니다. 다시 시도해 주십시오", text: "확인")
    }
    
    func bitmapImage() -> String {
        let thumbnailSize = CGSize(width: 300, height: 300)
        if let image = productImageView.image {
     
            // 압축 품질은 0.0 ~ 1.0 사이의 값으로, 0.3은 30% 품질을 의미
            let options: [SDImageCoderOption: Any] = [
                .encodeMaxPixelSize: CGSize(width: 200, height: 200),
                .encodeCompressionQuality: 0.1,
                .encodeMaxFileSize: 1024 * 10
            ]
            if let webpData = SDImageWebPCoder.shared.encodedData(with: image, format: .webP, options: options) {
                let base64String = webpData.base64EncodedString(options: [])
                // base64String을 DB에 저장합니다.
                print("WebP Base64 String: \(base64String)")
                return base64String
            } else {
                print("이미지를 WebP로 인코딩 실패")
            }
        }
        return ""
    }
    
    func decodeBitmapImage(from base64String: String) -> UIImage? {
        if base64String == "" {
            return nil
        }
        // Base64 문자열을 Data로 변환
        guard let webpData = Data(base64Encoded: base64String) else {
            print("Base64 문자열 디코딩 실패")
            return nil
        }
        
        // SDImageWebPCoder를 이용해 Data를 UIImage로 디코딩
        if let image = SDImageWebPCoder.shared.decodedImage(with: webpData, options: nil) {
            return image
        } else {
            print("WebP 데이터를 UIImage로 디코딩 실패")
            return nil
        }
    }
    
    // MARK: - Image Picker
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        } else {
            print("Camera not available")
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            productImageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func AlertBox(title : String, message : String, text : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okButton)
        return self.present(alertController, animated: true, completion: nil)
    }
    
    // 입력이 실제 끝날때 호출 (시점)
    func textFieldDidEndEditing(_ textField: UITextField) {
        totalMoneyCalcu()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
