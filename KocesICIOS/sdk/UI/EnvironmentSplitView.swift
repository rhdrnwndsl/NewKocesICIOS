//
//  EnvironmentSplitView.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 12/30/24.
//

import UIKit

class EnvironmentSplitView: UIView, UITableViewDelegate, UITableViewDataSource {
    // 환경 설정 목록 Enum
    public enum EnvironmentSplit: String {
        case STORE = "가맹점정보"
        case TAX = "결제설정"
        case BT = "BT설정"
        case CAT = "CAT설정"
        case PRINT = "프린트설정"
        case NETWORK = "네트워크설정"
        case PRODUCT = "상품관리"
        case QNA = "Q&A"
        case PRIVACY = "개인정보처리방침"
        case APPINFO = "앱정보"
    }
    private var isContentView = ""  //현재 실행중인 컨텐트뷰의 이름
    public var isStoreDownload = false //가맹점정보화면 = false 가맹점다운로드화면 = true
    public var isProduct = false //상품등록/상품수정화면이 아니면 = false 상품등록/상품수정화면 = true
    
    // UI 요소
    private let mainView = UITableView(frame: .zero, style: .grouped)   // 가로뷰 왼쪽 메뉴화면
    private let contentView = UIView()   // 가로뷰 오른쪽 화면
    private let separatorLine = UIView() // 가로뷰 중앙 구분 라인
    
    private var sections: [SettingSection] = []
    private var isContentViewVisible = false
    private var selectedIndexPath: IndexPath?   // 선택된 셀의 IndexPath
    
