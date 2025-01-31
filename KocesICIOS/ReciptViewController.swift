//
//  ReciptViewController.swift
//  osxapp
//
//  Created by 金載龍 on 2021/02/10.
//

import Foundation
import UIKit
import SwiftUI

/**
 사용안함
 */
class ReciptViewController:UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
    
        let controller = UIHostingController(rootView: ReceiptSwiftUI())
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(controller)
        self.view.addSubview(controller.view)
        
        //최상단에 만든다. leadingAnchor = left. trailingAnchor = right. bottomAnchor = bottom. topAnchor = top.
        controller.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        controller.didMove(toParent: self)
    }
    
    
}
