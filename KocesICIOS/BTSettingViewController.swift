//
//  BTSettingViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2/13/25.
//

import Foundation
import UIKit

class BTSettingViewController: UIViewController {
    
    // MARK: - Header (상단 고정 영역)
    private let headerView = UIView()
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "BT설정"
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
    
    // MARK: - Section 1: BT리더기설정
    private let btReaderTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "BT리더기설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let btReaderUnderline = BTSettingViewController.createUnderline()
    private let btReaderContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // 각 행: label 및 값 표시 (단순 UILabel)
    private let prodIdRow: UIStackView = {
        let label = BTSettingViewController.createRowLabel(text: "제품식별번호")
        let valueLabel = BTSettingViewController.createRowValueLabel(text: "제품식별번호에 해당하는 값")
        return BTSettingViewController.createInputRow(label: label, valueLabel: valueLabel)
    }()
    private let serialRow: UIStackView = {
        let label = BTSettingViewController.createRowLabel(text: "시리얼번호")
        let valueLabel = BTSettingViewController.createRowValueLabel(text: "시리얼번호에 해당하는 값")
        return BTSettingViewController.createInputRow(label: label, valueLabel: valueLabel)
    }()
    private let versionRow: UIStackView = {
        let label = BTSettingViewController.createRowLabel(text: "버전")
        let valueLabel = BTSettingViewController.createRowValueLabel(text: "버전에 해당하는 값")
        return BTSettingViewController.createInputRow(label: label, valueLabel: valueLabel)
    }()
    
