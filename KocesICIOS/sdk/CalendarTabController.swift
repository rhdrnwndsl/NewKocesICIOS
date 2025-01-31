//
//  CalendarTabController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 1/24/25.
//

import Foundation
import UIKit

class CalendarTabController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    
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

        add(asChildViewController: CalendarVC)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        remove(asChildViewController: CalendarVC)
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
    
    private lazy var CalendarVC: CalendarViewController = {
        let storyboard = getMainStoryBoard()

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    static func viewController() -> CalendarTabController {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "calendartab") as! CalendarTabController
        } else {
            return UIStoryboard.init(name: "pad", bundle: nil).instantiateViewController(withIdentifier: "calendartab") as! CalendarTabController
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

