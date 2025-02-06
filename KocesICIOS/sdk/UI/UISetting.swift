//
//  UISetting.swift
//  osxapp
//
//  Created by 신진우 on 2021/03/24.
//

import Foundation
import UIKit

class UISetting{
    
    //네비게이션 타이틀 바의 기본셋팅
    static func navigationTitleSetting(navigationBar _bar:UINavigationBar) {
        _bar.barTintColor = UIColor(displayP3Red: 45/255, green: 51/255, blue: 55/255, alpha: 1)
        _bar.barStyle = .black
        _bar.isTranslucent = false   //네비게이션 타이틀바에 투명도를 설정할지를 셋팅. 기본은 투명도있음(true)
        _bar.prefersLargeTitles = false   //네비게이션 타이틀바의 제목을 워드의 (제목, 본문) 처럼 일반 본문의 크기가 아닌 제목처럼 키움
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
//            NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 24)!
        ]
        _bar.titleTextAttributes = attrs
    }
    
    //네비게이션 타이틀 바에 이미지(로고)삽입
    static func navigationLogoTitle(TitleImageSet _uiImageView:UIImageView, TitleImage _title:UIImage) -> UIImageView {
        var _view = _uiImageView
  //      _view.contentMode = .scaleAspectFill
        _view.translatesAutoresizingMaskIntoConstraints = false
        _view.centerYAnchor.constraint(equalTo:_uiImageView.centerYAnchor).isActive = true
        _view.centerXAnchor.constraint(equalTo:_uiImageView.centerXAnchor).isActive = true
        _view.widthAnchor.constraint(equalToConstant: 150).isActive = true
        _view.heightAnchor.constraint(equalToConstant: 27).isActive = true
        _view.image = _title
        return _view
    }
    
    static func setGradientBackground(_bar:UINavigationBar , colors: [Any]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)

        var updatedFrame = _bar.bounds
        updatedFrame.size.height += _bar.frame.origin.y
        gradient.frame = updatedFrame
        gradient.colors = colors;
        _bar.setBackgroundImage(image(fromLayer: gradient), for: .default)
    }

    static func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
    //하단 탭바의 기본셋팅
    static func lowTabBarSetting(tabBar _bar:UITabBar) {
        _bar.barTintColor = UIColor(displayP3Red: 45/255, green: 51/255, blue: 55/255, alpha: 1)
        _bar.barStyle = .black
        _bar.isTranslucent = false   //네비게이션 타이틀바에 투명도를 설정할지를 셋팅. 기본은 투명도있음(true)
        let selectedAttributes = [NSAttributedString.Key.font : UIFont.systemFont (ofSize : 15.0), .foregroundColor: UIColor(displayP3Red: 233/255, green: 81/255, blue: 23/255, alpha: 1)]
        let normalAttributes = [NSAttributedString.Key.font : UIFont.systemFont (ofSize : 15.0), .foregroundColor: UIColor.white]
        for item in _bar.items! {
            item.setTitleTextAttributes(selectedAttributes, for: .selected)
            item.setTitleTextAttributes(normalAttributes, for: .normal)
            if UIDevice.current.orientation.isPortrait {
                switch UIDevice.current.userInterfaceIdiom {
                case .phone:
                    // It's an iPhone
                    item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)    //탭바의 텍스트의 위치를 아이콘과의 간격 조정
                    break
                case .pad:
                    // It's an iPad (or macOS Catalyst)
                    break
                @unknown default:
                    break
                }
            }
//            else {
//                switch UIDevice.current.userInterfaceIdiom {
//                case .phone:
//                    // It's an iPhone
//                    item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)    //탭바의 텍스트의 위치를 아이콘과의 간격 조정
//                    break
//                case .pad:
//                    // It's an iPad (or macOS Catalyst)
//                    break
//                @unknown default:
//                    break
//                }
//
//            }
        
        }
    }
    
    //상단 탭바의 기본셋팅
    static func highTabBarSetting(segBar _bar:UISegmentedControl) {
        _bar.layer.cornerRadius = 0
        _bar.layer.maskedCorners = CACornerMask(rawValue: 0)
        _bar.layer.cornerCurve = CALayerCornerCurve(rawValue: "0")
        _bar.layer.masksToBounds = true
        _bar.clipsToBounds = true
        //텍스트 선택/기본 시 컬러설정
        _bar.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        _bar.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        //기본버튼 이미지
        _bar.setBackgroundImage(imageWithColor(color: define.layout_border_lightgrey), for: .normal, barMetrics: .default)
        //선택버튼 이미지
        _bar.setBackgroundImage(imageWithColor(color: UIColor(displayP3Red: 87/255, green: 88/255, blue: 90/255, alpha: 1)), for: .selected, barMetrics: .default)
        //버튼 사이의 구분자
        _bar.setDividerImage(imageWithColor(color: .systemOrange), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    static func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    
    //텍스트 뷰에 라인그리기 viewDidLayoutSubviews 에서 불러올 것. 화면이 변경되고, 뷰에 있는 것이 변경될 때마다 호출이 되기 때문에.. 입력할 때 마다 선이 생성된다고 이해하면 된다. 우연히 잘 맞으면 하나의 선으로 보이지만, 아닌 경우 선이 두 줄 이상으로 생성되기도 하기 때문이다. 이 때는 저 border란 변수를 옵셔널 + 전역 변수로 선언하여 nil 체크를 하여 없을 때만 생성되게 하면 된다.
    static func underlined(TextView _view:UITextView) -> UITextView {
        let _textView = _view
        _textView.layer.borderWidth = 1.0  //테두리그리기
        _textView.layer.borderColor = UIColor.secondarySystemBackground.cgColor //테두리선색깔
        _textView.layer.cornerRadius = 10  //모서리 둥글게
        _textView.backgroundColor = .white  //텍스트 뷰 내부 색
        _textView.textColor = .black    //텍스트 색
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = define.underline_grey.cgColor  //텍스트 뷰 라인 색
        border.frame = CGRect(x: 0, y: _textView.frame.size.height - width, width:  _textView.frame.size.width, height: _textView.frame.size.height)
        border.borderWidth = width
        _textView.layer.addSublayer(border)
        _textView.layer.masksToBounds = true
        return _textView
    }

}