    // 부모 ViewController 참조 (옵셔널)
    private weak var parentViewController: UIViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupMainView()
        setupContentView()
        setupSeparatorLine()
        updateLayoutForCurrentOrientation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
        setupMainView()
        setupContentView()
        setupSeparatorLine()
        updateLayoutForCurrentOrientation()
    }

    private func setupMainView() {
        mainView.delegate = self
        mainView.dataSource = self
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // 그룹 스타일 테이블뷰의 배경을 회색으로, 셀 간 여백을 주기 위해 contentInset 설정
        mainView.backgroundColor = define.layout_border_lightgrey
        mainView.separatorStyle = .none
//        mainView.contentInset = UIEdgeInsets(top: define.pading_wight,
//                                             left: define.pading_wight,
//                                             bottom: define.pading_wight,
//                                             right: define.pading_wight)
        addSubview(mainView)
    }

    private func setupContentView() {
        isContentView = ""
        isStoreDownload = false
        isProduct = false
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
    }
    
    private func setupSeparatorLine() {
        separatorLine.backgroundColor = define.underline_grey
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLine)
    }

    func configure(with sections: [SettingSection]) {
        self.sections = sections
        mainView.reloadData()
    }

    private func updateLayoutForCurrentOrientation() {
        let isPortrait = UIScreen.main.bounds.height > UIScreen.main.bounds.width

        mainView.isHidden = isContentViewVisible && isPortrait
        contentView.isHidden = !isContentViewVisible && isPortrait
        separatorLine.isHidden = isPortrait // 가로 모드에서만 라인 표시

        NSLayoutConstraint.deactivate(mainView.constraints)
        NSLayoutConstraint.deactivate(contentView.constraints)
        NSLayoutConstraint.deactivate(separatorLine.constraints)

        if isPortrait {
            if isContentViewVisible {
                // Content view is full screen
                NSLayoutConstraint.activate([
                    contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    contentView.topAnchor.constraint(equalTo: topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
            } else {
                // Main view is full screen
                NSLayoutConstraint.activate([
                    mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    mainView.topAnchor.constraint(equalTo: topAnchor),
                    mainView.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
            }
        } else {
            // Horizontal mode: Show both views
            isContentViewVisible = false

            NSLayoutConstraint.activate([
                mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
                mainView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 3),
                mainView.topAnchor.constraint(equalTo: topAnchor),
                mainView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                separatorLine.leadingAnchor.constraint(equalTo: mainView.trailingAnchor),
                separatorLine.widthAnchor.constraint(equalToConstant: 1), // 라인 두께
                separatorLine.topAnchor.constraint(equalTo: topAnchor),
                separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),

                contentView.leadingAnchor.constraint(equalTo: separatorLine.trailingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.topAnchor.constraint(equalTo: topAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }

    func backToMainView() {
     
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width { // Portrait mode
            if isContentViewVisible {
                if isContentView == EnvironmentSplit.STORE.rawValue {
                    if isStoreDownload {
                        isStoreDownload = false
                        remove(asChildViewController: storesettingVC)
                        add(asChildViewController: storesettingVC)
                        return
                    }
                } else if isContentView == EnvironmentSplit.PRODUCT.rawValue {
                    if isProduct {
                        isProduct = false
                        remove(asChildViewController: ProductSettingVC)
                        add(asChildViewController: ProductSettingVC)
                        return
                    }
                }
                
                isContentViewVisible = false
                updateLayoutForCurrentOrientation()
            } else {
                backToMain()
            }
        } else {
            if isContentView == EnvironmentSplit.STORE.rawValue {
                if isStoreDownload {
                    isStoreDownload = false
                    storesettingVC.backStoreDownload()
                    remove(asChildViewController: storesettingVC)
                    add(asChildViewController: storesettingVC)
                    return
                }
            } else if isContentView == EnvironmentSplit.PRODUCT.rawValue {
                if isProduct {
                    isProduct = false
                    remove(asChildViewController: ProductSettingVC)
                    add(asChildViewController: ProductSettingVC)
                    return
                }
            }
            backToMain()
        }
    }
    
    func backToMain() {
        let storyboard = getMainStoryBoard()
        let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBar")
        mainTabBarController.modalPresentationStyle = .fullScreen
        parentViewController?.present(mainTabBarController, animated: true, completion: nil)
    }

    
    // MARK: - Section Header Spacing
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Utils.getRowSubHeight() // 섹션 간 간격
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }
      
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = define.pading_wight
        cell.backgroundColor = .clear

        // section 내 셀의 총 개수
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        // 셀 내부 content의 inset (왼쪽/right 여백 적용)
        let bounds = cell.bounds.insetBy(dx: define.pading_wight, dy: 0)
        
        let path: UIBezierPath
        if numberOfRows == 1 {
            // 한 셀만 있는 경우 모든 모서리를 둥글게
            path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        } else {
            if indexPath.row == 0 {
                // 첫 셀: 위쪽 모서리만 둥글게
                path = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            } else if indexPath.row == numberOfRows - 1 {
                // 마지막 셀: 아래쪽 모서리만 둥글게
                path = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            } else {
                // 중간 셀: 직각 사각형
                path = UIBezierPath(rect: bounds)
            }
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        // 선택된 셀이면 배경색을 변경 (예: define.layout_bg_green), 아니면 흰색
        if indexPath == selectedIndexPath {
            shapeLayer.fillColor = define.layout_bg_green.cgColor
        } else {
            shapeLayer.fillColor = UIColor.white.cgColor
        }
        
        // 마지막 셀을 제외한 모든 셀에 separator(언더라인) 추가
        if indexPath.row < numberOfRows - 1 {
            let separatorHeight = 1.0 / UIScreen.main.scale
            let separatorLayer = CALayer()
            // 셀 내부 inset에 맞춰 좌우 10pt 여백 적용
            separatorLayer.frame = CGRect(x: bounds.origin.x + 10,
                                          y: bounds.height - separatorHeight,
                                          width: bounds.width - 20,
                                          height: separatorHeight)
            separatorLayer.backgroundColor = define.underline_grey.cgColor
            shapeLayer.addSublayer(separatorLayer)
        }
        
        let bgView = UIView(frame: cell.bounds)
        bgView.layer.insertSublayer(shapeLayer, at: 0)
        cell.backgroundView = bgView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 재사용 셀 생성
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // 셀 기본 설정
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // 기존 accessoryView는 제거
        cell.accessoryType = .none
        cell.accessoryView = nil
        
        // 재사용에 대비해 기존 contentView의 인디케이터(태그 1000) 제거
        cell.contentView.subviews.forEach { subview in
            if subview.tag == 1000 { subview.removeFromSuperview() }
        }
        
        // 셀 내용 설정 (예: 텍스트 라벨)
        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.textLabel?.font = Utils.getSubTitleFont()
        cell.textLabel?.textColor = .darkGray
        
        // 만일 스위치가 필요한 경우 accessoryView에 스위치를 설정
        if item.hasSwitch {
            let switchView = UISwitch()
            switchView.isOn = false
            cell.accessoryView = switchView
        } else {
            // 스위치가 없는 경우, 인디케이터를 cell.contentView에 추가
            let indicator = UIImageView(image: UIImage(systemName: "chevron.right"))
            indicator.tintColor = .lightGray
            indicator.tag = 1000 // 재사용 시 제거하기 위한 태그
            indicator.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                indicator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -define.pading_wight * 2),
//                indicator.widthAnchor.constraint(equalToConstant: 12),
//                indicator.heightAnchor.constraint(equalToConstant: 16)
            ])
        }
        
        return cell

    }


    func tableView(_ tableView: UITableView, layoutMarginsForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: define.pading_wight, left: 0, bottom: define.pading_wight, right: 0)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0 // 모든 섹션의 푸터 높이를 0으로 설정
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView() // 빈 UIView 반환
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Utils.getRowHeight() // 원하는 높이로 조정
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
//        header.textLabel?.font = Utils.getSubTitleFont()
//        header.textLabel?.textColor = .darkGray
//        header.textLabel?.textAlignment = .left
//        
//        header.contentView.backgroundColor = .systemGray6 // 배경색 설정
//        header.backgroundView = nil // 기존 backgroundView 제거 (레이아웃 영향 방지)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

  
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택된 셀의 IndexPath 저장
        selectedIndexPath = indexPath
        mainView.reloadData() // 테이블 뷰 리로드하여 배경색 업데이트
        
        let item = sections[indexPath.section].items[indexPath.row]
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width { // Portrait mode
            isContentViewVisible = true
            updateLayoutForCurrentOrientation()
        }
        changeViewController(selectTab: item)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Set ViewController 
    private lazy var networkVC: NetworkViewController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "NetworkViewController") as! NetworkViewController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var btsettingVC: BTSettingViewController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BTSettingViewController") as! BTSettingViewController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private lazy var catsettingVC: CatSettingViewController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "CatSettingViewController") as! CatSettingViewController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var infoVC: AppInfoViewController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()
        var viewController = storyboard.instantiateViewController(withIdentifier: "AppInfoViewController") as! AppInfoViewController
         
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
 
    private lazy var printVC: PrintViewController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "PrintViewController") as! PrintViewController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
   
    private lazy var storesettingVC: StoreViewController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()
        
        // Instantiate View Controller
//        var viewController = storyboard.instantiateViewController(withIdentifier: "StoreSettingController") as! StoreSettingController
        var viewController = storyboard.instantiateViewController(withIdentifier: "StoreViewController") as! StoreViewController
        if let parentVC = self.parentViewController as? StoreViewControllerDelegate {
            viewController.delegate = parentVC
        }
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
   
    private lazy var PaymentSettingVC: PaymentSettingViewController = {
        let storyboard = getMainStoryBoard()

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "PaymentSettingViewController") as! PaymentSettingViewController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private lazy var ProductSettingVC: ProductSetViewController = {
        let storyboard = getMainStoryBoard()
        let viewController = storyboard.instantiateViewController(withIdentifier: "ProductSetViewController") as! ProductSetViewController
        // 부모 컨트롤러가 delegate 역할을 할 수 있으면 할당합니다.
        if let parentVC = self.parentViewController as? ProductSetViewControllerDelegate {
            viewController.delegate = parentVC
        }
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var qnaVC: QnaViewController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()
        var viewController = storyboard.instantiateViewController(withIdentifier: "QnaViewController") as! QnaViewController
         
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private func getMainStoryBoard() -> UIStoryboard {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        return storyboard!
    }
    
    func setViewController(viewController: UIViewController) {
        self.parentViewController = viewController
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        parentViewController?.addChild(viewController)

        // Add Child View as Subview
        contentView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self.parentViewController)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
        NotificationCenter.default.removeObserver(viewController)
    }
    
    private func initController() {
        remove(asChildViewController: networkVC)
        remove(asChildViewController: btsettingVC)
        remove(asChildViewController: catsettingVC)
        remove(asChildViewController: infoVC)
        remove(asChildViewController: printVC)
        remove(asChildViewController: storesettingVC)
        remove(asChildViewController: PaymentSettingVC)
        remove(asChildViewController: ProductSettingVC)
        remove(asChildViewController: qnaVC)
        
        mainView.reloadData()
    }
    
    public func disapearRemove() {
        remove(asChildViewController: networkVC)
        remove(asChildViewController: btsettingVC)
        remove(asChildViewController: catsettingVC)
        remove(asChildViewController: infoVC)
        remove(asChildViewController: printVC)
        remove(asChildViewController: storesettingVC)
        remove(asChildViewController: PaymentSettingVC)
        remove(asChildViewController: ProductSettingVC)
        remove(asChildViewController: qnaVC)
        selectedIndexPath = nil
        mainView.reloadData()
    }
    
    func changeViewController(selectTab:SettingItem) {
        // 다르게 처리되는 로직만 따로 빼서 정리
        switch selectTab.title {
        case EnvironmentSplit.NETWORK.rawValue:
            CheckPassword()
            return
        case EnvironmentSplit.PRIVACY.rawValue:
            Utils.openExternalLink(urlStr: define.PRIVACY_URL)
            return
        default:
            break
        }
        
        // 공통적으로 적용되는 로직을 처리
        initController()
        isContentView = selectTab.title
        switch selectTab.title {
        case EnvironmentSplit.STORE.rawValue:
            add(asChildViewController: storesettingVC)
            break
        case EnvironmentSplit.TAX.rawValue:
            add(asChildViewController: PaymentSettingVC)
            break
        case EnvironmentSplit.BT.rawValue:
            add(asChildViewController: btsettingVC)
            break
        case EnvironmentSplit.CAT.rawValue:
            add(asChildViewController: catsettingVC)
            break
        case EnvironmentSplit.PRINT.rawValue:
            add(asChildViewController: printVC)
            break
        case EnvironmentSplit.PRODUCT.rawValue:
            add(asChildViewController: ProductSettingVC)
        case EnvironmentSplit.QNA.rawValue:
            add(asChildViewController: qnaVC)
            break
        case EnvironmentSplit.APPINFO.rawValue:
            add(asChildViewController: infoVC)
            break
        default:
            break
        }
   }
    
    
    private func CheckPassword() {
        let alert = UIAlertController(title: nil, message: "비밀번호를 입력하세요", preferredStyle: UIAlertController.Style.alert)

        alert.addTextField(configurationHandler: {(textField) in
            textField.keyboardType = .numberPad
            textField.isSecureTextEntry = true
        })

        let ok = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { [self](ACTION) in
            let password = alert.textFields?[0].text
            if password?.isEmpty == false && password == "3415" {
                initController()
                add(asChildViewController: networkVC)
            } else {
                let alert2 = UIAlertController(title: nil, message: "비밀번호를 잘못 입력하였습니다", preferredStyle: .alert)
                self.parentViewController?.present(alert2, animated: false, completion:{Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
                    self.parentViewController?.dismiss(animated: true){ [self] in
                       
                    }
                })})
            }

        })

        let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: { [self](ACTION) in
           
        })

        alert.addAction(cancel)
        alert.addAction(ok)

        self.parentViewController?.present(alert, animated: false, completion: nil)
    }
}
