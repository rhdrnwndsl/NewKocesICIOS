//
//  NetworkViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/12/25.
//

import Foundation
import UIKit

class NetworkViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - UI Components
    
    // 상단 타이틀과 언더라인
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "네트워크 설정"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black  // 원하는 언더라인 색상
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 회색 라운드 컨테이너
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 첫 번째 행: VAN IP
    private let vanIPLabel: UILabel = {
        let label = UILabel()
        label.text = "VAN IP"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let vanIPTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "사용자 입력"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 두 번째 행: port
    private let portLabel: UILabel = {
        let label = UILabel()
        label.text = "PORT"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let portTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "사용자 입력"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 하단 버튼들
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("초기화", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        vanIPTextField.delegate = self
        portTextField.delegate = self
        setupUI()
        setupData()
    }
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    
    // Landscape 전용으로 지원 (원하는 경우 supportedInterfaceOrientations 재정의)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // 상단 타이틀 및 언더라인 추가
        view.addSubview(titleLabel)
        view.addSubview(underlineView)
        
        // 회색 컨테이너 추가
        view.addSubview(containerView)
        
        // 컨테이너 안에 VAN IP 행과 port 행 추가
        containerView.addSubview(vanIPLabel)
        containerView.addSubview(vanIPTextField)
        containerView.addSubview(portLabel)
        containerView.addSubview(portTextField)
        
        // 하단 버튼 추가
        view.addSubview(resetButton)
        view.addSubview(saveButton)
        
        // Auto Layout 제약조건 설정
        
        NSLayoutConstraint.activate([
            // 타이틀 레이블: 상단 중앙
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 언더라인: 타이틀 아래 8pt, 좌우 20pt, 높이 1pt
            underlineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            underlineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            underlineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            underlineView.heightAnchor.constraint(equalToConstant: 1),
            
            // 회색 컨테이너: 언더라인 아래 20pt, 좌우 20pt, 높이 120pt
            containerView.topAnchor.constraint(equalTo: underlineView.bottomAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 120),
            
            // VAN IP 행
            vanIPLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            vanIPLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            vanIPLabel.widthAnchor.constraint(equalToConstant: 80),
            
            vanIPTextField.centerYAnchor.constraint(equalTo: vanIPLabel.centerYAnchor),
            vanIPTextField.leadingAnchor.constraint(equalTo: vanIPLabel.trailingAnchor, constant: 10),
            vanIPTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            vanIPTextField.heightAnchor.constraint(equalToConstant: 30),
            
            // port 행
            portLabel.topAnchor.constraint(equalTo: vanIPLabel.bottomAnchor, constant: 20),
            portLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            portLabel.widthAnchor.constraint(equalToConstant: 80),
            
            portTextField.centerYAnchor.constraint(equalTo: portLabel.centerYAnchor),
            portTextField.leadingAnchor.constraint(equalTo: portLabel.trailingAnchor, constant: 10),
            portTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            portTextField.heightAnchor.constraint(equalToConstant: 30),
            
            // 하단 버튼: 컨테이너 아래 30pt, 좌우 여백 40pt, 버튼 크기 100x40
            resetButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 30),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            resetButton.widthAnchor.constraint(equalToConstant: 100),
            resetButton.heightAnchor.constraint(equalToConstant: 40),
            
            saveButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 30),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // 버튼 액션 연결
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func setupData() {
        if Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_IP).isEmpty {
            vanIPTextField.text = Setting.HOST_STORE_DOWNLOAD_IP
        } else {
            vanIPTextField.text = Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_IP)
        }
        if Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_PORT).isEmpty {
            portTextField.text = String(Setting.HOST_STORE_DOWNLOAD_PORT)
        } else {
            portTextField.text = Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_PORT)
        }
        vanIPTextField.delegate = self
        portTextField.delegate = self
        
        let bar = UIToolbar()
        //새로운 버튼을 만든다 키보드 닫기 버튼을 만든다.
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
        vanIPTextField.inputAccessoryView = bar
        portTextField.inputAccessoryView = bar
    }
    
    // MARK: - Button Actions
    
    @objc private func resetButtonTapped() {
        vanIPTextField.text = ""
        portTextField.text = ""
    }
    
    @objc private func saveButtonTapped() {
        guard let vanIP = vanIPTextField.text, !vanIP.isEmpty,
              let port = portTextField.text, !port.isEmpty else {
            showAlert(title: "오류", message: "모든 값을 입력해주세요")
            return
        }
        
        //IP 검사
        let temp:String = vanIPTextField.text ?? ""
        if temp.isEmpty || temp == ""  {
            showAlert(title: "에러", message: "빈칸은 사용할 수 없습니다.")
            return
        }
        let tempSplit:[String] = temp.components(separatedBy: ".")
        
        if tempSplit.count != 4 {
            showAlert(title: "에러", message: "주소가 잘못 되었습니다.")
            return
        }
        
        for str in tempSplit{
            if Int(str) != nil {
                if Int(str)! > 255 {
                    showAlert(title: "에러", message: "주소가 잘못 되었습니다.")
                    return
                }
            }else{
                showAlert(title: "에러", message: "주소가 잘못 되었습니다.")
                return
            }
        }
        
        //포트검사
        let temp1:String = portTextField.text ?? ""
        if temp1.isEmpty || temp1 == "" {
            showAlert(title: "에러", message: "빈칸은 사용할 수 없습니다.")
            return
        }
        
        if Int(temp1) != nil {
            if Int(temp1)! < 1 || Int(temp1)! > 65535 {
                showAlert(title: "에러", message: "포트 번호가 잘못 되었습니다.")
                return
            }
        }else{
            showAlert(title: "에러", message: "포트 번호가 잘못 되었습니다.")
            return
        }
        
        //로컬에 데이터 저장
        Setting.shared.setDefaultUserData(_data: temp, _key: define.HOST_SERVER_IP)
        Setting.shared.setDefaultUserData(_data: temp1, _key: define.HOST_SERVER_PORT)
        
        // 저장 로직 구현 (예: Setting.shared에 저장하거나 DB에 기록)
        print("저장: VAN IP = \(temp), PORT = \(temp1)")
        showAlert(title: "저장 완료", message: "네트워크 설정이 저장되었습니다")
    }
    
    // MARK: - Helper
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인",
                                                style: .default,
                                                handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength:Int = 5
        if textField == vanIPTextField {
            //255.255.255.255 = 15자
            maxLength = 15
        }
        let newLength = (textField.text?.count)! + string.count - range.length
                return !(newLength > maxLength)
    }
}
