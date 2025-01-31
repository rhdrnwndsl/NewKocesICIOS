//
//  InfoSettingController.swift
//  osxapp
//
//  Created by 신진우 on 2021/03/25.
//

import Foundation
import UIKit
import MessageUI

class InfoSettingController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mTxtInfoAppID: UILabel!
    
    @IBOutlet weak var mTxtInfoAppVerInfo: UILabel!

    @IBOutlet weak var mTxtInfoEmail: UITextField!
    
    //이용약관제거
    @IBOutlet weak var mTermTitle: UIStackView! //이용약관타이틀
    @IBOutlet weak var mTermBar: UIStackView!   //이용약관하단바
    @IBOutlet weak var mTermPrivate: UIStackView!   //이용약관개인정보약관
    @IBOutlet weak var mTermService: UIStackView!   //이용약관서비스약관
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initRes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    
    //이용약관을 숨긴다(당분간)
    func TermsViewHidden() {
        mTermTitle.isHidden = true
        mTermTitle.alpha = 0.0
        mTermBar.isHidden = true
        mTermBar.alpha = 0.0
        mTermPrivate.isHidden = true
        mTermPrivate.alpha = 0.0
        mTermService.isHidden = true
        mTermService.alpha = 0.0
    }
    
    func initRes(){
        
        TermsViewHidden()
        
        mTxtInfoAppID.text = define.KOCES_ID
        mTxtInfoAppVerInfo.text = define.KOCES_APP_VERINFO
        mTxtInfoEmail.keyboardType = .emailAddress
        let bar = UIToolbar()
                
        //새로운 버튼을 만든다 키보드 닫기 버튼을 만든다.
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
                
        mTxtInfoEmail.inputAccessoryView = bar
//        mTxtInfoEmail.text = "kocesprod@koces.com"
        mTxtInfoEmail.text = "kocesprod@koces.com"
    }
    
    @IBAction func clicked_btn_email(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        // Modify following variables with your text / recipient
        let recipientEmail = mTxtInfoEmail.text?.replacingOccurrences(of: " ", with: "") ?? ""
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
                AlertBox(title: "메일전송", message: "전송에 오류가 발생하였습니다" + "\n" + error!.localizedDescription, text: "확인")
                return
            }
            switch result {
            case .cancelled:
                AlertBox(title: "메일전송", message: "전송을 취소하였습니다", text: "확인")
                break
            case .sent:
                AlertBox(title: "메일전송", message: "전송을 완료하였습니다", text: "확인")
                break
            case .failed:
                AlertBox(title: "메일전송", message: "전송에 실패하였습니다", text: "확인")
                break
            default:
                AlertBox(title: "메일전송", message: "전송에 실패하였습니다", text: "확인")
                break
            }
        }
       
        
    }
    
    @IBAction func clicked_btn_private(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        let controller = (storyboard?.instantiateViewController(identifier: "TermsViewController"))! as TermsViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func clicked_btn_service(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        let controller = (storyboard?.instantiateViewController(identifier: "TermsViewController"))! as TermsViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
 
    
    func AlertBox(title : String, message : String, text : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
}
