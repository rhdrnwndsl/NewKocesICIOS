//
//  WebToAppResultViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2021/06/16.
//

import Foundation
import UIKit

class WebToAppResultViewController: UIViewController {
    
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var mMessage: UILabel!
    
    @IBOutlet weak var mBox: UIStackView!
    //웹컨트롤러를 열때 타이틀 이름과 메세지를 작성한다
    
    @IBOutlet weak var mGuideMessage: UILabel!
    public var mTitleText = ""
    public var mMessageText: Dictionary<String, String> = [:]
    public var mLabelText = ""
    public var WebToAppSendDataFail:Int = 0
    var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "요청을 완료했습니다. 좌측 상단의 ◀Safari 를 눌러주세요."
        label.numberOfLines = 3
        label.textAlignment = .center
        label.baselineAdjustment = .alignBaselines
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        initRes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        //등록된 노티 전체 제거
        NotificationCenter.default.removeObserver(self)
    }
    
    func initRes() {
        mTitle.text = mTitleText
        var result = ""
        var count = 0

        for (key,value) in mMessageText {
            if key == "AnsCode" {
                if value == "0000" {
                    mTitle.text = "정상승인"
                } else {
                    mTitle.text = "승인오류"
                }
            }
        }
 
        for (key,value) in mMessageText {
            if key == "Message" {
                result += value
            }
        }
        
        
        mMessage.text = result
        
        mGuideMessage.text = mLabelText == "" ? "요청을 완료했습니다. 좌측 상단의 ◀Safari 를 눌러주세요.":mLabelText
        
//        if WebToAppSendDataFail == 1 {
//            mMessage.text = "연동데이터 전송 실패로 인해 거래를 취소하였습니다"
//        }
//        let window = UIApplication.shared.keyWindow
        let transparentView = UIView()
//        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        view.addSubview(transparentView)
        transparentView.translatesAutoresizingMaskIntoConstraints = false
        transparentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        transparentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        transparentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        transparentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        mBox.layer.borderWidth = 1.0  //테두리그리기
        mBox.layer.borderColor = define.layout_border_lightgrey.cgColor //테두리선색깔은 일반글자색깔과 동일하게
        mBox.layer.cornerRadius = 10  //모서리 둥글게
        
//        transparentView.alpha = 0.5
        
        
//        var frame = view.frame
//        var OffsetY: CGFloat  = 44
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            OffsetY = 24
//            titleLabel.font = .boldSystemFont(ofSize: 15)
//        } else {
//            OffsetY = 44
//            titleLabel.font = .boldSystemFont(ofSize: 20)
//        }
//        titleLabel.text = mLabelText == "" ? "요청을 완료했습니다. 좌측 상단의 ◀Safari 를 눌러주세요.":mLabelText
//        frame.origin = CGPoint(x: frame.origin.x, y: frame.origin.y - OffsetY)
//        frame.size = CGSize(width: frame.width, height: frame.height + OffsetY)
//        view.frame = frame
//
//        let stackView_label = UIStackView(arrangedSubviews: [UIView(),titleLabel, UIView(), UIView(), UIView(), UIView(), UIView(), UIView()])
//        stackView_label.distribution = .fillEqually
//        stackView_label.contentMode = .scaleAspectFill
//        stackView_label.axis = .vertical
//        view.addSubview(stackView_label)
//
//        stackView_label.backgroundColor = .lightText
////        stackView_label.alpha = 0.5
//        stackView_label.layer.cornerRadius = 12
//        stackView_label.layer.borderWidth = 1
//        stackView_label.layer.borderColor = UIColor.label.cgColor //테두리선색깔은 일반글자색깔과 동일하게
//        stackView_label.translatesAutoresizingMaskIntoConstraints = false
//        stackView_label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
//        stackView_label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
//        stackView_label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: OffsetY).isActive = true
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        self.dismiss(animated: false) { [self] in
            var storyboard:UIStoryboard?
            if UIDevice.current.userInterfaceIdiom == .phone {
                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            } else {
                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
            }
            let mainTabBarController = storyboard!.instantiateViewController(identifier: "TabBar")
            mainTabBarController.modalPresentationStyle = .fullScreen
            self.present(mainTabBarController, animated: true, completion: nil)
            NotificationCenter.default.removeObserver(self)
        }
    }
}
