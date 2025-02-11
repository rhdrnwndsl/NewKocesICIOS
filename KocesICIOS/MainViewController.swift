//
//  ViewController.swift
//  osxapp
//
//  Created by 金載龍 on 2020/12/25.
//

import UIKit
import SystemConfiguration
import AVFoundation
import Photos

class MainViewController: UIViewController, UITabBarControllerDelegate {

    // 기존 MainViewController의 UI (스토리보드에 연결된 6개 버튼과 스택뷰)
    @IBOutlet weak var commonHomeStackView: UIStackView!
    @IBOutlet weak var mBtn_Credit: UIButton!   //신용버튼
    @IBOutlet weak var mBtn_Cash: UIButton!     //현금버튼
    @IBOutlet weak var mBtn_TradeList: UIButton!    //거래내역
    @IBOutlet weak var mBtn_SalesInquiry: UIButton! //정산
    @IBOutlet weak var mBtn_EasyPay: UIButton!      //간편결제
    @IBOutlet weak var mBtn_OtherPay: UIButton!     //기타결제
    
    // ProductHomeViewController를 자식으로 추가할 변수
    var productHomeVC: ProductHomeViewController?
    
    let mKocesSdk:KocesSdk = KocesSdk.instance
    let mSqlite:sqlite = sqlite.instance
    
    //로딩 메세지박스
    var alertLoading = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //배경이미지
        setupBackground()

