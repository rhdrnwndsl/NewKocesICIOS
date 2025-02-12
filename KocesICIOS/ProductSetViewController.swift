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
    
    // 상품 가져오기 시 진행률 표시
    private var progressOverlay: UIView?
    private var progressBar: UIProgressView?
    private var progressTitleLabel: UILabel?
    private var progressMessageLabel: UILabel?

    
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
        
        print("상품등록 버튼 클릭 - 모달로 ProductRegisterViewController 호출")
        let registerVC = ProductRegisterViewController()
        // 모달 내비게이션 컨트롤러로 감싸서 내비게이션 바를 사용할 수 있게 함
        let navController = UINavigationController(rootViewController: registerVC)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = registerVC  // 또는 별도로 지정
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func productModifyTapped() {
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
        print("상품수정 버튼 클릭 - 상품리스트 화면으로 이동(뒤로가기 시 이 화면으로 복귀)")
        // 직접 전환하는 대신 delegate 호출
        delegate?.productSetViewControllerDidTapModify(self)
        let listVC = ProductListViewController()
        // 모달 내비게이션 컨트롤러로 감싸서 내비게이션 바를 사용할 수 있게 함
        let navController = UINavigationController(rootViewController: listVC)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = listVC  // 또는 별도로 지정
        self.present(navController, animated: true, completion: nil)
    }
    
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
        
//        // 3. CSV 파일 생성 (exportProductTable(to:) 함수 호출)
//        if let exportedURL = sqlite.instance.exportProductTable(to: fileURL) {
//            print("CSV 파일 내보내기 성공: \(exportedURL.path)")
//            
//            // 4. UIDocumentPickerViewController로 내보내기
//            let documentPicker = UIDocumentPickerViewController(forExporting: [exportedURL])
//            documentPicker.delegate = self  // 필요 시 UIDocumentPickerDelegate 구현
//            documentPicker.modalPresentationStyle = .formSheet
//            present(documentPicker, animated: true, completion: nil)
//        } else {
//            print("CSV 파일 내보내기 실패")
//        }
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
    
    func showProgressBar(title: String, message: String) {
        // 기존 오버레이가 있다면 제거
        progressOverlay?.removeFromSuperview()
        
        // 전체 뷰를 덮는 오버레이 생성 (반투명 검정색 배경)
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.4)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 중앙에 배치할 컨테이너 뷰 생성 (흰색 배경, 라운드 처리)
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // 제목 라벨 생성
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 메시지 라벨 생성
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 진행률 표시줄 생성
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        // 컨테이너 뷰에 제목, 메시지, 진행률 표시줄 추가
        container.addSubview(titleLabel)
        container.addSubview(messageLabel)
        container.addSubview(progressView)
        
        // 오버레이에 컨테이너 추가
        overlay.addSubview(container)
        
        // 오버레이를 현재 뷰에 추가
        self.view.addSubview(overlay)
        
        // 컨테이너 뷰의 Auto Layout 제약조건 설정 (오버레이 중앙에 고정)
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 250),
            container.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        // 컨테이너 내부의 제목, 메시지, 진행률 표시줄 제약조건 설정
        NSLayoutConstraint.activate([
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
        
        // 진행률 오버레이 관련 프로퍼티에 참조 저장
        self.progressOverlay = overlay
        self.progressBar = progressView
        self.progressTitleLabel = titleLabel
        self.progressMessageLabel = messageLabel
    }
    
    func updateProgress(progress:Float) {
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

