//
//  NumberPad.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 12/24/24.
//

import UIKit
import CoreGraphics

public protocol NumberPadDelegate {
    func keyPressed(key: NumberKey?)
}

@IBDesignable open class NumberPad: UIView {

    open var delegate: NumberPadDelegate?
    private var longRunTimer: Timer?
   
    //일반 키
    @IBInspectable open var keyBackgroundColor: UIColor = defaultBackgroundColor {
        didSet { updateKeys() }
    }
    
    @IBInspectable open var keyHighlightColor: UIColor = defaultHighlightColor {
        didSet { updateKeys() }
    }
    
    
    @IBInspectable open var keyTitleColor: UIColor = .black {
        didSet { updateKeys() }
    }
    
    @IBInspectable open var keyOkTitleColor: UIColor = define.keypad_ok_lightgreen {
        didSet { updateKeys() }
    }
    
    @IBInspectable open var keyClearTitleColor: UIColor = define.keypad_clear_darkorange {
        didSet { updateKeys() }
    }
    
    @IBInspectable open var keyBorderWidth: CGFloat = 1.0 {
        didSet { updateKeys() }
    }
    
    @IBInspectable open var keyBorderColor: UIColor = define.layout_border_lightgrey {
        didSet { updateKeys() }
    }
    
    @IBInspectable open var keyScale: CGFloat = 1.0 {
        didSet { updateKeys() }
    }
    
    @IBInspectable open var clearScale: CGFloat = 2.0 {
        didSet { updateKeys() }
    }
    
    open var style: NumberPadStyle = .square {
        didSet { updateKeys() }
    }
    
//    open var keyFont: UIFont? = UIFont.boldSystemFont(ofSize: 35) {
//        didSet { updateKeys() }
//    }
   
    open var keyFont: UIFont? = UIFont.systemFont(ofSize: CGFloat(35)) {
        didSet { updateKeys() }
    }
    
    open var clearKeyPosition: NumberClearKeyPosition = .right {
        didSet { updateKeys() }
    }
    
    open var deleteKeyIcon: UIImage? = UIImage(systemName: "delete.backward.fill")?.withTintColor(define.keypad_delete_red, renderingMode: .alwaysOriginal) {
        didSet { updateKeys() }
    }
    
    open var deleteKeyBackgroundColor: UIColor = defaultBackgroundColor {
        didSet { updateKeys() }
    }
    
    open var deleteKeyHighlightColor: UIColor = define.keypad_delete_red {
        didSet { updateKeys() }
    }
    
    open var deleteKeyTintColor: UIColor = .white {
        didSet { updateKeys() }
    }
    
    open var clearKeyBackgroundColor: UIColor = defaultBackgroundColor {
        didSet { updateKeys() }
    }
    
    open var clearKeyHighlightColor: UIColor = define.keypad_clear_darkorange {
        didSet { updateKeys() }
    }
    
    open var clearKeyTintColor: UIColor = .white {
        didSet { updateKeys() }
    }
    
    open var okKeyBackgroundColor: UIColor = defaultBackgroundColor {
        didSet { updateKeys() }
    }
    
    open var okKeyHighlightColor: UIColor = define.keypad_ok_lightgreen {
        didSet { updateKeys() }
    }
    
    open var okKeyTintColor: UIColor = .white {
        didSet { updateKeys() }
    }
    
    
    
    open var emptyKeyBackgroundColor: UIColor = defaultBackgroundColor {
        didSet { updateKeys() }
    }
    
    open var customKeyText: String? = nil {
        didSet { updateKeys() }
    }
    
    open var customKeyImgae: UIImage? = nil {
        didSet { updateKeys() }
    }
    
    open var customKeyTitleColor: UIColor? = nil {
        didSet { updateKeys() }
    }
    
    open var customKeyBackgroundColor: UIColor? = nil {
        didSet { updateKeys() }
    }
    
    open var customKeyHighlightColor: UIColor? = nil {
        didSet { updateKeys() }
    }
    
