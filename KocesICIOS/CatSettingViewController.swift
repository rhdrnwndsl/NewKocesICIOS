//
//  CatSettingViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2/13/25.
//

import Foundation
import UIKit

class CatSettingViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Header (상단 고정 영역)
    private let headerView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CAT설정"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Scrollable Content
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    // MARK: - Section 1: CAT단말기설정
    private let catDeviceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "CAT단말기설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let catDeviceUnderline = CatSettingViewController.createUnderline()
    private let catDeviceContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // CAT IP row
    private let catIPLabel: UILabel = {
        let label = UILabel()
        label.text = "CAT IP"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let catIPTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "입력"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    // PORT row
    private let portLabel: UILabel = {
        let label = UILabel()
        label.text = "PORT"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let portTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "입력"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // MARK: - Section 2: QR스캐너 설정
    private let qrScannerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "QR스캐너 설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let qrScannerUnderline = CatSettingViewController.createUnderline()
    private let qrScannerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // QR스캐너 row: 레이블 + Segmented Control
    private let qrScannerLabel: UILabel = {
        let label = UILabel()
        label.text = "QR스캐너"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var qrScannerSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["카메라", "CAT단말기"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        catIPTextField.delegate = self
        portTextField.delegate = self
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Header Setup
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(saveButton)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            saveButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            saveButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // ScrollView & Content StackView Setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // Section 1: CAT단말기설정
        contentStackView.addArrangedSubview(catDeviceTitleLabel)
        contentStackView.addArrangedSubview(catDeviceUnderline)
        contentStackView.addArrangedSubview(catDeviceContainer)
        catDeviceContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Inside catDeviceContainer: 두 행 (CAT IP, PORT)
        let catIPRow = createInputRow(label: catIPLabel, textField: catIPTextField)
        let portRow = createInputRow(label: portLabel, textField: portTextField)
        let deviceStack = UIStackView(arrangedSubviews: [catIPRow, portRow])
        deviceStack.axis = .vertical
        deviceStack.spacing = 10
        deviceStack.translatesAutoresizingMaskIntoConstraints = false
        catDeviceContainer.addSubview(deviceStack)
        NSLayoutConstraint.activate([
            deviceStack.topAnchor.constraint(equalTo: catDeviceContainer.topAnchor, constant: 10),
            deviceStack.leadingAnchor.constraint(equalTo: catDeviceContainer.leadingAnchor, constant: 10),
            deviceStack.trailingAnchor.constraint(equalTo: catDeviceContainer.trailingAnchor, constant: -10),
            deviceStack.bottomAnchor.constraint(equalTo: catDeviceContainer.bottomAnchor, constant: -10)
        ])
        
        // Section 2: QR스캐너 설정
        contentStackView.addArrangedSubview(qrScannerTitleLabel)
        contentStackView.addArrangedSubview(qrScannerUnderline)
        contentStackView.addArrangedSubview(qrScannerContainer)
        qrScannerContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let qrRow = UIStackView(arrangedSubviews: [qrScannerLabel, qrScannerSegmented])
        qrRow.axis = .horizontal
        qrRow.spacing = 10
        qrRow.distribution = .fillProportionally
        qrRow.translatesAutoresizingMaskIntoConstraints = false
        qrScannerContainer.addSubview(qrRow)
        NSLayoutConstraint.activate([
            qrRow.topAnchor.constraint(equalTo: qrScannerContainer.topAnchor, constant: 10),
            qrRow.leadingAnchor.constraint(equalTo: qrScannerContainer.leadingAnchor, constant: 10),
            qrRow.trailingAnchor.constraint(equalTo: qrScannerContainer.trailingAnchor, constant: -10),
            qrRow.bottomAnchor.constraint(equalTo: qrScannerContainer.bottomAnchor, constant: -10)
        ])
    }
    
    // Helper: Create an input row with a label and textfield
    private func createInputRow(label: UILabel, textField: UITextField) -> UIView {
        let row = UIStackView(arrangedSubviews: [label, textField])
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillProportionally
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }
    
    // Helper: Create underline view
    static func createUnderline() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let catIP = catIPTextField.text, !catIP.isEmpty,
              let port = portTextField.text, !port.isEmpty else {
            showAlert(title: "오류", message: "모든 값을 입력해주세요.")
            return
        }
        print("저장: CAT IP = \(catIP), PORT = \(port)")
        showAlert(title: "저장 완료", message: "CAT 설정이 저장되었습니다.")
    }
    
    // Helper: Show alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate (필요 시 구현)
    // 예: 텍스트필드 입력 제한, 리턴키 처리 등
}

