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

class ProductSetViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: ProductSetViewControllerDelegate?
    
    // MARK: - UI Components
    
    // 맨 위에 표시할 "POS" 라벨
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text =  "상품관리"
        label.font = Utils.getTitleFont()
        label.textAlignment = .left
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
        return label
    }()
    
    private let merchantUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = define.underline_grey
        return view
    }()
    
    // 그룹 컨테이너 (밝은 회색 배경, 라운드)
    private let merchantContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = define.layout_border_lightgrey
        view.layer.cornerRadius = define.pading_wight
        view.clipsToBounds = true
        return view
    }()
    
    // TID 행
    private let tidLabel: UILabel = {
        let label = UILabel()
        label.text = "TID"
        label.textAlignment = .left
        label.font = Utils.getTextFont()
        return label
    }()
    
    private let tidValueLabel: UILabel = {
        let label = UILabel()
        label.text = "" // viewDidLoad에서 외부 값 세팅
        label.font = Utils.getTextFont()
        label.textColor = .darkGray
        return label
    }()
    
    // POS번호 행
    private let posLabel: UILabel = {
        let label = UILabel()
        label.text = "POS번호"
        label.font = Utils.getTextFont()
        label.textAlignment = .left
        return label
    }()
    
    private let posNumberTextField: UITextField = {
        let textField = UITextField()
        textField.text = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
        textField.placeholder = "숫자 2자리 입력"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.font = Utils.getTextFont()
        return textField
    }()
    
    private let posConfirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = Utils.getSubTitleFont()
        return button
    }()
    
    // 두번째 섹션: "상품관리 설정"
    private let productTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "상품관리 설정"
        label.font = Utils.getSubTitleFont()
        return label
    }()
    
    private let productUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = define.underline_grey
        return view
    }()
    
    private let productContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = define.layout_border_lightgrey
        view.layer.cornerRadius = define.pading_wight
        view.clipsToBounds = true
        return view
    }()
    
    // 상품관리 행 (첫번째 행)
    private let productManageLabel: UILabel = {
        let label = UILabel()
        label.text = "상품관리"
        label.font = Utils.getTextFont()
        label.textAlignment = .left
        return label
    }()
    
    private let productRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("상품등록", for: .normal)
        button.titleLabel?.font = Utils.getSubTitleFont()
        return button
    }()
    
    private let productModifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("상품수정", for: .normal)
        button.titleLabel?.font = Utils.getSubTitleFont()
        return button
    }()
    
    // 상품정보백업 행 (두번째 행)
    private let productBackupLabel: UILabel = {
        let label = UILabel()
        label.text = "상품정보백업"
        label.textAlignment = .left
        label.font = Utils.getTextFont()
        return label
    }()
    
    private let exportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("내보내기", for: .normal)
        button.titleLabel?.font = Utils.getTextFont()
        return button
    }()
    
    private let importButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("가져오기", for: .normal)
        button.titleLabel?.font = Utils.getTextFont()
        return button
    }()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "상품관리 설정" // 네비게이션 타이틀 등
        
        posNumberTextField.delegate = self
        
        setupUI()
        loadTIDValue()
        addActions()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // view에 subview 추가
        [titleLabel, titleUnderline, merchantTitleLabel, merchantUnderline, merchantContainerView, productTitleLabel, productUnderline, productContainerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // MARK: Merchant Container 구성 (TID / POS번호)
        // TID row
        let tidRowView = UIView()
        tidRowView.translatesAutoresizingMaskIntoConstraints = false
        merchantContainerView.addSubview(tidRowView)
        
        [tidLabel, tidValueLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            tidRowView.addSubview($0)
        }
        
        // POS번호 row
        let posRowView = UIView()
        posRowView.translatesAutoresizingMaskIntoConstraints = false
        merchantContainerView.addSubview(posRowView)
        
        [posLabel, posNumberTextField, posConfirmButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            posRowView.addSubview($0)
        }
        
        // MARK: Product Container 구성 (상품관리 / 상품정보백업)
        // 상품관리 row
        let productManageRowView = UIView()
        productManageRowView.translatesAutoresizingMaskIntoConstraints = false
        productContainerView.addSubview(productManageRowView)
        
        [productManageLabel, productRegisterButton, productModifyButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            productManageRowView.addSubview($0)
        }
        
        // 상품정보백업 row
        let productBackupRowView = UIView()
        productBackupRowView.translatesAutoresizingMaskIntoConstraints = false
        productContainerView.addSubview(productBackupRowView)
        
        [productBackupLabel, exportButton, importButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            productBackupRowView.addSubview($0)
        }
        
        // MARK: - Constraints
        
        let margin: CGFloat = 10
        
        NSLayoutConstraint.activate([
            // titleLabel 제약조건
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: margin),
            titleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            // titleUnderline (제목 밑 언더라인)
            titleUnderline.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            titleUnderline.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            titleUnderline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            titleUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            // merchantTitleLabel 제약조건
            merchantTitleLabel.topAnchor.constraint(equalTo: titleUnderline.bottomAnchor),
            merchantTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            merchantTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: margin),
            merchantTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            // merchantUnderline (제목 밑 언더라인)
            merchantUnderline.topAnchor.constraint(equalTo: merchantTitleLabel.bottomAnchor),
            merchantUnderline.leadingAnchor.constraint(equalTo: merchantTitleLabel.leadingAnchor),
            merchantUnderline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            merchantUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            // merchantContainerView
            merchantContainerView.topAnchor.constraint(equalTo: merchantUnderline.bottomAnchor, constant: define.pading_wight),
            merchantContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            merchantContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            
            // tidRowView (상단 행) - merchantContainerView 내부
            tidRowView.topAnchor.constraint(equalTo: merchantContainerView.topAnchor),
            tidRowView.leadingAnchor.constraint(equalTo: merchantContainerView.leadingAnchor, constant: define.pading_wight),
            tidRowView.trailingAnchor.constraint(equalTo: merchantContainerView.trailingAnchor, constant: -define.pading_wight),
            tidRowView.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()),
            
            // posRowView (하단 행)
            posRowView.topAnchor.constraint(equalTo: tidRowView.bottomAnchor),
            posRowView.leadingAnchor.constraint(equalTo: merchantContainerView.leadingAnchor, constant: define.pading_wight),
            posRowView.trailingAnchor.constraint(equalTo: merchantContainerView.trailingAnchor, constant: -define.pading_wight),
            posRowView.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()),
            posRowView.bottomAnchor.constraint(equalTo: merchantContainerView.bottomAnchor),
            
            // TID row 내부 제약조건
            tidLabel.leadingAnchor.constraint(equalTo: tidRowView.leadingAnchor),
            tidLabel.centerYAnchor.constraint(equalTo: tidRowView.centerYAnchor),
            tidLabel.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            
            tidValueLabel.leadingAnchor.constraint(equalTo: tidLabel.trailingAnchor, constant: define.pading_wight),
            tidValueLabel.trailingAnchor.constraint(equalTo: tidRowView.trailingAnchor),
            tidValueLabel.centerYAnchor.constraint(equalTo: tidRowView.centerYAnchor),
            
            // POS row 내부 제약조건
            posLabel.leadingAnchor.constraint(equalTo: posRowView.leadingAnchor),
            posLabel.centerYAnchor.constraint(equalTo: posRowView.centerYAnchor),
            posLabel.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            
            posNumberTextField.leadingAnchor.constraint(equalTo: posLabel.trailingAnchor, constant: define.pading_wight),
            posNumberTextField.centerYAnchor.constraint(equalTo: posRowView.centerYAnchor),
            // posNumberTextField 오른쪽은 확인버튼과 간격
            posNumberTextField.trailingAnchor.constraint(equalTo: posConfirmButton.leadingAnchor, constant: -define.pading_wight),
            
            posConfirmButton.trailingAnchor.constraint(equalTo: posRowView.trailingAnchor),
            posConfirmButton.centerYAnchor.constraint(equalTo: posRowView.centerYAnchor),
            posConfirmButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            
            // 두번째 섹션: 상품관리 설정 제목 및 언더라인
            productTitleLabel.topAnchor.constraint(equalTo: merchantContainerView.bottomAnchor, constant: Utils.getRowSubHeight()),
            productTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            productTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: margin),
            productTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            productUnderline.topAnchor.constraint(equalTo: productTitleLabel.bottomAnchor),
            productUnderline.leadingAnchor.constraint(equalTo: productTitleLabel.leadingAnchor),
            productUnderline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            productUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            // productContainerView
            productContainerView.topAnchor.constraint(equalTo: productUnderline.bottomAnchor, constant: define.pading_wight),
            productContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            productContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            
            // productManageRowView 제약조건 (상품관리 행)
            productManageRowView.topAnchor.constraint(equalTo: productContainerView.topAnchor),
            productManageRowView.leadingAnchor.constraint(equalTo: productContainerView.leadingAnchor, constant: define.pading_wight),
            productManageRowView.trailingAnchor.constraint(equalTo: productContainerView.trailingAnchor, constant: -define.pading_wight),
            productManageRowView.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()),
            
            // productBackupRowView 제약조건 (상품정보백업 행)
            productBackupRowView.topAnchor.constraint(equalTo: productManageRowView.bottomAnchor),
            productBackupRowView.leadingAnchor.constraint(equalTo: productContainerView.leadingAnchor, constant: define.pading_wight),
            productBackupRowView.trailingAnchor.constraint(equalTo: productContainerView.trailingAnchor, constant: -define.pading_wight),
            productBackupRowView.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()),
            productBackupRowView.bottomAnchor.constraint(equalTo: productContainerView.bottomAnchor),
            
            // 상품관리 행 내부 제약조건
            productManageLabel.leadingAnchor.constraint(equalTo: productManageRowView.leadingAnchor),
            productManageLabel.centerYAnchor.constraint(equalTo: productManageRowView.centerYAnchor),
            productManageLabel.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            
            productRegisterButton.leadingAnchor.constraint(equalTo: productManageLabel.trailingAnchor, constant: define.pading_wight),
            productRegisterButton.centerYAnchor.constraint(equalTo: productManageRowView.centerYAnchor),
            
            productModifyButton.leadingAnchor.constraint(equalTo: productRegisterButton.trailingAnchor, constant: define.pading_wight),
            productModifyButton.centerYAnchor.constraint(equalTo: productManageRowView.centerYAnchor),
            
            // 상품정보백업 행 내부 제약조건
            productBackupLabel.leadingAnchor.constraint(equalTo: productBackupRowView.leadingAnchor),
            productBackupLabel.centerYAnchor.constraint(equalTo: productBackupRowView.centerYAnchor),
            productBackupLabel.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            
            exportButton.leadingAnchor.constraint(equalTo: productBackupLabel.trailingAnchor, constant: define.pading_wight),
            exportButton.centerYAnchor.constraint(equalTo: productBackupRowView.centerYAnchor),
            
            importButton.leadingAnchor.constraint(equalTo: exportButton.trailingAnchor, constant: define.pading_wight),
            importButton.centerYAnchor.constraint(equalTo: productBackupRowView.centerYAnchor)
        ])
    }
    
    // MARK: - 데이터 로드
    
    private func loadTIDValue() {
        // 외부 Setting 클래스로부터 TID 값을 로드합니다.
        var tidValue: String?
        if Utils.getIsCAT() {
            tidValue = Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID)
        } else {
            tidValue = Setting.shared.getDefaultUserData(_key: define.STORE_TID)
        }
        tidValueLabel.text = tidValue ?? ""
        print("로드된 TID: \(tidValue ?? "없음")")
    }
    
    // MARK: - Button Actions
    
    private func addActions() {
        posConfirmButton.addTarget(self, action: #selector(confirmPOSTapped), for: .touchUpInside)
        productRegisterButton.addTarget(self, action: #selector(productRegisterTapped), for: .touchUpInside)
        productModifyButton.addTarget(self, action: #selector(productModifyTapped), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(exportDataTapped), for: .touchUpInside)
        importButton.addTarget(self, action: #selector(importDataTapped), for: .touchUpInside)
    }
    
    @objc private func confirmPOSTapped() {
        // TID 값이 없는 경우 리턴 및 로그 남기기
        guard let tid = tidValueLabel.text, !tid.isEmpty else {
            print("TID 값이 없습니다. POS번호 저장 실패")
            AlertBox(title: "POS번호등록", message: "TID 값이 없습니다. POS번호 저장 실패", text: "확인")
            return
        }
        
        let posNumber = posNumberTextField.text ?? ""
        print("입력한 POS번호: \(posNumber)")
        // 이후 실제 저장 로직 구현 가능 (현재는 로그만 남김)
        Setting.shared.setDefaultUserData(_data: posNumber, _key: define.LOGIN_POS_NO)
        AlertBox(title: "POS번호등록", message: "등록한 POS번호는 \(posNumber) 입니다", text: "확인")
    }
    
    @objc private func productRegisterTapped() {
        guard let tid = tidValueLabel.text, !tid.isEmpty else {
            print("TID 값이 없습니다. POS번호 저장 실패")
            AlertBox(title: "상품등록 실패", message: "TID 값이 없습니다. 가맹점 다운로드를 진행해 주세요", text: "확인")
            return
        }
        let posNo = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
        if posNo.isEmpty {
            AlertBox(title: "상품등록 실패", message: "POS번호 값이 없습니다. POS번호를 입력해 주세요", text: "확인")
            return
        }
        print("상품등록 버튼 클릭 - 다른 화면으로 이동 (뒤로가기 시 이 화면으로 복귀)")
        // 직접 전환하는 대신 delegate 호출
        delegate?.productSetViewControllerDidTapRegister(self)
    }
    
    @objc private func productModifyTapped() {
        guard let tid = tidValueLabel.text, !tid.isEmpty else {
            print("TID 값이 없습니다. POS번호 저장 실패")
            AlertBox(title: "상품등록 실패", message: "TID 값이 없습니다. 가맹점 다운로드를 진행해 주세요", text: "확인")
            return
        }
        let posNo = Setting.shared.getDefaultUserData(_key: define.LOGIN_POS_NO)
        if posNo.isEmpty {
            AlertBox(title: "상품등록 실패", message: "POS번호 값이 없습니다. POS번호를 입력해 주세요", text: "확인")
            return
        }
        print("상품수정 버튼 클릭 - 다른 화면으로 이동 (뒤로가기 시 이 화면으로 복귀)")
        // 직접 전환하는 대신 delegate 호출
        delegate?.productSetViewControllerDidTapModify(self)
    }
    
    @objc private func exportDataTapped() {
        print("내보내기 버튼 클릭 - DB 데이터를 CSV 파일로 변환 후 저장 및 공유 기능 수행")
        // 실제 구현:
        // 1. sqlite 데이터베이스에서 데이터를 조회하여 CSV 형식으로 변환
        // 2. 안드로이드의 다운로드 폴더와 유사한 위치(예: Documents 디렉토리)에 파일 저장
        // 3. UIActivityViewController 등을 이용하여 메일, 카카오톡, 메세지 등으로 공유
    }
    
    @objc private func importDataTapped() {
        print("가져오기 버튼 클릭 - 외부 CSV 파일을 읽어서 sqlite DB에 저장")
        // 실제 구현:
        // 1. 외부 파일 선택 (UIDocumentPickerViewController 등 사용)
        // 2. CSV 파일 파싱 후 sqlite DB에 데이터 삽입
    }
    
    // MARK: - UITextFieldDelegate (숫자 2자리 제한)
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 숫자만 입력 가능하도록 제한
        let allowedCharacters = CharacterSet.decimalDigits
        if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return false
        }
        
        // 최대 2자리 제한
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 2
    }
    
    func AlertBox(title : String, message : String, text : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okButton)
        return self.present(alertController, animated: true, completion: nil)
    }
}

