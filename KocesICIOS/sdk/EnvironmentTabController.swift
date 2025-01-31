//
//  EnvironmentTabController.swift
//  osxapp
//
//  Created by 신진우 on 2021/01/07.
//

import UIKit

class EnvironmentTabController: UISplitViewController, UISplitViewControllerDelegate {
    
    var productItem:[UITabBarItem] = [
        UITabBarItem(title: "메인화면", image: UIImage(systemName: "house"), tag: 0),
        UITabBarItem(title: "환경설정", image: UIImage(systemName: "gearshape"), tag: 1),
        UITabBarItem(title: "거래내역", image: UIImage(systemName: "text.book.closed"), tag: 2),
        UITabBarItem(title: "매출정보", image: UIImage(systemName: "calendar"), tag: 3)
    ]
    
    var commonItem:[UITabBarItem] = [
        UITabBarItem(title: "메인화면", image: UIImage(systemName: "house"), tag: 0),
        UITabBarItem(title: "환경설정", image: UIImage(systemName: "gearshape"), tag: 1),
//        UITabBarItem(title: "거래내역", image: UIImage(systemName: "text.book.closed"), tag: 2),
//        UITabBarItem(title: "매출정보", image: UIImage(systemName: "calendar"), tag: 3)
    ]

    private var rootView = EnvironmentSplitView()
    private func createSections() -> [SettingSection] {
        return [
            SettingSection(
                title: "가맹점설정",
                items: [
                    SettingItem(title: "가맹점정보", hasSwitch: false, detail: "Standard", action: nil),
                    SettingItem(title: "결제설정", hasSwitch: false, detail: "Standard", action: nil),
                ]
            ),
            SettingSection(
                title: "장치설정",
                items: [
//                    SettingItem(title: "USB설정", hasSwitch: false, detail: "Standard", action: nil),
                    SettingItem(title: "BT설정", hasSwitch: false, detail: "Standard", action: nil),
                    SettingItem(title: "CAT설정", hasSwitch: false, detail: nil, action: nil),
                    SettingItem(title: "프린트설정", hasSwitch: false, detail: nil, action: nil),
                ]
            ),
            SettingSection(
                title: "상품설정",
                items: [
                    SettingItem(title: "상품관리", hasSwitch: false, detail: "Standard", action: nil),
                ]
            ),
            SettingSection(
                title: "관리자설정",
                items: [
                    SettingItem(title: "네트워크설정", hasSwitch: false, detail: nil, action: nil),
                ]
            ),
            SettingSection(
                title: "앱정보",
                items: [
                    SettingItem(title: "Q&A", hasSwitch: false, detail: nil, action: nil),
                    SettingItem(title: "개인정보처리방침", hasSwitch: false, detail: nil, action: nil),
                    SettingItem(title: "앱정보", hasSwitch: false, detail: nil, action: nil),
                ]
            )
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //네비게이션 바의 배경색 rgb 변경
        UISetting.navigationTitleSetting(navigationBar: navigationController?.navigationBar ?? UINavigationBar())

        rootView = EnvironmentSplitView()
        rootView.configure(with: createSections())
        rootView.setViewController(viewController: self)
        self.view = rootView
        
        let backImage = UIImage(systemName: "chevron.backward")
        let backButton = UIButton()
        backButton.setImage(backImage, for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(define.txt_title_blue, for: .normal)
        backButton.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(BackMainView), for: .touchUpInside)

        
        let backNav = UIBarButtonItem(customView: backButton)

        navigationItem.leftBarButtonItem = backNav
        
//        if let tabBarController = self.tabBarController as? TabBarController {
//            tabBarController.hideItems(at: [2,3] ) // 1번과 2번 탭 숨기기
//        }
        if let tabBarController = self.tabBarController as? TabBarController {
                  tabBarController.hideTabs(at: [2, 3]) // 1번과 2번 탭 숨기기
              }
    }
    
    @objc func BackMainView() {
        rootView.backToMainView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if let tabBarController = self.tabBarController as? TabBarController {
//            tabBarController.showCommonItems(item: productItem)
//        }
        if let tabBarController = self.tabBarController as? TabBarController {
                   tabBarController.showAllTabs() // 원래 탭 복원
               }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
