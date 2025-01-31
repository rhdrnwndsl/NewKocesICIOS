//
//  JLabel.swift
//  osxapp
//
//  Created by 金載龍 on 2021/03/27.
//

import Foundation
import UIKit

class JLabel: UILabel {
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        initRes()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame) 
    }
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
    }
    
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }

    private func initRes() {
        
    }
}