        // BLE 관련 내용은 기존 코드의 공통 BLE 검사로 처리
        //장치가 연결 되어 있는지 않은지 확인 한다. 만일 최초 앱이 실행되어 여기에 도달한다면 1회 블루투스장치 검사를 하고 2회이상 메인뷰를 실행하고 있다면 검사하지 않는다
        if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
            if mKocesSdk.mFirstRunning == 0 {
                let alertController = UIAlertController(title: "장치연결", message: "BLE 디바이스가 연결 되지 않았습니다", preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel) {_ in
                    self.AlertLoadingBox(title: "잠시만 기다려 주세요")
                    self.mKocesSdk.mFirstRunning = 1
                    self.mKocesSdk.bleConnect()
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //UI가 모두 정상적으로 로딩이 된 후에
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)
        
        //앱투앱으로 처리하고 넘어오면 해당 데이터 초기화
        Setting.shared.mWebAPPReturnAddr = ""
        
        // 앱 UI 설정값에 따라 분기처리
        let appUISetting = Setting.shared.getDefaultUserData(_key: define.APP_UI_CHECK)
        
        if appUISetting == define.UIMethod.Common.rawValue {
            // Common: 기존 MainViewController UI (6개 버튼 등) 사용
            // BLE 관련 내용은 공통 설정(예: initRes() 내부에 BLE 체크 부분은 공통으로 사용)
            initRes()
            // ProductHomeViewController UI가 있다면 숨김(또는 제거)
            removeProductHomeUI()
            // 거래내역, 매출정보 탭 숨기기
            if let tabBarController = self.tabBarController as? TabBarController {
                tabBarController.hideTabs(at: [2, 3]) // 2번과 3번 탭 숨기기
            }
        } else if appUISetting == define.UIMethod.Product.rawValue {
            // Product: ProductHomeViewController UI 보이고, 기존 MainViewController UI는 숨김
            hideCommonUI()
            addProductHomeUI()
            // 거래내역, 매출정보 모두 보이게 설정
            if let tabBarController = self.tabBarController as? TabBarController {
                tabBarController.showAllTabs() // 원래 탭 복원
            }
        } else {
            // 메인홈 ,거래내역, 매출정보 탭 숨기기 -> 환경설정밖에 없다
            if let tabBarController = self.tabBarController as? TabBarController {
                tabBarController.hideTabs(at: [0, 2, 3]) // 0번, 2번과 3번 탭 숨기기
            }
            // 그 외 (AppToApp 등): EnvironmentTabController로 이동
            navigateToEnvironmentTabController()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        //등록된 노티 전체 제거
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Background Setup
        
    private func setupBackground() {
        //네비게이션 바의 배경색 rgb 변경
        UISetting.navigationTitleSetting(navigationBar: navigationController?.navigationBar ?? UINavigationBar())

        //네비게이션 바타이틀을 이미지로 지정(로고)
        let imageView = UIImageView()
        let image = #imageLiteral(resourceName: "TOP_LOGO_White")
        navigationItem.titleView = UISetting.navigationLogoTitle(TitleImageSet: imageView, TitleImage: image)
        
        let backgroundImage = UIImageView(frame: view.bounds) // 아니면 UIScreen.main.bounds
        backgroundImage.image = #imageLiteral(resourceName: "MAIN_BG_LOGO")
        backgroundImage.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - 분기별 UI 설정
        
    /// Common UI(기존 6개 버튼 등)를 초기화하고 보이도록 설정 (BLE 관련 기능 포함)
    func initRes() {
        mBtn_Credit.setImage(UIImage(named: "card-normal"), for: .normal)
        mBtn_Credit.setImage(UIImage(named: "card-select"), for: .highlighted)
        mBtn_Cash.setImage( UIImage(named: "cash-normal"), for: .normal)
        mBtn_Cash.setImage( UIImage(named: "cash-select"), for: .highlighted)
        mBtn_TradeList.setImage(UIImage(named: "trade-normal") , for: .normal)
        mBtn_TradeList.setImage(UIImage(named: "trade-select") , for: .highlighted)
        mBtn_SalesInquiry.setImage(UIImage(named: "calendar-normal") , for: .normal)
        mBtn_SalesInquiry.setImage(UIImage(named: "calendar-select"), for: .highlighted)
        mBtn_EasyPay.setImage(UIImage(named: "easy-normal") , for: .normal)
        mBtn_EasyPay.setImage(UIImage(named: "easy-select") , for: .highlighted)
        mBtn_OtherPay.setImage(UIImage(named: "other-normal") , for: .normal)
        mBtn_OtherPay.setImage(UIImage(named: "other-select") , for: .highlighted)
    }
    
    /// Common UI를 숨기는 함수: 기존 MainViewController의 UI 요소를 숨깁니다.
    func hideCommonUI() {
        commonHomeStackView.isHidden = true
        mBtn_Credit.isHidden = true
        mBtn_Cash.isHidden = true
        mBtn_TradeList.isHidden = true
        mBtn_SalesInquiry.isHidden = true
        mBtn_EasyPay.isHidden = true
        mBtn_OtherPay.isHidden = true
    }
    
    /// Common UI를 다시 보이게 하는 함수 (필요 시 호출)
    func showCommonUI() {
        commonHomeStackView.isHidden = false
        mBtn_Credit.isHidden = false
        mBtn_Cash.isHidden = false
        mBtn_TradeList.isHidden = false
        mBtn_SalesInquiry.isHidden = false
        mBtn_EasyPay.isHidden = false
        mBtn_OtherPay.isHidden = false
    }
    
    /// ProductHomeViewController의 UI를 자식 뷰 컨트롤러로 추가
    func addProductHomeUI() {
        // 이미 추가되어 있다면 제거 후 다시 추가할 수도 있음
        removeProductHomeUI()
        productHomeVC = ProductHomeViewController()
        guard let productHomeVC = productHomeVC else { return }
        addChild(productHomeVC)
        productHomeVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(productHomeVC.view)
        productHomeVC.didMove(toParent: self)
        
        // ProductHomeViewController의 뷰를 전체 화면에 맞게 제약조건 설정
        NSLayoutConstraint.activate([
            productHomeVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            productHomeVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productHomeVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productHomeVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /// ProductHomeViewController의 UI를 제거(숨김)
    func removeProductHomeUI() {
        if let productHomeVC = productHomeVC {
            productHomeVC.willMove(toParent: nil)
            productHomeVC.view.removeFromSuperview()
            productHomeVC.removeFromParent()
            self.productHomeVC = nil
        }
    }
    
    /// EnvironmentTabController로 이동 (모달 전환)
    func navigateToEnvironmentTabController() {
        let storyboard = getStoryBoard()
        if let envTabVC = storyboard?.instantiateViewController(withIdentifier: "EnvironmentTabController") as? EnvironmentTabController {
            envTabVC.navigationItem.title = "환경설정"
            navigationController?.pushViewController(envTabVC, animated: true)
        }
    }
  
    /** 1. 카메라 권한 체크하는 곳 */
    func checkCameraPermission(){
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            if granted {
                print("Camera: 권한 허용")
                self.checkAlbumPermission()
            } else {
                print("Camera: 권한 거부")
                let alert = UIAlertController(title: "권한거부", message: "바코드/QR 리딩을 위해 카메라 권한을 설정해야 합니다", preferredStyle: .alert)
                let okBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                        self.checkCameraPermission()
                    }
                })
                alert.addAction(okBtn)
                self.present(alert, animated: true, completion: nil)
            }
        })
     }
    
    /** 2. 갤러리 권한 체크하는 곳 */
    func checkAlbumPermission(){
        PHPhotoLibrary.requestAuthorization( { [self] status in
            switch status{
            case .authorized:
                print("Album: 권한 허용")
                //장치가 연결 되어 있는지 않은지 확인 한다. 만일 최초 앱이 실행되어 여기에 도달한다면 1회 블루투스장치 검사를 하고 2회이상 메인뷰를 실행하고 있다면 검사하지 않는다
                if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                    if mKocesSdk.mFirstRunning == 0 {
                        let alertController = UIAlertController(title: "장치연결", message: "BLE 디바이스가 연결 되지 않았습니다", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel) {_ in
                            self.AlertLoadingBox(title: "잠시만 기다려 주세요")
                            self.mKocesSdk.mFirstRunning = 1
                            self.mKocesSdk.bleConnect()
                        }
                        alertController.addAction(okButton)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            case .denied:
                print("Album: 권한 거부")
                let alert = UIAlertController(title: "권한거부", message: "영수증 이미지 저장을 위해 권한을 설정해야 합니다", preferredStyle: .alert)
                let okBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                        self.checkAlbumPermission()
                    }
                })
                alert.addAction(okBtn)
                self.present(alert, animated: true, completion: nil)
            case .restricted, .notDetermined:
                print("Album: 선택하지 않음")
                let alert = UIAlertController(title: "권한거부", message: "영수증 이미지 저장을 위해 권한을 설정해야 합니다", preferredStyle: .alert)
                let okBtn = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                        self.checkAlbumPermission()
                    }
                })
                alert.addAction(okBtn)
                self.present(alert, animated: true, completion: nil)
            default:
                break
            }
        })
    }

    /// 신용 버튼 클릭함
    /// - Parameter sender: <#sender description#>
    @IBAction func mBtn_Credit_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }

        //CAT상태에서는 ble체크를 하지 않는다.
        if CheckBle() {
            if CheckBeforeTrading() {
                moveCredit()
            }
        }
    }
    
    /// 현금 버튼 클릭함
    /// - Parameter sender: <#sender description#>
    @IBAction func mBtn_Cash_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        
        //CAT상태에서는 ble체크를 하지 않는다.
        if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
            if Utils.CheckCatPortIP() != "" {
                AlertBox(title: "에러", message: Utils.CheckCatPortIP(), text: "확인")
                return
            }
            moveCash()
        } else {
            if CheckBeforeTrading() {
                moveCash()
            }
        }
    }
    
    /// 거래내역 버튼 클릭함
    /// - Parameter sender: <#sender description#>
    @IBAction func mBtn_TradeList_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        moveTradeList()
    }
    
    @IBAction func mBtn_EasyPay_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch:UITouch = (event.allTouches?.first)!
        if touch.tapCount != 1 {
            return
        }
        if CheckBeforeTrading() {
            easyPay()
        }
    }
    
    @IBAction func mBtn_OtherPay_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch:UITouch = (event.allTouches?.first)!
        if touch.tapCount != 1 {
            return
        }
        if CheckBeforeTrading() {
            otherPay()
        }
    }
    
    /// 정산 버튼 클릭함
    /// - Parameter sender: <#sender description#>
    @IBAction func mBtn_SalesInquiry_Clicked(_ sender: UIButton, forEvent event: UIEvent) {
        let touch: UITouch = (event.allTouches?.first)!
        if (touch.tapCount != 1) {
            // do action.
            return
        }
        moveSalesInquiry()
    }
    
    func moveSalesInquiry() {
        var storyboard:UIStoryboard? = getStoryBoard()
        let controller = (storyboard!.instantiateViewController(identifier: "CalendarViewController")) as CalendarViewController
        controller.navigationItem.title = "매출정보"    //2021-08-19 수정사항 169.B
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func easyPay(){
        var storyboard:UIStoryboard? = getStoryBoard()
        let controller = (storyboard!.instantiateViewController(identifier: "EasyPayController")) as EasyPayController
        controller.navigationItem.title = "간편결제"
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func otherPay(){
        var storyboard:UIStoryboard? = getStoryBoard()
        let controller = (storyboard!.instantiateViewController(identifier: "OtherPayController")) as OtherPayController
        controller.navigationItem.title = "기타결제"
//        let controller = (storyboard!.instantiateViewController(identifier: "ProductHomeViewController")) as ProductHomeViewController
//        controller.navigationItem.title = "상품홈화면"
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func moveTradeList(){
        var storyboard:UIStoryboard? = getStoryBoard()
        let controller = (storyboard!.instantiateViewController(identifier: "TradelistController")) as TradelistController
        controller.navigationItem.title = "거래내역"
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func moveCash(){
        var storyboard:UIStoryboard? = getStoryBoard()
        let controller = (storyboard!.instantiateViewController(identifier: "CashController")) as CashController
        controller.navigationItem.title = "현금결제"
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func moveCredit(){
        var storyboard:UIStoryboard? = getStoryBoard()
        let controller = (storyboard!.instantiateViewController(identifier: "CreditController")) as CreditController
        controller.navigationItem.title = "카드결제"    //수정사항 169.1 A
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func getStoryBoard() -> UIStoryboard? {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            return UIStoryboard(name: "pad", bundle: Bundle.main)
        }
    }
    
    @objc func didBle(_ notification: Notification) {
        guard let bleStatus: String = notification.userInfo?["Status"] as? String else { return }
        switch bleStatus {
        case define.IsPaired:   //직전에 연결했었던 장비를 스캔하였을 때
            //장치 이름만 추출 하기 2020-03-08 kim.jy
            let TempDeviceName:String = String(describing: self.mKocesSdk.isPairedDevice[0]["device"].unsafelyUnwrapped)
            var deviceName:String = ""
            if TempDeviceName != "" {
                let temp = TempDeviceName.components(separatedBy: ":")
                if temp.count > 0 {
                    deviceName = String(temp[0])
                }
            }
            mKocesSdk.manager.connect(uuid: mKocesSdk.isPaireduuid)
            print("BLE_Status :", bleStatus)
            break
        case define.ScanSuccess:    //다른 장비를 스캔하였을 때
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                var message:String = "연결 가능한 목록입니다"
                if self.mKocesSdk.manager.devices.count == 0 {
                    message = "연결 가능한 디바이스가 존재하지 않습니다"
                }
                let blealert = UIAlertController(title: "리더기연결", message: message, preferredStyle: .alert)
                if self.mKocesSdk.manager.devices.count == 0 {
                    let button = UIAlertAction(title: "확인", style: .default)
                    blealert.addAction(button)
                }
                else {
                    for i in 0 ..< self.mKocesSdk.manager.devices.count {
                        let device = self.mKocesSdk.devices[i]
                        let TempDeviceName:String = String(describing: device["device"].unsafelyUnwrapped)
                        var deviceName:String = ""
                        if TempDeviceName != "" {
                            let temp = TempDeviceName.components(separatedBy: ":")
                            if temp.count > 0 {
                                deviceName = String(temp[0])
                            }
                        }
                        blealert.addAction(UIAlertAction(title: deviceName , style: .default, handler: { (Action) in
                            let uuid = device["uuid"] as! UUID
                            self.AlertLoadingBox(title: "잠시만 기다려 주세요")
                            self.mKocesSdk.manager.connect(uuid: uuid)
                        }))
                    }
                    let button = UIAlertAction(title: "취소", style: .default, handler: {(action) in
                        self.AlertBox(title: "장치연결취소", message: "장치 연결을 종료하였습니다", text: "확인")
                    })
                    blealert.addAction(button)
                }
                self.present(blealert, animated: true, completion: nil)
            }
            print("BLE_Status :", bleStatus)
            break
        case define.ConnectSuccess:
            print("BLE_Status :", bleStatus)
            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertLoadingBox(title: "무결성 검사를 진행합니다. 잠시만 기다려 주세요")
                DispatchQueue.main.async { [self] in
                    mKocesSdk.GetVerity()   //연결에 성공하면 자동으로 무결성검사 시작
                }
            }
            break
        case define.ConnectFail:
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "장치연결실패", message: "장치연결에 실패하였습니다. 연결을 다시 시도해 주십시오", text: "확인")
            }
            break
        case define.ConnectTimeOut:
            print("BLE_Status :", bleStatus)
            let alertFail = UIAlertController(title: "연결에 실패하였습니다", message: "장치연결에 실패하였습니다. 아이폰설정으로 이동하여 등록된 블루투스 리더기를 제거해 주십시오", preferredStyle: .alert)
            let failOK = UIAlertAction(title: "확인", style: .default, handler: {(action) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
          
            let failCancel = UIAlertAction(title: "취소", style: .default, handler: {(action) in
                
            })
            alertFail.addAction(failCancel)
            alertFail.addAction(failOK)
            alertLoading.dismiss(animated: true){ [self] in
                self.present(alertFail, animated: true, completion: nil)
            }
            break
        case define.ScanFail:
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "장치검색실패", message: "장치검색에 실패하였습니다", text: "확인")
            }
            break
        case define.PowerOff:
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "블루투스불가", message: "BLE 사용 할 수 없는 모델입니다", text: "확인")
            }
            break
        case define.Disconnect:
            print("BLE_Status :", bleStatus)
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "장치차단", message: "장치가 끊어졌습니다", text: "확인")
            }
            break
        case define.PairingKeyFail:
            print("BLE_Status :", bleStatus)
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "페어링실패", message: "핀번호 오류", text: "확인")
            }
            break
        case define.Receive:
            DeviceInfoRes(ResData: self.mKocesSdk.mReceivedData)
            break
        default:
            break
        }
    }
    
    /// 장치 정보 파싱 함수
    /// - Parameter _res: 무결성 검사 결과 데이터
    func DeviceInfoRes(ResData _res:[UInt8]) {
        let receive: String = String(describing: _res)
        let receiveData = _res
        
        switch receiveData[3] {
        case Command.CMD_POSINFO_RES:
            var spt:Int = 4
            let TmIcNo = Utils.UInt8ArrayToStr(UInt8Array: Array(receiveData[spt...spt + 15]))
            Setting.shared.setDefaultUserData(_data: TmIcNo, _key: define.APP_ID)
            spt += 32
            let serialNumber = Utils.UInt8ArrayToStr(UInt8Array: Array(receiveData[spt...spt + 9]))
            spt += 10
            let version = Utils.UInt8ArrayToStr(UInt8Array: Array(receiveData[spt...spt + 4]))
            spt += 5
            let key = Utils.UInt8ArrayToStr(UInt8Array: Array(receiveData[spt...spt + 1]))
            mKocesSdk.mKocesCode = define.KOCES_ID
            mKocesSdk.mAppCode = define.KOCES_APP_ID
            mKocesSdk.mModelNumber = TmIcNo
            mKocesSdk.mSerialNumber = serialNumber
            mKocesSdk.mModelVersion = version //version
            //가맹점 등록이 완료 되지 않은 상태에서 시리얼 저장 안함.
            alertLoading.dismiss(animated: false){ [self] in
                if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                    AlertBox(title: "무결성검증실패", message: "리더기 무결성 검증실패 제조사A/S요망", text: "확인")
                    return
                }
                if key != "00" {
                    AlertBox(title: "장치정보", message: "키 갱신이 필요합니다", text: "확인")
                }
            }
            break
        case Command.NAK:
            AlertBox(title: "결과", message: "장치 오류. 연결 해제 후, 다시 연결을 시도해 주세요.", text: "확인")
            break
        case Command.CMD_VERITY_RES:
            //무결성검사가 정상인지 아닌지를 체크하여 메세지박스로 표시한다
            var _resultMessage:String = ""
            switch receiveData[4...5] {
            case [0x30,0x30]:
                _resultMessage = "무결성검사가 정상입니다"
                mKocesSdk.mVerityCheck = define.VerityMethod.Success.rawValue
                mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "0", Result: "0")
                //정상
                break
            case [0x30,0x31]:
                _resultMessage = "리더기 무결성 검증실패 제조사A/S요망"
                mKocesSdk.mVerityCheck = define.VerityMethod.Fail.rawValue
                mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "1", Result: "1")
                //실패
                break
            case [0x30,0x32]:
                _resultMessage = "리더기 무결성 검증실패 제조사A/S요망"
                mKocesSdk.mVerityCheck = define.VerityMethod.Fail.rawValue
                mSqlite.InsertVerity(Date: Utils.getDate(format: "yyMMddhhmmss"), Mode: "1", Result: "1")
                //FK검증실패
                break
            default:
                break
            }
            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
            mKocesSdk.GetDeviceInfo(Date: Utils.getDate(format: "yyyyMMddHHmmss"))
            break
        default:
            break
        }
    }
    
    func AlertBox(title : String, message : String, text : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okButton)
        return self.present(alertController, animated: true, completion: nil)
    }
    
    //로딩 박스
    func AlertLoadingBox(title _title:String) {
        alertLoading = UIAlertController(title: _title, message: nil, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()

        alertLoading.view.addSubview(activityIndicator)
        alertLoading.view.heightAnchor.constraint(equalToConstant: 95).isActive = true

        activityIndicator.centerXAnchor.constraint(equalTo: alertLoading.view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: alertLoading.view.bottomAnchor, constant: -20).isActive = true

        present(alertLoading, animated: true, completion: nil)
    }
    
    func CheckBle() -> Bool {
        //ble 연결되어있지 않다면 들어가는 것을 막는다
        if KocesSdk.instance.bleState == define.TargetDeviceState.BLENOCONNECT {
            let alert = UIAlertController(title: nil, message: "BLE 디바이스가 연결 되지 않았습니다 환경설정에서 장치를 검색하십시오", preferredStyle: .alert)
            present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
                self.dismiss(animated: false){
                    self.tabBarController?.selectedIndex = 0
                }
            })})
            return false
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.BLECONNECTED {
            if KocesSdk.instance.mVerityCheck != define.VerityMethod.Success.rawValue{
                let alert = UIAlertController(title: nil, message: "리더기 무결성 검증이 정상 완료하지 않았습니다.", preferredStyle: .alert)
                present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
                    self.dismiss(animated: false){
                        self.tabBarController?.selectedIndex = 0
                    }
                })})
                return false
            }
        }
        
        if KocesSdk.instance.bleState == define.TargetDeviceState.CATCONNECTED {
            if Utils.CheckCatPortIP() != "" {
                let alert = UIAlertController(title: nil, message: Utils.CheckCatPortIP(), preferredStyle: .alert)
                present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
                    self.dismiss(animated: false){
                        self.tabBarController?.selectedIndex = 0
                    }
                })})
                return false
            }
        }
        
        return true
    }
    
    func CheckBeforeTrading() -> Bool {
        //거래 전 체크 사항
        let temp:String = KocesSdk.instance.ChecklistBeforeTrading()
        
        //21-06-01. by.tlswlsdn 코세스 수정요청사항 중 CAT결제방식 선택시 가맹점등록 다운로드없이 결제진행 관련검토
        if KocesSdk.instance.bleState != define.TargetDeviceState.CATCONNECTED {
            if temp != "" {     //temp에 문자열이 있는 경우 거래전 체크 사항에 문제가 있는 것으로 판단 한다.
                let alert = UIAlertController(title: nil, message: temp, preferredStyle: .alert)
                present(alert, animated: false, completion: {Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
                    self.dismiss(animated: false){
                        self.tabBarController?.selectedIndex = 0
                    }
                })})
                return false
            }
        }
        return true
    }
}

extension MainViewController: CustomAlertDelegate{
    func OkButtonTapped() {
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){[self] in
            mKocesSdk.manager.connect(uuid: mKocesSdk.isPaireduuid)
        }
    }
    
    func CancelButtonTapped() {
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){[self] in
            UserDefaults.standard.setValue("", forKey: define.LAST_CONNECT_DEVICE)
            mKocesSdk.manager.scan()
        }
    }
}
