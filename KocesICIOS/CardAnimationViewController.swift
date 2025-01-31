//
//  CardAnimationViewController.swift
//  osxapp
//
//  Created by 신진우 on 2021/02/08.
//

import Foundation
import UIKit
import SwiftUI
/**
 메세지박스로 카드읽기해주세요를 뷰컨트롤러로 바꾼다
 */
class CardAnimationViewController: UIViewController {
    var mpaySdk:PaySdk = PaySdk.instance
    var paylistener: PayResultDelegate?
    var connectionTimeout:Timer?
    
    @IBOutlet weak var mTitleMsg: UILabel!
    @IBOutlet weak var mCardImg: UIImageView!
    @IBOutlet weak var mCountLayerStack: UIStackView!
    @IBOutlet weak var mNavigationBar: UINavigationBar!
    
    @IBOutlet weak var mMoneyStack: UIStackView!
    
    @IBOutlet weak var mTotalMoney: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var mCountImg: UIImageView!
    var countdownMsg:String = "20"
    public var cardMsg:String = ""
    public var totalMoney:String = ""
    
    let trackShape = CAShapeLayer()
    let shape = CAShapeLayer()
    var circlePath = UIBezierPath()
    var animation = CABasicAnimation(keyPath: "strokeEnd")
    
    var count = 20

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CardViewInit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.connectionTimeout?.invalidate()
        self.connectionTimeout = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func animatedImages(Count _count:Int) -> [UIImage] {
        var countImg = _count
        if countImg > 99 {
            countImg = 99
        }
        var images = [UIImage]()
        for i in 0 ... countImg {
            images.append(UIImage(named: "\(i)")!)
        }
        images.reverse()

        return images
    }

    public func CardViewInit() {
        mMoneyStack.roundCorners(corners: [.allCorners], radius: 10)
        self.connectionTimeout?.invalidate()
        self.connectionTimeout = nil
        UISetting.navigationTitleSetting(navigationBar: mNavigationBar)
        
        btnCancel.isHidden = false
        btnCancel.alpha = 1.0

        countdownMsg = Setting.shared.mDgTmout
        count = Int(countdownMsg) ?? 20
        
        mTotalMoney.text = Utils.PrintMoney(Money: totalMoney) + " 원"
        
        if (!cardMsg.contains("서버")) {
            countdownMsg = "20"
            count = 20
        }
        mTitleMsg.text = cardMsg

        count = count - 1
        connectionTimeout = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        connectionTimeout?.tolerance = 0.1
        RunLoop.current.add(connectionTimeout!, forMode: .common)

        CircularShape(Msg: cardMsg)
    }
    
    @objc func fireTimer() {
        debugPrint("애니메이션 타임:\(count)")
        count -= 1
        if count == 0 {
            mCountImg.stopAnimating()
            connectionTimeout?.invalidate()
            dismiss(animated: true){ [self] in
                if KocesSdk.instance.bleIsConnected() {
                    if (KocesSdk.instance.mBleConnectedName.contains(define.bleName) || KocesSdk.instance.mBleConnectedName.contains(define.bleNameNew)) {
                        KocesSdk.instance.SendESC()
                    } else {
                        KocesSdk.instance.DeviceInit(VanCode: "99")
                    }
                }
                var resDataDic:[String:String] = [:]
                resDataDic["Message"] = "결제를 취소하였습니다"
                paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
            }
        }
    }
    
    func CircularShape(Msg _msg:String) {
        if _msg.contains("서버") {    //서버전송시
            mCardImg.isHidden = true
            mCardImg.alpha = 0.0
            mNavigationBar.topItem?.title = "결제"
            
            btnCancel.isHidden = true
            btnCancel.alpha = 0.0

        } else if _msg.contains("마그네틱") {   //폴백거래
            mCardImg.image = #imageLiteral(resourceName: "swipe_card")
            mCardImg.contentMode = .scaleAspectFit
            mNavigationBar.topItem?.title = "폴백결제"
            cardChangeImage(카드: "마그네틱")
        } else if _msg.contains("MSR") {    //msr거래
            mCardImg.image = #imageLiteral(resourceName: "swipe_card")
//            mCardImg.heightAnchor.constraint(equalToConstant: mCardImg.frame.width).isActive = true
            mCardImg.contentMode = .scaleAspectFit
            mNavigationBar.topItem?.title = "MSR결제"
            cardChangeImage(카드: "MSR")
        } else {    //일반신용
            mCardImg.image = #imageLiteral(resourceName: "CARD_INSERT4")
            mCardImg.contentMode = .scaleAspectFit
            mNavigationBar.topItem?.title = "카드결제"
            cardChangeImage(카드: "카드")
        }
        if mCountImg.isAnimating {
            mCountImg.stopAnimating()
        }

        mCountImg.animationImages = animatedImages(Count: Int(countdownMsg)!)
        mCountImg.animationDuration = TimeInterval(Int(countdownMsg)!)
        mCountImg.image = mCountImg.animationImages?.last
        if !mCountImg.isAnimating {
            mCountImg.startAnimating()
        }
    }
    
