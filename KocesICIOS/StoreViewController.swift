//
//  StoreViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/4/25.
//

import Foundation
import UIKit

// MARK: - 간단한 모델 구조체 예시
struct MerchantInfo {
    var tid: String
    var businessNumber: String
    var storeName: String
    var phoneNumber: String
    var address: String
    var representativeName: String
}

class StoreViewController: UIViewController {
    
    // 대표사업자 (무조건 1개)
    private var representativeMerchant = MerchantInfo(
        tid: "",
        businessNumber: "",
        storeName: "",
        phoneNumber: "",
        address: "",
        representativeName: ""
    )
     
    // 서브사업자 (0~10개 가능)
    private var subMerchants: [MerchantInfo] = [
        MerchantInfo(tid: "", businessNumber: "",
                     storeName: "", phoneNumber: "",
                     address: "", representativeName: ""),
        MerchantInfo(tid: "", businessNumber: "",
                     storeName: "", phoneNumber: "",
                     address: "", representativeName: ""),
        MerchantInfo(tid: "", businessNumber: "",
                     storeName: "", phoneNumber: "",
                     address: "", representativeName: ""),
        MerchantInfo(tid: "", businessNumber: "",
                     storeName: "", phoneNumber: "",
                     address: "", representativeName: ""),
        MerchantInfo(tid: "", businessNumber: "",
                     storeName: "", phoneNumber: "",
                     address: "", representativeName: ""),
        MerchantInfo(tid: "", businessNumber: "",
                     storeName: "", phoneNumber: "",
                     address: "", representativeName: ""),
        MerchantInfo(tid: "", businessNumber: "",
                     storeName: "", phoneNumber: "",
                     address: "", representativeName: ""),
        MerchantInfo(tid: "", businessNumber: "",
                     storeName: "", phoneNumber: "",
                     address: "", representativeName: ""),
        MerchantInfo(tid: "", businessNumber: "",
                     storeName: "", phoneNumber: "",
                     address: "", representativeName: ""),
        MerchantInfo(tid: "", businessNumber: "",
                     storeName: "", phoneNumber: "",
                     address: "", representativeName: ""),
    ]
    
    // 서브사업자정보 표시 여부
    private var isSubMerchantExpanded: Bool = false
    
    // MARK: - UI 컴포넌트
    private let scrollView = UIScrollView()
    private let titleStackView = UIStackView()
    private let contentStackView = UIStackView()
    
    // 맨 위에 표시할 "POS" 라벨
    private let representativePosLabelView = UIView()
    private lazy var posLabel: UILabel = {
        let label = UILabel()
        label.text = "POS"
        label.font = UIFont.boldSystemFont(ofSize: Utils.getHeadingFontSize())  // 24, Bold
        label.textAlignment = .left
        return label
    }()
    
