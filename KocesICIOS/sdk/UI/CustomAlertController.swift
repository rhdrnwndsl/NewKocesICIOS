//
//  CustomAlertController.swift
//  osxapp
//
//  Created by 신진우 on 2021/03/31.
//

import Foundation
import UIKit

protocol CustomAlertDelegate {
    func OkButtonTapped()
    func CancelButtonTapped()
}

class CustomAlertController:UIViewController {
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mMessageLabel: UILabel!
    @IBOutlet weak var mCancelButton: UIButton!
    @IBOutlet weak var mOkButton: UIButton!
    @IBOutlet weak var mAlertView: UIView!
    var delegate:CustomAlertDelegate? = nil
    public var mTitle:String = ""
    public var mMessage:String = ""
    
    @IBOutlet weak var mContentView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        showAlert(Title: mTitle, Message: mMessage)
    }
    
    @IBAction func clicked_cancel(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        dismiss(animated: false){
            self.delegate?.CancelButtonTapped()
        }
    }
    
    @IBAction func clicked_ok(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        dismiss(animated: false){
            self.delegate?.OkButtonTapped()
        }
    }
    
    func showAlert(Title _title:String, Message _msg:String) {
        mAlertView.backgroundColor = .white
        mAlertView.layer.masksToBounds = true
        mAlertView.layer.cornerRadius = 12
        
//        mAlertView.layer.borderWidth = 0.5
//        mAlertView.layer.borderColor = UIColor.lightGray.cgColor

        mTitleLabel.text = _title
        mTitleLabel.textAlignment = .center

        mMessageLabel.text = _msg
        mMessageLabel.textAlignment = .center
        mMessageLabel.numberOfLines = 0
 
//        mCancelButton.frame = CGRect(x: 0,y: mAlertView.frame.size.height-40,width: mAlertView.frame.size.width/2,height: 40)
        mCancelButton.setTitle("취소", for: .normal)
        mCancelButton.setTitleColor(.systemBlue, for: .normal)
        mCancelButton.setTitleColor(.systemBlue, for: .selected)
        mCancelButton.layer.borderWidth = 0.5
        mCancelButton.layer.borderColor = UIColor.lightGray.cgColor

//        mOkButton.frame = CGRect(x: mAlertView.frame.size.width/2,y: mAlertView.frame.size.height-40,width: mAlertView.frame.size.width/2,height: 40)
        mOkButton.setTitle("확인", for: .normal)
        mOkButton.setTitleColor(.white, for: .normal)
        mOkButton.setTitleColor(.white, for: .selected)
        mOkButton.backgroundColor = .systemBlue
        mOkButton.layer.borderWidth = 0.5
        mOkButton.layer.borderColor = UIColor.systemBlue.cgColor

    }
}
