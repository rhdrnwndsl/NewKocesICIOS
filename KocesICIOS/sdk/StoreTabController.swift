//
//  StoreTabController.swift
//  osxapp
//
//  Created by 신진우 on 2021/03/25.
//

import Foundation
import UIKit
//storesettingVC,TaxSettingVC,printSettingVC
class StoreTabController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        if UserDefaults.standard.string(forKey: define.TERMS_AGREE) == nil {    //동의한 적이 없다면
//            add(asChildViewController: TermsAgreeVC)
//            remove(asChildViewController: storesettingVC)
//        } else {    //동의했다면
//            add(asChildViewController: storesettingVC)
//            remove(asChildViewController: TermsAgreeVC)
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //네비게이션 바의 배경색 rgb 변경
        UISetting.navigationTitleSetting(navigationBar: navigationController?.navigationBar ?? UINavigationBar())
        
//        UISetting.setGradientBackground(_bar: navigationController?.navigationBar ?? UINavigationBar(), colors: [
//            UIColor.systemBlue.cgColor,
//            UIColor.white.cgColor
//        ])
        
        //상단의 세그먼트컨트롤 탭의 rgb 셋팅한다
        UISetting.highTabBarSetting(segBar: segmentControl)
//        segmentControl.layer.cornerRadius = 0
        add(asChildViewController: storesettingVC)
        remove(asChildViewController: printSettingVC)
        remove(asChildViewController: TaxSettingVC)
        segmentControl.selectedSegmentIndex = 0
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        remove(asChildViewController: storesettingVC)
        remove(asChildViewController: printSettingVC)
        remove(asChildViewController: TaxSettingVC)
        segmentControl.selectedSegmentIndex = 0
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func getMainStoryBoard() -> UIStoryboard {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        return storyboard!
    }
    
    private lazy var printSettingVC: PrintSettingController = {
        // Load Storyboard
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }

        // Instantiate View Controller
        var viewController = storyboard!.instantiateViewController(withIdentifier: "PrintSettingController") as! PrintSettingController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var storesettingVC: StoreSettingController = {
        // Load Storyboard
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        
        // Instantiate View Controller
        var viewController = storyboard!.instantiateViewController(withIdentifier: "StoreSettingController") as! StoreSettingController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private lazy var TaxSettingVC: TaxController = {
        // Load Storyboard
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }

        // Instantiate View Controller
        var viewController = storyboard!.instantiateViewController(withIdentifier: "TaxController") as! TaxController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    @IBAction func changeViewController(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            add(asChildViewController: storesettingVC)
            remove(asChildViewController: printSettingVC)
            remove(asChildViewController: TaxSettingVC)
            break
        case 1:
            add(asChildViewController: TaxSettingVC)
            remove(asChildViewController: storesettingVC)
            remove(asChildViewController: printSettingVC)
            break
        case 2:
            remove(asChildViewController: TaxSettingVC)
            add(asChildViewController: printSettingVC)
            remove(asChildViewController: storesettingVC)
            break
        default:
            break
        }
    }
    
    static func viewController() -> StoreTabController {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "storetab") as! StoreTabController
        } else {
            return UIStoryboard.init(name: "pad", bundle: nil).instantiateViewController(withIdentifier: "storetab") as! StoreTabController
        }
     
    }
    
    private func add(asChildViewController viewController: UIViewController) {

        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        viewContainer.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = viewContainer.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
        NotificationCenter.default.removeObserver(viewController)
//        viewController.dismiss(animated: true, completion: nil)
    }
}

