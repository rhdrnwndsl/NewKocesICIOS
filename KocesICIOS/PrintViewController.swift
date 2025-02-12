//
//  PrintViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/12/25.
//

import Foundation
import UIKit

class PrintViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var printlistener: PrintResult?
    var listener: TcpResult?
    let mCatSdk:CatSdk = CatSdk.instance
    var catlistener:CatResult?
    
    //로딩 메세지박스
    var alertLoading = UIAlertController()

    var scanTimeout:Timer?       //프린트시 타임아웃
    
    // MARK: - Section 1: 프린트 장치 설정
    
    private let deviceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "프린트 장치 설정"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deviceUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let deviceContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Row 1: 프린트장치 label + segmented control ("BT", "NET", 기본 "BT")
    private let printDeviceLabel: UILabel = {
        let label = UILabel()
        label.text = "프린트장치"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var printDeviceSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["BT", "NET"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.addTarget(self, action: #selector(printDeviceChanged(_:)), for: .valueChanged)
        return seg
    }()
    
    // BT 전용 내용 컨테이너
    private let btSettingsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private func createBTRow(labelText: String, valueText: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillProportionally
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 16)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let valueLabel = UILabel()
        valueLabel.text = valueText
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textAlignment = .right
        
        row.addArrangedSubview(label)
        row.addArrangedSubview(valueLabel)
        return row
    }
    
    // NET 전용 내용 컨테이너
    private let netSettingsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // NET 전용 행
    private func createNETRow(labelText: String, placeholder: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillProportionally
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 16)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        
        row.addArrangedSubview(label)
        row.addArrangedSubview(textField)
        return row
    }
    
    // 저장 NET 전용 텍스트필드를 참조 (필요 시 나중에 값 사용)
    private var printIPTextField: UITextField?
    private var portTextField: UITextField?
    
    // MARK: - Section 2: 프린트 출력 옵션
    
    private let printOptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "프린트 출력 옵션"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let printOptionUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let printOptionContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let customerPrintLabel: UILabel = {
        let label = UILabel()
        label.text = "고객용"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var customerPrintSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["출력", "미출력"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    
    // MARK: - Section 3: 하단 문구 출력
    
    private let bottomMessageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "하단 문구 출력"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bottomMessageUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomMessageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 하단문구 row
    private let bottomTextLabel: UILabel = {
        let label = UILabel()
        label.text = "하단문구"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bottomTextSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["사용", "미사용"])
        seg.selectedSegmentIndex = 1  // 기본 미사용
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    
    // 하단광고 row
    private let bottomAdLabel: UILabel = {
        let label = UILabel()
        label.text = "하단광고"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bottomAdSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["수동", "자동"])
        seg.selectedSegmentIndex = 1  // 기본 자동
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.addTarget(self, action: #selector(bottomAdSegmentChanged(_:)), for: .valueChanged)
        return seg
    }()
    
    private let adDownloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("광고다운로드", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.isHidden = false  // 초기값 자동이면 보임
        return button
    }()
    
    private let bottomUserTextField: UITextView = {
        let tf = UITextView()
//        tf.placeholder = "사용자 입력"
//        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // MARK: - Section 4: 하단 버튼 영역
    private let testButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("테스트", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Scroll View & Main StackView
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomUserTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)
        setupUI()
        setupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        //등록된 노티 전체 제거
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didBle(_ notification: Notification) {
        guard let bleStatus: String = notification.userInfo?["Status"] as? String else { return }
        switch bleStatus {

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
 
        default:
            break
        }
        
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // Section 1: 프린트 장치 설정
        mainStackView.addArrangedSubview(deviceTitleLabel)
        mainStackView.addArrangedSubview(deviceUnderline)
        deviceUnderline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        mainStackView.addArrangedSubview(deviceContainer)
        
        // deviceContainer 내부
        let deviceRow = UIStackView(arrangedSubviews: [printDeviceLabel, printDeviceSegmented])
        deviceRow.axis = .horizontal
        deviceRow.spacing = 10
        deviceRow.distribution = .fillProportionally
        deviceRow.translatesAutoresizingMaskIntoConstraints = false
        deviceContainer.addSubview(deviceRow)
        NSLayoutConstraint.activate([
            deviceRow.topAnchor.constraint(equalTo: deviceContainer.topAnchor, constant: 10),
            deviceRow.leadingAnchor.constraint(equalTo: deviceContainer.leadingAnchor, constant: 10),
            deviceRow.trailingAnchor.constraint(equalTo: deviceContainer.trailingAnchor, constant: -10),
            deviceRow.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // BT Settings Stack
        let btRow1 = createDeviceRow(labelText: "BT연결상태", valueText: "연결 장치 없습니다")
        let btRow2 = createDeviceRow(labelText: "제품식별번호", valueText: "v1.0.1.3")
        let btRow3 = createDeviceRow(labelText: "출력가능여부", valueText: "프린트 가능")
        btSettingsStack.addArrangedSubview(btRow1)
        btSettingsStack.addArrangedSubview(btRow2)
        btSettingsStack.addArrangedSubview(btRow3)
        deviceContainer.addSubview(btSettingsStack)
        NSLayoutConstraint.activate([
            btSettingsStack.topAnchor.constraint(equalTo: deviceRow.bottomAnchor, constant: 10),
            btSettingsStack.leadingAnchor.constraint(equalTo: deviceContainer.leadingAnchor, constant: 10),
            btSettingsStack.trailingAnchor.constraint(equalTo: deviceContainer.trailingAnchor, constant: -10)
        ])
        
        // NET Settings Stack
        let netRow1 = createDeviceRow(labelText: "PRINT IP", valueText: "")
        let netRow2 = createDeviceRow(labelText: "PORT", valueText: "")
        netSettingsStack.addArrangedSubview(netRow1)
        netSettingsStack.addArrangedSubview(netRow2)
        deviceContainer.addSubview(netSettingsStack)
        NSLayoutConstraint.activate([
            netSettingsStack.topAnchor.constraint(equalTo: deviceRow.bottomAnchor, constant: 10),
            netSettingsStack.leadingAnchor.constraint(equalTo: deviceContainer.leadingAnchor, constant: 10),
            netSettingsStack.trailingAnchor.constraint(equalTo: deviceContainer.trailingAnchor, constant: -10)
        ])
        netSettingsStack.isHidden = true  // 초기 "BT" 선택
        
        // Section 2: 프린트 출력 옵션
        mainStackView.addArrangedSubview(printOptionTitleLabel)
        mainStackView.addArrangedSubview(printOptionUnderline)
        printOptionUnderline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        mainStackView.addArrangedSubview(printOptionContainer)
        let printOptionRow = UIStackView(arrangedSubviews: [customerPrintLabel, customerPrintSegmented])
        printOptionRow.axis = .horizontal
        printOptionRow.spacing = 10
        printOptionRow.distribution = .fillProportionally
        printOptionRow.translatesAutoresizingMaskIntoConstraints = false
        printOptionContainer.addSubview(printOptionRow)
        NSLayoutConstraint.activate([
            printOptionRow.topAnchor.constraint(equalTo: printOptionContainer.topAnchor, constant: 10),
            printOptionRow.leadingAnchor.constraint(equalTo: printOptionContainer.leadingAnchor, constant: 10),
            printOptionRow.trailingAnchor.constraint(equalTo: printOptionContainer.trailingAnchor, constant: -10),
            printOptionRow.heightAnchor.constraint(equalToConstant: 30)
        ])
        printOptionContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Section 3: 하단 문구 출력
        mainStackView.addArrangedSubview(bottomMessageTitleLabel)
        mainStackView.addArrangedSubview(bottomMessageUnderline)
        bottomMessageUnderline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        mainStackView.addArrangedSubview(bottomMessageContainer)
        
        let bottomRow1 = UIStackView(arrangedSubviews: [bottomTextLabel, bottomTextSegmented])
        bottomRow1.axis = .horizontal
        bottomRow1.spacing = 10
        bottomRow1.distribution = .fillProportionally
        bottomRow1.translatesAutoresizingMaskIntoConstraints = false
        bottomMessageContainer.addSubview(bottomRow1)
        NSLayoutConstraint.activate([
            bottomRow1.topAnchor.constraint(equalTo: bottomMessageContainer.topAnchor, constant: 10),
            bottomRow1.leadingAnchor.constraint(equalTo: bottomMessageContainer.leadingAnchor, constant: 10),
            bottomRow1.trailingAnchor.constraint(equalTo: bottomMessageContainer.trailingAnchor, constant: -10),
            bottomRow1.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let bottomRow2 = UIStackView(arrangedSubviews: [bottomAdLabel, bottomAdSegmented])
        bottomRow2.axis = .horizontal
        bottomRow2.spacing = 10
        bottomRow2.distribution = .fillProportionally
        bottomRow2.translatesAutoresizingMaskIntoConstraints = false
        bottomMessageContainer.addSubview(bottomRow2)
        NSLayoutConstraint.activate([
            bottomRow2.topAnchor.constraint(equalTo: bottomRow1.bottomAnchor, constant: 10),
            bottomRow2.leadingAnchor.constraint(equalTo: bottomMessageContainer.leadingAnchor, constant: 10),
            bottomRow2.trailingAnchor.constraint(equalTo: bottomMessageContainer.trailingAnchor, constant: -10),
            bottomRow2.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        bottomMessageContainer.addSubview(adDownloadButton)
        NSLayoutConstraint.activate([
            adDownloadButton.topAnchor.constraint(equalTo: bottomRow2.bottomAnchor, constant: 10),
            adDownloadButton.leadingAnchor.constraint(equalTo: bottomMessageContainer.leadingAnchor, constant: 10),
            adDownloadButton.widthAnchor.constraint(equalToConstant: 140),
            adDownloadButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        adDownloadButton.isHidden = (bottomAdSegmented.selectedSegmentIndex == 0) // 수동이면 숨김, 자동이면 보임
        
        bottomMessageContainer.addSubview(bottomUserTextField)
        NSLayoutConstraint.activate([
            bottomUserTextField.topAnchor.constraint(equalTo: adDownloadButton.bottomAnchor, constant: 10),
            bottomUserTextField.leadingAnchor.constraint(equalTo: bottomMessageContainer.leadingAnchor, constant: 10),
            bottomUserTextField.trailingAnchor.constraint(equalTo: bottomMessageContainer.trailingAnchor, constant: -10),
            bottomUserTextField.heightAnchor.constraint(equalToConstant: 30),
            bottomUserTextField.bottomAnchor.constraint(equalTo: bottomMessageContainer.bottomAnchor, constant: -10)
        ])
        
        bottomMessageContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
        
        // Section 4: 하단 버튼 영역
        let buttonStack = UIStackView(arrangedSubviews: [testButton, saveButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(buttonStack)
        testButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Actions
        printDeviceSegmented.addTarget(self, action: #selector(printDeviceChanged(_:)), for: .valueChanged)
        bottomAdSegmented.addTarget(self, action: #selector(bottomAdSegmentChanged(_:)), for: .valueChanged)
        testButton.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        adDownloadButton.addTarget(self, action: #selector(adDownloadButtonTapped), for: .touchUpInside)
    }
    
    func setupData() {
        if Setting.shared.getDefaultUserData(_key: define.PRINT_CUSTOMER) == "PRINT_NONE" {
            customerPrintSegmented.selectedSegmentIndex = 1
        }
        else {
            customerPrintSegmented.selectedSegmentIndex = 0
        }

        if Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL).isEmpty {
            bottomTextSegmented.selectedSegmentIndex = 1
//            mPrintUseCheckView.isHidden = true
//            mPrintUseCheckView.alpha = 0.0
        }
        else {
            bottomTextSegmented.selectedSegmentIndex = 0
//            mPrintUseCheckView.isHidden = false
//            mPrintUseCheckView.alpha = 1.0
        }
        
        bottomUserTextField.layer.borderColor = define.layout_border_lightgrey.cgColor
        bottomUserTextField.layer.borderWidth = 1
        if Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL).isEmpty || Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL) == "" {
            bottomUserTextField.text = ""
        } else {
            bottomUserTextField.text = Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL)
        }
        
        //프린트를 자동으로할건지 수동으로 할건지 처리
        if Setting.shared.getDefaultUserData(_key: define.PRINT_AD_AUTO).isEmpty ||
            Setting.shared.getDefaultUserData(_key: define.PRINT_AD_AUTO) == "" {
            //수동설정
            bottomAdSegmented.selectedSegmentIndex = 1
            bottomUserTextField.isEditable = true
            
//            adDownloadButton.isHidden = true
//            adDownloadButton.alpha = 0.0
            
        } else {
            //자동설정
            bottomAdSegmented.selectedSegmentIndex = 0
            bottomUserTextField.isEditable = false
            
//            adDownloadButton.isHidden = false
//            adDownloadButton.alpha = 1.0
        }
        
   
        let bar = UIToolbar()
                
        //새로운 버튼을 만든다
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        
        //
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
        //
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
        bottomUserTextField.inputAccessoryView = bar
        
        listener = TcpResult()
        listener?.delegate = self
    }
    
    @objc func dismissMyKeyboard(){
           view.endEditing(true)
       }
    
    // Helper: 공통 행 생성 함수
    private func createDeviceRow(labelText: String, valueText: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = valueText
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(label)
        row.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: row.topAnchor),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            label.widthAnchor.constraint(equalToConstant: 120),
            
            valueLabel.topAnchor.constraint(equalTo: row.topAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
        return row
    }
    
    // MARK: - Action Methods
    @objc func printDeviceChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { // BT selected
            btSettingsStack.isHidden = false
            netSettingsStack.isHidden = true
        } else { // NET selected
            btSettingsStack.isHidden = true
            netSettingsStack.isHidden = false
        }
    }
    
    @objc func bottomAdSegmentChanged(_ sender: UISegmentedControl) {
        // "수동"이면 index 0, "자동"이면 index 1
        adDownloadButton.isHidden = (sender.selectedSegmentIndex == 0)
    }
    
    @objc func testButtonTapped() {
        print("테스트 버튼 클릭")
        if mKocesSdk.blePrintState == define.PrintDeviceState.BLENOPRINT {
            AlertBox(title: "BLE 프린트 테스트", message: "프린트 가능한 BLE 장비를 연결해 주세요", text: "확인")
            return
        }
        
        //cat 연동일 경우
        else if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
            let _catMsg = Utils.CheckPrintCatPortIP()
            if _catMsg != "" {
                AlertBox(title: "BLE 프린트 테스트", message: _catMsg, text: "확인")
                return
            }
        } else {
            if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
                AlertBox(title: "BLE 프린트 테스트", message: "연결이 되어 있지 않습니다. 연결 후 실행 해 주세요", text: "확인")
                return
            }
            if !Utils.PrintDeviceCheck().isEmpty {
                AlertBox(title: "BLE 프린트 테스트", message: "출력 가능 장비 없음", text: "확인")
                return
            }
        }

        if Setting.shared.getDefaultUserData(_key: define.PRINT_CUSTOMER) == "PRINT_NONE" {
            AlertBox(title: "BLE 프린트 테스트", message: "출력 옵션에 출력 가능 옵션(고객용)이 설정되지 않았습니다", text: "확인")
            return
        }
        
        //검색될 때까지 로딩메세지박스를 띄운다
        Utils.printAlertBox(Title: "프린트 출력중입니다", LoadingBar: true, GetButton: "")
        printTimeOut()
        let 왼쪽 = define.PLEFT
        let 중앙 = define.PCENTER
        let 오른쪽 = define.PRIGHT
        let 엔터 = define.PENTER
 
        let _p:[UInt8] = [
        0x32, 0x30, 0x32, 0x34, 0x31, 0x32, 0x32, 0x37, 0x39, 0x35, 0x31, 0x30, 0x35, 0xE2, 0x80, 0xAF, 0x41, 0x4D
        ]
        
        var str = (Utils.PrintCenter(Center: " 테 스 트 ") + define.PENTER)
        str += Utils.UInt8ArrayToStr(UInt8Array: _p) + 엔터
        str += 오른쪽 + " 한국신용카드결제(주) " + 엔터
//        str +=  define.PBOLDSTART + " 신용매출 " + define.PBOLDEND + 엔터
        str += Setting.shared.getDefaultUserData(_key: define.STORE_NAME) + 엔터
        str += Setting.shared.getDefaultUserData(_key: define.STORE_OWNER) + 엔터
        str += "사업자 번호 :" + Setting.shared.getDefaultUserData(_key: define.STORE_BSN) + 엔터
        str += "TEL: " + Setting.shared.getDefaultUserData(_key: define.STORE_PHONE) + 엔터
        str += Setting.shared.getDefaultUserData(_key: define.STORE_ADDR) + 엔터
        str += String.init(repeating: "-", count: 48)
        str += "TID: " + Setting.shared.getDefaultUserData(_key: define.STORE_TID) + 엔터

        str += String.init(repeating: "=", count: 48)

        if !Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL).isEmpty {
            str += (Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL) + define.PENTER)
        }
        let prtStr = mKocesSdk.PrintParser(파싱할프린트내용: str)
        catlistener = CatResult()
        catlistener?.delegate = self
        DispatchQueue.global().asyncAfter(deadline: .now() + 1){ [self] in
            if mKocesSdk.blePrintState == define.PrintDeviceState.CATUSEPRINT {
                mCatSdk.Print(파싱할프린트내용: prtStr, CompletionCallback: catlistener?.delegate! as! CatResultDelegate)
            } else if mKocesSdk.blePrintState == define.PrintDeviceState.BLEUSEPRINT {
                BlePrinter(내용: prtStr)
            } else {
                if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED {
                    BlePrinter(내용: prtStr)
                } else if mKocesSdk.bleState == define.TargetDeviceState.CATCONNECTED {
                    mCatSdk.Print(파싱할프린트내용: prtStr, CompletionCallback: catlistener?.delegate! as! CatResultDelegate)
                }
            }
        }
    }
    
    @objc func saveButtonTapped() {
        print("저장 버튼 클릭")
        // 저장 처리 구현
        //로컬에 데이터 저장
        let _lowlavel:String = bottomUserTextField.text ?? ""
        if customerPrintSegmented.selectedSegmentIndex == 0 {   //출력 = 0
            Setting.shared.setDefaultUserData(_data: "PRINT_CUSTOMER", _key: define.PRINT_CUSTOMER)
        } else {    //미출력 = 1
            Setting.shared.setDefaultUserData(_data: "PRINT_NONE", _key: define.PRINT_CUSTOMER)
        }

        if bottomTextSegmented.selectedSegmentIndex == 0 {  //사용 = 0
            Setting.shared.setDefaultUserData(_data: _lowlavel, _key: define.PRINT_LOWLAVEL)
        } else {    //미사용 = 1
            Setting.shared.setDefaultUserData(_data: "", _key: define.PRINT_LOWLAVEL)
            bottomUserTextField.text = ""
        }
        
        //프린트를 자동으로할건지 수동으로 할건지 처리
        if bottomAdSegmented.selectedSegmentIndex == 1 { //자동설정 = 1
            Setting.shared.setDefaultUserData(_data: define.PRINT_AD_AUTO, _key: define.PRINT_AD_AUTO)
            bottomUserTextField.isEditable = false
        } else { //수동설정 = 0
            Setting.shared.setDefaultUserData(_data: "", _key: define.PRINT_AD_AUTO)
            bottomUserTextField.isEditable = true
        }
        
        AlertBox(title: "성공", message: "설정이 저장되었습니다.", text: "확인")
    }
    
    @objc func adDownloadButtonTapped() {
        print("광고다운로드 버튼 클릭")
        // 광고 다운로드 처리 구현
    }
    
    func printTimeOut() {
        self.scanTimeout = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false, block: { timer in
            var resDataDic:[String:String] = [:]    //응답 데이터 key,Value구분
            resDataDic["Message"] = NSString("프린트를 실패(타임아웃)하였습니다") as String
            self.onPrintResult(printStatus: .OK, printResult: resDataDic)
            self.scanTimeout?.invalidate()
            self.scanTimeout = nil
        })
    }
    
    ///경고 박스
    func AlertBox(title : String, message : String, text : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okButton)
        return self.present(alertController, animated: true, completion: nil)
    }
}

extension PrintViewController: PrintResultDelegate, CatResultDelegate, TcpResultDelegate {
    func onDirectResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>, DirectData _directData: Dictionary<String, String>) {
        print(_result)
    }
    
    func onKeyResult(tcpStatus _status: tcpStatus, Result _result: [UInt8], DicResult _dicresult: Dictionary<String, String>) {
        print(_result)
    }
    
    func onResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>) {
        print(_result)
        alertLoading.dismiss(animated: true) { [self] in
            if _result["AnsCode"] == "0000" {
                AlertBox(title: "결과", message: "광고문구 다운로드를 완료하였습니다", text: "확인")
                Setting.shared.setDefaultUserData(_data: _result["AdInfoData"] ?? "", _key: define.PRINT_LOWLAVEL)
                bottomUserTextField.text = Setting.shared.getDefaultUserData(_key: define.PRINT_LOWLAVEL)
                
                saveButtonTapped()
            }
            else
            {
                AlertBox(title: "에러", message: " 응답코드: \(_result["AnsCode"] ?? "") \n \(_result["Message"] ?? "") ", text: "확인")
            }
        }
        
    }
    
    func onResult(CatState _state:payStatus,Result _message:Dictionary<String,String>) {
        self.scanTimeout?.invalidate()
        self.scanTimeout = nil
        Utils.customAlertBoxClear()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "프린트결과", message: _message["Message"] ?? "프린트에 실패하였습니다", text: "확인")
            }
        }
    }
    
    func BlePrinter(내용 _Contents:String) {
        mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
        
        printlistener = PrintResult()
        printlistener?.delegate = self
        mKocesSdk.BlePrinter(내용: _Contents, CallbackListener: printlistener?.delegate as! PrintResultDelegate)
    }
    
    func onPrintResult(printStatus _status: printStatus, printResult _result: Dictionary<String, String>) {
        self.scanTimeout?.invalidate()
        self.scanTimeout = nil
        Utils.customAlertBoxClear()
        
        if (_result["Message"] ?? "").contains("완료") {
            
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "프린트결과", message: _result["Message"] ?? "프린트에 실패하였습니다", text: "확인")
            }
        }
    }
}
