//
//  CatAnimationViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2021/05/26.
//

import Foundation
import UIKit
import SwiftUI

class CatAnimationViewController: UIViewController {
    var mCatSdk:CatSdk = CatSdk.instance
    var catlistener:CatResultDelegate?
    var connectionTimeout:Timer?
    
    @IBOutlet weak var mbtnCancel: UIButton!
    
    @IBOutlet weak var mTitleMsg: UILabel!
    @IBOutlet weak var mCardImg: UIImageView!
    @IBOutlet weak var mCountLayerStack: UIStackView!
    @IBOutlet weak var mNavigationBar: UINavigationBar!
    
    @IBOutlet weak var mMoneyStack: UIStackView!
    
    @IBOutlet weak var mTotalMoney: UILabel!
    @IBOutlet weak var mCountImg: UIImageView!
    var countdownMsg:String = "30"
    public var cardMsg:String = ""
    public var totalMoney:String = ""
    public var iscancel = false
    var count = 30
    
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
        
        mbtnCancel.isHidden = false
        mbtnCancel.alpha = 1.0
        

        countdownMsg = "30"
        count = Int(countdownMsg) ?? 30
        
        if iscancel {
            mTotalMoney.text = "-" + Utils.PrintMoney(Money: totalMoney) + " 원"
        } else {
            mTotalMoney.text = Utils.PrintMoney(Money: totalMoney) + " 원"
        }
 
        
        mTitleMsg.text = cardMsg

        connectionTimeout = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        connectionTimeout?.tolerance = 0.1
        RunLoop.current.add(connectionTimeout!, forMode: .common)
        
        CircularShape(Msg: cardMsg)

    }
    
    func cardChangeImage(카드 _card:String) {
        var uiImage = ""
        switch(_card) {
        case "카드":
            uiImage = "cat_ic"
            break
        case "마그네틱":
            uiImage = "cat_cash"
            break
        case "MSR":
            uiImage = "cat_ms"
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

    @objc func fireTimer() {
        print(count)
        count -= 1
//        mCountMsg.text = String(count)
        if count == 0 {
            connectionTimeout?.invalidate()
            connectionTimeout = nil
            if mCountImg.isAnimating {
                mCountImg.stopAnimating()
            }
            dismiss(animated: true){ [self] in
//                var resDataDic:[String:String] = [:]
//                resDataDic["Message"] = "결제를 취소하였습니다"
                mCatSdk.Cat_SendCancelCommandE(메세지: "결제를 취소하였습니다")
//                catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
            }
        }
    }
    
    func CircularShape(Msg _msg:String) {
        mTitleMsg.text = _msg
        if _msg.contains("서버") {    //서버전송시
            mCardImg.isHidden = true
            mCardImg.alpha = 0.0
            mNavigationBar.topItem?.title = "결제"
            
            mbtnCancel.isHidden = true
            mbtnCancel.alpha = 0.0
        } else if _msg.contains("마그네틱") {   //폴백거래
            mCardImg.image = #imageLiteral(resourceName: "cat_cash")
            mCardImg.contentMode = .scaleAspectFit
            mNavigationBar.topItem?.title = "폴백결제"
            cardChangeImage(카드: "마그네틱")
        } else if _msg.contains("MSR") {    //msr거래
            mCardImg.image = #imageLiteral(resourceName: "cat_cash")
            mCardImg.contentMode = .scaleAspectFit
            mNavigationBar.topItem?.title = "MSR결제"
            cardChangeImage(카드: "MSR")
        } else {    //일반신용
            mCardImg.image = #imageLiteral(resourceName: "cat_ic")
            mCardImg.contentMode = .scaleAspectFit
            mNavigationBar.topItem?.title = "카드결제"
            cardChangeImage(카드: "카드")
        }
        
        if mCountImg.isAnimating {
            mCountImg.stopAnimating()
        }

        mCountImg.animationImages = animatedImages(Count: Int(countdownMsg)!)
        mCountImg.animationDuration = TimeInterval(Int(countdownMsg)! + 3)
//        mCountImg.animationRepeatCount = 1
        mCountImg.image = mCountImg.animationImages?.last
        if !mCountImg.isAnimating {
            mCountImg.startAnimating()
        }

    }
    
    
    @IBAction func click_btn_cancel(_ sender: UIButton, forEvent event: UIEvent) {
        connectionTimeout?.invalidate()
        connectionTimeout = nil
        if !mCountImg.isAnimating {
            mCountImg.startAnimating()
        }
        dismiss(animated: true){ [self] in
//            var resDataDic:[String:String] = [:]
//            resDataDic["Message"] = "결제를 취소하였습니다"
            mCatSdk.Cat_SendCancelCommandE(메세지: "결제를 취소하였습니다")
//            catlistener?.onResult(CatState: .ERROR, Result: resDataDic)
        }
    }
    
    public func GoToReceiptSwiftUI() {
        DispatchQueue.main.async {[self] in
            let nextVC = UIHostingController(rootView: ReceiptSwiftUI())
            if String(describing: self.catlistener).contains("Credit") {
                nextVC.rootView.setData(영수증데이터: sqlite.instance.getTradeLastData(), 뷰컨트롤러: "신용", 전표번호: String(sqlite.instance.getTradeList().count))
            } else  {
                nextVC.rootView.setData(영수증데이터: sqlite.instance.getTradeLastData(), 뷰컨트롤러: "현금", 전표번호: String(sqlite.instance.getTradeList().count))
            }
          
            nextVC.modalPresentationStyle = .fullScreen
            self.connectionTimeout?.invalidate()
            self.connectionTimeout = nil
            mCatSdk.Clear()
            present(nextVC, animated: true, completion: nil)
        }
        
    }
    
    public func GoToReceiptEasySwiftUI() {
        DispatchQueue.main.async {[self] in
            let nextVC = UIHostingController(rootView: ReceiptSwiftUI())
            nextVC.rootView.setData(영수증데이터: sqlite.instance.getTradeLastData(), 뷰컨트롤러: "간편결제", 전표번호: String(sqlite.instance.getTradeList().count))
            nextVC.modalPresentationStyle = .fullScreen
            self.connectionTimeout?.invalidate()
            self.connectionTimeout = nil
            mCatSdk.Clear()
            self.present(nextVC, animated: true, completion: nil)
        }
    }
}
