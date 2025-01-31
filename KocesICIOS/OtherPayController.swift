//
//  File.swift
//  KocesICIOS
//
//  Created by 신진우 on 2021/07/28.
//

import Foundation
import UIKit
import SwiftUI

class OtherPayController: UIViewController {
    
    @IBOutlet weak var mBtnCashIC: UIButton!        //현금IC결제버튼
    @IBOutlet weak var mBtnCreditCancel: UIButton!  //신용취소버튼
    @IBOutlet weak var mBtnCashCancel: UIButton!    //현금취소버튼
    @IBOutlet weak var mBtnPoint: UIButton!         //포인트결제버튼
    @IBOutlet weak var mBtnMember: UIButton!        //멤버십결제버튼
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
        //네비게이션 바의 배경색 rgb 변경
        UISetting.navigationTitleSetting(navigationBar: navigationController?.navigationBar ?? UINavigationBar())
        
        mBtnCashIC.setImage(UIImage(named: "cashic-normal"), for: .normal)
        mBtnCashIC.setImage(UIImage(named: "cashic-select"), for: .highlighted)
        mBtnCreditCancel.setImage( UIImage(named: "creditcancel-normal"), for: .normal)
        mBtnCreditCancel.setImage( UIImage(named: "creditcancel-select"), for: .highlighted)
        mBtnCashCancel.setImage(UIImage(named: "cashcancel-normal") , for: .normal)
        mBtnCashCancel.setImage(UIImage(named: "cashcancel-select") , for: .highlighted)
        mBtnPoint.setImage(UIImage(named: "point-normal") , for: .normal)
        mBtnPoint.setImage(UIImage(named: "point-select") , for: .highlighted)
        mBtnMember.setImage(UIImage(named: "member-normal") , for: .normal)
        mBtnMember.setImage(UIImage(named: "member-select") , for: .highlighted)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clicked_btn_cashic(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        //CAT상태에서만 사용한다.
        if KocesSdk.instance.bleState != define.TargetDeviceState.CATCONNECTED {
            AlertBox(title: "에러", message: "CAT 단말기 사용시 거래 가능", text: "확인")
            return
        }
        moveCashIC()
    }
    func moveCashIC()
    {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        let controller = (storyboard!.instantiateViewController(identifier: "CashICCatController")) as CashICCatController
        controller.navigationItem.title = "현금IC결제"
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func clicked_btn_creditcancel(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        
        //CAT상태에서는 ble체크를 하지 않는다.
        if CheckBle() {
            if CheckBeforeTrading() {
                moveCredit()
            }
        }
    }
    func moveCredit()
    {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        let controller = (storyboard!.instantiateViewController(identifier: "CreditCancelController")) as CreditCancelController
        controller.navigationItem.title = "카드결제취소"  //2021.08.19 수정사항 169.C.1
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func clicked_btn_cashcancel(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        //CAT상태에서는 ble체크를 하지 않는다.
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            if Utils.CheckCatPortIP() != "" {
                AlertBox(title: "에러", message: Utils.CheckCatPortIP(), text: "확인")
                return
            }
            moveCash()
        } else {
            if CheckBeforeTrading() {
    //            self.tabBarController?.selectedIndex = 2
                moveCash()
            }
        }
    }
    func moveCash()
    {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        let controller = (storyboard!.instantiateViewController(identifier: "CashCancelController")) as CashCancelController
        controller.navigationItem.title = "현금결제취소"  //2021.08.19 수정사항 169.D
        navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func clicked_btn_point(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        //BLE 연결상태에서만 사용한다.
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            AlertBox(title: "에러", message: "CAT 단말기 사용시 거래 불가능", text: "확인")
            return
        }
        
        if CheckBeforeTrading() {
            movePoint()
        }
    }
    func movePoint() {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        let controller = (storyboard!.instantiateViewController(identifier: "PointController")) as PointController
        controller.navigationItem.title = "포인트결제"  //2021.08.19 수정사항 169.D
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func clicked_btn_member(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        //BLE 연결상태에서만 사용한다.
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            AlertBox(title: "에러", message: "CAT 단말기 사용시 거래 불가능", text: "확인")
            return
        }
        
        if CheckBeforeTrading() {
            moveMember()
        }
    }
    func moveMember() {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        let controller = (storyboard!.instantiateViewController(identifier: "MemberController")) as MemberController
        controller.navigationItem.title = "멤버십결제"  //2021.08.19 수정사항 169.D
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func CheckBle() -> Bool {
        //ble 연결되어있지 않다면 들어가는 것을 막는다
        if KocesSdk.instance.bleState == define.TargetDeviceState.BLENOCONNECT {
            let alert = UIAlertController(title: nil, message: "BLE 디바이스가 연결 되지 않았습니다 환경설정에서 장치를 검색하십시오", preferredStyle: .alert)
            present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
                self.dismiss(animated: false){
                    self.tabBarController?.selectedIndex = 0
                }
            })})
            return false
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
            if KocesSdk.instance.mVerityCheck != define.VerityMethod.Success.rawValue{
                let alert = UIAlertController(title: nil, message: "리더기 무결성 검증이 정상 완료하지 않았습니다.", preferredStyle: .alert)
                present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
                    self.dismiss(animated: false){
                        self.tabBarController?.selectedIndex = 0
                    }
                })})
                return false
            }
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            if Utils.CheckCatPortIP() != "" {
                let alert = UIAlertController(title: nil, message: Utils.CheckCatPortIP(), preferredStyle: .alert)
                present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
                    self.dismiss(animated: false){
                        self.tabBarController?.selectedIndex = 0
                    }
                })})
                return false
            }
        }
        
        return true
    }
    
    func CheckBeforeTrading() -> Bool {
        //거래 전 체크 사항
        let temp:String = KocesSdk.instance.ChecklistBeforeTrading()
        
        //21-06-01. by.tlswlsdn 코세스 수정요청사항 중 CAT결제방식 선택시 가맹점등록 다운로드없이 결제진행 관련검토
        //
        if KocesSdk.instance.bleState != define.TargetDeviceState.CATCONNECTED {
            if temp != "" {     //temp에 문자열이 있는 경우 거래전 체크 사항에 문제가 있는 것으로 판단 한다.
                let alert = UIAlertController(title: nil, message: temp, preferredStyle: .alert)
                present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
                    self.dismiss(animated: false){
                        self.tabBarController?.selectedIndex = 0
                    }
                })})
                return false
            }
        }
        return true
    }
    
    func AlertBox(title : String, message : String, text : String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(okButton)
            return self.present(alertController, animated: true, completion: nil)
    }
}

extension OtherPayController : UITabBarControllerDelegate {
    //탭바로 다른 탭 이동시 네비게이션은 초기로 이동한다
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.navigationController?.popViewController(animated: false)
    }
}
