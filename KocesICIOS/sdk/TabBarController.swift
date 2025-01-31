//
//  TabBarController.swift
//  osxapp
//
//  Created by 신진우 on 2021/02/22.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    var originalViewControllers: [UIViewController] = []
    enum Title:String {
//        case Credit = "신용"
//        case Cash = "현금"
//        case TradeList = "거래내역"
        case Main = "메인"
        case Environment = "환경설정"
        case Store = "가맹점정보"
        
        case TradeList = "거래내역"
        case CalendarInfo = "매출정보"
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 초기 ViewControllers 저장
               originalViewControllers = self.viewControllers ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate = self
        self.tabBarController?.delegate = self
        //하단의 탭바 셋팅
        UISetting.lowTabBarSetting(tabBar: tabBar)
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        UISetting.lowTabBarSetting(tabBar: tabBar)
//    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case Title.Main.rawValue:   //메인
            return
//        case Title.Credit.rawValue: //신용
//            CheckBeforeTrading()
//            return
//        case Title.Cash.rawValue:   //현금
//            CheckBeforeTrading()
//            return
//        case Title.TradeList.rawValue:  //거래내역
//            return
        case Title.Environment.rawValue:    //환경설정
//            CheckPassword()
            return
        case Title.Store.rawValue:  //가맹점정보
            return
            
            
        case Title.TradeList.rawValue:  //거래내역
            return
            
        case Title.CalendarInfo.rawValue:  //매출정보
            return
        default:
            return
        }
    }
    
//    func CheckBeforeTrading() {
//        //ble 연결되어있지 않다면 들어가는 것을 막는다
//        if KocesSdk.instance.bleState == define.TargetDeviceState.BLENOCONNECT {
//            let alert = UIAlertController(title: nil, message: "BLE 디바이스가 연결 되지 않았습니다 환경설정에서 장치를 검색하십시오", preferredStyle: .alert)
//            present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
//                self.dismiss(animated: false){ [self] in
//                    self.selectedIndex = 0
//                    goToMain()
//                }
//            })})
//            return
//        }
//        
//        //거래 전 체크 사항
//        let temp:String = KocesSdk.instance.ChecklistBeforeTrading()
//        
//        if temp != "" {     //temp에 문자열이 있는 경우 거래전 체크 사항에 문제가 있는 것으로 판단 한다.
//            let alert = UIAlertController(title: nil, message: temp, preferredStyle: .alert)
//            present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
//                self.dismiss(animated: false){ [self] in
//                    self.selectedIndex = 0
//                    goToMain()
//                }
//            })})
//            return
//        }
//        
//        if KocesSdk.instance.mVerityCheck != define.VerityMethod.Success.rawValue {
//            let alert = UIAlertController(title: nil, message: "리더기 무결성 검증이 정상 완료하지 않았습니다.", preferredStyle: .alert)
//            present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
//                self.dismiss(animated: false){ [self] in
//                    self.selectedIndex = 0
//                    goToMain()
//                }
//            })})
//            return
//        }
//    }
    
//    func CheckPassword() {
//        let alert = UIAlertController(title: nil, message: "비밀번호를 입력하세요", preferredStyle: UIAlertController.Style.alert)
//
//        alert.addTextField(configurationHandler: {(textField) in
//            textField.placeholder = "비밀번호는 3415"
//            textField.keyboardType = .numberPad
//            textField.isSecureTextEntry = true
//        })
//
//        let ok = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { [self](ACTION) in
//            let password = alert.textFields?[0].text
//            if password?.isEmpty == false && password == "3415" {
//                
//            } else {
//                let alert2 = UIAlertController(title: nil, message: "비밀번호를 잘못 입력하였습니다", preferredStyle: .alert)
//                self.present(alert2, animated: false, completion:{Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
//                    self.dismiss(animated: true){
//                        self.selectedIndex = 0
//                        goToMain()
//                    }
//                })})
//            }
//           
//        })
//        
//        let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: { [self](ACTION) in
//            selectedIndex = 0
//            goToMain()
//        })
//
//        alert.addAction(cancel)
//        alert.addAction(ok)
//
//        present(alert, animated: false, completion: nil)
//    }
    
    func goToMain() {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        let mainTabBarController = storyboard!.instantiateViewController(identifier: "TabBar")
        mainTabBarController.modalPresentationStyle = .fullScreen
        self.present(mainTabBarController, animated: true, completion: nil)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }

}
extension TabBarController {
    func hideTabs(at indices: [Int]) {
        // 숨길 인덱스를 제외한 뷰 컨트롤러로 설정
        self.viewControllers = originalViewControllers.enumerated()
            .filter { !indices.contains($0.offset) }
            .map { $0.element }
    }
    
    func showAllTabs() {
         // 원래 ViewControllers로 복원
//         self.viewControllers = originalViewControllers
        setViewControllersWithAnimation(originalViewControllers)
     }
    
    func setViewControllersWithAnimation(_ viewControllers: [UIViewController]) {
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.viewControllers = viewControllers
        }, completion: nil)
    }
}
