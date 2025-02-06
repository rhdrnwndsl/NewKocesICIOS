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
        mainView.contentInset = UIEdgeInsets(top: define.pading_wight,
                                             left: define.pading_wight,
                                             bottom: define.pading_wight,
                                             right: define.pading_wight)
        addSubview(mainView)
    }

    private func setupContentView() {
        isContentView = ""
        isStoreDownload = false
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
        return 20 // 섹션 간 간격
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // 기존 셀 스타일 초기화
        cell.backgroundColor = .clear
        cell.contentView.subviews.forEach { subview in
            if subview.tag == 999 { subview.removeFromSuperview() }
        }
        
        // containerView: white background, 라운드 효과, 좌우 상하 여백 적용
        let containerInset = UIEdgeInsets(top: define.pading_wight / 2, left: 0, bottom: define.pading_wight / 2, right: 0)
        let containerFrame = cell.contentView.bounds.inset(by: containerInset)
        let containerView = UIView(frame: containerFrame)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.tag = 999
        cell.contentView.insertSubview(containerView, at: 0)
        
        // 기존 텍스트 라벨을 containerView 위로 이동 및 inset 적용
        if let textLabel = cell.textLabel {
            textLabel.frame = containerView.bounds.insetBy(dx: define.pading_wight, dy: define.pading_wight / 2)
            textLabel.backgroundColor = .clear
            textLabel.font = Utils.getSubTitleFont()
            textLabel.textColor = .darkGray
        }
        
        // cell 선택 시 색상 변경 (예: 선택된 셀의 배경을 green으로)
        if indexPath == selectedIndexPath {
            containerView.backgroundColor = define.layout_bg_green
        }
        
        // 셀의 accessory는 containerView 위에 표시되도록 함 (기존 방식 그대로)
        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.hasSwitch ? .none : .disclosureIndicator
        if item.hasSwitch {
            let switchView = UISwitch()
            switchView.isOn = false
            cell.accessoryView = switchView
        } else {
            cell.accessoryView = nil
        }
        
        // Style the cell
//        styleCell(cell, at: indexPath)
        return cell
    }
    
//    private func styleCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
//        // 배경색 처리
//        if indexPath == selectedIndexPath {
//            cell.backgroundColor = define.layout_bg_green
//        } else {
//            cell.backgroundColor = .white
//        }
//
//        // 테이블 뷰의 배경색과 여백 일치
//        mainView.backgroundColor = .systemGray6
//
//        // 셀 내용에 패딩 적용
//        cell.contentView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
//        cell.contentView.layer.masksToBounds = true
//    }
    

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
    private lazy var networksettingVC: NetworkSettingController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "NetworkSettingController") as! NetworkSettingController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var devicesettingVC: DeviceSettingController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "DeviceSettingController") as! DeviceSettingController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var infoSettingVC: InfoSettingController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()
        var viewController = storyboard.instantiateViewController(withIdentifier: "InfoSettingController") as! InfoSettingController
         
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
 
    private lazy var printSettingVC: PrintSettingController = {
        // Load Storyboard
        let storyboard = getMainStoryBoard()

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "PrintSettingController") as! PrintSettingController

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
   
    private lazy var TaxSettingVC: TaxController = {
        let storyboard = getMainStoryBoard()

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "TaxController") as! TaxController

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
        remove(asChildViewController: networksettingVC)
        remove(asChildViewController: devicesettingVC)
        remove(asChildViewController: infoSettingVC)
        remove(asChildViewController: printSettingVC)
        remove(asChildViewController: storesettingVC)
        remove(asChildViewController: TaxSettingVC)
        remove(asChildViewController: ProductSettingVC)
        remove(asChildViewController: qnaVC)
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
            add(asChildViewController: TaxSettingVC)
            break
        case EnvironmentSplit.BT.rawValue:
            add(asChildViewController: devicesettingVC)
            break
        case EnvironmentSplit.CAT.rawValue:
            add(asChildViewController: devicesettingVC)
            break
        case EnvironmentSplit.PRINT.rawValue:
            add(asChildViewController: printSettingVC)
            break
        case EnvironmentSplit.PRODUCT.rawValue:
            add(asChildViewController: ProductSettingVC)
        case EnvironmentSplit.QNA.rawValue:
            add(asChildViewController: qnaVC)
            break
        case EnvironmentSplit.APPINFO.rawValue:
            add(asChildViewController: infoSettingVC)
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
                add(asChildViewController: networksettingVC)
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
