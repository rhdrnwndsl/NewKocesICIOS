//
//  EnvironmentTabController.swift
//  osxapp
//
//  Created by 신진우 on 2021/01/07.
//

import UIKit

class EnvironmentTabController: UISplitViewController, UISplitViewControllerDelegate {

    var productItem: [UITabBarItem] = [
        UITabBarItem(title: "메인화면", image: UIImage(systemName: "house"), tag: 0),
        UITabBarItem(title: "환경설정", image: UIImage(systemName: "gearshape"), tag: 1),
        UITabBarItem(title: "거래내역", image: UIImage(systemName: "text.book.closed"), tag: 2),
        UITabBarItem(title: "매출정보", image: UIImage(systemName: "calendar"), tag: 3)
    ]
        
    var commonItem: [UITabBarItem] = [
        UITabBarItem(title: "메인화면", image: UIImage(systemName: "house"), tag: 0),
        UITabBarItem(title: "환경설정", image: UIImage(systemName: "gearshape"), tag: 1)
    ]
    
    public var rootView = EnvironmentSplitView()
    private func createSections() -> [SettingSection] {
        var storeSection =
        SettingSection(
            title: "가맹점설정",
            items: [
                SettingItem(title: "가맹점정보", hasSwitch: false, detail: "Standard", action: nil),
                SettingItem(title: "결제설정", hasSwitch: false, detail: "Standard", action: nil),
            ]
        )
        var deviceSection =
        SettingSection(
            title: "장치설정",
            items: [
//                    SettingItem(title: "USB설정", hasSwitch: false, detail: "Standard", action: nil),
                SettingItem(title: "BT설정", hasSwitch: false, detail: "Standard", action: nil),
                SettingItem(title: "CAT설정", hasSwitch: false, detail: nil, action: nil),
                SettingItem(title: "프린트설정", hasSwitch: false, detail: nil, action: nil),
            ]
        )
        var productSection =
        SettingSection(
            title: "상품설정",
            items: [
                SettingItem(title: "상품관리", hasSwitch: false, detail: "Standard", action: nil),
            ]
        )
        var managerSection =
        SettingSection(
            title: "관리자설정",
            items: [
                SettingItem(title: "네트워크설정", hasSwitch: false, detail: nil, action: nil),
            ]
        )
        var infoSection =
        SettingSection(
            title: "앱정보",
            items: [
                SettingItem(title: "Q&A", hasSwitch: false, detail: nil, action: nil),
                SettingItem(title: "개인정보처리방침", hasSwitch: false, detail: nil, action: nil),
                SettingItem(title: "앱정보", hasSwitch: false, detail: nil, action: nil),
            ]
        )
        
        let appUISetting = Setting.shared.getDefaultUserData(_key: define.APP_UI_CHECK)
        
        if appUISetting == define.UIMethod.Common.rawValue {
            return [
                storeSection,   //가맹점
                deviceSection,  //장치
                managerSection, //관리자
                infoSection     //앱정보
            ]
        } else if appUISetting == define.UIMethod.Product.rawValue {
            return [
                storeSection,   //가맹점
                deviceSection,  //장치
                productSection, //상품
                managerSection, //관리자
                infoSection     //앱정보
            ]
        } else {
            //AppToApp
            storeSection =
            SettingSection(
                title: "가맹점설정",
                items: [
//                    SettingItem(title: "가맹점정보", hasSwitch: false, detail: "Standard", action: nil),
                    SettingItem(title: "결제설정", hasSwitch: false, detail: "Standard", action: nil)
                ]
            )
            return [
                storeSection,   //가맹점
                deviceSection,  //장치
                managerSection, //관리자
                infoSection     //앱정보
            ]
        }
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

        if !rootView.isProduct {
            rootView = EnvironmentSplitView()
            rootView.configure(with: createSections())
            // 부모 컨트롤러로 self를 등록하여, EnvironmentSplitView 내에서 자식 ProductSetViewController의 delegate로 할당되도록 함
            rootView.setViewController(viewController: self)
            self.view = rootView
            
            setupNavigationBar()
        } else {
            rootView.isProduct = false
        }
    }
    
    @objc func BackMainView() {
        let appUISetting = Setting.shared.getDefaultUserData(_key: define.APP_UI_CHECK)
        
        if appUISetting == define.UIMethod.AppToApp.rawValue {
            UIApplication.shared.perform (#selector (NSXPCConnection.suspend))
        } else {
            rootView.backToMainView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupNavigationBar() {
        // 왼쪽에 커스텀 백 버튼 생성: "chevron.backward" 이미지 + "BACK" 텍스트
        let backButton = UIButton(type: .system)
        if let backImage = UIImage(systemName: "chevron.backward") {
            backButton.setImage(backImage, for: .normal)
        }
        // 이미지와 텍스트 사이에 약간의 공백을 주기 위해 앞에 공백 추가
        backButton.setTitle(" Back", for: .normal)
        
        // 아이콘과 텍스트 모두 흰색으로 설정
        backButton.tintColor = define.txt_blue
        backButton.setTitleColor(define.txt_blue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        // 크기 조정
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(BackMainView), for: .touchUpInside)
        
        // 커스텀 버튼을 좌측 바 버튼 아이템으로 설정
        let leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem

    }
}

// MARK: - ProductSetViewControllerDelegate Implementation

extension EnvironmentTabController: ProductSetViewControllerDelegate, StoreViewControllerDelegate {
    func storeViewControllerInit(_ controller: StoreViewController) {
        print("StoreViewController: 가맹점 다운로드 화면으로 이동")
        rootView.isStoreDownload = true
    }
    
    
    func productSetViewControllerDidTapRegister(_ controller: ProductSetViewController) {
        // ProductRegisterViewController 전환: 네비게이션 스택에 push
//        let registerVC = ProductRegisterViewController()
        rootView.isProduct = true
        print("EnvironmentTabController: 상품등록 전환")
//        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    func productSetViewControllerDidTapModify(_ controller: ProductSetViewController) {
        // 상품수정 화면 전환 (예시: ProductModifyViewController, 별도로 구현)
//        let productListVC = ProductListViewController()
        rootView.isProduct = true
        print("EnvironmentTabController: 상품수정리스트 전환")
//        navigationController?.pushViewController(productListVC, animated: true)
    }
}
