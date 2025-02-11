//
//  AppDelegate.swift
//  osxapp
//
//  Created by 金載龍 on 2020/12/25.
//

import UIKit
import CoreData
import SDWebImageWebPCoder


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //여기서 로딩화면을 몇초간 유지할지를 정한다
        sleep(3)
        NetworkManager.shared.startMonitoring()
        // AppDelegate의 didFinishLaunchingWithOptions 내부 또는 SceneDelegate에서:
        let webPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(webPCoder)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        // 앱 UI 설정값에 따라 분기처리
        let appUISetting = Setting.shared.getDefaultUserData(_key: define.APP_UI_CHECK)
    
        // 세로방향 고정
        if UIDevice.current.userInterfaceIdiom == .phone ||
            UIDevice.current.userInterfaceIdiom == .unspecified {
            // 여기서 셋팅으로 일반모드일 경우 세로고정. 상품모드일 경우 가로고정으로 처리한다
            return appUISetting == define.UIMethod.Product.rawValue ? UIInterfaceOrientationMask.landscape:UIInterfaceOrientationMask.portrait
        } else {
            //맥, 카플레이, 패드, 비전프로
            return UIInterfaceOrientationMask.landscape
        }
    }
    
    let mKocesSdk:KocesSdk = KocesSdk.instance
    //앱이 백그라운드에 들어갔을 때 호출 됨.
     func applicationDidEnterBackground(_ application: UIApplication)
     {
         LogFile.instance.InsertLog("GO App_Background", Tid: "");
         print("GO App_Background")
         mKocesSdk.manager.disconnect()
         mKocesSdk.manager.disconnectClear()
         
     }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "bleDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

