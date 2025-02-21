//
//  Untitled.swift
//  KocesICIOS
//
//  Created by 신진우 on 2/5/25.
//

import Foundation
import UIKit

protocol ProductSetViewControllerDelegate: AnyObject {
    func productSetViewControllerDidTapRegister(_ controller: ProductSetViewController)
    func productSetViewControllerDidTapModify(_ controller: ProductSetViewController)
}

class ProductSetViewController: UIViewController, UITextFieldDelegate, UIDocumentPickerDelegate {
    
    weak var delegate: ProductSetViewControllerDelegate?
    
    // MARK: - UI Components
     private let scrollView: UIScrollView = {
         let sv = UIScrollView()
         sv.translatesAutoresizingMaskIntoConstraints = false
         return sv
     }()
     
     private let contentView: UIView = {
         let view = UIView()
         view.translatesAutoresizingMaskIntoConstraints = false
         return view
     }()
    
    // 상단 타이틀
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "상품관리"
        label.font = Utils.getTitleFont()
        label.textAlignment = .left
        label.textColor = .darkGray
        return label
    }()
    
    private let titleUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = define.underline_grey
        return view
    }()
    
    // 첫번째 섹션: "상품관리가맹점 설정"
    private let merchantTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "상품관리가맹점 설정"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        return label
    }()
    
    private let merchantUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = define.underline_grey
        return view
    }()
    
    // 그룹 컨테이너 (배경: 시스템 회색, 라운드 처리)
    private let merchantContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private var tidRowView: UIView!
    private var posRowView: UIView!
    
    // TID 행
    private let tidLabel: UILabel = {
        let label = UILabel()
        label.text = "TID"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.textAlignment = .left
        return label
    }()
    
    private let tidValueLabel: UILabel = {
        let label = UILabel()
        label.text = "" // viewDidLoad에서 세팅
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        return label
    }()
    
    // POS 번호 편집 행 (라벨 + disclosure)
    private let posLabel: UILabel = {
        let label = UILabel()
        label.text = "POS번호"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.textAlignment = .left
        return label
    }()
    
    // 현재 POS 번호를 표시하는 라벨
    private let posNumberLabel: UILabel = {
        let label = UILabel()
        label.text = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.textAlignment = .right
        return label
    }()
    
    // POS 편집 행 오른쪽의 disclosure 이미지
    private let posDisclosureImage: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .lightGray
        return iv
    }()
    
    // 두번째 섹션: "상품관리 설정" (상품등록/상품수정)
    private let productTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "상품관리 설정"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        return label
    }()
    
    private let productUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = define.underline_grey
        return view
    }()
    
    // 상품관리 컨테이너 (배경: 시스템 회색, 라운드)
    private let productContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    // 상품등록 행 (라벨 + disclosure)
    private lazy var registerRow: UIView = {
        return self.createRow(title: "상품등록", action: #selector(productRegisterTapped))
    }()
    
    // 상품수정 행 (라벨 + disclosure)
    private lazy var modifyRow: UIView = {
        return self.createRow(title: "상품수정", action: #selector(productModifyTapped))
    }()
    
    // 세번째 섹션: "상품정보 백업"
    private let backupTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "상품정보 백업"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.textAlignment = .left
        return label
    }()
    
    private let backupUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = define.underline_grey
        return view
    }()
    
    // 백업 컨테이너 (라운드 박스)
    private let productBackupContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    // 내보내기 행 (라벨 + disclosure)
    private lazy var backupExportRow: UIView = {
        return self.createRow(title: "내보내기", action: #selector(exportDataTapped))
    }()
    
    // 가져오기 행 (라벨 + disclosure)
    private lazy var backupImportRow: UIView = {
        return self.createRow(title: "가져오기", action: #selector(importDataTapped))
    }()
    
    // 상품 가져오기 시 진행률 표시
    private var progressOverlay: UIView?
    private var progressBar: UIProgressView?
    private var progressTitleLabel: UILabel?
    private var progressMessageLabel: UILabel?

    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = define.layout_border_lightgrey
        title = "상품관리 설정"
        
        // scrollView와 contentView를 뷰 계층에 추가
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        
        // 기존의 UI 요소들은 contentView에 추가
        [titleLabel, titleUnderline,
         merchantTitleLabel, merchantUnderline, merchantContainerView,
         productTitleLabel, productUnderline, productContainerView,
         backupTitleLabel, backupUnderline, productBackupContainerView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // 상품관리가맹점 설정 영역 구성
        setupMerchantContainer()
        // 상품관리 설정 영역 구성 (상품등록/상품수정)
        setupProductContainer()
        // 상품정보 백업 영역 구성
        setupBackupContainer()
        setupConstraints()
        
        //데이터 처리
        loadTIDValue()
    }
    
    // MARK: - UI Setup
    
    private func setupMerchantContainer() {
        // merchantContainerView 내부: TID 행과 POS 행
        // TID 행
        tidRowView = createEditableRow(title: "TID", value: tidValueLabel.text ?? "", action: nil)
        merchantContainerView.addSubview(tidRowView)
        
        [tidLabel, tidValueLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            tidRowView.addSubview($0)
        }
        
        // POS 번호 행 (탭 시 editPOSNumber 호출)
        posRowView = createEditableRow(title: "POS번호", value: posNumberLabel.text ?? "", action: #selector(editPOSNumber))
        merchantContainerView.addSubview(posRowView)
        
        [posLabel, posNumberLabel, posDisclosureImage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            posRowView.addSubview($0)
        }
        
        // posRowView 터치 시 편집 액션 호출
        let posTap = UITapGestureRecognizer(target: self, action: #selector(editPOSNumber))
        posRowView.addGestureRecognizer(posTap)
    }
    
    private func setupProductContainer() {
        // productContainerView 내부: 상품등록 행과 상품수정 행
        [registerRow, modifyRow].forEach {
            productContainerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupBackupContainer() {
        // productBackupContainerView 내부: 내보내기 행과 가져오기 행
        [backupExportRow, backupImportRow].forEach {
            productBackupContainerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        let margin: CGFloat = 10
                
        // scrollView 제약조건: view의 safeArea를 채우도록
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // contentView 제약조건: scrollView의 contentLayoutGuide에 맞추고, frameLayoutGuide와 너비가 같도록
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        // 이후 기존의 UI 요소에 대한 제약조건을 contentView 기준으로 설정합니다.
        NSLayoutConstraint.activate([
            // titleLabel
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            titleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            titleUnderline.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            titleUnderline.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            titleUnderline.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            titleUnderline.heightAnchor.constraint(equalToConstant: 1),

            // merchant 섹션
            merchantTitleLabel.topAnchor.constraint(equalTo: titleUnderline.bottomAnchor, constant: margin),
            merchantTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            merchantTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            merchantTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
                       
            merchantUnderline.topAnchor.constraint(equalTo: merchantTitleLabel.bottomAnchor, constant: 2),
            merchantUnderline.leadingAnchor.constraint(equalTo: merchantTitleLabel.leadingAnchor),
            merchantUnderline.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            merchantUnderline.heightAnchor.constraint(equalToConstant: 1),
                       
            merchantContainerView.topAnchor.constraint(equalTo: merchantUnderline.bottomAnchor, constant: define.pading_wight),
            merchantContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            merchantContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
  
            // merchantContainerView 내부 제약조건 (tidRowView, merchantSeparator, posRowView는 setupMerchantContainer()에서 추가한 후 아래와 같이 배치)
            tidRowView.topAnchor.constraint(equalTo: merchantContainerView.topAnchor, constant: define.pading_wight),
            tidRowView.leadingAnchor.constraint(equalTo: merchantContainerView.leadingAnchor, constant: define.pading_wight),
            tidRowView.trailingAnchor.constraint(equalTo: merchantContainerView.trailingAnchor, constant: -define.pading_wight),
                        
            posRowView.topAnchor.constraint(equalTo: tidRowView.bottomAnchor, constant: 2),
            posRowView.leadingAnchor.constraint(equalTo: merchantContainerView.leadingAnchor, constant: define.pading_wight),
            posRowView.trailingAnchor.constraint(equalTo: merchantContainerView.trailingAnchor, constant: -define.pading_wight),
            posRowView.bottomAnchor.constraint(equalTo: merchantContainerView.bottomAnchor, constant: -define.pading_wight),

            // TID row 내부
            tidLabel.leadingAnchor.constraint(equalTo: merchantContainerView.subviews[0].leadingAnchor, constant: margin),
            tidLabel.centerYAnchor.constraint(equalTo: merchantContainerView.subviews[0].centerYAnchor),
            tidLabel.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            
            tidValueLabel.leadingAnchor.constraint(equalTo: tidLabel.trailingAnchor, constant: define.pading_wight),
            tidValueLabel.trailingAnchor.constraint(equalTo: merchantContainerView.subviews[0].trailingAnchor),
            tidValueLabel.centerYAnchor.constraint(equalTo: merchantContainerView.subviews[0].centerYAnchor),
            
            // POS row 내부
            posLabel.leadingAnchor.constraint(equalTo: merchantContainerView.subviews[1].leadingAnchor, constant: margin),
            posLabel.centerYAnchor.constraint(equalTo: merchantContainerView.subviews[1].centerYAnchor),
            posLabel.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            
            posNumberLabel.leadingAnchor.constraint(equalTo: posLabel.trailingAnchor, constant: define.pading_wight),
            posNumberLabel.centerYAnchor.constraint(equalTo: merchantContainerView.subviews[1].centerYAnchor),
            
            posDisclosureImage.trailingAnchor.constraint(equalTo: merchantContainerView.subviews[1].trailingAnchor, constant: -define.pading_wight * 2),
            posDisclosureImage.centerYAnchor.constraint(equalTo: merchantContainerView.subviews[1].centerYAnchor),

            // Product 섹션 (상품관리 설정)
            productTitleLabel.topAnchor.constraint(equalTo: merchantContainerView.bottomAnchor, constant: Utils.getRowSubHeight()),
            productTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            productTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            productTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            productUnderline.topAnchor.constraint(equalTo: productTitleLabel.bottomAnchor, constant: 2),
            productUnderline.leadingAnchor.constraint(equalTo: productTitleLabel.leadingAnchor),
            productUnderline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            productUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            productContainerView.topAnchor.constraint(equalTo: productUnderline.bottomAnchor, constant: define.pading_wight),
            productContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            productContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            
            // productContainerView 내부: registerRow 및 modifyRow (세로로 배치, 일정 간격)
            registerRow.topAnchor.constraint(equalTo: productContainerView.topAnchor, constant: define.pading_wight),
            registerRow.leadingAnchor.constraint(equalTo: productContainerView.leadingAnchor, constant: define.pading_wight),
            registerRow.trailingAnchor.constraint(equalTo: productContainerView.trailingAnchor, constant: -define.pading_wight),
            
            modifyRow.topAnchor.constraint(equalTo: registerRow.bottomAnchor, constant: 2),
            modifyRow.leadingAnchor.constraint(equalTo: productContainerView.leadingAnchor, constant: define.pading_wight),
            modifyRow.trailingAnchor.constraint(equalTo: productContainerView.trailingAnchor, constant: -define.pading_wight),
            modifyRow.bottomAnchor.constraint(equalTo: productContainerView.bottomAnchor, constant: -define.pading_wight),
            
            // 백업 섹션
            backupTitleLabel.topAnchor.constraint(equalTo: productContainerView.bottomAnchor, constant: Utils.getRowSubHeight()),
            backupTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            backupTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            backupTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            backupUnderline.topAnchor.constraint(equalTo: backupTitleLabel.bottomAnchor, constant: 2),
            backupUnderline.leadingAnchor.constraint(equalTo: backupTitleLabel.leadingAnchor),
            backupUnderline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            backupUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            productBackupContainerView.topAnchor.constraint(equalTo: backupUnderline.bottomAnchor, constant: define.pading_wight),
            productBackupContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            productBackupContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            // 백업 컨테이너 내부: backupExportRow 위쪽, backupImportRow 아래쪽
            backupExportRow.topAnchor.constraint(equalTo: productBackupContainerView.topAnchor, constant: define.pading_wight),
            backupExportRow.leadingAnchor.constraint(equalTo: productBackupContainerView.leadingAnchor, constant: define.pading_wight),
            backupExportRow.trailingAnchor.constraint(equalTo: productBackupContainerView.trailingAnchor, constant: -define.pading_wight),
            
            backupImportRow.topAnchor.constraint(equalTo: backupExportRow.bottomAnchor, constant: 2),
            backupImportRow.leadingAnchor.constraint(equalTo: productBackupContainerView.leadingAnchor, constant: define.pading_wight),
            backupImportRow.trailingAnchor.constraint(equalTo: productBackupContainerView.trailingAnchor, constant: -define.pading_wight),
            backupImportRow.bottomAnchor.constraint(equalTo: productBackupContainerView.bottomAnchor, constant: -define.pading_wight),
            
            // 마지막 요소는 contentView의 bottomAnchor에 연결하여 스크롤 가능하게 함.
            productBackupContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin)
        ])

        // hide separator for last row
        if let separator = modifyRow.viewWithTag(1001)?.subviews.last {
            separator.isHidden = true
        }
        if let separator = backupImportRow.viewWithTag(1001)?.subviews.last {
            separator.isHidden = true
        }
    }
    
    // MARK: - Helper Functions for Row Creation
    
    /// 좌측 제목과 우측 값(및 disclosure 아이콘)을 포함하는 행을 생성하는 함수
    private func createEditableRow(title: String, value: String, action: Selector?) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let leftLabel = UILabel()
        leftLabel.text = title
        leftLabel.font = Utils.getSubTitleFont()
        leftLabel.textColor = .darkGray
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let rightLabel = UILabel()
        rightLabel.text = value
        rightLabel.font = Utils.getSubTitleFont()
        rightLabel.textColor = .darkGray
        rightLabel.textAlignment = .right
        rightLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(leftLabel)
        container.addSubview(rightLabel)

        NSLayoutConstraint.activate([
            leftLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            leftLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
//            leftLabel.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),

            rightLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rightLabel.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor, constant: 10)
        ])
        
        // 하단 구분선 추가. 2번째 인 POS번호 가 아래에 있기 때문에 넣지 않는다
        if action == nil {
            let separator = UIView()
            separator.backgroundColor = define.underline_grey
            separator.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(separator)
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
                separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
                separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
        
        container.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()).isActive = true
        
        // tag를 부여해서 나중에 숨김 처리 가능하게 함
        container.tag = 1001
        
        if let action = action {
            let tap = UITapGestureRecognizer(target: self, action: action)
            container.addGestureRecognizer(tap)
        }
        
        return container
    }
       
    /// 단순 행: 좌측 타이틀과 우측 ">" disclosure 아이콘
    private func createRow(title: String, action: Selector) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UITapGestureRecognizer(target: self, action: action)
        container.addGestureRecognizer(tap)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Utils.getSubTitleFont()
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let disclosure = UIImageView(image: UIImage(systemName: "chevron.right"))
        disclosure.tintColor = .lightGray
        disclosure.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(disclosure)
        
        // 하단 separator 라인
        let separator = UIView()
        separator.backgroundColor = define.underline_grey
        separator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(separator)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            
            disclosure.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            disclosure.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -define.pading_wight * 2),

            // separator: 하단 전체 폭, 높이 1
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])

        // 행 높이를 고정 (나중에 마지막 행은 separator를 숨김)
        container.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()).isActive = true
        // tag를 부여해서 나중에 숨김 처리 가능하게 함
        container.tag = 1001
        
        return container
    }
    
    // MARK: - Button Actions
    
    // POS 번호 편집 alert 표시
    @objc private func editPOSNumber() {
        let alert = UIAlertController(title: "POS 번호 입력", message: "POS 번호를 입력해 주세요", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "숫자 최대 2자리 입력"
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            if let newPOS = alert.textFields?.first?.text, !newPOS.isEmpty {
                // 새로운 POS 번호 업데이트 및 posConfirmButton과 동일한 기능 호출
                self.posNumberLabel.text = newPOS
                self.posConfirmTapped()
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    // POS 번호 확인 기능 (기존 posConfirmButton 기능)
    @objc private func posConfirmTapped() {
        guard let tid = tidValueLabel.text, !tid.isEmpty else {
            print("TID 값이 없습니다. POS번호 저장 실패")
            self.AlertBox(title: "POS번호등록", message: "TID 값이 없습니다. POS번호 저장 실패", text: "확인")
            return
        }
        let posNumber = posNumberLabel.text ?? ""
        print("입력한 POS번호: \(posNumber)")
        Setting.shared.setDefaultUserData(_data: posNumber, _key: define.LOGIN_POS_NO)
        self.AlertBox(title: "POS번호등록", message: "등록한 POS번호는 \(posNumber) 입니다", text: "확인")
    }
    
    @objc private func productRegisterTapped() {
        guard let tid = tidValueLabel.text, !tid.isEmpty else {
            self.AlertBox(title: "상품등록 실패", message: "TID 값이 없습니다. 가맹점 다운로드를 진행해 주세요", text: "확인")
            return
        }
        let posNo = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
        if posNo.isEmpty {
            self.AlertBox(title: "상품등록 실패", message: "POS번호 값이 없습니다. POS번호를 입력해 주세요", text: "확인")
            return
        }
        delegate?.productSetViewControllerDidTapRegister(self)
        let registerVC = ProductRegisterViewController()
        let navController = UINavigationController(rootViewController: registerVC)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = registerVC
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func productModifyTapped() {
        guard let tid = tidValueLabel.text, !tid.isEmpty else {
            self.AlertBox(title: "상품수정 실패", message: "TID 값이 없습니다. 가맹점 다운로드를 진행해 주세요", text: "확인")
            return
        }
        let posNo = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
        if posNo.isEmpty {
            self.AlertBox(title: "상품수정 실패", message: "POS번호 값이 없습니다. POS번호를 입력해 주세요", text: "확인")
            return
        }
        delegate?.productSetViewControllerDidTapModify(self)
        let listVC = ProductListViewController()
        let navController = UINavigationController(rootViewController: listVC)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = listVC
        present(navController, animated: true, completion: nil)
    }
    
    // exportDataTapped와 importDataTapped는 기존 코드와 동일
    @objc private func exportDataTapped() {
        guard let tid = tidValueLabel.text, !tid.isEmpty else {
            print("TID 값이 없습니다. POS번호 저장 실패")
            AlertBox(title: "상품수정 실패", message: "TID 값이 없습니다. 가맹점 다운로드를 진행해 주세요", text: "확인")
            return
        }
        let posNo = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
        if posNo.isEmpty {
            AlertBox(title: "상품수정 실패", message: "POS번호 값이 없습니다. POS번호를 입력해 주세요", text: "확인")
            return
        }
        print("내보내기 버튼 클릭 - DB 데이터를 CSV 파일로 변환 후 저장 및 공유 기능 수행")
        // 실제 구현:
        // 1. sqlite 데이터베이스에서 데이터를 조회하여 CSV 형식으로 변환
        // 2. 안드로이드의 다운로드 폴더와 유사한 위치(예: Documents 디렉토리)에 파일 저장
        // 3. UIActivityViewController 등을 이용하여 메일, 카카오톡, 메세지 등으로 공유

        // 1. 파일 이름 생성: "koces_db_product_" + 현재날짜("yymmddhhmmss") + ".csv"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmmss"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "koces_db_product_\(dateString).csv"
          
        // 2. Documents 디렉토리 내에 파일 경로 지정
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // 3. 새 폴더 이름 (예: "KOCES")
        let exportFolderURL = documentsURL.appendingPathComponent("KOCES", isDirectory: true)
        // 4. 폴더가 존재하지 않으면 생성
        if !FileManager.default.fileExists(atPath: exportFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: exportFolderURL, withIntermediateDirectories: true, attributes: nil)
                print("폴더 생성 성공: \(exportFolderURL.path)")
            } catch {
                print("폴더 생성 실패: \(error)")
            }
        }

        let fileURL = exportFolderURL.appendingPathComponent(fileName)

        // 5. DB에서 상품 테이블 데이터를 CSV로 내보내는 함수를 호출 (exportProductTable(to:) 함수 사용)
        if let exportedURL = sqlite.instance.exportProductTable(to: fileURL) {
            print("CSV 파일 내보내기 성공: \(exportedURL.path)")
    
            // 6. UIActivityViewController를 이용하여 공유 기능 표시
            let activityVC = UIActivityViewController(activityItems: [exportedURL], applicationActivities: nil)
            // iPad의 경우 popoverPresentationController 설정 (필수)
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: self.view.bounds.midX,
                                            y: self.view.bounds.midY,
                                            width: 0,
                                            height: 0)
                popover.permittedArrowDirections = []  // 화살표가 표시되지 않도록 설정
            }
            present(activityVC, animated: true, completion: nil)
            
        } else {
            print("CSV 파일 내보내기 실패")
        }

    }
    
    @objc private func importDataTapped() {
        guard let tid = tidValueLabel.text, !tid.isEmpty else {
            print("TID 값이 없습니다. POS번호 저장 실패")
            AlertBox(title: "상품수정 실패", message: "TID 값이 없습니다. 가맹점 다운로드를 진행해 주세요", text: "확인")
            return
        }
        let posNo = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
        if posNo.isEmpty {
            AlertBox(title: "상품수정 실패", message: "POS번호 값이 없습니다. POS번호를 입력해 주세요", text: "확인")
            return
        }
        print("가져오기 버튼 클릭 - 외부 CSV 파일을 읽어서 sqlite DB에 저장")
        // 실제 구현:
        // 1. 외부 파일 선택 (UIDocumentPickerViewController 등 사용)
        // 2. CSV 파일 파싱 후 sqlite DB에 데이터 삽입
        
        // UIDocumentPickerViewController 생성 (CSV 파일 선택)
        // "public.comma-separated-values-text"만 지정하여 CSV 파일만 보이게 함
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.comma-separated-values-text"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        
        // iOS 14 이상에서 기본 폴더 지정 (예: Documents/KocesICIOS/KOCES)
        if #available(iOS 14.0, *) {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let defaultFolderURL = documentsURL.appendingPathComponent("KOCES", isDirectory: true)
            // 폴더가 없으면 생성
            if !FileManager.default.fileExists(atPath: defaultFolderURL.path) {
                do {
                    try FileManager.default.createDirectory(at: defaultFolderURL, withIntermediateDirectories: true, attributes: nil)
                    print("CSVFiles 폴더 생성 성공: \(defaultFolderURL.path)")
                } catch {
                    print("CSVFiles 폴더 생성 실패: \(error)")
                }
            }
            documentPicker.directoryURL = defaultFolderURL
        }
        present(documentPicker, animated: true, completion: nil)
    }
    
    // 파일 선택 성공 시 호출
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        let fileName = fileURL.lastPathComponent
        // 파일 이름 유효성 검사
        if !fileName.contains("koces_db_product_") || !fileName.hasSuffix(".csv") {
            AlertBox(title: "오류", message: "해당 파일은 koces db 파일이 아닙니다", text: "확인")
            return
        }
        
        // DB에서 기존 상품 데이터를 제거하고 테이블을 재생성하는 함수 호출 (구현 필요)
        let dropResult = sqlite.instance.dropAndCreateTable(TableName: define.DB_ProductTable)
        if !dropResult {
            AlertBox(title: "오류", message: "기존 상품 데이터를 정상적으로 제거하지 못했습니다. 다시 시도해 주십시오", text: "확인")
            return
        }
        
        // 진행률 표시 (실제 구현에 따라 progressView나 커스텀 progress dialog 사용)
        showProgressBar(title: "상품정보 가져오기", message: "파일을 읽는 중입니다. 잠시만 기다려 주십시오...")
        
        // CSV 파일의 총 행 수를 파악 (진행률 계산용)
        DispatchQueue.global(qos: .background).async {
            var totalLineCount = 0
            do {
                var fileContents = try String(contentsOf: fileURL, encoding: .utf8)
                fileContents = fileContents.replacingOccurrences(of: "\"", with: "")
                var lines = fileContents.components(separatedBy: "idt")
//                let lines = fileContents.components(separatedBy: .newlines).filter { !$0.isEmpty }
                totalLineCount = lines.count
            } catch {
                DispatchQueue.main.async {
                    self.hideProgressBar()
                    self.AlertBox(title: "오류", message: "파일 읽기 오류: \(error.localizedDescription)", text: "확인")
                }
                return
            }
            
            // CSV 파일의 실제 파싱 및 DB 삽입 처리
            do {
                // 파일을 다시 열어서 CSV를 한 줄씩 읽습니다.
                var fileContents = try String(contentsOf: fileURL, encoding: .utf8)
                fileContents = fileContents.replacingOccurrences(of: "\"", with: "")
                var lines = fileContents.components(separatedBy: "idt")
                // CSV 파일에 헤더가 포함되어 있다면 제거 (헤더 행이 "Tid" 등의 문자열을 포함한다고 가정. 헤더 행은 존재하지 않음)
//                if let header = lines.first, header.contains("idt") {
//                    lines.removeFirst()
//                }
                
                var processedLines = 0
                
                // 최대 1000개까지만 처리
                for line in lines {
//                    if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
                    processedLines += 1
                    if processedLines > 1000 { break }
                    
                    // 진행률 업데이트 (메인 스레드에서)
                    let progress = Float(processedLines) / Float(totalLineCount)
                    DispatchQueue.main.async {
                        self.updateProgress(progress:progress)
                    }
                    
                    // CSV 파싱 (간단하게 쉼표로 분리; 실제 데이터에 따라 개선 필요)
                    let fields = line.components(separatedBy: ",")
                    if fields.count < 24 { continue }  // 필드 부족 시 건너뛰기
                    
                    // 인덱스는 CREATE TABLE 순서에 맞게 (예시로 Android 코드와 동일)
                    // 예시: fields[1]=Tid, [2]=ProductSeq, [3]=TableNo, [4]=Code, [5]=Name, [6]=Category,
                    // [7]=Price, [8]=Date, [9]=Barcode, [10]=IsUse, [11]=ImgUrl, [12]=ImgString,
                    // [13]=VATUSE, [14]=VATAUTO, [15]=VATINCLUDE, [16]=VATRATE, [17]=VATWON,
                    // [18]=SVCUSE, [19]=SVCAUTO, [20]=SVCINCLUDE, [21]=SVCRATE, [22]=SVCWON, [23]=TotalPrice, [24]=IsImgUse
                    
                    let _tableNo = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
                    
             
                    let pSeq = KocesSdk.instance.getTid() +
                    Utils.leftPad(str: _tableNo, fillChar: "0", length: 3) +
                    Utils.leftPad(str: fields[3], fillChar: "0", length: 5)
                    
                    let tid = KocesSdk.instance.getTid()
                    let productSeq = pSeq
                    let tableNo = Int(_tableNo)
                    let pcode = fields[3]
                    let pname = fields[4]
                    let pcategory = fields[5]
                    let price = fields[6]
                    let pdate = fields[7]
                    let barcode = fields[8]
                    let isUse = Int(fields[9]) ?? 0
                    let imgUrl = fields[10]
                    let imgBitmapString = fields[11]
                    let useVAT = Int(fields[12]) ?? 0
                    let autoVAT = Int(fields[13]) ?? 0
                    let includeVAT = Int(fields[14]) ?? 0
                    let vatRate = Int(fields[15]) ?? 0
                    let vatWon = fields[16]
                    let useSVC = Int(fields[17]) ?? 0
                    let autoSVC = Int(fields[18]) ?? 0
                    let includeSVC = Int(fields[19]) ?? 0
                    let svcRate = Int(fields[20]) ?? 0
                    let svcWon = fields[21]
                    let totalPrice = fields[22]
                    let isImgUse = Int(fields[23]) ?? 0
                    
                    // DB에 상품 정보 삽입 (구현되어 있는 insertProductInfo 함수를 호출)
                    let success = sqlite.instance.insertProductInfo(tid: tid,
                                                                    productSeq: productSeq,
                                                                    tableNo: tableNo ?? 1,
                                                                    pcode: pcode,
                                                                    pname: pname,
                                                                    pcategory: pcategory,
                                                                    price: price,
                                                                    pdate: pdate,
                                                                    barcode: barcode,
                                                                    isUse: isUse,
                                                                    imgUrl: imgUrl,
                                                                    imgBitmapString: imgBitmapString,
                                                                    useVAT: useVAT,
                                                                    autoVAT: autoVAT,
                                                                    includeVAT: includeVAT,
                                                                    vatRate: vatRate,
                                                                    vatWon: vatWon,
                                                                    useSVC: useSVC,
                                                                    autoSVC: autoSVC,
                                                                    includeSVC: includeSVC,
                                                                    svcRate: svcRate,
                                                                    svcWon: svcWon,
                                                                    totalPrice: totalPrice,
                                                                    isImgUse: isImgUse)
                    // 실패 시 로그 찍거나 처리할 수 있습니다.
                }
                
                DispatchQueue.main.async {
                    self.hideProgressBar()
                    if processedLines >= 1 {
                        self.AlertBox(title: "성공", message: "상품 전체 가져오기 성공",text: "확인")
                        // 상품 UI 갱신 (기존 함수 호출)
                        KocesSdk.instance.clearProductList()
                        KocesSdk.instance.getProductList()
                    } else {
                        self.AlertBox(title: "실패", message: "등록할 상품이 없습니다",text: "확인")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.hideProgressBar()
                    self.AlertBox(title: "오류", message: "파일 읽기 오류: \(error.localizedDescription)",text: "확인")
                }
            }
        }
    }
    
    // 파일 선택 취소 시
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        hideProgressBar()
        AlertBox(title: "취소", message: "파일 선택 취소", text: "확인")
    }
    
    
    
    // MARK: - 데이터 로드
    
    private func loadTIDValue() {
        let tidValue: String?
        if Utils.getIsCAT() {
            tidValue = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID)
        } else {
            tidValue = Setting.shared.getDefaultUserData(_key: define.STORE_TID)
        }
        tidValueLabel.text = tidValue ?? ""
        print("로드된 TID: \(tidValue ?? "없음")")
    }
    

    
    // MARK: - Alert & Progress UI (기존 코드와 동일)
       
       func AlertBox(title: String, message: String, text: String) {
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okButton = UIAlertAction(title: text, style: .cancel, handler: nil)
           alertController.addAction(okButton)
           self.present(alertController, animated: true, completion: nil)
       }
       
       func showProgressBar(title: String, message: String) {
           progressOverlay?.removeFromSuperview()
           let overlay = UIView(frame: self.view.bounds)
           overlay.backgroundColor = UIColor(white: 0, alpha: 0.4)
           overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           let container = UIView()
           container.backgroundColor = .white
           container.layer.cornerRadius = 10
           container.translatesAutoresizingMaskIntoConstraints = false
           let titleLabel = UILabel()
           titleLabel.text = title
           titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
           titleLabel.textAlignment = .center
           titleLabel.translatesAutoresizingMaskIntoConstraints = false
           let messageLabel = UILabel()
           messageLabel.text = message
           messageLabel.font = UIFont.systemFont(ofSize: 16)
           messageLabel.textAlignment = .center
           messageLabel.numberOfLines = 0
           messageLabel.translatesAutoresizingMaskIntoConstraints = false
           let progressView = UIProgressView(progressViewStyle: .default)
           progressView.progress = 0.0
           progressView.translatesAutoresizingMaskIntoConstraints = false
           container.addSubview(titleLabel)
           container.addSubview(messageLabel)
           container.addSubview(progressView)
           overlay.addSubview(container)
           self.view.addSubview(overlay)
           NSLayoutConstraint.activate([
               container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
               container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
               container.widthAnchor.constraint(equalToConstant: 250),
               container.heightAnchor.constraint(equalToConstant: 120),
               titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
               titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
               titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
               messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
               messageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
               messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
               progressView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 15),
               progressView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
               progressView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
               progressView.heightAnchor.constraint(equalToConstant: 2)
           ])
           self.progressOverlay = overlay
           self.progressBar = progressView
           self.progressTitleLabel = titleLabel
           self.progressMessageLabel = messageLabel
       }
       
       func updateProgress(progress: Float) {
           DispatchQueue.main.async {
               self.progressBar?.setProgress(progress, animated: true)
           }
       }
       
       func hideProgressBar() {
           DispatchQueue.main.async {
               self.progressOverlay?.removeFromSuperview()
               self.progressOverlay = nil
               self.progressBar = nil
               self.progressTitleLabel = nil
               self.progressMessageLabel = nil
           }
       }
}

