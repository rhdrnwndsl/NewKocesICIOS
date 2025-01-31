//
//  NetworkSettingController.swift
//  osxapp
//
//  Created by 신진우 on 2021/01/07.
//

import UIKit

class NetworkSettingController: UIViewController {
    
    @IBOutlet weak var mNetWorkIP: UITextField!
    
    @IBOutlet weak var mNetWorkPort: UITextField!
    
    let mKocesSdk:KocesSdk = KocesSdk.instance

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initRes()   //초기화 과정
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initRes(){
        if Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_IP).isEmpty {
            mNetWorkIP.text = Setting.HOST_STORE_DOWNLOAD_IP
        } else {
            mNetWorkIP.text = Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_IP)
        }
        if Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_PORT).isEmpty {
            mNetWorkPort.text = String(Setting.HOST_STORE_DOWNLOAD_PORT)
        } else {
            mNetWorkPort.text = Setting.shared.getDefaultUserData(_key: define.HOST_SERVER_PORT)
        }
        mNetWorkIP.delegate = self
        mNetWorkPort.delegate = self
        
        let bar = UIToolbar()
        //새로운 버튼을 만든다 키보드 닫기 버튼을 만든다.
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
        mNetWorkIP.inputAccessoryView = bar
        mNetWorkPort.inputAccessoryView = bar
    }
    
    @objc func dismissMyKeyboard(){
           view.endEditing(true)
       }
    
    @IBAction func clicked_btn_Default(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        mNetWorkIP.text = Setting.HOST_STORE_DOWNLOAD_IP
        mNetWorkPort.text = String(Setting.HOST_STORE_DOWNLOAD_PORT)
        //로컬에 데이터 저장
        Setting.shared.setDefaultUserData(_data: Setting.HOST_STORE_DOWNLOAD_IP, _key: define.HOST_SERVER_IP)
        Setting.shared.setDefaultUserData(_data: String(Setting.HOST_STORE_DOWNLOAD_PORT), _key: define.HOST_SERVER_PORT)
        AlertBox(title: "성공", message: "설정을 초기화하였습니다.", text: "확인")
        
    }
    
    @IBAction func clicked_btn_Save(_ sender: Any, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        //IP 검사
        let temp:String = mNetWorkIP.text ?? ""
        if temp.isEmpty || temp == ""  {
            AlertBox(title: "에러", message: "빈칸은 사용할 수 없습니다.", text: "확인")
            return
        }
        let tempSplit:[String] = temp.components(separatedBy: ".")
        
        if tempSplit.count != 4 {
            AlertBox(title: "에러", message: "주소가 잘못 되었습니다.", text: "확인")
            return
        }
        
        for str in tempSplit{
            if Int(str) != nil {
                if Int(str)! > 255 {
                    AlertBox(title: "에러", message: "주소가 잘못 되었습니다.", text: "확인")
                    return
                }
            }else{
                AlertBox(title: "에러", message: "주소가 잘못 되었습니다.", text: "확인")
                return
            }
        }
        
        //포트검사
        let temp1:String = mNetWorkPort.text ?? ""
        if temp1.isEmpty || temp1 == "" {
            AlertBox(title: "에러", message: "빈칸은 사용할 수 없습니다.", text: "확인")
            return
        }
        
        if Int(temp1) != nil {
            if Int(temp1)! < 1 || Int(temp1)! > 65535 {
                AlertBox(title: "에러", message: "포트 번호가 잘못 되었습니다.", text: "확인")
                return
            }
        }else{
            AlertBox(title: "에러", message: "포트 번호가 잘못 되었습니다.", text: "확인")
            return
        }
        
        //로컬에 데이터 저장
        Setting.shared.setDefaultUserData(_data: temp, _key: define.HOST_SERVER_IP)
        Setting.shared.setDefaultUserData(_data: temp1, _key: define.HOST_SERVER_PORT)
        
//        Setting.shared.HOST_STORE_DOWNLOAD_IP = mTxtBoxServerIP.text ?? ""
//        Setting.shared.HOST_STORE_DOWNLOAD_PORT = Int(mTxtBoxServerPort.text ?? "") ?? 10555
        
        
        AlertBox(title: "성공", message: "설정이 저장되었습니다.", text: "확인")
    }

    func AlertBox(title : String, message : String, text : String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            return self.present(alertController, animated: true, completion: nil)
        }

}

extension NetworkSettingController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength:Int = 5
        if textField == mNetWorkIP {
            //255.255.255.255 = 15자
            maxLength = 15
        }
        let newLength = (textField.text?.count)! + string.count - range.length
                return !(newLength > maxLength)
    }
}

