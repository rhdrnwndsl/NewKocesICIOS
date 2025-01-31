//
//  NumberKeyButton.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 12/24/24.
//

import Foundation
import UIKit

class NumberKeyButton: UIButton {
    let animationDuration: TimeInterval = 0.2
    var key: NumberKey?
    private var backgroundColors: [UIControl.State.RawValue: UIColor] = [:]
    private var originRect: CGRect = CGRect.zero
    private var originTintColor: UIColor?
    private var originHightlightColor: UIColor?
    
    override var isHighlighted: Bool {
        didSet {
            guard let color = self.backgroundColors[isHighlighted ? UIControl.State.highlighted.rawValue : UIControl.State.normal.rawValue] else {
                return
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: self.isHighlighted ? 0.0 : self.animationDuration,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                                self.layer.backgroundColor = color.cgColor
                                if self.key == .delete {
                                    self.tintColor = self.isHighlighted ? self.originHightlightColor : self.originTintColor
                                }
                })
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let keyType = key else {
            return
        }
        
        isEnabled = keyType != .empty
        titleEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        contentHorizontalAlignment = .center
        titleLabel?.textAlignment = .center
        if keyType != .custom {
            setTitle(keyType.value(), for: .normal)
        }
        if keyType == .empty {
            setIcon(image: nil)
        }
    }
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        backgroundColors[forState.rawValue] = color
        if forState == .normal {
            self.layer.backgroundColor = color.cgColor
        }
    }
    
    func setScale(scale: CGFloat) {
        
        originRect = frame
        guard scale < 1.0 else {
            return
        }
        
        let marginWidth: CGFloat = originRect.width - (originRect.width * scale)
        let marginHeight: CGFloat = originRect.height - (originRect.height * scale)
        let x: CGFloat = marginWidth/2
        let y: CGFloat = marginHeight/2
        let w: CGFloat = originRect.width - marginWidth
        let h: CGFloat = originRect.height - marginHeight
        frame = CGRect(x: originRect.origin.x + x, y: originRect.origin.y + y, width: w, height: h)
        guard layer.cornerRadius > 0 else {
            return
        }
        layer.cornerRadius = h/2
    }
    
    func setIcon(image: UIImage?) {
        setIcon(image: image, color: titleColor(for: .normal))
    }
    
    func setIcon(image: UIImage?, color: UIColor?) {
        setImage(image?.resize(newWidth: (image?.size.width)! * 2), for: .normal)
        setImage(image?.resize(newWidth: (image?.size.width)! * 2), for: .highlighted)
        tintColor = color
        originHightlightColor = backgroundColors[UIControl.State.highlighted.rawValue]
        originTintColor = tintColor
    }
}

extension UIColor {
    func convertImage() -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setFillColor(self.cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
}
extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
            let scale = newWidth / self.size.width
            let newHeight = self.size.height * scale

            let size = CGSize(width: newWidth, height: newHeight)
            let render = UIGraphicsImageRenderer(size: size)
            let renderImage = render.image { context in
                self.draw(in: CGRect(origin: .zero, size: size))
            }
            
            print("화면 배율: \(UIScreen.main.scale)")// 배수
            print("origin: \(self), resize: \(renderImage)")
            return renderImage
        }
}
