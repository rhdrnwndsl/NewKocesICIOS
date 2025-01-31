//
//  mms.swift
//  osxapp
//
//  Created by 金載龍 on 2021/02/26.
//

import Foundation
import MessageUI

class mms:NSObject, MFMessageComposeViewControllerDelegate {

    static let instance = mms()
    var mUIView:UIViewController?
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if mUIView != nil {
            switch result {
            case .cancelled:
                mUIView!.dismiss(animated: true, completion: nil)
                break
            case .sent:
                mUIView!.dismiss(animated: true, completion: nil)
                break
            case .failed:
                mUIView!.dismiss(animated: true, completion: nil)
                break
            @unknown default:
                mUIView!.dismiss(animated: true, completion: nil)
                break
            }
        }
    }
    
    @discardableResult
    func sendMeesage(대상전화번호 _target:String,내용 _contents:String,UIControllerView uiView:UIViewController) -> Bool {
        mUIView = uiView
        if _target == "" {
            return false
        }
        
        if _contents == "" {
            return false
        }
        //장치 mms 초기화 및 상태 체크
        guard MFMessageComposeViewController.canSendText() else {
            debugPrint("mms 장치 초기화 실패")
            return false
        }
        
        let mms = MFMessageComposeViewController()
        mms.messageComposeDelegate = self
        mms.recipients  = [_target]
        mms.body = _contents
        
        if uiView == nil {
            return false
        }
        
        uiView.present(mms, animated: true, completion: nil)
     
        
        return true
    }
}

