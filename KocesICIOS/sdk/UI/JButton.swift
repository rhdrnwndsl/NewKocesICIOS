//
//  JButton.swift
//  osxapp
//
//  Created by 金載龍 on 2021/03/11.
//

import Foundation
import UIKit
class JButton : UIButton {
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
        self.backgroundColor = UIColor(displayP3Red: 0/255, green:113/255, blue: 188/255, alpha: 100.0)
        self.setTitleColor(UIColor.white, for: .normal)
        //self.setTitleColor(UIColor(displayP3Red: 0/255, green:113/255, blue: 188/255, alpha: 100.0), for: .normal)
        
        self.layer.cornerRadius = 5
//        self.layer.borderColor = UIColor(displayP3Red: 0/255, green:113/255, blue: 188/255, alpha: 100.0).cgColor
//        self.layer.borderWidth = 3
        
    }
    
    public func setClientSize(가로 _width:CGFloat,세로 _height:CGFloat){
        
    }
    
    public func getClientRect() -> CGRect {
        self.frame
    }
    
    /// 버튼 타이틀을 설정한다.
    /// - Parameter _title: String
    public func Title(타이틀 _title:String){
        self.setTitle(_title, for: .normal)
    }
    
    /// 버튼 타이틀과 버튼 색상을 설정한다.
    /// 미리 설정된 이름을 입력 하면 설정 된다
    /// - Parameters:
    ///   - _title: 버튼 타이틀
    ///   - _color: 설정색상: jwRed, jwBlue
    public func Title(타이틀 _title:String,설정색상 _color:String){
        self.setTitle(_title, for: .normal)
        setBorderColor(설정색상: _color)
    }
    
    /// 버튼 색상을 설정한다.  미리 설정된 이름을 입력 하면 설정 된다
    /// - Parameter 설정색상: jwRed, jwBlue
    public func setBorderColor(설정색상 _color:String){
        switch _color {
        case "jwRed":
            self.setTitleColor(UIColor(displayP3Red: 233/255, green:81/255, blue: 23/255, alpha: 100.0), for: .normal)
            self.layer.borderColor = UIColor(displayP3Red: 233/255, green:81/255, blue: 23/255, alpha: 100.0).cgColor
            break
        case "jwWhite":
//            self.setTitleColor(UIColor(displayP3Red: 0/255, green:113/255, blue: 188/255, alpha: 100.0), for: .normal)
            self.setTitleColor(UIColor(displayP3Red: 255/255, green:255/255, blue: 255/255, alpha: 100.0), for: .normal)
            self.layer.borderColor = UIColor(displayP3Red: 0/255, green:113/255, blue: 188/255, alpha: 100.0).cgColor
            break
        default:
            break
        }
    }
}