    func cardChangeImage(카드 _card:String) {
        var uiImage = ""
        switch(_card) {
        case "카드":
            uiImage = "reader_ic2_rf"
            break
        case "마그네틱":
            uiImage = "reader_fallback"
            break
        case "MSR":
            uiImage = "reader_cash"
            break
        default:
            break
        }
        guard
            let gifURL = Bundle.main.url(forResource: uiImage, withExtension: "gif"),
            let gifData = try? Data(contentsOf: gifURL),
            let source = CGImageSourceCreateWithData(gifData as CFData, nil)
        else { return }
        let frameCount = CGImageSourceGetCount(source)
        var images = [UIImage]()

        (0..<frameCount)
            .compactMap { CGImageSourceCreateImageAtIndex(source, $0, nil) }
            .forEach { images.append(UIImage(cgImage: $0)) }

        mCardImg.animationImages = images
        mCardImg.animationDuration = TimeInterval(frameCount) * 1 // 0.05는 임의의 값
        mCardImg.animationRepeatCount = 0
        mCardImg.startAnimating()
    }
    
    @IBAction func clkck_btn_cancel(_ sender: UIButton, forEvent event: UIEvent) {
        if mCountImg.isAnimating {
            mCountImg.stopAnimating()
        }

        connectionTimeout?.invalidate()
        connectionTimeout = nil
        
        dismiss(animated: true){ [self] in
            if KocesSdk.instance.bleIsConnected() {
                if (KocesSdk.instance.mBleConnectedName.contains(define.bleName) ||
                    KocesSdk.instance.mBleConnectedName.contains(define.bleNameNew)) {
                    KocesSdk.instance.SendESC()
                } else {
                    KocesSdk.instance.DeviceInit(VanCode: "99")
                }
            }
  
            var resDataDic:[String:String] = [:]
            resDataDic["Message"] = "결제를 취소하였습니다"
            paylistener?.onPaymentResult(payTitle: .ERROR, payResult: resDataDic)
        }
    }
    
    public func GoToReceiptSwiftUI() {
        if KocesSdk.instance.bleIsConnected() {
            KocesSdk.instance.DeviceInit(VanCode: "99")
        }
        
        let nextVC = UIHostingController(rootView: ReceiptSwiftUI())
        if String(describing: paylistener).contains("Credit") {
            nextVC.rootView.setData(영수증데이터: sqlite.instance.getTradeLastData(), 뷰컨트롤러: "신용", 전표번호: String(sqlite.instance.getTradeList().count))
        } else  {
            nextVC.rootView.setData(영수증데이터: sqlite.instance.getTradeLastData(), 뷰컨트롤러: "현금", 전표번호: String(sqlite.instance.getTradeList().count))
        }
      
        nextVC.modalPresentationStyle = .fullScreen
        self.connectionTimeout?.invalidate()
        self.connectionTimeout = nil
        mpaySdk.Clear()
        present(nextVC, animated: true, completion: nil)
    }
    
    public func GoToReceiptEasyPaySwiftUI() {
        if KocesSdk.instance.bleIsConnected() {
            KocesSdk.instance.DeviceInit(VanCode: "99")
        }
        
        let nextVC = UIHostingController(rootView: ReceiptEasyPaySwiftUI())
        nextVC.rootView.setData(영수증데이터: sqlite.instance.getTradeLastData(), 뷰컨트롤러: "간편결제", 전표번호: String(sqlite.instance.getTradeList().count))
        nextVC.modalPresentationStyle = .fullScreen
        self.connectionTimeout?.invalidate()
        self.connectionTimeout = nil
        mpaySdk.Clear()
        present(nextVC, animated: true, completion: nil)
    }
    
}
extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
