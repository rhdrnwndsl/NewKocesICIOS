//
//  AppInfoViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/12/25.
//

import Foundation
import UIKit
import MessageUI

class AppInfoViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - Version Info Section
    
    private let versionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "버전정보"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let versionUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = .black  // 언더라인 색상
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let versionContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 식별번호 행
    private let idLabel: UILabel = {
        let label = UILabel()
        label.text = "식별번호"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let idValueLabel: UILabel = {
        let label = UILabel()
        label.text = define.KOCES_ID
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 버전정보 행
    private let versionInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "버전정보"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let versionValueLabel: UILabel = {
        let label = UILabel()
        label.text = define.KOCES_APP_VERINFO
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Email Log Section
    
    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "로그전송(E-mail)"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "E-mail"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "사용자 입력"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.keyboardType = .emailAddress
        textField.text = "kocesprod@koces.com"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - Send Button
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전송", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        emailTextField.delegate = self
        let bar = UIToolbar()
                
        //새로운 버튼을 만든다 키보드 닫기 버튼을 만든다.
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
                
        emailTextField.inputAccessoryView = bar
        setupUI()
    }
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // 메인 StackView를 사용하여 세로로 구성
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        // 버전 정보 섹션 추가
        mainStack.addArrangedSubview(versionTitleLabel)
        mainStack.addArrangedSubview(versionUnderline)
        versionUnderline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // 버전 컨테이너 내에 내용 배치: 두 행을 포함할 수평/수직 StackView 사용
        let versionStack = UIStackView()
        versionStack.axis = .vertical
        versionStack.spacing = 10
        versionStack.translatesAutoresizingMaskIntoConstraints = false
        
        // 첫 번째 행: 식별번호
        let idRow = UIStackView(arrangedSubviews: [idLabel, idValueLabel])
        idRow.axis = .horizontal
        idRow.distribution = .fillEqually
        idRow.spacing = 10
        versionStack.addArrangedSubview(idRow)
        
        // 두 번째 행: 버전정보
        let versionRow = UIStackView(arrangedSubviews: [versionInfoLabel, versionValueLabel])
        versionRow.axis = .horizontal
        versionRow.distribution = .fillEqually
        versionRow.spacing = 10
        versionStack.addArrangedSubview(versionRow)
        
        versionContainer.addSubview(versionStack)
        versionStack.topAnchor.constraint(equalTo: versionContainer.topAnchor, constant: 10).isActive = true
        versionStack.leadingAnchor.constraint(equalTo: versionContainer.leadingAnchor, constant: 10).isActive = true
        versionStack.trailingAnchor.constraint(equalTo: versionContainer.trailingAnchor, constant: -10).isActive = true
        versionStack.bottomAnchor.constraint(equalTo: versionContainer.bottomAnchor, constant: -10).isActive = true
        
        mainStack.addArrangedSubview(versionContainer)
        versionContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // 이메일 로그 전송 섹션 추가
        mainStack.addArrangedSubview(emailTitleLabel)
        mainStack.addArrangedSubview(emailUnderline)
        emailUnderline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // 이메일 컨테이너: E-mail 레이블과 텍스트필드를 수평 스택뷰로 배치
        let emailStack = UIStackView(arrangedSubviews: [emailLabel, emailTextField])
        emailStack.axis = .horizontal
        emailStack.spacing = 10
        emailStack.distribution = .fillProportionally
        emailStack.translatesAutoresizingMaskIntoConstraints = false
        emailContainer.addSubview(emailStack)
        NSLayoutConstraint.activate([
            emailStack.topAnchor.constraint(equalTo: emailContainer.topAnchor, constant: 10),
            emailStack.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 10),
            emailStack.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: -10),
            emailStack.bottomAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: -10)
        ])
        
        mainStack.addArrangedSubview(emailContainer)
        emailContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Spacer (빈공간)
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(spacer)
        
        // 전송 버튼 추가
        mainStack.addArrangedSubview(sendButton)
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // mainStack 제약조건: 화면 상하좌우 20pt 여백
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // 전송 버튼 액션
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Button Actions
    
    @objc private func sendButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "오류", message: "E-mail을 입력해주세요.")
            return
        }
        // 로그 전송 처리 (실제 구현 시 네트워크 전송 등)
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        // Modify following variables with your text / recipient
        let recipientEmail = emailTextField.text?.replacingOccurrences(of: " ", with: "") ?? ""
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: Date())
        var fileName = "LOG_\(dateString).log"
        var subject = fileName
//        let body = LogFile.instance.LoadLog()
        var body = fileName + " (을) 전송합니다"
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache: \(fileNames)")
                for Name in fileNames {
                    if Name.contains("\(dateString)") {
                        fileName = Name
                        subject = fileName
                        body = fileName + " (을) 전송합니다"
                    }
                }

            }

        } catch {
            print("Could not clear temp folder: \(error)")
        }
        
        
        // Show default mail composer
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            do {
                if let documentPath = documentsPath
                {
                    let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                    print("all files in cache: \(fileNames)")
                    for fileName in fileNames {
                        if fileName.contains(".log") {
                            mail.addAttachmentData(LogFile.instance.LoadFileData(Title: fileName), mimeType: "text/plain", fileName: fileName)
                        }
                    }

                }

            } catch {
                print("Could not clear temp folder: \(error)")
            }
            
            present(mail, animated: true)
        
        // Show third party email composer if default Mail app is not present
        } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
        
        print("로그 전송: \(email)")
        showAlert(title: "전송 완료", message: "로그가 전송되었습니다.")
    }
    
    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        
        return defaultUrl
    }
        
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {[self] in
            if let _ = error {
                showAlert(title: "메일전송", message: "전송에 오류가 발생하였습니다" + "\n" + error!.localizedDescription)
                return
            }
            switch result {
            case .cancelled:
                showAlert(title: "메일전송", message: "전송을 취소하였습니다")
                break
            case .sent:
                showAlert(title: "메일전송", message: "전송을 완료하였습니다")
                break
            case .failed:
                showAlert(title: "메일전송", message: "전송에 실패하였습니다")
                break
            default:
                showAlert(title: "메일전송", message: "전송에 실패하였습니다")
                break
            }
        }
       
        
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
}
