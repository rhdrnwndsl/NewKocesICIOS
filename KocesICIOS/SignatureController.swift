//
//  SignatureController.swift
//  osxapp
//
//  Created by 신진우 on 2021/01/08.
//

import UIKit
import MobileCoreServices

class Canvas:UIView {

    fileprivate var lines = [[CGPoint]]()
    var touchScreen:Bool = false
    var touchEnd:Bool = false
    var endCheck:Int = 0
    
//    func undo() {
//        lines.popLast()
//        setNeedsDisplay()
//    }
    
    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }

    func save() -> [UInt8] {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var imageData = [UInt8]()
        if touchScreen {
            //사이즈 리사이즈
            let resize = resizeImage(with: image!, scaledTo: CGSize(width: 128.0, height: 64.0))
            //이미지바이트변환
            imageData = pixelValues(fromCGImage: resize.cgImage)!
        }
        return imageData
    }
    
    func resizeImage(with image: UIImage, scaledTo newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize,true,1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }

    func pixelValues(fromCGImage imageRef: CGImage?) -> [UInt8]?{
        let bitmap:BMImage = BMImage(cgImage: imageRef!)
        let IamgeByteData = bitmap.getPixelBytes()
        var bmpByteData:[UInt8] = [0x42,0x4D]   //'BM'
        bmpByteData += [0x3E, 0x04, 0x00, 0x00, 0x00, 0x00] //4바이트 파일크가 2바이트 bfReserved1
        bmpByteData += [0x00, 0x00, 0x3E, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00] //2바이트 bfReserved2 //4바이트  비트맵데이터시작위치 //4바이트 비트맵 헤더 정보 사이즈
        bmpByteData += [0x80, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00] //4바이트 이미지 가로크기 //4바이트 비트맵 세로 크기
        bmpByteData += [0x01, 0x00, 0x01, 0x00 ] //2바이트 사용하는 색상판수 항상 1 //2바이트 픽셀 하나를 표현하는 비트 수
        bmpByteData += [0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00] //4바이트 항상 0 //4바이트 픽셀데이터 크기
        bmpByteData += [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] //4바이트 가로 해상도 //4바이트 세로 해상도
        bmpByteData += [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] //4바이트 사용되는 색상수 //4바이트 색상 인덱스
        bmpByteData += [0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00]
                bmpByteData += IamgeByteData
        return bmpByteData
    }
    
    override func draw(_ rect: CGRect) {
        //그림을 글는 곳
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 라인의 색, 라인의 굵기, 라인의 끝나는 부분처리
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(5)
        context.setLineCap(.butt)
        
        // 라인을 그린다
        lines.forEach{ (line) in
            for (i, p) in line.enumerated() {
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
            }
        }
        context.strokePath()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchEnd = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchEnd = false
        touchScreen = true
        endCheck = 0
        lines.append([CGPoint]())
    }
    
    //터치스크린으로 움직인다
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchEnd = false
        guard let point = touches.first?.location(in: nil) else {
            return
        }

        guard var lastLine = lines.popLast() else { return }
        lastLine.append(point)
        
        lines.append(lastLine)

        setNeedsDisplay()
    }
}

class SignatureController: UIViewController {
    var mpaySdk:PaySdk = PaySdk()
    var mKakaoSdk:KaKaoPaySdk = KaKaoPaySdk()
    var connectionTimeout:Timer?
    let canvas = Canvas()
    var canvasImage = [UInt8]()
    public var sdk = ""
    public var money = ""
    public var iscancel = false
    
