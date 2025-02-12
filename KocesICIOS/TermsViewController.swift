//
//  TermsViewController.swift
//  osxapp
//
//  Created by 신진우 on 2021/03/04.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import CoreBluetooth

class TermsViewController: UIViewController, CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("unknown")
            AlertPermissionBox(title: "권한실패", message: "블루투스 권한 확인 중 알 수 없는 오류로 실패. 설정에서 권한을 부여해 주십시오.", text: "확인")
        case .resetting:
            print("restting")
            AlertPermissionBox(title: "권한실패", message: "블루투스 권한 확인 중 블루투스 리셋으로 인한 실패. 설정에서 권한을 부여해 주십시오.", text: "확인")
        case .unsupported:
            print("unsupported")
            AlertPermissionBox(title: "권한실패", message: "블루투스 권한 확인 실패. 블루투스를 지원하지 않는 모델입니다.", text: "확인")
        case .unauthorized:
            print("unauthorized")
            AlertPermissionBox(title: "권한실패", message: "블루투스 권한 확인 실패. 사용자가 허락하지 않았습니다. 설정에서 권한을 부여해 주십시오.", text: "확인")
        case .poweredOff:
            print("power Off")
            AlertPermissionBox(title: "권한실패", message: "블루투스 권한 확인 실패. 블루투스가 꺼져 있습니다. 설정에서 권한을 확인 후 블루투스를 활성화해 주십시오.", text: "확인")
        case .poweredOn:
            print("power on")
            checkCameraPermission()
        @unknown default:
            fatalError()
        }
    }
    
    
    @IBOutlet weak var mTermsStackView: UIStackView!
    @IBOutlet weak var mPermissionsStackView: UIStackView!
    @IBOutlet weak var mSelectUIStackView: UIStackView!
    
    var mTermAgree:Bool = false //약관 동의 여부
    @IBOutlet weak var mTermsText: UITextView!  //약관설명문
    @IBOutlet weak var mbtnAgree: UIButton!     //동의 버튼
    
    @IBOutlet weak var mPermissionsText: UITextView!  //접근권한설명문
    @IBOutlet weak var mbtnPerAgree: UIButton!     //동의 버튼
    
    var centralManager: CBCentralManager!
    @IBOutlet weak var mTermsAgreeStack: UIStackView!   //약관동의체크버튼이 있는 스택

    @IBOutlet weak var mBtnAppToApp: UIButton!
    
    @IBOutlet weak var mBtnCommon: UIButton!
    
    @IBOutlet weak var mBtnProduct: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //이용약관을 체크하지 않았다면 약관으로 이동
        let APP_TERMS_CHECK:String = Setting.shared.getDefaultUserData(_key: define.APP_TERMS_CHECK)
        if APP_TERMS_CHECK.isEmpty {
            mPermissionsStackView.isHidden = true
            mPermissionsStackView.alpha = 0.0
            mSelectUIStackView.isHidden = true
            mSelectUIStackView.alpha = 0.0
            initTerms()
        } else {
            //권한설정을 완료하지 않았다면 권한설정으로 이동
            let APP_PERMISSION_CHECK:String = Setting.shared.getDefaultUserData(_key: define.APP_PERMISSION_CHECK)
            if APP_PERMISSION_CHECK.isEmpty {
                mTermsStackView.isHidden = true
                mTermsStackView.alpha = 0.0
                mSelectUIStackView.isHidden = true
                mSelectUIStackView.alpha = 0.0
                initPermissions()
            } else {
                let APP_UI_CHECK:String = Setting.shared.getDefaultUserData(_key: define.APP_UI_CHECK)
                if APP_UI_CHECK.isEmpty || APP_UI_CHECK == define.UIMethod.None.rawValue {
                    mPermissionsStackView.isHidden = true
                    mPermissionsStackView.alpha = 0.0
                    mTermsStackView.isHidden = true
                    mTermsStackView.alpha = 0.0
                    initPermissions()
                }
            }

        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.popViewController(animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initTerms() {
        mTermsText.layer.borderWidth = 1.0  //테두리그리기
        mTermsText.layer.borderColor = UIColor.label.cgColor //테두리선색깔은 일반글자색깔과 동일하게
        mTermsText.layer.cornerRadius = 10  //모서리 둥글게
        mTermsText.backgroundColor = .secondarySystemBackground

        //버튼들도 이런식으로 만들수 있다
        
        //약관설명문의 내용을 적는다
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 10
        paragraphStyle.headIndent = 10
        paragraphStyle.tailIndent = -10
        let attributedText = NSAttributedString(string: TermsText(), attributes: [.paragraphStyle : paragraphStyle])
        mTermsText.attributedText = attributedText
        mTermsText.font?.withSize(20)
        
        if !Setting.shared.getDefaultUserData(_key: define.APP_TERMS_CHECK).isEmpty {
            mTermAgree = true
            mbtnAgree.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            mTermsAgreeStack.isHidden = true
            mTermsAgreeStack.alpha = 0.0
        }
    }

    @IBAction func mBtnAgree_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let ImageAgree:UIImage = mbtnAgree.currentImage!
        
        if ImageAgree == UIImage(systemName: "square") {
            mTermAgree = true
            mbtnAgree.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        }
        else{
            mTermAgree = false
            mbtnAgree.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
    }
    
    //확인버튼 누르고 가맹점등록페이지로 이동한다
    @IBAction func click_btn_ok(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        if mTermAgree {
            Setting.shared.setDefaultUserData(_data: define.APP_TERMS_CHECK, _key: define.APP_TERMS_CHECK)
            //권한설정을 완료하지 않았다면 권한설정으로 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                mTermsStackView.isHidden = true
                mTermsStackView.alpha = 0.0
                mSelectUIStackView.isHidden = true
                mSelectUIStackView.alpha = 0.0
                mPermissionsStackView.isHidden = false
                mPermissionsStackView.alpha = 1.0
                initPermissions()
            }
        } else {
            AlertBox(title: "약관동의", message: "약관에 동의하지 않았습니다", text: "확인")
        }
    }
    
    func initPermissions() {
        mPermissionsText.layer.borderWidth = 1.0  //테두리그리기
        mPermissionsText.layer.borderColor = UIColor.label.cgColor //테두리선색깔은 일반글자색깔과 동일하게
        mPermissionsText.layer.cornerRadius = 10  //모서리 둥글게
        mPermissionsText.backgroundColor = .secondarySystemBackground
        
        //약관설명문의 내용을 적는다
        let paragraphStyle = NSMutableParagraphStyle()
    
        paragraphStyle.firstLineHeadIndent = 10
        paragraphStyle.headIndent = 10
        paragraphStyle.tailIndent = -10
        let attributedText = NSAttributedString(string: PermissionsText(), attributes: [.paragraphStyle : paragraphStyle])
        mPermissionsText.attributedText = attributedText
        mPermissionsText.font?.withSize(20)
    }
    
    //확인버튼 누르고 UI선택창을 표시하러 이동한다
    @IBAction func click_btn_per(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        checkBlePermission()
    }
    
    /** 1. 블루투스 권한 체크하는 곳 */
    func checkBlePermission() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /** 2. 카메라 권한 체크하는 곳 */
    func checkCameraPermission(){
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            if granted {
                print("Camera: 권한 허용")
                self.checkAlbumPermission()
            } else {
                print("Camera: 권한 거부")
                DispatchQueue.main.async() { [self] in
                    AlertPermissionBox(title: "권한실패", message: "바코드/QR 리딩을 위해 카메라 권한을 설정해야 합니다. 설정에서 권한을 허용해 주십시오.", text: "확인")
                }
 
            }
        })
     }
    
    /** 3. 갤러리 권한 체크하는 곳 */
    func checkAlbumPermission(){
        PHPhotoLibrary.requestAuthorization( { [self] status in
            switch status{
            case .authorized:
                print("Album: 권한 허용")
                Setting.shared.setDefaultUserData(_data: define.APP_PERMISSION_CHECK, _key: define.APP_PERMISSION_CHECK)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                    mTermsStackView.isHidden = true
                    mTermsStackView.alpha = 0.0
                    mPermissionsStackView.isHidden = true
                    mPermissionsStackView.alpha = 0.0
                    mSelectUIStackView.isHidden = false
                    mSelectUIStackView.alpha = 1.0
                    initUISelect()
                }
            case .denied:
                print("Album: 권한 거부")
                DispatchQueue.main.async() { [self] in
                    AlertPermissionBox(title: "권한실패", message: "영수증 이미지 저장을 위해 권한을 설정해야 합니다. 설정에서 권한을 허용해 주십시오.", text: "확인")
                }
            case .restricted, .notDetermined:
                print("Album: 선택하지 않음")
                DispatchQueue.main.async() { [self] in
                    AlertPermissionBox(title: "권한실패", message: "영수증 이미지 저장을 위해 권한을 설정해야 합니다. 설정에서 권한을 허용해 주십시오.", text: "확인")
                }
            default:
                break
            }
        })
    }
    
    func initUISelect() {
        mBtnAppToApp.setImage(UIImage(named: "apptoapp_up"), for: .normal)
        mBtnAppToApp.setImage(UIImage(named: "apptoapp_dn"), for: .highlighted)
        mBtnCommon.setImage( UIImage(named: "common_up"), for: .normal)
        mBtnCommon.setImage( UIImage(named: "common_dn"), for: .highlighted)
        mBtnProduct.setImage(UIImage(named: "product_up") , for: .normal)
        mBtnProduct.setImage(UIImage(named: "product_dn") , for: .highlighted)
    }
    
    @IBAction func clicked_apptoapp(_ sender: Any, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            Setting.shared.setDefaultUserData(_data: define.UIMethod.AppToApp.rawValue, _key: define.APP_UI_CHECK)
            var storyboard:UIStoryboard?
            if UIDevice.current.userInterfaceIdiom == .phone {
                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            } else {
                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
            }
            let mainTabBarController = storyboard!.instantiateViewController(identifier: "TabBar")
            mainTabBarController.modalPresentationStyle = .fullScreen
            self.present(mainTabBarController, animated: true, completion: nil)
        }
    }
    
    @IBAction func clicked_common(_ sender: Any, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            Setting.shared.setDefaultUserData(_data: define.UIMethod.Common.rawValue, _key: define.APP_UI_CHECK)
            var storyboard:UIStoryboard?
            if UIDevice.current.userInterfaceIdiom == .phone {
                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            } else {
                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
            }
            let mainTabBarController = storyboard!.instantiateViewController(identifier: "TabBar")
            mainTabBarController.modalPresentationStyle = .fullScreen
            self.present(mainTabBarController, animated: true, completion: nil)
        }
    }
    
    @IBAction func clicked_product(_ sender: Any, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            Setting.shared.setDefaultUserData(_data: define.UIMethod.Product.rawValue, _key: define.APP_UI_CHECK)
            var storyboard:UIStoryboard?
            if UIDevice.current.userInterfaceIdiom == .phone {
                storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            } else {
                storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
            }
            let mainTabBarController = storyboard!.instantiateViewController(identifier: "TabBar")
            mainTabBarController.modalPresentationStyle = .fullScreen
            self.present(mainTabBarController, animated: true, completion: nil)
        }
    
    }
    
    
    ///경고 박스
    func AlertBox(title : String, message : String, text : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    ///경고 박스
    func AlertPermissionBox(title : String, message : String, text : String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okBtn = UIAlertAction(title: text, style: .default, handler: {(action) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
//                            self.checkCameraPermission()
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) {success in
                        UIApplication.shared.perform (#selector (NSXPCConnection.suspend))
                    }
                }
            })
            alert.addAction(okBtn)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension TermsViewController {
    //약관설명문의 내용을 정의한다
    func TermsText() -> String {
        
        let _terms = 
        "한국신용카드결제(주)는 정보통신망 이용촉진 및 정보보호 등에 관한 법률, 개인정보보호법 등 관련 법령에 따라 정보주체의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 다음과 같이 개인정보 처리방침을 수립 · 공개합니다.\n" +
        "\n" +
        "1. 수집하는 개인정보 항목 및 방법\n" +
        "\n" +
        "한국신용카드결제(주)는 회원가입, 상담, 서비스 제공 등을 위해 아래와 같은 개인정보를 수집하고 있습니다.\n" +
        "\n" +
        "A. VAN 서비스(신용카드/현금영수증 중계 서비스 등)\n" +
        "① 개인식별 정보: 신용카드번호, 고유 식별정보, 휴대전화번호, 계좌번호\n" +
        "② 가맹점 정보 :  대표자명, 사업장명, 사업자등록번호, 사업장 주소, 전화번호\n" +
        "③ 거래정보 : 매출정보(신용, 체크, 직불, 상품권, 현금, 현금IC 등), 멤버십(통신사 멤버십 등) 거래내역\n" +
        "\n" +
        "B. KCS 관리전산\n" +
        "① 개인식별 정보 : 성명, 로그인 ID, 비밀번호\n" +
        "② 가맹점 정보 : 대표자명, 사업장명, 사업자등록번호, 사업장주소, 전화번호\n" +
        "③ 거래정보 : 매출정보(신용, 체크, 직불, 상품권, 현금, 현금IC 등), 멤버십(통신사 멤버십 등) 거래내역\n" +
        "\n" +
        "또한, 서비스 이용과정이나 서비스 처리 과정에서 아래와 같은 정보들이 자동 또는 수동으로 생성되어 수집될 수 있습니다.\n" +
        "※ 서비스 이용기록, 접속 로그, 쿠키 등\n" +
        "\n" +
        "한국신용카드결제(주)는 다음과 같은 방법으로 개인정보를 수집합니다.\n" +
        "\n" +
        "- 홈페이지, 서면양식, 전화/팩스를 통한 회원가입\n" +
        "\n" +
        "2. 개인정보의 수집 및 이용 목적\n" +
        "\n" +
        "한국신용카드결제(주)는 수집한 개인정보를 다음의 목적을 위해 활용합니다.\n" +
        "\n" +
        "▶ 서비스 제공에 관한 계약 이행 및 서비스 제공에 따른 요금정산\n" +
        "▶ 회원 관리 : 회원제 서비스 이용에 따른 본인확인, 개인식별, 불량회원의 부정 이용 방지와 비인가 사용 방지, 가입 의사 확인, 연령확인, 불만처리 등 민원처리, 공지사항 전달\n" +
        "\n" +
        "3. 개인정보의 보유 및 이용 기간\n" +
        "\n" +
        "한국신용카드결제(주)는 원칙적으로 개인정보 수집 및 이용목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다.\n" +
        "단, 다음의 정보에 대해서는 아래의 이유로 명시한 기간 동안 보존합니다.\n" +
        "\n" +
        "보유 정보 / \t사유 / \t보유 기간\n" +
        "- 웹사이트 방문 기록 / \t통신비밀보호법 / \t3개월\n" +
        "- 본인확인에 의한 기록 / \t정보통신망 이용 촉진 및 정보보호 등에 관한 법률 / \t6개월\n" +
        "- 소비자의 불만 또는 분쟁 처리에 관한 기록 / \t전자상거래 등에서의 소비자보호에 관한 법률 / \t3년\n" +
        "- 계약 또는 청약철회 등에 관한 기록 / \t전자상거래 등에서의 소비자보호에 관한 법률 / \t5년\n" +
        "- 대금 결제 및 재화 등의 공급에 관한 기록 / \t전자상거래 등에서의 소비자보호에 관한 법률 / \t5년\n" +
        "\n" +
        "\n" +
        "4. 개인정보의 파기절차 및 방법\n" +
        "\n" +
        "한국신용카드결제(주)는 원칙적으로 개인정보 수집 및 이용 목적이 달성된 후에는 해당 정보를 지체없이 파기합니다.\n" +
        "파기절차 및 방법은 다음과 같습니다.\n" +
        "\n" +
        "① 파기절차\n" +
        "고객님이 회원가입 등을 위해 입력하신 정보는 목적이 달성된 후 별도의 DB로 옮겨져(종이의 경우 별도의 서류함) 내부 방침 및 기타 관련 법령에 의한 정보보호 사유에 따라(보유 및 이용기간 참조) 일정 기간 저장된 후 파기됩니다. 별도 DB로 옮겨진 개인정보는 법률에 의한 경우가 아니고서는 보유 목적 이외의 다른 목적으로 이용되지 않습니다.\n" +
        "\n" +
        "② 파기방법\n" +
        "- 전자적 파일형태로 저장된 개인정보는 기록을 재생할 수 없는 기술적 방법을 사용하여 삭제합니다.\n" +
        "- 종이에 출력된 개인정보는 분쇄기로 분쇄하거나 소각을 통하여 파기합니다.\n" +
        "\n" +
        "5. 개인정보의 제3자 제공\n" +
        "\n" +
        "① 한국신용카드결제㈜는 고객님의 개인정보를 '개인정보의 수집 및 이용 목적'에서 고지한 범위 내에서 사용하며, 동 범위를 초과하여 이용하거나 외부에 공개 또는 제공하지 않습니다. 다만, 아래의 경우에는 예외로 합니다.\n" +
        "\n" +
        "- 정보주체가 사전에 동의한 경우\n" +
        "- 서비스 제공에 따른 요금 정산을 위하여 필요한 경우\n" +
        "- 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우\n" +
        "\n" +
        "제공 목적\t제공받는 자\t제공 정보\t보유 및 이용기간\n" +
        "신용카드 결제\t전 카드사, 직불카드 및 현금IC 처리 전 은행,\n" +
        "(주)한국스마트카드, (사)금융결제원\t거래 정보\t5년\n" +
        "멤버십 서비스\t전 카드사, SK텔레콤(주), (주)KT,\n" +
        "(주)LG유플러스, SK플래닛(주) 등\t거래 정보\t5년\n" +
        "현금영수증 발행\t국세청\t거래 정보, 고유식별 정보,\n" +
        "휴대전화번호, 카드번호\t5년\n" +
        "\n" +
        "\n" +
        "② 수탁업체는 위탁자인 한국신용카드결제(주)의 사전 승낙을 얻은 경우를 제외하고 위탁자와의 계약상의 권리와 의무의 전부 또는 일부를 제3자에게 양도하거나 재위탁할 수 없습니다. 수탁업체가 다른 제3의 회사와 수탁 계약을 할 경우에는 수탁업체는 해당 사실을 계약 체결 7일 이전에 위탁자인 한국신용카드결제(주)에게 통보하고 협의하도록 하고 있습니다.\n" +
        "\n" +
        "6. 개인정보처리 위탁\n" +
        "\n" +
        "① 한국신용카드결제(주)는 고객님의 동의 없이 고객님의 정보를 외부 업체에 위탁하지 않습니다. 향후 그러한 필요가 생길 경우, 위탁 대상자와 위탁업무 내용에 대해 고객님에게 통지하고 필요한 경우 사전 동의를 받도록 하겠습니다.\n" +
        "회사가 현재 고객님의 동의 하에 고객님의 정보를 위탁하는 외부 업체 및 위탁 내용은 다음과 같습니다.\n" +
        "\n" +
        "수탁 업체\t위탁업무 내용\t개인정보 이용기간\n" +
        "하모니테크\t매출전표 스캔\t위탁 계약 종료 시까지\n" +
        "모바일리더\t모바일 VAN서비스 신청서 작성\n" +
        "대리점\t가맹점 모집, 매출전표 수거\n" +
        "\n" +
        "\n" +
        "② 한국신용카드결제(주)는 위탁계약 체결 시 개인정보보호법 제26조 업무위탁에 따른 개인정보의 처리 제한에 따라 위탁업무 수행 목적 외 개인정보 처리금지, 기술적, 관리적 보호조치, 재 위탁 제한, 수탁자에 대한 관리 및 감독, 손해배상 등에 책임에 관한 사항을 계약서 등에 명시하고, 수탁자가 개인정보를 안전하게 처리하는지를 감독하고 있습니다.\n" +
        "\n" +
        "7. 이용자 및 법정대리인 권리와 그 행사방법\n" +
        "\n" +
        "① 고객님 및 법정대리인은 언제든지 등록된 자신 혹은 당해 만 14세 미만 아동의 개인정보를 조회하거나 수정할 수 있으며 가입해지를 요청할 수도 있습니다. 고객님 혹은 만 14세 미만 아동의 개인정보 조회/ 수정을 위해서는 '개인정보변경(또는 '회원정보수정' 등)’을, 가입해지(동의철회)를 위해서는 \"회원(고객)탈퇴\"를 클릭하여 본인 확인 절차를 거치신 후 직접 열람, 정정 또는 탈퇴가 가능합니다. 혹은 개인정보관리책임자에게 서면, 전화 또는 이메일로 연락하시면 지체 없이 조치하겠습니다.\n" +
        "\n" +
        "② 고객님이 개인정보의 오류에 대한 정정을 요청하신 경우, 회사는 정정을 완료하기 전까지 당해 개인정보를 이용 또는 제공하지 않습니다. 또한 잘못된 개인정보를 제3자 에게 이미 제공한 경우에는 정정 처리결과를 제3자에게 지체 없이 통지하여 정정이 이루어지도록 하겠습니다.\n" +
        "\n" +
        "③ 한국신용카드결제(주)는 이용자 혹은 법정 대리인의 요청에 의해 해지 또는 삭제된 개인정보를 \" 개인정보의 보유 및 이용기간\"에 명시된 바에 따라 처리하고 그 외의 용도로 열람 또는 이용할 수 없도록 처리하고 있습니다.\n" +
        "\n" +
        "8. 개인정보 자동 수집 장치의 설치, 운영 및 거부\n" +
        "\n" +
        "한국신용카드결제(주)는 이용자의 정보를 수시로 저장하고 찾아내는 쿠키(cookie)를 사용합니다. 쿠키란, 한국신용카드결제㈜의 웹사이트를 운영하는데 이용되는 서버가 이용자의 브라우저에 보내는 아주 작은 텍스트 파일로서 이용자의 컴퓨터 하드디스크에 저장됩니다. 한국신용카드결제㈜는 다음과 같은 목적을 위해 쿠키 등을 사용합니다.\n" +
        "\n" +
        "① 쿠키 등 사용 목적\n" +
        "- 한국신용카드결제(주)는 고객님께 적합하고 보다 유용한 서비스를 제공하기 위해서 쿠키를 이용하여 고객님의 아이디에 대한 정보를 회사 사이트에 접속하는 이용자의 브라우저에 고유한 쿠키를 부여함으로써 고객 및 비 고객의 사이트 이용빈도, 전체 이용자수 등과 같은 이용자 규모 파악에 이용됩니다. 또한 기타 이벤트나 설문조사에서 고객님의 참여 경력을 확인하기 위해서 쿠키를 이용하게 됩니다.\n" +
        "- 고객님은 쿠키 설치에 대한 선택권을 가지고 있습니다. 따라서, 귀하는 웹브라우저에서 옵션을 설정함으로써 모든 쿠키를 허용하거나, 쿠키가 저장될 때마다 확인을 거치거나, 아니면 모든 쿠키의 저장을 거부할 수도 있습니다.\n" +
        "\n" +
        "② 쿠키 설정 거부 방법\n" +
        "- 쿠키 설정을 거부하는 방법으로는 이용자가 사용하는 웹 브라우저의 옵션을 선택함으로써 모든 쿠키를 허용하거나 저장할 때마다 확인 또는 모든 쿠키의 저장을 거부할 수 있습니다.\n" +
        "- 설정방법 예(인터넷 익스플로러의 경우) : 웹 브라우저 상단의 도구 > 인터넷 옵션 > 개인정보\n" +
        "\n" +
        "※ 이용자가 쿠키 설치를 거부하였을 경우, 서비스 제공에 일부 어려움이 있을 수 있습니다.\n" +
        "\n" +
        "9. 개인정보의 안전성 확보 조치\n" +
        "\n" +
        "한국신용카드결제(주)는 다음과 같이 안전성 확보에 필요한 기술적, 관리적, 물리적 조치를 하고 있습니다.\n" +
        "\n" +
        "① 관리적 조치\n" +
        "한국신용카드결제(주)는 개인정보의 안전한 관리를 위하여 개인정보보호 정책 및 지침을 수립하여 담당자에 대한 정기적인 교육을 실시하고 있으며, 임직원에게 개인정보처리방침의 준수를 항상 강조하고 있습니다. 또한 개인정보취급자를 최소한의 인원으로 한정시키고 있고, 이를 위한 별도의 비밀번호를 부여하여 정기적으로 갱신하고 있습니다.\n" +
        "\n" +
        "② 기술적 보호조치\n" +
        "고객님의 개인정보는 비밀번호에 의해 보호되며, 중요한 데이터는 파일 및 전송데이터를 암호화하여 보호하고 있습니다.\n" +
        "한국신용카드결제(주)는 해킹이나 컴퓨터 바이러스 등에 의해 회원의 개인정보가 유출되거나 훼손되는 것을 막기 위해 최선을 다하고 있습니다. 개인정보의 훼손에 대비해서 자료를 수시로 백업하고 있고, 최신 백신프로그램을 이용하여 이용자들의 개인정보나 자료가 누출되거나 손상되지 않도록 방지하고 있으며, 암호화 통신 등을 통하여 네트워크상에서 개인정보를 안전하게 전송할 수 있도록 하고 있습니다. 그리고 침입차단시스템을 이용하여 외부로부터의 무단 접근을 통제하고 있으며, 기타 시스템적으로 보안성을 확보하기 위한 가능한 모든 기술적 장치를 갖추려 노력하고 있습니다.\n" +
        "\n" +
        "③ 물리적 보호조치\n" +
        "한국신용카드결제(주)는 출입통제 시스템 및 CCTV의 설치를 통하여 사내의 외부인 접근을 제한하고 있으며, 개인정보처리시스템을 운영하고 있는 전산실에 대해서는 담당자 이외의 출입을 엄격하게 통제하고 있습니다. 또한 개인정보를 포함하고 있는 서류 및 매체는 시건 장치가 구비된 캐비닛에 안전하게 관리하고 있습니다.\n" +
        "\n" +
        "10. 영상정보처리기기 설치 및 운영 관한 사항\n" +
        "\n" +
        "한국신용카드결제(주)의 영상정보처리기기 설치 및 운영 관한 사항은 다음과 같습니다.\n" +
        "\n" +
        "① 설치 근거 및 설치 목적\n" +
        "한국신용카드결제(주)은 『개인정보보호법』 제25조에 따라 시설안전 및 화재예방, 범죄예방 등의 목적으로 영상정보처리기기를 설치 운영 합니다.\n" +
        "\n" +
        "② 설치 대수, 설치 위치 및 촬영범위\n" +
        "\n" +
        "설치 대수\t설치 위치 및 촬영범위\n" +
        "1대\t서울시 강남구 영동대로 511,901호(삼성동,트레이드타워)\n" +
        "\n" +
        "\n" +
        "\n" +
        "\n" +
        "④영상정보의 촬영시간, 보관기간, 보관장소 및 처리 방법\n" +
        "\n" +
        "촬영시간\t보관기간\t보관장소\n" +
        "1대\t3개월\t서울시 강남구 영동대로 511,901호\n" +
        "(삼성동,트레이드타워)\n" +
        "\n" +
        "처리방법 : 개인영상정보의 목적 외 이용, 제3자 제공, 파기, 열람 등 요구에 관한 사항을 기록ㆍ관리하고, 보관기간 만료 시 복원이 불가능한 방법으로 영구 삭제(출력물의 경우 파쇄 또는 소각)합니다.\n" +
        "\n" +
        "⑤영상정보 확인 방법 및 장소\n" +
        "\n" +
        "확인방법\t보관기간 내 영상정보의 경우 담당자에게 미리 연락 후 방문\n" +
        "확인장소\t서울시 강남구 영동대로 511,901호(삼성동,트레이드타워)\n" +
        "\n" +
        "⑥정보주체의 영상정보 열람 등 요구에 관한 조치\n" +
        "정보주체는 정보주체 자신이 촬영된 개인영상정보 및 명백히 정보주체의 급박한 생명, 신체 재산의 이익을 위하여 필요한 개인영상정보에 대하여 열람 또는 존재 확인을 요구할 수 있으며, 한국신용카드결제(주)은 법규 등에 따라 지체 없이 필요한 조치를 하겠습니다.\n" +
        "\n" +
        "⑦영상정보 보호를 위한 기술적 관리적 및 물리적 조치\n" +
        "한국신용카드결제(주)의 영상정보에 대하여 『개인정보보호법』 제29조에 따라 안전성 확보에 필요한 조치를 시행합니다.\n" +
        "\n" +
        "11. 개인위치정보의 처리\n" +
        "\n" +
        "① 한국신용카드결제(주)는 위치정보의 보호 및 이용 등에 관한 법률(이하’위치정보법’)에 따라 다음과 같이 개인위치정보를 처리합니다.\n" +
        "위치기반서비스 이용 및 제공 목적 달성한 때에는 지체없이 개인위치정보를 파기합니다. 이용자가 작성한 게시물 또는 콘텐츠와 함께 위치정보가 저장되는 서비스의 경우 해당 게시물 또는 콘텐츠의 보관기간 동안 개인위치정보가 보관됩니다. 그 외 위치기반서비스 제공을 위해 필요한 경우 이용목적 달성을 위해 필요한 최소한의 기간 동안 개인위치정보를 보유할 수 있습니다.\n" +
        "소프트웨어(APP) / \t서비스 / \t비고\n" +
        " - KOCESICAPP / \t결제장치 통신을 위한 위치정보 사용 / \tAndroid 결제 소프트웨어\n" +
        " - KOCESICIOS(KOCESPOS) / \t결제장치 통신을 위한 위치정보 사용 / \tIOS 결제 소프트웨어\n" +
        "\n" +
        "* 결제서비스를 사용하는 소프트웨어(APP)는 원활한 결제 및 장치연결을 위하여 위치 데이터 사용 권한을 요구합니다.\n" +
        "* 결제 소프트웨어는 사용중, 백그라운드에 동작중에 위치 정보를 사용합니다.\n" +
        "* 블루투스 장치연결을 위한 사용일뿐 이용자의 위치정보를 저장, 이용하지 않습니다.\n" +
        "\n" +
        "② 개인위치정보의 수집 및 이용목적이 달성되면 지체없이 파기합니다.\n" +
        "수집 및 이용 목적의 달성 또는 회원 탈퇴 등 개인위치정보 처리목적이 달성된 경우, 개인위치정보를 복구 및 재생되지 않도록 안전하게 삭제합니다. 다만, 다른 법령에 따라 보관해야 하는 등 정당한 사유가 있는 경우에는 그에 따릅니다. 또한, 위치정보법 제16조2항에 따라 이용자의 위치정보의 이용ㆍ제공사실 확인자료를 위치정보시스템에 6개월간 보관합니다.\n" +
        "\n" +
        "③ 이용자의 사전 동의 없이 개인위치정보를 제3자에게 제공하지 않습니다.\n" +
        "한국신용카드결제(주)는 이용자의 동의 없이 개인위치정보를 제3자에게 제공하지 않으며, 제3자에게 제공하는 경우에는 제공받는 자 및 제공목적을 사전에 이용자에게 고지하고 동의를 받습니다. 이용자의 동의를 거쳐 개인위치정보를 제3자에게 제공하는 경우, 이용자에게 매회 이용자에게 제공받는 자, 제공일시 및 제공목적을 즉시 통지합니다.\n" +
        "\n"
        return _terms
    }
    
    func PermissionsText() -> String {
        
        let _terms =
        "아래의 항목에 접근 권한 허용이 필요 합니다." + "\n" + "\n" +
        "필수 접근권한" + "\n" + "\n" +
        "갤러리 : 거래전표 저장 등을 위한 권한" + "\n" + "\n" +
        "블루투스 : 카드리더기 기기 연결을 위한 권한" + "\n" + "\n" +
        "카메라 : 간편결제 바코드/QR 스캔을 위한 권한" + "\n" + "\n" + "\n" +
        "위의 필수 접근 권한은 미동의 시 앱 이용이 제한됩니다." + "\n" + "\n" +
        "KocesICIOS 은 앱이 종료되었거나 사용 중이 아닐 때도 거래서비스 및 블루투스리더기 통신 기능을 지원합니다." + "\n" +
        "위치 데이터는 블루투스 리더기 통신 기능 외에 별도로 위치정보를 수집하여 저장 하거나 사용하지 않습니다." + "\n" +
        "\n"
        return _terms
    }
}