    // 대표사업자 상단 헤더(제목 + 화살표)
    private let representativeHeaderView = UIView()
    private lazy var representativeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "대표사업자정보"
        label.font = UIFont.boldSystemFont(ofSize: Utils.getHeadingFontSize())
        return label
    }()
    private let arrowButton: UIButton = {
        let button = UIButton(type: .system)
        // 화살표 이미지는 프로젝트 내 적절한 Asset을 사용하세요.
        // 여기서는 SF Symbol 예시: "chevron.down" 사용(초기값)
        if let image = UIImage(systemName: "chevron.down") {
            button.setImage(image, for: .normal)
        }
        button.tintColor = .black
        return button
    }()
    
    // 대표사업자 구분선
    private let representativeDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
       
    // 대표사업자 정보 뷰 (TID ~ 대표자명)
    private let representativeInfoView = UIView()

    // 대표사업자 버튼 영역(가맹점등록, 정보수정)
    private let representativeButtonView = UIView()
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("가맹점등록", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Utils.getHeadingFontSize(), weight: .medium)
        button.layer.cornerRadius = 8
        return button
    }()
    private lazy var repEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("정보수정", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Utils.getHeadingFontSize(), weight: .medium)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // 서브사업자 영역을 담을 스택뷰
    private let subMerchantStackView = UIStackView()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        configureActions()
        // 초기에는 서브사업자 정보를 숨긴 상태
        updateSubMerchantVisibility(animated: false)
    }
    

    // MARK: - UI 설정
    private func setupUI() {
        view.backgroundColor = .white
        
        // scrollView + contentStackView
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        titleStackView.axis = .vertical
//        titleStackView.spacing = 16
        titleStackView.alignment = .fill
        titleStackView.distribution = .fill
        scrollView.addSubview(titleStackView)
        
        // --- "POS" Label(맨 위)
        representativePosLabelView.addSubview(posLabel)
        titleStackView.addArrangedSubview(representativePosLabelView)
        
        // --- "POS" Label 구분선
        // 구분선
        let divider = UIView()
        divider.backgroundColor = .lightGray
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        titleStackView.addArrangedSubview(divider)
        
        contentStackView.axis = .vertical
//        contentStackView.spacing = 16
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        scrollView.addSubview(contentStackView)
        
        // --- 데이터 셋업
        setupStoreInfoData()
        
        // --- 대표사업자 상단 헤더(제목 + 화살표)
        representativeHeaderView.addSubview(representativeTitleLabel)
        representativeHeaderView.addSubview(arrowButton)
        contentStackView.addArrangedSubview(representativeHeaderView)
        
        // --- 대표사업자 구분선
        contentStackView.addArrangedSubview(representativeDivider)
        representativeDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // --- 대표사업자 정보뷰
        setupRepresentativeInfoView()
        contentStackView.addArrangedSubview(representativeInfoView)
        
        // --- 대표사업자 버튼 영역
        setupRepresentativeButtonView()
        contentStackView.addArrangedSubview(representativeButtonView)
        
        // --- 서브사업자 스택뷰
        subMerchantStackView.axis = .vertical
//        subMerchantStackView.spacing = 16
        subMerchantStackView.alignment = .fill
        subMerchantStackView.distribution = .fill
        contentStackView.addArrangedSubview(subMerchantStackView)
        
        // 서브사업자 UI(초기에 추가만 해두고, 펼쳐진 상태 업데이트는 toggle 로직으로 처리)
        refreshSubMerchantViews()
    }
    
    //가맹점 정보 가져오기
    private func setupStoreInfoData() {
        var count = "1"
        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.contains(define.STORE_TID) {
                if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                    if key == "CAT_STORE_TID" || key == "CAT_STORE_TID0" {
                        self.representativeMerchant = MerchantInfo(
                            tid: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID)),
                            businessNumber: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN)),
                            storeName: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME)),
                            phoneNumber: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE)),
                            address: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR)),
                            representativeName: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER))
                        )
                        
                    } else {
                        for i in 1...10 {
                            if key == "CAT_STORE_TID" + String(i) {
                                count = String(i)
                                self.subMerchants[i - 1] = MerchantInfo(
                                    tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + count),
                                    businessNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + count),
                                    storeName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + count),
                                    phoneNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + count),
                                    address: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + count),
                                    representativeName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + count)
                                )
                            }
                        }
                    }
                } else {
                    //로컬 가맹점 정보 읽어서 표시 하기
                    if key == "STORE_TID" || key == "STORE_TID0" {
                        self.representativeMerchant = MerchantInfo(
                            tid: (Setting.shared.getDefaultUserData(_key: define.STORE_TID) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_TID)),
                            businessNumber: (Setting.shared.getDefaultUserData(_key: define.STORE_BSN) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_BSN)),
                            storeName: (Setting.shared.getDefaultUserData(_key: define.STORE_NAME) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_NAME)),
                            phoneNumber: (Setting.shared.getDefaultUserData(_key: define.STORE_PHONE) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_PHONE)),
                            address: (Setting.shared.getDefaultUserData(_key: define.STORE_ADDR) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_ADDR)),
                            representativeName: (Setting.shared.getDefaultUserData(_key: define.STORE_OWNER) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
                        )
                        
                    } else {
                        for i in 1...10 {
                            if key == "STORE_TID" + String(i) {
                                count = String(i)
                                self.subMerchants[i - 1] = MerchantInfo(
                                    tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID + count),
                                    businessNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN + count),
                                    storeName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME + count),
                                    phoneNumber: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + count),
                                    address: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + count),
                                    representativeName: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + count)
                                )
                            }
                        }
                    }
                }
            }
        }

    }
    
    // 대표사업자 정보뷰(라운드 박스)
    private func setupRepresentativeInfoView() {
        representativeInfoView.backgroundColor = .clear
        representativeInfoView.layer.cornerRadius = 0
        // 예시: 6개의 항목 각각 가로 스택(왼쪽 타이틀, 오른쪽 데이터)
        let items: [(String, String)] = [
            ("TID", representativeMerchant.tid),
            ("사업자번호", representativeMerchant.businessNumber),
            ("가맹점명", representativeMerchant.storeName),
            ("전화번호", representativeMerchant.phoneNumber),
            ("가맹점주소", representativeMerchant.address),
            ("대표자명", representativeMerchant.representativeName)
        ]
        
        // 전체를 세로 스택으로 묶어서 infoView에 추가
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.spacing = 8
        verticalStack.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        verticalStack.layer.cornerRadius = 8
        
        for (title, value) in items {
            let rowStack = createTwoLabelRow(title: title, value: value)
            verticalStack.addArrangedSubview(rowStack)
        }
        
        representativeInfoView.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: representativeInfoView.topAnchor, constant: 16),
            verticalStack.leadingAnchor.constraint(equalTo: representativeInfoView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: representativeInfoView.trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: representativeInfoView.bottomAnchor, constant: -16)
        ])
    }
    
    // 대표사업자 버튼 영역(배경/라운드 없음, 오른쪽 정렬)
    private func setupRepresentativeButtonView() {
        representativeButtonView.backgroundColor = .clear
        representativeButtonView.layer.cornerRadius = 0
        
        // 수평 스택 뷰로 버튼을 오른쪽에 몰기 위해 스페이서 사용
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let buttonStack = UIStackView(arrangedSubviews: [spacerView, registerButton, repEditButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.spacing = 8
        
        representativeButtonView.addSubview(buttonStack)
        
        // 버튼 레이아웃 예시
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: representativeButtonView.topAnchor, constant: 0),
            registerButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            registerButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
                     
            repEditButton.topAnchor.constraint(equalTo: representativeButtonView.topAnchor, constant: 0),
            repEditButton.leadingAnchor.constraint(equalTo: registerButton.trailingAnchor, constant: 16),
            repEditButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            repEditButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            buttonStack.topAnchor.constraint(equalTo: representativeButtonView.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: representativeButtonView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: representativeButtonView.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: representativeButtonView.bottomAnchor)
        ])
    }
    
    // MARK: - 서브사업자 영역 갱신
    private func refreshSubMerchantViews() {
        // 기존에 있던 서브뷰 모두 제거
        subMerchantStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, merchant) in subMerchants.enumerated() {
            if merchant.tid == "" {
                continue
            }
            // 서브사업자 상단 헤더(제목)
            let headerView = createSubMerchantHeaderView()
            
            // 구분선
            let divider = UIView()
            divider.backgroundColor = .lightGray
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            // 서브사업자 정보뷰(라운드 박스)
            let infoView = createSubMerchantInfoView(merchant: merchant)
            
            // 서브사업자 버튼영역(배경/라운드 없음, 오른쪽 정렬)
            let buttonView = createSubMerchantButtonView(merchantIndex: index)
            
            subMerchantStackView.addArrangedSubview(headerView)
            subMerchantStackView.addArrangedSubview(divider)
            subMerchantStackView.addArrangedSubview(infoView)
            subMerchantStackView.addArrangedSubview(buttonView)
        }
    }
    
    //서브사업자 헤더뷰 만들기
    private func createSubMerchantHeaderView() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.layer.cornerRadius = 0

        let label = UILabel()
        label.text = "서브사업자정보"
        label.font = UIFont.boldSystemFont(ofSize: Utils.getHeadingFontSize())
        
        let stack = UIStackView(arrangedSubviews: [
            label
        ])
        stack.axis = .vertical
        stack.alignment = .leading
          
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stack.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
        ])
   
        return container
    }
    
    // 서브사업자 정보뷰 만들기 (라운드 박스, 6개의 항목)
    private func createSubMerchantInfoView(merchant: MerchantInfo) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.layer.cornerRadius = 0
        
        let items: [(String, String)] = [
            ("TID", merchant.tid),
            ("사업자번호", merchant.businessNumber),
            ("가맹점명", merchant.storeName),
            ("전화번호", merchant.phoneNumber),
            ("가맹점주소", merchant.address),
            ("대표자명", merchant.representativeName)
        ]
        
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.spacing = 8
        verticalStack.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        verticalStack.layer.cornerRadius = 8
        
        for (title, value) in items {
            let rowStack = createTwoLabelRow(title: title, value: value)
            verticalStack.addArrangedSubview(rowStack)
        }
        
        container.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    // 서브사업자 버튼영역 만들기(가맹점제거, 정보수정) - 배경/라운드 없고 오른쪽 정렬
    private func createSubMerchantButtonView(merchantIndex: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.layer.cornerRadius = 0
        
        let removeButton = UIButton(type: .system)
        removeButton.setTitle("가맹점제거", for: .normal)
        removeButton.titleLabel?.font = UIFont.systemFont(ofSize: Utils.getHeadingFontSize(), weight: .regular)
        removeButton.backgroundColor = .systemRed
        removeButton.setTitleColor(.white, for: .normal)
        removeButton.layer.cornerRadius = 8
        removeButton.tag = merchantIndex
        
        let editButton = UIButton(type: .system)
        editButton.setTitle("정보수정", for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: Utils.getHeadingFontSize(), weight: .regular)
        editButton.backgroundColor = .systemGreen
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 8
        editButton.tag = merchantIndex
        
        // 오른쪽 정렬을 위해 스페이서 사용
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let spacerView2 = UIView()
        spacerView2.setContentHuggingPriority(.defaultLow, for: .horizontal)
        var _arrayView:[UIView]
        if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
            _arrayView = [spacerView, removeButton, editButton]
            let buttonStack = UIStackView(arrangedSubviews: _arrayView)
            buttonStack.axis = .horizontal
            buttonStack.alignment = .center
            buttonStack.spacing = 8
            
            container.addSubview(buttonStack)
            buttonStack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                removeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                removeButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
                removeButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
                         
                editButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                editButton.leadingAnchor.constraint(equalTo: removeButton.trailingAnchor, constant: 16),
                editButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
                editButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
     
                buttonStack.topAnchor.constraint(equalTo: container.topAnchor),
                buttonStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                buttonStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                buttonStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            // 액션 연결
            removeButton.addTarget(self, action: #selector(didTapRemoveSubMerchant(_:)), for: .touchUpInside)
            editButton.addTarget(self, action: #selector(didTapEditSubMerchant(_:)), for: .touchUpInside)
        } else {
            _arrayView = [spacerView, spacerView2, editButton]
            let buttonStack = UIStackView(arrangedSubviews: _arrayView)
            buttonStack.axis = .horizontal
            buttonStack.alignment = .center
            buttonStack.spacing = 8
            
            container.addSubview(buttonStack)
            buttonStack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                spacerView2.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                spacerView2.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
                spacerView2.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
                         
                editButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                editButton.leadingAnchor.constraint(equalTo: spacerView2.trailingAnchor, constant: 16),
                editButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
                editButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
     
                buttonStack.topAnchor.constraint(equalTo: container.topAnchor),
                buttonStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                buttonStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                buttonStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            // 액션 연결
//            removeButton.addTarget(self, action: #selector(didTapRemoveSubMerchant(_:)), for: .touchUpInside)
            editButton.addTarget(self, action: #selector(didTapEditSubMerchant(_:)), for: .touchUpInside)
        }
        
        
        return container
    }
    
    
    // MARK: - Layout
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        representativePosLabelView.translatesAutoresizingMaskIntoConstraints = false
        posLabel.translatesAutoresizingMaskIntoConstraints = false
        representativeHeaderView.translatesAutoresizingMaskIntoConstraints = false
        representativeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // titleStackView
            titleStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            titleStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            titleStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
//            titleStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            // 스크롤뷰 폭에 맞추기
            titleStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            
            // contentStackView
            contentStackView.topAnchor.constraint(greaterThanOrEqualTo: titleStackView.bottomAnchor, constant: 0),
//            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            // 스크롤뷰 폭에 맞추기
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
        
        NSLayoutConstraint.activate([
            posLabel.topAnchor.constraint(equalTo: representativePosLabelView.topAnchor),
            posLabel.bottomAnchor.constraint(equalTo: representativePosLabelView.bottomAnchor),
            posLabel.leadingAnchor.constraint(equalTo: representativePosLabelView.leadingAnchor),
            posLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
        ])
        
        // 대표사업자 헤더(제목 + 화살표)
        NSLayoutConstraint.activate([

            representativeTitleLabel.topAnchor.constraint(equalTo: representativeHeaderView.topAnchor),
            representativeTitleLabel.bottomAnchor.constraint(equalTo: representativeHeaderView.bottomAnchor),
            representativeTitleLabel.leadingAnchor.constraint(equalTo: representativeHeaderView.leadingAnchor),
            representativeTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            arrowButton.centerYAnchor.constraint(equalTo: representativeTitleLabel.centerYAnchor),
            arrowButton.leadingAnchor.constraint(greaterThanOrEqualTo: representativeTitleLabel.trailingAnchor, constant: 8),
            arrowButton.trailingAnchor.constraint(equalTo: representativeHeaderView.trailingAnchor),
            arrowButton.heightAnchor.constraint(equalToConstant: 24),
            arrowButton.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    
    // MARK: - Actions
    private func configureActions() {
        arrowButton.addTarget(self, action: #selector(didTapArrowButton), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        repEditButton.addTarget(self, action: #selector(didTapEditRepresentative), for: .touchUpInside)
    }
    
    @objc private func didTapArrowButton() {
        // 서브사업자 표시 토글
        isSubMerchantExpanded.toggle()
        updateSubMerchantVisibility(animated: true)
    }
    
    @objc private func didTapRegisterButton() {
        // 가맹점등록 버튼 클릭 시: 우선 로그만
        print("가맹점등록 버튼이 클릭되었습니다.")
        // 실제 처리는 프로젝트에 맞춰 구현
    }
    
    @objc private func didTapEditRepresentative() {
        // 대표사업자 정보 수정
        showEditPopup(forRepresentative: true, index: nil)
    }
    
    @objc private func didTapRemoveSubMerchant(_ sender: UIButton) {
        let index = sender.tag
        guard index < subMerchants.count else { return }
        let i = index
        if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_TID + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_BSN + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_NAME + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_OWNER + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_PHONE + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_ADDR + String(i+1))
        } else {
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_TID + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_BSN + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_NAME + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_OWNER + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_PHONE + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_ADDR + String(i+1))
        }
        // 해당 서브사업자 제거
        subMerchants.remove(at: index)
        // UI 갱신
        refreshSubMerchantViews()
    }
    
    @objc private func didTapEditSubMerchant(_ sender: UIButton) {
        let index = sender.tag
        guard index < subMerchants.count else { return }
        // 서브사업자 정보 수정
        showEditPopup(forRepresentative: false, index: index)
    }
    
    // 서브사업자 표시/숨김 갱신
    private func updateSubMerchantVisibility(animated: Bool) {
        // 화살표 이미지 변경 (펼침/접힘)
        let symbolName = isSubMerchantExpanded ? "chevron.up" : "chevron.down"
        arrowButton.setImage(UIImage(systemName: symbolName), for: .normal)
        
        // 서브사업자 스택뷰 자체를 숨김
        let alphaValue: CGFloat = isSubMerchantExpanded ? 1.0 : 0.0
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.subMerchantStackView.alpha = alphaValue
            }
        } else {
            subMerchantStackView.alpha = alphaValue
        }
    }
    
    // MARK: - 정보수정 팝업 표시
    private func showEditPopup(forRepresentative: Bool, index: Int?) {
        let alert = UIAlertController(title: "정보수정",
                                      message: "수정할 내용을 입력하세요.",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "TID"
            if forRepresentative {
                textField.text = self.representativeMerchant.tid
            } else if let i = index {
                textField.text = self.subMerchants[i].tid
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "사업자번호"
            if forRepresentative {
                textField.text = self.representativeMerchant.businessNumber
            } else if let i = index {
                textField.text = self.subMerchants[i].businessNumber
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "가맹점명"
            if forRepresentative {
                textField.text = self.representativeMerchant.storeName
            } else if let i = index {
                textField.text = self.subMerchants[i].storeName
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "전화번호"
            if forRepresentative {
                textField.text = self.representativeMerchant.phoneNumber
            } else if let i = index {
                textField.text = self.subMerchants[i].phoneNumber
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "가맹점주소"
            if forRepresentative {
                textField.text = self.representativeMerchant.address
            } else if let i = index {
                textField.text = self.subMerchants[i].address
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "대표자명"
            if forRepresentative {
                textField.text = self.representativeMerchant.representativeName
            } else if let i = index {
                textField.text = self.subMerchants[i].representativeName
            }
        }
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            let fields = alert.textFields ?? []
            guard fields.count == 6 else { return }
            
            let tid = fields[0].text ?? ""
            let bizNum = fields[1].text ?? ""
            let storeName = fields[2].text ?? ""
            let phone = fields[3].text ?? ""
            let address = fields[4].text ?? ""
            let repName = fields[5].text ?? ""
            
            if forRepresentative {
                self.representativeMerchant = MerchantInfo(
                    tid: tid,
                    businessNumber: bizNum,
                    storeName: storeName,
                    phoneNumber: phone,
                    address: address,
                    representativeName: repName
                )
                if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.CAT_STORE_TID)
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.CAT_STORE_TID + "0")
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.CAT_STORE_BSN)
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.CAT_STORE_BSN + "0")
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.CAT_STORE_NAME)
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.CAT_STORE_NAME + "0")
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.CAT_STORE_OWNER)
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.CAT_STORE_OWNER + "0")
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.CAT_STORE_PHONE)
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.CAT_STORE_PHONE + "0")
                    Setting.shared.setDefaultUserData(_data: address, _key: define.CAT_STORE_ADDR)
                    Setting.shared.setDefaultUserData(_data: address, _key: define.CAT_STORE_ADDR + "0")
                } else {
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.STORE_TID)
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.STORE_TID + "0")
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.STORE_BSN)
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.STORE_BSN + "0")
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.STORE_NAME)
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.STORE_NAME + "0")
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.STORE_OWNER)
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.STORE_OWNER + "0")
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.STORE_PHONE)
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.STORE_PHONE + "0")
                    Setting.shared.setDefaultUserData(_data: address, _key: define.STORE_ADDR)
                    Setting.shared.setDefaultUserData(_data: address, _key: define.STORE_ADDR + "0")
                }
                // 대표사업자 UI 업데이트
                self.setupRepresentativeInfoView()
            } else if let i = index, i < self.subMerchants.count {
                self.subMerchants[i] = MerchantInfo(
                    tid: tid,
                    businessNumber: bizNum,
                    storeName: storeName,
                    phoneNumber: phone,
                    address: address,
                    representativeName: repName
                )
                
                if Setting.shared.getDefaultUserData(_key: define.TARGETDEVICE) == define.TAGETCAT {
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.CAT_STORE_TID + String(i+1))
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.CAT_STORE_BSN + String(i+1))
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.CAT_STORE_NAME + String(i+1))
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.CAT_STORE_OWNER + String(i+1))
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.CAT_STORE_PHONE + String(i+1))
                    Setting.shared.setDefaultUserData(_data: address, _key: define.CAT_STORE_ADDR + String(i+1))
                } else {
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.STORE_TID + String(i+1))
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.STORE_BSN + String(i+1))
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.STORE_NAME + String(i+1))
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.STORE_OWNER + String(i+1))
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.STORE_PHONE + String(i+1))
                    Setting.shared.setDefaultUserData(_data: address, _key: define.STORE_ADDR + String(i+1))
                }
            }
            // UI 갱신
            self.refreshSubMerchantViews()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
// MARK: - 유틸: (타이틀, 값) 두 개 레이블이 들어간 가로 스택 만들기
extension StoreViewController {
    private func createTwoLabelRow(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = "  " + title
        titleLabel.font = UIFont.systemFont(ofSize: Utils.getDetailFontSize(), weight: .regular)
        titleLabel.textAlignment = .left
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        titleLabel.font = UIFont.systemFont(ofSize: Utils.getDetailFontSize(), weight: .regular)
        valueLabel.textAlignment = .left
        // 필요하면 여러 줄 표시도 가능 (numberOfLines = 0)
        
        let rowStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        rowStack.axis = .horizontal
        rowStack.alignment = .fill
        rowStack.spacing = 8
        
        // 행 높이 60
        rowStack.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()).isActive = true
                
        // 타이틀의 폭(예: 150 정도)을 고정해도 되지만, 이미 setContentHuggingPriority를 줬다면
        // 필요 시 아래처럼 고정 폭 설정 가능:
         titleLabel.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()).isActive = true
//        NSLayoutConstraint.activate([
//            titleLabel.widthAnchor.constraint(equalToConstant: 150),
//            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
//        ])
        
        return rowStack
    }
}
