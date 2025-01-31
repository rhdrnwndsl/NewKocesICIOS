//
//  SceneDelegate.swift
//  osxapp
//
//  Created by 金載龍 on 2020/12/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let urlinfo = connectionOptions.urlContexts
        
        if let url = urlinfo.first?.url {

            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            var items = urlComponents?.query ?? ""
//            if items == "" {
//                items = urlComponents?.host ?? ""
//            }
            debugPrint(String((urlinfo.first?.url.absoluteString)!))
            debugPrint("items : "+items)
            if String((urlinfo.first?.url.absoluteString)!).contains("kocesWeb") {
                var _str = String((urlinfo.first?.url.absoluteString)!)
                _str.removeFirst();  _str.removeFirst();  _str.removeFirst();  _str.removeFirst();  _str.removeFirst();
                _str.removeFirst();  _str.removeFirst();  _str.removeFirst();  _str.removeFirst();  _str.removeFirst();
                _str.removeFirst();  _str.removeFirst();  _str.removeFirst();
                let _t1 = _str.replacingOccurrences(of: "%2F", with: "/")
                let _t2 = _t1.replacingOccurrences(of: "%3A", with: ":")
                let _t3 = _t2.removingPercentEncoding
//                Setting.shared.WebtoApp = _t2
                Setting.shared.WebtoApp = _t3!
            } else {
                Setting.shared.ApptoApp = items
            }
            
        }
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene:UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>){
        guard let url = URLContexts.first?.url  else {
            return
        }

        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var items = urlComponents?.query ?? ""
//        if items == "" {
//            items = urlComponents?.host ?? ""
//        }
        debugPrint(String((URLContexts.first?.url.absoluteString)!))
        debugPrint("items : "+items)
        if String((URLContexts.first?.url.absoluteString)!).contains("kocesWeb") {
            var _str = String((URLContexts.first?.url.absoluteString)!)
            _str.removeFirst();  _str.removeFirst();  _str.removeFirst();  _str.removeFirst();  _str.removeFirst();
            _str.removeFirst();  _str.removeFirst();  _str.removeFirst();  _str.removeFirst();  _str.removeFirst();
            _str.removeFirst();  _str.removeFirst();  _str.removeFirst();
            let _t1 = _str.replacingOccurrences(of: "%2F", with: "/")
            let _t2 = _t1.replacingOccurrences(of: "%3A", with: ":")
            let _t3 = _t2.removingPercentEncoding
//            Setting.shared.WebtoApp = _t2
            Setting.shared.WebtoApp = _t3!
        } else {
            Setting.shared.ApptoApp = items
        }
        
       
        
//        if #available(iOS 13.0, *){
//            window?.overrideUserInterfaceStyle = .light
//        }
        
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else { return }
        
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        let appToAppController = storyboard!.instantiateViewController(identifier: "AppToAppViewController")
        appToAppController.modalPresentationStyle = .fullScreen
        self.window?.rootViewController = appToAppController
        self.window?.makeKeyAndVisible()
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        UIApplication.shared.isIdleTimerDisabled = false
    }


}

