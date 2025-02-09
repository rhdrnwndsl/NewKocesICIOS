//
//  ProductModifyViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2/5/25.
//

import Foundation
import UIKit

class ProductModifyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {
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
    let classificationList = ["식품", "의류", "전자제품"]
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "상품 수정"
               
        // 내비게이션 바에 '나가기' 버튼 추가 (모달 dismiss)
        let backImage = UIImage(systemName: "chevron.backward")
        let backButton = UIButton()
        backButton.setImage(backImage, for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(define.txt_blue, for: .normal)
        backButton.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        let backNav = UIBarButtonItem(customView: backButton)

        navigationItem.leftBarButtonItem = backNav
     
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "나가기", style: .plain, target: self, action: #selector(exitButtonTapped))
               
        // 가로 모드 전용 (앱 설정이나 Info.plist에서 별도 처리 가능)
        // 여기서는 supportedInterfaceOrientations를 오버라이드합니다.
        
        setupTopBar()
        setupMainContainer()
        setupLeftSide()
        setupRightSide()
        
        // 기본값 및 타겟 설정
        taxableSwitch.isOn = true       //부가세는 기본이 사용
        vatModeSegmented.selectedSegmentIndex = 0  // 자동
        vatCalcSegmented.selectedSegmentIndex = 0   // 포함
        updateTaxViewsVisibility()

        svcableSwitch.isOn = false      //봉사료는 기본이 미사용
        svcModeSegmented.selectedSegmentIndex = 0  // 자동
        svcCalcSegmented.selectedSegmentIndex = 0   // 포함
        updateSvcViewsVisibility()
        
        usageSegmented.selectedSegmentIndex = 0 //사용
        defaultImageSegmented.selectedSegmentIndex = 0 //사용
        
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
        
        navigationItem.titleView?.backgroundColor = .black
    }
    
    @objc private func exitButtonTapped() {
        // 모달로 present된 경우 dismiss 처리
        dismiss(animated: true, completion: nil)
    }
    
    // 가로 모드 전용
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    // MARK: - Setup UI Methods
    
    func setupTopBar() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        // 타이틀 레이블
        titleLabel.text = "상품설정"
        titleLabel.font = Utils.getTitleFont()
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
        let pSeq = "00000"
        let tableNo = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
        let pCode = "00000"
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
        let pDate = Utils.getDate(format: "yyMMddHHmmSS")
        let pBarcode = ""
        let pUse = usageSegmented.selectedSegmentIndex
        let pImgUrl = ""
        let pBitmapString = ""
        let pUseVat = taxableSwitch.isOn ? 0:1
        let pAutoVat = vatModeSegmented.selectedSegmentIndex
        let pIncludeVat = vatCalcSegmented.selectedSegmentIndex
        guard let pVatRate = vatRateTextField.text else {
            AlertBox(title: "상품수정 실패", message: "부가세율을 정상적으로 입력해 주십시오", text: "확인")
            return
        }
        guard let pVatWon = vatAmountTextField.text else {
            AlertBox(title: "상품수정 실패", message: "부가세액을 정상적으로 입력해 주십시오", text: "확인")
            return
        }
        let pUseSvc = svcableSwitch.isOn ? 0:1
        let pAutoSvc = svcModeSegmented.selectedSegmentIndex
        let pIncludeSvc = svcCalcSegmented.selectedSegmentIndex
        guard let pSvcRate = svcRateTextField.text else {
            AlertBox(title: "상품수정 실패", message: "봉사료율을 정상적으로 입력해 주십시오", text: "확인")
            return
        }
        guard let pSvcWon = svcAmountTextField.text else {
            AlertBox(title: "상품수정 실패", message: "봉사료액을 정상적으로 입력해 주십시오", text: "확인")
            return
        }
        guard let pTotalPrice = paymentAmountTextField.text else {
            AlertBox(title: "상품수정 실패", message: "봉사료액을 정상적으로 입력해 주십시오", text: "확인")
            return
        }
        let pIsImgUse = defaultImageSegmented.selectedSegmentIndex
        
        let result = sqlite.instance.insertProductInfo(tid: tid, productSeq: pSeq, tableNo: Int(tableNo)!, pcode: pCode, pname: pName, pcategory: pCategory, price: pPrice, pdate: pDate, barcode: pBarcode, isUse: pUse, imgUrl: pImgUrl, imgBitmapString: pBitmapString, useVAT: pUseVat, autoVAT: pAutoVat, includeVAT: pIncludeVat, vatRate: Int(pVatRate)!, vatWon: pVatWon, useSVC: pUseSvc, autoSVC: pAutoSvc, includeSVC: pIncludeSvc, svcRate: Int(pSvcRate)!, svcWon: pSvcWon, totalPrice: pTotalPrice, isImgUse: pIsImgUse)
        
        AlertBox(title: result ? "상품수정 성공":"상품수정 실패", message: result ? "상품을 수정하였습니다":"상품수정에 실패하였습니다. 다시 시도해 주십시오", text: "확인")
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
}