    open var customKeyBorderWidth: CGFloat = 0 {
        didSet { updateKeys() }
    }
    
    open var customKeyBorderColor: UIColor? = nil {
        didSet { updateKeys() }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        print("########### layoutSubviews ")
        updateKeys()
    }
    
    @objc func keyEvent(sender: NumberKeyButton) {
        delegate?.keyPressed(key: sender.key)
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if let button = sender.view as? NumberKeyButton {
            switch sender.state {
            case .began:
                button.isHighlighted = true
//                longRunTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(runLongPressed(sender:)), userInfo: button, repeats: true)
            case .ended:
                button.isHighlighted = false
//                if longRunTimer != nil {
//                    longRunTimer?.invalidate()
//                    longRunTimer = nil
//                }
                
            default: break
            }
        }
    }
    
    @objc func runLongPressed(sender: Timer) {
        if let button = sender.userInfo as? NumberKeyButton {
            delegate?.keyPressed(key: button.key)
        }
    }
    
    private static let defaultBackgroundColor: UIColor = UIColor(white: 1, alpha: 0.6)
    private static let defaultHighlightColor: UIColor = UIColor(white: 0, alpha: 0.4)
    private final let rows: Int = 4
    private final let cols: Int = 4
    private var keys: [NumberKeyButton] = []
    