    var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "서명을 해주세요"
        label.textAlignment = .center
        label.baselineAdjustment = .alignBaselines
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    var countLabel: JLabel = {
        var label = JLabel()
        label.text = "30"
        label.textAlignment = .center
        label.baselineAdjustment = .alignBaselines
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    var moneyLabel: JLabel = {
        var label = JLabel()
        label.text = "30"
        label.textColor = define.txt_title_orange
        label.textAlignment = .center
        label.baselineAdjustment = .alignBaselines
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    let saveButton: JButton = {
        let button = JButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.addTarget(SignatureController.self, action: #selector(handleSave(_:event:)), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleSave(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        print("save draw")
        moneyLabel.text = ""
        countLabel.text = ""
        titleLabel.text = ""
        self.connectionTimeout?.invalidate()
        self.connectionTimeout = nil
        canvasImage = canvas.save()
        self.dismiss(animated: true) { [self] in
            if canvas.touchScreen {
                if sdk == "KaKaoPaySdk" {mKakaoSdk.Result_SignPad(signCheck: true, signImage: canvasImage)}
                else {   mpaySdk.Result_SignPad(signCheck: true, signImage: canvasImage)}
            }
            else {
                if sdk == "KaKaoPaySdk" {mKakaoSdk.Result_SignPad(signCheck: false, signImage: canvasImage)}
                else {   mpaySdk.Result_SignPad(signCheck: false, signImage: canvasImage)}
             
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas.backgroundColor = .white
        setupLayout()
    }
    
    fileprivate func setupLayout() {
        let stackView_label = UIStackView(arrangedSubviews: [
            titleLabel
        ])
        stackView_label.distribution = .fillEqually
        view.addSubview(stackView_label)
        
        let stackView_Countlabel = UIStackView(arrangedSubviews: [
            countLabel
        ])
        stackView_Countlabel.distribution = .fillEqually
        view.addSubview(stackView_Countlabel)
        
        let stackView_Moneylabel = UIStackView(arrangedSubviews: [
            moneyLabel
        ])
        stackView_Moneylabel.distribution = .fillEqually
        view.addSubview(stackView_Moneylabel)
        
        let stackView_btn = UIStackView(arrangedSubviews: [
            saveButton
        ])
        stackView_btn.distribution = .fillEqually
        view.addSubview(stackView_btn)
        
        //최상단에 만든다. leadingAnchor = left. trailingAnchor = right. bottomAnchor = bottom. topAnchor = top.
        stackView_label.translatesAutoresizingMaskIntoConstraints = false
        stackView_label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        stackView_label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        stackView_label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        
        stackView_Countlabel.translatesAutoresizingMaskIntoConstraints = false
        stackView_Countlabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        stackView_Countlabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        stackView_Countlabel.topAnchor.constraint(equalTo: stackView_label.topAnchor, constant: 30).isActive = true

        //하단에 만든다
        stackView_btn.translatesAutoresizingMaskIntoConstraints = false
        stackView_btn.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView_btn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        stackView_btn.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView_btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stackView_Moneylabel.translatesAutoresizingMaskIntoConstraints = false
        stackView_Moneylabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        stackView_Moneylabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        stackView_Moneylabel.bottomAnchor.constraint(equalTo: stackView_btn.topAnchor, constant: -50).isActive = true
    }
    
    override func loadView() {
        self.view = canvas
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if iscancel {
            moneyLabel.text = "결제금액 : -" + Utils.PrintMoney(Money: money) + "원"
        } else {
            moneyLabel.text = "결제금액 : " + Utils.PrintMoney(Money: money) + "원"
        }

        var countDown:Int = 30
        var _interv:Int = 0
        self.connectionTimeout = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [self] timer in
            _interv += 1
            if _interv == 2 {
                _interv = 0
                countDown -= 1
                countLabel.text = String(countDown)
            }
            if canvas.touchScreen {
                saveButton.Title(타이틀: "확인")
            }
            if canvas.touchEnd {
                canvas.endCheck += 1
                if canvas.endCheck == 5 {
                    self.connectionTimeout?.invalidate()
                    canvasImage = canvas.save()
                    self.dismiss(animated: true) { [self] in
                        if canvas.touchScreen {
                            if sdk == "KaKaoPaySdk" {mKakaoSdk.Result_SignPad(signCheck: true, signImage: canvasImage)}
                            else {   mpaySdk.Result_SignPad(signCheck: true, signImage: canvasImage)}
                        }
                        else {
                            if sdk == "KaKaoPaySdk" {mKakaoSdk.Result_SignPad(signCheck: false, signImage: canvasImage)}
                            else {   mpaySdk.Result_SignPad(signCheck: false, signImage: canvasImage)}
                        }
                    }
                }
                if countDown == 0 {
                    self.connectionTimeout?.invalidate()
                    canvasImage = canvas.save()
                    self.dismiss(animated: true) { [self] in
                        if canvas.touchScreen {
                            if sdk == "KaKaoPaySdk" {mKakaoSdk.Result_SignPad(signCheck: true, signImage: canvasImage)}
                            else {   mpaySdk.Result_SignPad(signCheck: true, signImage: canvasImage)}
                        }
                        else {
                            if sdk == "KaKaoPaySdk" {mKakaoSdk.Result_SignPad(signCheck: false, signImage: canvasImage)}
                            else {   mpaySdk.Result_SignPad(signCheck: false, signImage: canvasImage)}
                        }
                    }
                }
            } else {
                if countDown == 0 {
                    self.connectionTimeout?.invalidate()
                    canvasImage = canvas.save()
                    self.dismiss(animated: true) { [self] in
                        if canvas.touchScreen {
                            if sdk == "KaKaoPaySdk" {mKakaoSdk.Result_SignPad(signCheck: true, signImage: canvasImage)}
                            else {   mpaySdk.Result_SignPad(signCheck: true, signImage: canvasImage)}
                        }
                        else {
                            if sdk == "KaKaoPaySdk" {mKakaoSdk.Result_SignPad(signCheck: false, signImage: canvasImage)}
                            else {   mpaySdk.Result_SignPad(signCheck: false, signImage: canvasImage)}
                        }
                    }
                }
            }
        })
    }
}
