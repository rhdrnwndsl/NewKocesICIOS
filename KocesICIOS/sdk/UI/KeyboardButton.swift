//
//  KeyboardButton.swift
//  KocesICIOS
//
//  Created by 金載龍 on 2021/05/18.
//

import Foundation
import UIKit

class KeyboardButton : UIButton {
    //기본적으로 높이를 높게 잡는다.
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        initRes()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
    }
    
    //버튼 테두리 굵기
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    //버튼 모서리를 둥글게
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    //버튼 테두리 색깔
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    private func initRes(){

        //self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: 150.0, height: 40.0))
        //setBackgroundImage(UIImage(named: "btnBack"), for: .normal)
        
        //버튼 테두리의 굵기, 색깔, 모서리의 둥글기, 버튼 백그라운드색깔, 텍스트 색깔의 디폴트 값을 정의한다
        self.backgroundColor = UIColor.white
        self.setTitleColor(UIColor.black, for: .normal)
        //self.setTitleColor(UIColor(displayP3Red: 0/255, green:113/255, blue: 188/255, alpha: 100.0), for: .normal)
        self.cornerRadius = 5
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: .black)
 
    }
    
    public func getClientRect() -> CGRect {
        self.frame
    }
}