    // MARK: - Section 2: 하단 버튼 영역 (BT리더기 관련)
    private let btButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BT연결", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let disconnectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("연결해제", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let keyRenewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("키갱신", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let integrityCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("무결성검증", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let firmwareUpdateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("펌웨어\n업데이트", for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Section 3: BT리더기 페어링 해제 후 전원설정
    private let powerSettingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "BT리더기 페어링 해제 후 전원설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let powerSettingUnderline = BTSettingViewController.createUnderline()
    private let powerSettingContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let powerLabel = BTSettingViewController.createRowLabel(text: "전원설정")
    private lazy var powerSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["상시유지", "5분", "10분"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    private let powerSaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전원저장", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Section 4: 터치서명설정
    private let touchSigTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "터치서명설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let touchSigUnderline = BTSettingViewController.createUnderline()
    private let touchSigContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let touchSigLabel = BTSettingViewController.createRowLabel(text: "터치서명크기")
    private lazy var touchSigSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["전체", "보통", "작게"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    
    // MARK: - Section 5: 기타설정
    private let etcTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "기타설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let etcUnderline = BTSettingViewController.createUnderline()
    private let etcContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let appExitLabel = BTSettingViewController.createRowLabel(text: "앱종료시 리더기종료")
    private lazy var appExitSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["종료", "종료안함"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        catIPTextField.delegate = self  // dummy delegate assignment; not used in this screen.
//        portTextField.delegate = self   // dummy delegate assignment; not used in this screen.
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 1. Header Setup
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerView.addSubview(headerLabel)
        headerView.addSubview(saveButton)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            saveButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            saveButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // 2. ScrollView & Content StackView Setup
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
        
        // Section 1: BT리더기설정
        contentStackView.addArrangedSubview(btReaderTitleLabel)
        contentStackView.addArrangedSubview(btReaderUnderline)
        contentStackView.addArrangedSubview(btReaderContainer)
        btReaderContainer.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        let btStack = UIStackView(arrangedSubviews: [prodIdRow, serialRow, versionRow])
        btStack.axis = .vertical
        btStack.spacing = 10
        btStack.translatesAutoresizingMaskIntoConstraints = false
        btReaderContainer.addSubview(btStack)
        NSLayoutConstraint.activate([
            btStack.topAnchor.constraint(equalTo: btReaderContainer.topAnchor, constant: 10),
            btStack.leadingAnchor.constraint(equalTo: btReaderContainer.leadingAnchor, constant: 10),
            btStack.trailingAnchor.constraint(equalTo: btReaderContainer.trailingAnchor, constant: -10),
            btStack.bottomAnchor.constraint(equalTo: btReaderContainer.bottomAnchor, constant: -10)
        ])
        
        // Section 2: 하단 버튼 영역 (BT리더기 관련)
        contentStackView.addArrangedSubview(btButtonStack)
        btButtonStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        for btn in [connectButton, disconnectButton, keyRenewButton, integrityCheckButton, firmwareUpdateButton] {
            btButtonStack.addArrangedSubview(btn)
        }
        
        // Section 3: BT리더기 페어링 해제 후 전원설정
        contentStackView.addArrangedSubview(powerSettingTitleLabel)
        contentStackView.addArrangedSubview(powerSettingUnderline)
        contentStackView.addArrangedSubview(powerSettingContainer)
        powerSettingContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let powerRow = UIStackView(arrangedSubviews: [powerLabel, powerSegmented, powerSaveButton])
        powerRow.axis = .horizontal
        powerRow.spacing = 10
        powerRow.distribution = .fillProportionally
        powerRow.translatesAutoresizingMaskIntoConstraints = false
        powerSettingContainer.addSubview(powerRow)
        NSLayoutConstraint.activate([
            powerRow.topAnchor.constraint(equalTo: powerSettingContainer.topAnchor, constant: 10),
            powerRow.leadingAnchor.constraint(equalTo: powerSettingContainer.leadingAnchor, constant: 10),
            powerRow.trailingAnchor.constraint(equalTo: powerSettingContainer.trailingAnchor, constant: -10),
            powerRow.bottomAnchor.constraint(equalTo: powerSettingContainer.bottomAnchor, constant: -10)
        ])
        
        // Section 4: 터치서명설정
        contentStackView.addArrangedSubview(touchSigTitleLabel)
        contentStackView.addArrangedSubview(touchSigUnderline)
        contentStackView.addArrangedSubview(touchSigContainer)
        touchSigContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let touchRow = UIStackView(arrangedSubviews: [touchSigLabel, touchSigSegmented])
        touchRow.axis = .horizontal
        touchRow.spacing = 10
        touchRow.distribution = .fillProportionally
        touchRow.translatesAutoresizingMaskIntoConstraints = false
        touchSigContainer.addSubview(touchRow)
        NSLayoutConstraint.activate([
            touchRow.topAnchor.constraint(equalTo: touchSigContainer.topAnchor, constant: 10),
            touchRow.leadingAnchor.constraint(equalTo: touchSigContainer.leadingAnchor, constant: 10),
            touchRow.trailingAnchor.constraint(equalTo: touchSigContainer.trailingAnchor, constant: -10),
            touchRow.bottomAnchor.constraint(equalTo: touchSigContainer.bottomAnchor, constant: -10)
        ])
        
        // Section 5: 기타설정
        contentStackView.addArrangedSubview(etcTitleLabel)
        contentStackView.addArrangedSubview(etcUnderline)
        contentStackView.addArrangedSubview(etcContainer)
        etcContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let etcRow = UIStackView(arrangedSubviews: [appExitLabel, appExitSegmented])
        etcRow.axis = .horizontal
        etcRow.spacing = 10
        etcRow.distribution = .fillProportionally
        etcRow.translatesAutoresizingMaskIntoConstraints = false
        etcContainer.addSubview(etcRow)
        NSLayoutConstraint.activate([
            etcRow.topAnchor.constraint(equalTo: etcContainer.topAnchor, constant: 10),
            etcRow.leadingAnchor.constraint(equalTo: etcContainer.leadingAnchor, constant: 10),
            etcRow.trailingAnchor.constraint(equalTo: etcContainer.trailingAnchor, constant: -10),
            etcRow.bottomAnchor.constraint(equalTo: etcContainer.bottomAnchor, constant: -10)
        ])
        
        // Section 6: 하단 버튼 영역 (테스트, 저장)
//        contentStackView.addArrangedSubview(buttonStack)
//        buttonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        buttonStack.addArrangedSubview(testButton)
//        buttonStack.addArrangedSubview(saveButton)
    }
    
    // MARK: - Helper Methods
    static func createUnderline() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createRowLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createRowValueLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createInputRow(label: UILabel, valueLabel: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [label, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    // MARK: - Action Methods
    @objc func saveButtonTapped() {
        print("저장 버튼 클릭 - BT 설정 저장")
        // 저장 로직 구현
    }
    
    @objc func connectButtonTapped() {
        print("BT연결 버튼 클릭")
    }
    
    @objc func disconnectButtonTapped() {
        print("연결해제 버튼 클릭")
    }
    
    @objc func keyRenewButtonTapped() {
        print("키갱신 버튼 클릭")
    }
    
    @objc func integrityCheckButtonTapped() {
        print("무결성검증 버튼 클릭")
    }
    
    @objc func firmwareUpdateButtonTapped() {
        print("펌웨어 업데이트 버튼 클릭")
    }
    
    @objc func powerSaveButtonTapped() {
        print("전원저장 버튼 클릭")
    }
    
    @objc func testButtonTapped() {
        print("테스트 버튼 클릭")
    }
}

//// MARK: - UITextFieldDelegate
//extension BTSettingViewController: UITextFieldDelegate {
//    // 필요한 텍스트필드 delegate 메서드 구현
//}