    private func setupViews() {
        clipsToBounds = true
        let width: CGFloat = bounds.width / CGFloat(cols)
        let height: CGFloat = bounds.height / CGFloat(rows)
        var keyNumber = 1
        for i in 1...rows {
            for j in 1...cols {
                let keyButton = NumberKeyButton(type: .custom)
                if keyNumber == 12 {
                    //키넘버가 11에서 키버튼을 만들면 이건 ok 버튼(12번째) 이다
                    keyButton.frame = CGRect(x: CGFloat(j-1) * width, y: CGFloat(i-1) * height, width: width, height: height * 2)
                } else {
                    keyButton.frame = CGRect(x: CGFloat(j-1) * width, y: CGFloat(i-1) * height, width: width, height: height)
                }
         
                keyButton.addTarget(self, action: #selector(keyEvent(sender:)), for: .touchUpInside)
                keyButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:))))
                switch keyNumber {
                case 1,2,3:
                    keyButton.key = NumberKey(rawValue: keyNumber)
                case 4:
                    keyButton.key = .delete
                case 5,6,7:
                    keyButton.key = NumberKey(rawValue: keyNumber - 1)
                case 8:
                    keyButton.key = .clear
                case 9,10,11:
                    keyButton.key = NumberKey(rawValue: keyNumber - 2)
                case 12:
                    keyButton.key = .keyok
                case 13:
                    keyButton.key = .key00
                case 14:
                    keyButton.key = .key0
                case 15:
                    keyButton.key = .key010
                case 16:
                    break
                    
//                case 10:
//                    keyButton.key = .empty
//                case 11:
//                    keyButton.key = .key0
//                case 12:
//                    keyButton.key = .clear
                default:
                    keyButton.key = NumberKey(rawValue: keyNumber)
                }
                if keyNumber != 16 {
                    keys.append(keyButton)
                    self.addSubview(keyButton)
                }
                keyNumber += 1
            }
        }
        updateKeys()
    }
    
    private func updateKeys() {
        var row: Int = 0
        var col: Int = 0
        let width: CGFloat = bounds.width / CGFloat(cols)
        let height: CGFloat = bounds.height / CGFloat(rows)
        
        for (index, button) in keys.enumerated() {
            
//            if clearKeyPosition == .left {
//                if index == 9 {
//                    button.key = .clear
//                }
//                if index == 11 {
//                    button.key = (customKeyText != nil || customKeyImgae != nil) ? .custom : .empty
//                }
//            } else {
//                if index == 9 {
//                    button.key = (customKeyText != nil || customKeyImgae != nil) ? .custom : .empty
//                }
//                if index == 11 {
//                    button.key = .clear
//                }
//            }
            
            if button.bounds.width != width || button.bounds.height != height {
                if style == .circle && width != height {
                    if width > height {
                        button.frame = CGRect(x: CGFloat(col) * width, y: CGFloat(row) * height, width: height, height: index == 11 ? height*2:height)
                    } else {
                        button.frame = CGRect(x: CGFloat(col) * width, y: CGFloat(row) * height, width: width, height: index == 11 ? width*2:width)
                    }
                } else {
                    var offset: CGFloat = (keyBorderWidth > 0) ? keyBorderWidth : 0
                    offset = (button.key == .custom) ? 0 : offset
                    button.frame = CGRect(x: CGFloat(col) * width, y: CGFloat(row) * height, width: width - offset, height: index == 11 ? (height*2 - offset):(height - offset))
                }
            }
            
            button.layer.cornerRadius = style == .square ? 10 : button.bounds.height / 2
    
            button.setBackgroundColor(color: keyBackgroundColor, forState: .normal)
            button.setBackgroundColor(color: keyHighlightColor, forState: .highlighted)
            button.setTitleColor(keyTitleColor, for: .normal)
            button.titleLabel?.font = keyFont
            button.clipsToBounds = true
            
            switch button.key {
            case .some(.delete):
                button.setScale(scale: clearScale)
                button.setIcon(image: deleteKeyIcon, color: define.keypad_delete_red)
                button.setBackgroundColor(color: deleteKeyBackgroundColor, forState: .normal)
                button.setBackgroundColor(color: deleteKeyHighlightColor, forState: .highlighted)
                button.layer.borderWidth = keyBorderWidth
                button.layer.borderColor = define.keypad_delete_red.cgColor
            case .some(.clear):
                button.setScale(scale: keyScale)
                button.setBackgroundColor(color: clearKeyBackgroundColor, forState: .normal)
                button.setBackgroundColor(color: clearKeyHighlightColor, forState: .highlighted)
                button.setTitleColor(keyClearTitleColor, for: .normal)
                button.layer.borderWidth = keyBorderWidth
                button.layer.borderColor = define.keypad_clear_darkorange.cgColor
            case .some(.keyok):
                button.setScale(scale: keyScale)
                button.setBackgroundColor(color: okKeyBackgroundColor, forState: .normal)
                button.setBackgroundColor(color: okKeyHighlightColor, forState: .highlighted)
                button.setTitleColor(keyOkTitleColor, for: .normal)
                button.layer.borderWidth = keyBorderWidth
                button.layer.borderColor = define.keypad_ok_lightgreen.cgColor
            case .some(.empty):
                button.setScale(scale: keyScale)
                button.setBackgroundColor(color: emptyKeyBackgroundColor, forState: .normal)
                button.setBackgroundColor(color: emptyKeyBackgroundColor, forState: .highlighted)
                button.layer.borderWidth = keyBorderWidth
                button.layer.borderColor = keyBorderColor.cgColor
            case .some(.custom):
                button.setScale(scale: keyScale)
                button.setIcon(image: customKeyImgae, color: deleteKeyTintColor)
                button.setTitle(customKeyText, for: .normal)
                button.setBackgroundColor(color: customKeyBackgroundColor ?? keyBackgroundColor, forState: .normal)
                button.setBackgroundColor(color: customKeyHighlightColor ?? keyHighlightColor, forState: .highlighted)
                button.setTitleColor(customKeyTitleColor ?? keyTitleColor, for: .normal)
                button.layer.borderWidth = customKeyBorderWidth
                button.layer.borderColor = customKeyBorderColor?.cgColor
            default:
                button.setScale(scale: keyScale)
                button.layer.borderWidth = keyBorderWidth
                button.layer.borderColor = keyBorderColor.cgColor
            }
            
            col += 1
            if col >= cols {
                row += 1
                col = 0
            }
        }
    }
}

extension Bundle {
    static func myBundle() -> Bundle {
        let bundle = Bundle(for: NumberPad.self)
        return bundle
    }
}
