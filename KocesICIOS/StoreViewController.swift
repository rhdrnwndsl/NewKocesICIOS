//
//  StoreViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/4/25.
//

import Foundation
import UIKit

// MARK: - 간단한 모델 구조체 예시
struct MerchantInfo {
    var tid: String
    var businessNumber: String
    var storeName: String
    var phoneNumber: String
    var address: String
    var representativeName: String
}

protocol StoreViewControllerDelegate: AnyObject {
    func storeViewControllerInit(_ controller: StoreViewController)
}

class StoreViewController: UIViewController {
    weak var delegate: StoreViewControllerDelegate?
    
    let mKocesSdk:KocesSdk = KocesSdk.instance
    var listener: TcpResult?
    let mSqlite:sqlite = sqlite.instance
    //로딩 메세지박스
    var alertLoading = UIAlertController()
    // 대표사업자 (무조건 1개)
    private var representativeMerchant = MerchantInfo(
        tid: "",
        businessNumber: "",
        storeName: "",
        phoneNumber: "",
        address: "",
        representativeName: ""
    )
     
    // 서브사업자 (0~10개 가능)
    private var subMerchants: [MerchantInfo] = [
           // 10개 빈 객체 (필요한 경우 실제 데이터로 채워짐)
           MerchantInfo(tid: "", businessNumber: "", storeName: "", phoneNumber: "", address: "", representativeName: ""),
           MerchantInfo(tid: "", businessNumber: "", storeName: "", phoneNumber: "", address: "", representativeName: ""),
           MerchantInfo(tid: "", businessNumber: "", storeName: "", phoneNumber: "", address: "", representativeName: ""),
           MerchantInfo(tid: "", businessNumber: "", storeName: "", phoneNumber: "", address: "", representativeName: ""),
           MerchantInfo(tid: "", businessNumber: "", storeName: "", phoneNumber: "", address: "", representativeName: ""),
           MerchantInfo(tid: "", businessNumber: "", storeName: "", phoneNumber: "", address: "", representativeName: ""),
           MerchantInfo(tid: "", businessNumber: "", storeName: "", phoneNumber: "", address: "", representativeName: ""),
           MerchantInfo(tid: "", businessNumber: "", storeName: "", phoneNumber: "", address: "", representativeName: ""),
           MerchantInfo(tid: "", businessNumber: "", storeName: "", phoneNumber: "", address: "", representativeName: ""),
           MerchantInfo(tid: "", businessNumber: "", storeName: "", phoneNumber: "", address: "", representativeName: "")
       ]
    
    // 서브사업자정보 표시 여부
    private var isSubMerchantExpanded: Bool = false
    
    // MARK: - UI 컴포넌트
    private let scrollView = UIScrollView()
    private let titleStackView = UIStackView() // 상단 고정 영역 (예: "POS" 라벨 등)
    public let contentStackView = UIStackView() //대표/서브사업자 정보를 담은 기존 UI (등록 시 숨김)
    private var registrationView: UIView? // 신규 등록용 UI (등록 버튼 클릭 시 보여질)
    
    // 맨 위에 표시할 "POS" 라벨
    private let representativePosLabelView = UIView()
    private lazy var posLabel: UILabel = {
        let label = UILabel()
        label.text = Utils.getIsCAT() ? "CAT":"POS"
        label.font = Utils.getTitleFont()
        label.textAlignment = .left
        return label
    }()
    
    // 대표사업자 상단 헤더(제목 + 화살표)
    private let representativeHeaderView = UIView()
    private lazy var representativeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "대표사업자정보"
        label.font = Utils.getSubTitleFont()
        return label
    }()
    private let arrowButton: UIButton = {
        let button = UIButton(type: .system)
        // 화살표 이미지는 프로젝트 내 적절한 Asset을 사용하세요.
        // 여기서는 SF Symbol 예시: "chevron.down" 사용(초기값)
        if let image = UIImage(systemName: "chevron.down") {
            button.setImage(image, for: .normal)
        }
        button.tintColor = .black
        return button
    }()
    
    // 대표사업자 구분선
    private let representativeDivider: UIView = {
        let view = UIView()
        view.backgroundColor = define.underline_grey
        return view
    }()
       
    // 대표사업자 정보 뷰 (TID ~ 대표자명)
    private let representativeInfoView = UIView()

    // 대표사업자 버튼 영역(가맹점등록, 정보수정)
    private let representativeButtonView = UIView()
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("가맹점등록", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Utils.getSubTitleFont()
        button.layer.cornerRadius = 8
        return button
    }()
    private lazy var repEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("정보수정", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Utils.getSubTitleFont()
        button.layer.cornerRadius = 8
        return button
    }()
    
    // 서브사업자 영역을 담을 스택뷰
    private let subMerchantStackView = UIStackView()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmented = UISegmentedControl(items: ["일반", "복수"])
        segmented.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0),
            NSAttributedString.Key.font: Utils.getTextFont()
        ], for: .normal)
        segmented.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: define.txt_blue,
            NSAttributedString.Key.font: Utils.getTextFont()
        ], for: .selected)
        return segmented
    }()
  
    private lazy var serialNumberTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "시리얼번호 입력"
        textField.font = Utils.getTextFont()
        return textField
    }()
    private lazy var bisNumberTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "사업자번호 입력"
        textField.font = Utils.getTextFont()
        return textField
    }()
    private lazy var tidNumberTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "TID 입력"
        textField.font = Utils.getTextFont()
        return textField
    }()

    private var countAck: Int = 0
    let CharMaxLength = 10
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didBle(_:)), name: NSNotification.Name(rawValue: "BLEStatus"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        //등록된 노티 전체 제거
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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


            print(deviceName)
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
                DispatchQueue.main.async{ [self] in
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
            let resData:[UInt8] = mKocesSdk.mReceivedData

            if resData[3] == Command.ACK && countAck == 0 {
                if (mKocesSdk.mBleConnectedName.contains(define.bleName) || mKocesSdk.mBleConnectedName.contains(define.bleNameNew)) {
                    debugPrint("ACK 데이터 버림")
                    countAck += 1
                    return
                } else {
 
                }
            }
            
            countAck = 0
            // 검색할 때 띄웠던 로딩박스를 지운다
            alertLoading.dismiss(animated: true){ [self] in
                switch resData[3] {
                case Command.CMD_POSINFO_RES:
                    var spt:Int = 4
                    let TmIcNo = Utils.UInt8ArrayToStr(UInt8Array: Array(resData[spt...spt + 15]))
                    Setting.shared.setDefaultUserData(_data: TmIcNo, _key: define.APP_ID)
                    spt += 32
                    let serialNumber = Utils.UInt8ArrayToStr(UInt8Array: Array(resData[spt...spt + 9]))
                    spt += 10
                    let version = Utils.UInt8ArrayToStr(UInt8Array: Array(resData[spt...spt + 4]))
                    spt += 5
                    let key = Utils.UInt8ArrayToStr(UInt8Array: Array(resData[spt...spt + 1]))
                    mKocesSdk.mKocesCode = define.KOCES_ID
                    mKocesSdk.mAppCode = define.KOCES_APP_ID
                    mKocesSdk.mModelNumber = TmIcNo
                    mKocesSdk.mSerialNumber = serialNumber
                    mKocesSdk.mModelVersion = version //version
                    /** 시리얼번호 저장 */
                    //Setting.shared.setDefaultUserData(_data: serialNumber, _key: define.STORE_SERIAL) //가맹점 등록이 완료 되지 않은 상태에서 시리얼 저장 안함.
                    serialNumberTextField.text = serialNumber
                    
                    if mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
                        AlertBox(title: "무결성검증실패", message: "리더기 무결성 검증실패 제조사A/S요망", text: "확인")
                        return
                    }
                    
                    if key != "00" {
                        AlertBox(title: "장치정보", message: "키 갱신이 필요합니다", text: "확인")
                    } else {
//                        let alertController = UIAlertController(title: "무결성검사", message: "무결성검사가 정상입니다", preferredStyle: UIAlertController.Style.alert)
//                        let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){_ in
//
//                        }
//                        alertController.addAction(okButton)
//                        self.present(alertController, animated: true, completion: nil)
                    }
                  
                    break
                case Command.NAK:
                    AlertBox(title: "결과", message: "장치 오류. 연결 해제 후, 다시 연결을 시도해 주세요.", text: "확인")
                    break
                case Command.CMD_VERITY_RES:
                    //무결성검사가 정상인지 아닌지를 체크하여 메세지박스로 표시한다
                    var _resultMessage:String = ""
                    switch resData[4...5] {
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
                    print(_resultMessage)
                    mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
                    
                    mKocesSdk.GetDeviceInfo(Date: Utils.getDate(format: "yyyyMMddHHmmss"))

                    
                    break
                default:
                    break
                }
            }
            break

        default:
            break
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        configureActions()
        // 초기에는 서브사업자 정보를 숨긴 상태
        updateSubMerchantVisibility(animated: false)
    }
    
    

    // MARK: - UI 설정
    private func setupUI() {
        view.backgroundColor = .white
        
        // scrollView + contentStackView
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // titleStackView: 상단 영역 (예: POS, 구분선 등)
        titleStackView.axis = .vertical
        titleStackView.alignment = .fill
        titleStackView.distribution = .fill
        scrollView.addSubview(titleStackView)
        
        // --- titleStackView에 "POS" 영역 추가
        representativePosLabelView.addSubview(posLabel)
        titleStackView.addArrangedSubview(representativePosLabelView)
        
        // titleStackView에 구분선 추가
        let divider = UIView()
        divider.backgroundColor = define.underline_grey
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        titleStackView.addArrangedSubview(divider)
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        scrollView.addSubview(contentStackView)
        
        // --- 데이터 셋업
        setupStoreInfoData()
        setupRepresentativeInfoView()
        
        // --- 대표사업자 상단 헤더(제목 + 화살표)
        representativeHeaderView.addSubview(representativeTitleLabel)
        representativeHeaderView.addSubview(arrowButton)
        contentStackView.addArrangedSubview(representativeHeaderView)
        
        // --- 대표사업자 구분선
        contentStackView.addArrangedSubview(representativeDivider)
        representativeDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // --- 대표사업자 정보뷰
        contentStackView.addArrangedSubview(representativeInfoView)
        
        // --- 대표사업자 버튼 영역
        setupRepresentativeButtonView()
        contentStackView.addArrangedSubview(representativeButtonView)
        
        // --- 서브사업자 스택뷰
        subMerchantStackView.axis = .vertical
        subMerchantStackView.alignment = .fill
        subMerchantStackView.distribution = .fill
        contentStackView.addArrangedSubview(subMerchantStackView)
        
        // 서브사업자 UI(초기에 추가만 해두고, 펼쳐진 상태 업데이트는 toggle 로직으로 처리)
        refreshSubMerchantViews()
    }

    // MARK: - 데이터 로드 (예시)
    
    //가맹점 정보 가져오기
    private func setupStoreInfoData() {
        // UserDefaults나 Setting.shared에서 데이터를 읽어와 representativeMerchant와 subMerchants에 할당
        var count = "1"
        for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.contains(define.STORE_TID) {
                if Utils.getIsCAT() {
                    if key == "CAT_STORE_TID" || key == "CAT_STORE_TID0" {
                        self.representativeMerchant = MerchantInfo(
                            tid: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID)),
                            businessNumber: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN)),
                            storeName: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME)),
                            phoneNumber: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE)),
                            address: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR)),
                            representativeName: (Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER) == "" ? Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + "0"):Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER))
                        )
                        
                    } else {
                        for i in 1...10 {
                            if key == "CAT_STORE_TID" + String(i) {
                                count = String(i)
                                self.subMerchants[i - 1] = MerchantInfo(
                                    tid: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_TID + count),
                                    businessNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_BSN + count),
                                    storeName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_NAME + count),
                                    phoneNumber: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_PHONE + count),
                                    address: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_ADDR + count),
                                    representativeName: Setting.shared.getDefaultUserData(_key: define.CAT_STORE_OWNER + count)
                                )
                            }
                        }
                    }
                } else {
                    //로컬 가맹점 정보 읽어서 표시 하기
                    if key == "STORE_TID" || key == "STORE_TID0" {
                        self.representativeMerchant = MerchantInfo(
                            tid: (Setting.shared.getDefaultUserData(_key: define.STORE_TID) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_TID + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_TID)),
                            businessNumber: (Setting.shared.getDefaultUserData(_key: define.STORE_BSN) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_BSN + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_BSN)),
                            storeName: (Setting.shared.getDefaultUserData(_key: define.STORE_NAME) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_NAME + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_NAME)),
                            phoneNumber: (Setting.shared.getDefaultUserData(_key: define.STORE_PHONE) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_PHONE)),
                            address: (Setting.shared.getDefaultUserData(_key: define.STORE_ADDR) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_ADDR)),
                            representativeName: (Setting.shared.getDefaultUserData(_key: define.STORE_OWNER) == "" ? Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + "0"):Setting.shared.getDefaultUserData(_key: define.STORE_OWNER))
                        )
                        
                    } else {
                        for i in 1...10 {
                            if key == "STORE_TID" + String(i) {
                                count = String(i)
                                self.subMerchants[i - 1] = MerchantInfo(
                                    tid: Setting.shared.getDefaultUserData(_key: define.STORE_TID + count),
                                    businessNumber: Setting.shared.getDefaultUserData(_key: define.STORE_BSN + count),
                                    storeName: Setting.shared.getDefaultUserData(_key: define.STORE_NAME + count),
                                    phoneNumber: Setting.shared.getDefaultUserData(_key: define.STORE_PHONE + count),
                                    address: Setting.shared.getDefaultUserData(_key: define.STORE_ADDR + count),
                                    representativeName: Setting.shared.getDefaultUserData(_key: define.STORE_OWNER + count)
                                )
                            }
                        }
                    }
                }
            }
        }

    }
    
    // 대표사업자 정보뷰(라운드 박스)
    private func setupRepresentativeInfoView() {
        representativeInfoView.backgroundColor = .clear
        representativeInfoView.layer.cornerRadius = 0
        // 예시: 6개의 항목 각각 가로 스택(왼쪽 타이틀, 오른쪽 데이터)
        let items: [(String, String)] = [
            ("TID", representativeMerchant.tid),
            ("사업자번호", representativeMerchant.businessNumber),
            ("가맹점명", representativeMerchant.storeName),
            ("전화번호", representativeMerchant.phoneNumber),
            ("가맹점주소", representativeMerchant.address),
            ("대표자명", representativeMerchant.representativeName)
        ]
        
        // 전체를 세로 스택으로 묶어서 infoView에 추가
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.spacing = 5
        verticalStack.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        verticalStack.layer.cornerRadius = 8
        
        for (title, value) in items {
            let rowStack = createTwoLabelRow(title: title, value: value)
            verticalStack.addArrangedSubview(rowStack)
        }
        
        representativeInfoView.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: representativeInfoView.topAnchor, constant: 10),
            verticalStack.leadingAnchor.constraint(equalTo: representativeInfoView.leadingAnchor, constant: 10),
            verticalStack.trailingAnchor.constraint(equalTo: representativeInfoView.trailingAnchor, constant: -10),
            verticalStack.bottomAnchor.constraint(equalTo: representativeInfoView.bottomAnchor, constant: -10)
        ])
    }
    
    // 대표사업자 버튼 영역(배경/라운드 없음, 오른쪽 정렬)
    private func setupRepresentativeButtonView() {
        representativeButtonView.backgroundColor = .clear
        representativeButtonView.layer.cornerRadius = 0
        
        // 수평 스택 뷰로 버튼을 오른쪽에 몰기 위해 스페이서 사용
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let buttonStack = UIStackView(arrangedSubviews: [spacerView, registerButton, repEditButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.spacing = 5
        
        representativeButtonView.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        // 버튼 레이아웃 예시
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: representativeButtonView.topAnchor, constant: 0),
            registerButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            registerButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
                     
            repEditButton.topAnchor.constraint(equalTo: representativeButtonView.topAnchor, constant: 0),
            repEditButton.leadingAnchor.constraint(equalTo: registerButton.trailingAnchor, constant: 10),
            repEditButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
            repEditButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            buttonStack.topAnchor.constraint(equalTo: representativeButtonView.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: representativeButtonView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: representativeButtonView.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: representativeButtonView.bottomAnchor)
        ])
    }
    
    // MARK: - 서브사업자 영역 갱신
    private func refreshSubMerchantViews() {
        // 기존에 있던 서브뷰 모두 제거
        subMerchantStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, merchant) in subMerchants.enumerated() {
            if merchant.tid == "" {
                continue
            }
            
            // 서브사업자 상단 헤더(제목)
            let headerView = createSubMerchantHeaderView()
            
            // 구분선
            let divider = UIView()
            divider.backgroundColor = define.underline_grey
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            // 서브사업자 정보뷰(라운드 박스)
            let infoView = createSubMerchantInfoView(merchant: merchant)
            
            // 서브사업자 버튼영역(배경/라운드 없음, 오른쪽 정렬)
            let buttonView = createSubMerchantButtonView(merchantIndex: index)
            
            subMerchantStackView.addArrangedSubview(headerView)
            subMerchantStackView.addArrangedSubview(divider)
            subMerchantStackView.addArrangedSubview(infoView)
            subMerchantStackView.addArrangedSubview(buttonView)
        }
    }
    
    //서브사업자 헤더뷰 만들기
    private func createSubMerchantHeaderView() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.layer.cornerRadius = 0

        let label = UILabel()
        label.text = "서브사업자정보"
        label.font = Utils.getSubTitleFont()
        
        let stack = UIStackView(arrangedSubviews: [label])
        stack.axis = .vertical
        stack.alignment = .leading
          
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stack.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
        ])
   
        return container
    }
    
    // 서브사업자 정보뷰 만들기 (라운드 박스, 6개의 항목)
    private func createSubMerchantInfoView(merchant: MerchantInfo) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.layer.cornerRadius = 0
        
        let items: [(String, String)] = [
            ("TID", merchant.tid),
            ("사업자번호", merchant.businessNumber),
            ("가맹점명", merchant.storeName),
            ("전화번호", merchant.phoneNumber),
            ("가맹점주소", merchant.address),
            ("대표자명", merchant.representativeName)
        ]
        
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.spacing = 5
        verticalStack.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        verticalStack.layer.cornerRadius = 8
        
        for (title, value) in items {
            let rowStack = createTwoLabelRow(title: title, value: value)
            verticalStack.addArrangedSubview(rowStack)
        }
        
        container.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10)
        ])
        
        return container
    }
    
    // 서브사업자 버튼영역 만들기(가맹점제거, 정보수정) - 배경/라운드 없고 오른쪽 정렬
    private func createSubMerchantButtonView(merchantIndex: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.layer.cornerRadius = 0
        
        let removeButton = UIButton(type: .system)
        removeButton.setTitle("가맹점제거", for: .normal)
        removeButton.titleLabel?.font = Utils.getSubTitleFont()
        removeButton.backgroundColor = .systemRed
        removeButton.setTitleColor(.white, for: .normal)
        removeButton.layer.cornerRadius = 8
        removeButton.tag = merchantIndex
        
        let editButton = UIButton(type: .system)
        editButton.setTitle("정보수정", for: .normal)
        editButton.titleLabel?.font = Utils.getSubTitleFont()
        editButton.backgroundColor = .systemGreen
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 8
        editButton.tag = merchantIndex
        
        // 오른쪽 정렬을 위해 스페이서 사용
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let spacerView2 = UIView()
        spacerView2.setContentHuggingPriority(.defaultLow, for: .horizontal)
        var arrayView: [UIView]
        if Utils.getIsCAT() {
            arrayView = [spacerView, removeButton, editButton]
        } else {
            arrayView = [spacerView, spacerView2, editButton]
        }
        let buttonStack = UIStackView(arrangedSubviews: arrayView)
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.spacing = 5
        
        container.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        if Utils.getIsCAT() {
            NSLayoutConstraint.activate([
                removeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                removeButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
                removeButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
                         
                editButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                editButton.leadingAnchor.constraint(equalTo: removeButton.trailingAnchor, constant: 10),
                editButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
                editButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
     
                buttonStack.topAnchor.constraint(equalTo: container.topAnchor),
                buttonStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                buttonStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                buttonStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            // 액션 연결
            removeButton.addTarget(self, action: #selector(didTapRemoveSubMerchant(_:)), for: .touchUpInside)
            editButton.addTarget(self, action: #selector(didTapEditSubMerchant(_:)), for: .touchUpInside)
        } else {
            NSLayoutConstraint.activate([
                spacerView2.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                spacerView2.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
                spacerView2.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
                         
                editButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                editButton.leadingAnchor.constraint(equalTo: spacerView2.trailingAnchor, constant: 10),
                editButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()),
                editButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
     
                buttonStack.topAnchor.constraint(equalTo: container.topAnchor),
                buttonStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                buttonStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                buttonStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            editButton.addTarget(self, action: #selector(didTapEditSubMerchant(_:)), for: .touchUpInside)
        }
        
        
        return container
    }
    
    // MARK: - 새 등록 UI 구성
    private func createRegistrationView() -> UIView {
        // registrationView는 새로 등록 요청 관련 UI를 구성합니다.
        let registrationStack = UIStackView()
        registrationStack.axis = .vertical
        registrationStack.alignment = .fill
        registrationStack.distribution = .fill
        registrationStack.spacing = 10
        
        // 가맹점다운로드 + 구분선
        let labelStack = UIStackView()
        labelStack.axis = .vertical
        labelStack.alignment = .fill
        labelStack.distribution = .fill
        labelStack.spacing = 0
        
        // "가맹점 다운로드" 라벨
        let downloadLabel = UILabel()
        downloadLabel.text = "가맹점 다운로드"
        downloadLabel.font = Utils.getSubTitleFont()
        labelStack.addArrangedSubview(downloadLabel)
        
        // 구분선
        let regDivider = UIView()
        regDivider.backgroundColor = define.underline_grey
        regDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        labelStack.addArrangedSubview(regDivider)
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = 10
        
        // TID row
        let tidRow = createRegistrationRow(labelText: "TID")
        contentStack.addArrangedSubview(tidRow)
        
        // 사업자번호 row
        let bizRow = createRegistrationRow(labelText: "사업자번호")
        contentStack.addArrangedSubview(bizRow)
        
        // SN row (label, 텍스트필드, '장치' 버튼)
        let snRow = createRegistrationSNRow()
        contentStack.addArrangedSubview(snRow)
        
        // 복수가맹점 row (label + segmented control)
        let multiRow = createRegistrationMultiRow()
        contentStack.addArrangedSubview(multiRow)
        
        tidNumberTextField.delegate = self
        bisNumberTextField.delegate = self
        serialNumberTextField.delegate = self
        tidNumberTextField.text = Setting.shared.getDefaultUserData(_key: define.STORE_TID)
        bisNumberTextField.text = Setting.shared.getDefaultUserData(_key: define.STORE_BSN)
        serialNumberTextField.text = Setting.shared.getDefaultUserData(_key: define.STORE_SERIAL)
        
        //새로운 버튼을 만든다 키보드 닫기 버튼을 만든다.
        let bar = UIToolbar()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
                
        tidNumberTextField.inputAccessoryView = bar
        bisNumberTextField.inputAccessoryView = bar
        serialNumberTextField.inputAccessoryView = bar
        
        // 등록요청 버튼 (우측정렬)
        let regRequestButton = UIButton(type: .system)
        regRequestButton.setTitle("등록요청", for: .normal)
        regRequestButton.setTitleColor(.white, for: .normal)
        regRequestButton.backgroundColor = .systemBlue
        regRequestButton.titleLabel?.font = Utils.getSubTitleFont()
        regRequestButton.layer.cornerRadius = 8
        regRequestButton.addTarget(self, action: #selector(didTapRegistrationRequest), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [UIView(), regRequestButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.spacing = 5
        
        registrationStack.addArrangedSubview(labelStack)
        registrationStack.addArrangedSubview(contentStack)
        registrationStack.addArrangedSubview(buttonStack)
        // 타이틀의 폭(예: 150 정도)을 고정해도 되지만, 이미 setContentHuggingPriority를 줬다면
        // 필요 시 아래처럼 고정 폭 설정 가능:
        regRequestButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()).isActive = true
        regRequestButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        downloadLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        
        return registrationStack
    }
    
    // 키보드를 숨긴다
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    
    // Helper: 일반 행 (label + 텍스트필드)
    private func createRegistrationRow(labelText: String) -> UIView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 5
        
        let label = UILabel()
        label.text = labelText
        label.font = Utils.getTextFont()
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        rowStack.addArrangedSubview(label)
        if labelText == "TID" {
            rowStack.addArrangedSubview(tidNumberTextField)
            tidNumberTextField.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        } else {
            rowStack.addArrangedSubview(bisNumberTextField)
            bisNumberTextField.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        }
        
        // 타이틀의 폭(예: 150 정도)을 고정해도 되지만, 이미 setContentHuggingPriority를 줬다면
        // 필요 시 아래처럼 고정 폭 설정 가능:
        label.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()).isActive = true
        label.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
      
        rowStack.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        
        return rowStack
    }
        
    // Helper: SN row (label + 텍스트필드 + '장치' 버튼)
    private func createRegistrationSNRow() -> UIView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 5
        
        let label = UILabel()
        label.text = "SN"
        label.font = Utils.getTextFont()
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let deviceButton = UIButton(type: .system)
        deviceButton.setTitle("장치", for: .normal)
        deviceButton.setTitleColor(.white, for: .normal)
        deviceButton.backgroundColor = .systemBlue
        deviceButton.titleLabel?.font = Utils.getSubTitleFont()
        deviceButton.layer.cornerRadius = 8
        deviceButton.addTarget(self, action: #selector(didTapDeviceButton), for: .touchUpInside)
        
        rowStack.addArrangedSubview(label)
        rowStack.addArrangedSubview(serialNumberTextField)
        rowStack.addArrangedSubview(deviceButton)
        
        // 타이틀의 폭(예: 150 정도)을 고정해도 되지만, 이미 setContentHuggingPriority를 줬다면
        // 필요 시 아래처럼 고정 폭 설정 가능:
        label.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()).isActive = true
        serialNumberTextField.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        label.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        deviceButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()).isActive = true
        deviceButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        rowStack.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        
        return rowStack
    }
        
    // Helper: 복수가맹점 row (label + segmented control)
    private func createRegistrationMultiRow() -> UIView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 5
        
        let label = UILabel()
        label.text = "복수가맹점"
        label.font = Utils.getTextFont()
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
//        let segmentedControl = UISegmentedControl(items: ["일반", "복수"])
        segmentedControl.selectedSegmentIndex = 0
        
        rowStack.addArrangedSubview(label)
        rowStack.addArrangedSubview(segmentedControl)
        
        // 타이틀의 폭(예: 150 정도)을 고정해도 되지만, 이미 setContentHuggingPriority를 줬다면
        // 필요 시 아래처럼 고정 폭 설정 가능:
        label.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()).isActive = true
        label.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        rowStack.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        
        return rowStack
    }
    
    
    // MARK: - Layout
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        representativePosLabelView.translatesAutoresizingMaskIntoConstraints = false
        posLabel.translatesAutoresizingMaskIntoConstraints = false
        representativeHeaderView.translatesAutoresizingMaskIntoConstraints = false
        representativeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // titleStackView
            titleStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            titleStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            titleStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -10),
//            titleStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            // 스크롤뷰 폭에 맞추기
            titleStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -20),
            
            // contentStackView
            contentStackView.topAnchor.constraint(greaterThanOrEqualTo: titleStackView.bottomAnchor, constant: 0),
//            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -10),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            // 스크롤뷰 폭에 맞추기
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            posLabel.topAnchor.constraint(equalTo: representativePosLabelView.topAnchor),
            posLabel.bottomAnchor.constraint(equalTo: representativePosLabelView.bottomAnchor),
            posLabel.leadingAnchor.constraint(equalTo: representativePosLabelView.leadingAnchor),
            posLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
        ])
        
        // 대표사업자 헤더(제목 + 화살표)
        NSLayoutConstraint.activate([

            representativeTitleLabel.topAnchor.constraint(equalTo: representativeHeaderView.topAnchor),
            representativeTitleLabel.bottomAnchor.constraint(equalTo: representativeHeaderView.bottomAnchor),
            representativeTitleLabel.leadingAnchor.constraint(equalTo: representativeHeaderView.leadingAnchor),
            representativeTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            arrowButton.centerYAnchor.constraint(equalTo: representativeTitleLabel.centerYAnchor),
            arrowButton.leadingAnchor.constraint(greaterThanOrEqualTo: representativeTitleLabel.trailingAnchor, constant: 8),
            arrowButton.trailingAnchor.constraint(equalTo: representativeHeaderView.trailingAnchor),
            arrowButton.heightAnchor.constraint(equalToConstant: 24),
            arrowButton.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    
    // MARK: - Actions
    private func configureActions() {
        arrowButton.addTarget(self, action: #selector(didTapArrowButton), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        repEditButton.addTarget(self, action: #selector(didTapEditRepresentative), for: .touchUpInside)
    }
    
    @objc private func didTapArrowButton() {
        // 서브사업자 표시 토글
        isSubMerchantExpanded.toggle()
        updateSubMerchantVisibility(animated: true)
    }
    
    @objc private func didTapRegisterButton() {
        // 만약 TARGETDEVICE가 TAGETCAT이 아니라면 등록용 UI를 보여줍니다.
        if Utils.getIsCAT() {
            print("가맹점등록 버튼이 클릭되었습니다.")
        } else {
            contentStackView.isHidden = true
            titleStackView.isHidden = false
            if registrationView == nil {
                registrationView = createRegistrationView()
                titleStackView.addArrangedSubview(registrationView!)
            } else {
                registrationView?.isHidden = false
            }
            storeDownloadTapped()
          
        }
    }
    
    @objc private func didTapEditRepresentative() {
        // 대표사업자 정보 수정
        showEditPopup(forRepresentative: true, index: nil)
    }
    
    @objc private func didTapRemoveSubMerchant(_ sender: UIButton) {
        let index = sender.tag
        guard index < subMerchants.count else { return }
        let i = index
        if Utils.getIsCAT() {
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_TID + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_BSN + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_NAME + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_OWNER + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_PHONE + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.CAT_STORE_ADDR + String(i+1))
        } else {
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_TID + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_BSN + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_NAME + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_OWNER + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_PHONE + String(i+1))
            Setting.shared.setDefaultUserData(_data: "", _key: define.STORE_ADDR + String(i+1))
        }
        // 해당 서브사업자 제거
        subMerchants.remove(at: index)
        // UI 갱신
        refreshSubMerchantViews()
    }
    
    @objc private func didTapEditSubMerchant(_ sender: UIButton) {
        let index = sender.tag
        guard index < subMerchants.count else { return }
        // 서브사업자 정보 수정
        showEditPopup(forRepresentative: false, index: index)
    }
    
    // 서브사업자 표시/숨김 갱신
    private func updateSubMerchantVisibility(animated: Bool) {
        // 화살표 이미지 변경 (펼침/접힘)
        let symbolName = isSubMerchantExpanded ? "chevron.up" : "chevron.down"
        arrowButton.setImage(UIImage(systemName: symbolName), for: .normal)
        
        // 서브사업자 스택뷰 자체를 숨김
        let alphaValue: CGFloat = isSubMerchantExpanded ? 1.0 : 0.0
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.subMerchantStackView.alpha = alphaValue
            }
        } else {
            subMerchantStackView.alpha = alphaValue
        }
    }
    
    @objc private func didTapDeviceButton() {
        print("장치 버튼이 클릭되었습니다.")
        //검색될 때까지 로딩메세지박스를 띄운다
        AlertLoadingBox(title: "잠시만 기다려 주세요")
        if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED && mKocesSdk.mVerityCheck == define.VerityMethod.Success.rawValue {
            //정상적으로 가맹점다운로드를 진행한다
            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                mKocesSdk.GetDeviceInfo(Date: Utils.getDate(format: "yyyyMMddHHmmss"))
            }
        } else if mKocesSdk.bleState == define.TargetDeviceState.BLECONNECTED && mKocesSdk.mVerityCheck != define.VerityMethod.Success.rawValue {
            //블루투스는 연결되어 있지만 무결성검사가 정상적이지 않으므로 먼저 무결성검사를 진행한다
            mKocesSdk.bleReConnected()  //혹시 연결이 끊어져있다면 자동으로 1회 재연결을 시도한다.
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                mKocesSdk.GetVerity()
            }
        } else if mKocesSdk.bleState == define.TargetDeviceState.BLENOCONNECT {
            //블루투스가 연결되어 있지 않으므로 블루투스연결을 먼저 시도한다
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                mKocesSdk.bleConnect()
            }
        } else {
            alertLoading.dismiss(animated: true) {
                self.AlertBox(title: "CAT/BLE 에러", message: "현재 디바이스를 CAT 으로 셋팅되어 있습니다", text: "확인")
            }
        }
    }
      
    @objc private func didTapRegistrationRequest() {
        print("등록요청 버튼이 클릭되었습니다.")
        StoreDownload()
    }
    
    // MARK: - 가맹점다운로드 완료
    @objc private func storeDownloadTapped() {
        print("가맹점 다운로드 버튼 클릭. 가맹점 다운로드 화면으로 이동")
        // 직접 전환하는 대신 delegate 호출
        delegate?.storeViewControllerInit(self)
    }
    public func backStoreDownload() {
        // --- 데이터 셋업
        setupStoreInfoData()
        setupRepresentativeInfoView()
        refreshSubMerchantViews()
        
        contentStackView.isHidden = false
        titleStackView.isHidden = false
        registrationView?.isHidden = true
    }
    
    // MARK: - 정보수정 팝업 표시
    private func showEditPopup(forRepresentative: Bool, index: Int?) {
        let alert = UIAlertController(title: "정보수정",
                                      message: "수정할 내용을 입력하세요.",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "TID"
            if forRepresentative {
                textField.text = self.representativeMerchant.tid
            } else if let i = index {
                textField.text = self.subMerchants[i].tid
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "사업자번호"
            if forRepresentative {
                textField.text = self.representativeMerchant.businessNumber
            } else if let i = index {
                textField.text = self.subMerchants[i].businessNumber
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "가맹점명"
            if forRepresentative {
                textField.text = self.representativeMerchant.storeName
            } else if let i = index {
                textField.text = self.subMerchants[i].storeName
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "전화번호"
            if forRepresentative {
                textField.text = self.representativeMerchant.phoneNumber
            } else if let i = index {
                textField.text = self.subMerchants[i].phoneNumber
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "가맹점주소"
            if forRepresentative {
                textField.text = self.representativeMerchant.address
            } else if let i = index {
                textField.text = self.subMerchants[i].address
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "대표자명"
            if forRepresentative {
                textField.text = self.representativeMerchant.representativeName
            } else if let i = index {
                textField.text = self.subMerchants[i].representativeName
            }
        }
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let fields = alert.textFields ?? []
            guard fields.count == 6 else { return }
            
            let tid = fields[0].text ?? ""
            let bizNum = fields[1].text ?? ""
            let storeName = fields[2].text ?? ""
            let phone = fields[3].text ?? ""
            let address = fields[4].text ?? ""
            let repName = fields[5].text ?? ""
            
            if forRepresentative {
                self.representativeMerchant = MerchantInfo(
                    tid: tid,
                    businessNumber: bizNum,
                    storeName: storeName,
                    phoneNumber: phone,
                    address: address,
                    representativeName: repName
                )
                if Utils.getIsCAT() {
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.CAT_STORE_TID)
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.CAT_STORE_TID + "0")
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.CAT_STORE_BSN)
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.CAT_STORE_BSN + "0")
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.CAT_STORE_NAME)
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.CAT_STORE_NAME + "0")
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.CAT_STORE_OWNER)
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.CAT_STORE_OWNER + "0")
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.CAT_STORE_PHONE)
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.CAT_STORE_PHONE + "0")
                    Setting.shared.setDefaultUserData(_data: address, _key: define.CAT_STORE_ADDR)
                    Setting.shared.setDefaultUserData(_data: address, _key: define.CAT_STORE_ADDR + "0")
                } else {
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.STORE_TID)
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.STORE_TID + "0")
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.STORE_BSN)
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.STORE_BSN + "0")
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.STORE_NAME)
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.STORE_NAME + "0")
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.STORE_OWNER)
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.STORE_OWNER + "0")
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.STORE_PHONE)
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.STORE_PHONE + "0")
                    Setting.shared.setDefaultUserData(_data: address, _key: define.STORE_ADDR)
                    Setting.shared.setDefaultUserData(_data: address, _key: define.STORE_ADDR + "0")
                }
                // 대표사업자 UI 업데이트
                self.setupRepresentativeInfoView()
            } else if let i = index, i < self.subMerchants.count {
                self.subMerchants[i] = MerchantInfo(
                    tid: tid,
                    businessNumber: bizNum,
                    storeName: storeName,
                    phoneNumber: phone,
                    address: address,
                    representativeName: repName
                )
                
                if Utils.getIsCAT() {
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.CAT_STORE_TID + String(i+1))
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.CAT_STORE_BSN + String(i+1))
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.CAT_STORE_NAME + String(i+1))
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.CAT_STORE_OWNER + String(i+1))
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.CAT_STORE_PHONE + String(i+1))
                    Setting.shared.setDefaultUserData(_data: address, _key: define.CAT_STORE_ADDR + String(i+1))
                } else {
                    Setting.shared.setDefaultUserData(_data: tid, _key: define.STORE_TID + String(i+1))
                    Setting.shared.setDefaultUserData(_data: bizNum, _key: define.STORE_BSN + String(i+1))
                    Setting.shared.setDefaultUserData(_data: storeName, _key: define.STORE_NAME + String(i+1))
                    Setting.shared.setDefaultUserData(_data: repName, _key: define.STORE_OWNER + String(i+1))
                    Setting.shared.setDefaultUserData(_data: phone, _key: define.STORE_PHONE + String(i+1))
                    Setting.shared.setDefaultUserData(_data: address, _key: define.STORE_ADDR + String(i+1))
                }
            }
            // UI 갱신
            self.refreshSubMerchantViews()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
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
    
    func AlertBox(title : String, message : String, text : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: text, style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okButton)
        return self.present(alertController, animated: true, completion: nil)
    }
}
// MARK: - 유틸: (타이틀, 값) 두 개 레이블이 들어간 가로 스택 만들기
extension StoreViewController {
    private func createTwoLabelRow(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = "  " + title
        titleLabel.font = Utils.getTextFont()
        titleLabel.textAlignment = .left
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Utils.getTextFont()
        valueLabel.textAlignment = .left
        // 필요하면 여러 줄 표시도 가능 (numberOfLines = 0)
        
        let rowStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        rowStack.axis = .horizontal
        rowStack.alignment = .fill
        rowStack.spacing = 5
        
        // 행 높이 60
        rowStack.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()).isActive = true
                
        // 타이틀의 폭(예: 150 정도)을 고정해도 되지만, 이미 setContentHuggingPriority를 줬다면
        // 필요 시 아래처럼 고정 폭 설정 가능:
         titleLabel.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()).isActive = true
//        NSLayoutConstraint.activate([
//            titleLabel.widthAnchor.constraint(equalToConstant: 150),
//            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
//        ])
        
        return rowStack
    }
}
extension StoreViewController: TcpResultDelegate, UITextFieldDelegate, CustomAlertDelegate
{
    func onDirectResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>, DirectData _directData: Dictionary<String, String>) {
        debugPrint("앱투앱/웹투앱에서만 사용")
    }
    
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

    func StoreDownload(){
        listener = TcpResult()
        listener?.delegate = self

        mKocesSdk.StoreDownload(Command: segmentedControl.selectedSegmentIndex == 1 ? "D12":"D10", Tid: tidNumberTextField.text!, Date: Utils.getDate(format: "yyMMddHHmmss"), PosVer: define.TEST_SOREWAREVERSION, Etc: "", Length: "0003", PosCheckData: "MDO", BSN: bisNumberTextField.text!, Serial: serialNumberTextField.text!, PosData: "", MacAddr: Utils.getKeyChainUUID(), CallbackListener: listener?.delegate as! TcpResultDelegate)
    }
    
    /** 키갱신시 사용 */
    func onKeyResult(tcpStatus _status: tcpStatus, Result _result: [UInt8], DicResult _dicresult: Dictionary<String, String>) {
        print(_result)
    }

    func onResult(tcpStatus _status: tcpStatus, Result _result: Dictionary<String, String>) {

        if _result["AnsCode"] == "0000" {
            //기존 정보들을 일단 다 제거 한다.
            for (key,value) in UserDefaults.standard.dictionaryRepresentation() {
                if key.contains(define.STORE_TID) {
                    if key.contains(define.CAT_STORE_TID) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                        KeychainWrapper.standard.removeObject(forKey: keyChainTarget.KocesICIOSPay.rawValue + (value as! String))
                    }
              
                }
                if key.contains(define.STORE_BSN) {
                    if key.contains(define.CAT_STORE_BSN) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                  
                }
                if key.contains(define.STORE_SERIAL) {
                    if key.contains(define.CAT_STORE_SERIAL) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                 
                }
                if key.contains(define.STORE_NAME) {
                    if key.contains(define.CAT_STORE_NAME) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
               
                }
                if key.contains(define.STORE_PHONE) {
                    if key.contains(define.CAT_STORE_PHONE) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                 
                }
                if key.contains(define.STORE_OWNER) {
                    if key.contains(define.CAT_STORE_OWNER) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
          
                }
                if key.contains(define.STORE_ADDR) {
                    if key.contains(define.CAT_STORE_ADDR) {
                        
                    } else {
                        Setting.shared.setDefaultUserData(_data: "", _key: key)
                    }
                
                }
            }
            if segmentedControl.selectedSegmentIndex == 1 {
                Setting.shared.setDefaultUserData(_data: String(segmentedControl.selectedSegmentIndex), _key: define.MULTI_STORE)
            } else {
                Setting.shared.setDefaultUserData(_data: "", _key: define.MULTI_STORE)
            }
            
            //복수가맹점응답일경우
            if _result["TrdType"]! == "D16" || _result["TrdType"]! == "D17" {
                var _msg:String = ""
                var keyCount:Int = 0
                var TermIDCount:Int = 0    //총 몇개의 키를 저장해야 하는지 체크
                for (key,value) in _result {
                    if key.contains("TermID") {
                        TermIDCount += 1
                    }
                    
                    if _result.count - 1 == keyCount {
                        _msg += key + " = " + value
                    }
                    else{
                        _msg += key + " = " + value + "\n"
                    }
                    keyCount += 1
                }
                
                //이게 1개란 소리는 복수가맹점으로 했지만 실제로 복수가맹점데이터 필드에는 데이터가 없었다는 소리다.
                if TermIDCount == 1 {
                    Setting.shared.setDefaultUserData(_data: _result["TermID"]!, _key: define.STORE_TID)
                    Setting.shared.setDefaultUserData(_data: _result["BsnNo"]!, _key: define.STORE_BSN)
                    Setting.shared.setDefaultUserData(_data: serialNumberTextField.text!, _key: define.STORE_SERIAL)
                    
                    //가맹점 정보 저장
                    Setting.shared.setDefaultUserData(_data: _result["ShpNm"]!, _key: define.STORE_NAME) //업체명
                    Setting.shared.setDefaultUserData(_data: _result["ShpTel"]!, _key: define.STORE_PHONE) //업체 전화번호
                    Setting.shared.setDefaultUserData(_data: _result["PreNm"]!, _key: define.STORE_OWNER) //업체 대표자명
                    Setting.shared.setDefaultUserData(_data: _result["ShpAdr"]!, _key: define.STORE_ADDR) //업체 주소
                    
                    let _key = _result["HardwareKey"] ?? ""
                    //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
                    Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (_result["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                    bisNumberTextField.text = ""
                    serialNumberTextField.text = ""
                    //                setStoreInfo()
                    alertLoading.dismiss(animated: true){ [self] in
                        AlertBox(title: "결과", message: "가맹점 등록 다운로드가 완료 되었습니다.", text: "확인")
                    }
                    return
                }
                //기본데이터는 업데이트 한다.
                Setting.shared.setDefaultUserData(_data: _result["TermID0"]!, _key: define.STORE_TID)
                Setting.shared.setDefaultUserData(_data: _result["BsnNo0"]!, _key: define.STORE_BSN)
                Setting.shared.setDefaultUserData(_data: serialNumberTextField.text!, _key: define.STORE_SERIAL)
                
                //가맹점 정보 저장
                Setting.shared.setDefaultUserData(_data: _result["ShpNm0"]!, _key: define.STORE_NAME) //업체명
                Setting.shared.setDefaultUserData(_data: _result["ShpTel0"]!, _key: define.STORE_PHONE) //업체 전화번호
                Setting.shared.setDefaultUserData(_data: _result["PreNm0"]!, _key: define.STORE_OWNER) //업체 대표자명
                Setting.shared.setDefaultUserData(_data: _result["ShpAdr0"]!, _key: define.STORE_ADDR) //업체 주소
                Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (_result["TermID0"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _result["HardwareKey"] ?? _result["HardwareKey" + (_result["TermID0"] ?? "")] ?? "")
                
                var _key:String = ""
                for i in 0 ..< (TermIDCount - 1) {
                    Setting.shared.setDefaultUserData(_data: _result["TermID" + String(i)]!, _key: define.STORE_TID + String(i))
                    Setting.shared.setDefaultUserData(_data: _result["BsnNo" + String(i)]!, _key: define.STORE_BSN + String(i))
                    Setting.shared.setDefaultUserData(_data: serialNumberTextField.text!, _key: define.STORE_SERIAL + String(i))

                    //가맹점 정보 저장
                    Setting.shared.setDefaultUserData(_data: _result["ShpNm" + String(i)]!, _key: define.STORE_NAME + String(i)) //업체명
                    Setting.shared.setDefaultUserData(_data: _result["ShpTel" + String(i)]!, _key: define.STORE_PHONE + String(i)) //업체 전화번호
                    Setting.shared.setDefaultUserData(_data: _result["PreNm" + String(i)]!, _key: define.STORE_OWNER + String(i)) //업체 대표자명
                    Setting.shared.setDefaultUserData(_data: _result["ShpAdr" + String(i)]!, _key: define.STORE_ADDR + String(i)) //업체 주소
                    
                    _key = _result["HardwareKey"] ?? _result["HardwareKey" + (_result["TermID" + String(i)] ?? "")] ?? ""
                    //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
                    Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (_result["TermID" + String(i)] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                }
                bisNumberTextField.text = ""
                serialNumberTextField.text = ""
                
//                setStoreInfo()
                alertLoading.dismiss(animated: true){ [self] in
                    AlertBox(title: "결과", message: "가맹점 등록 다운로드가 완료 되었습니다.", text: "확인")
                }
            } else {
                Setting.shared.setDefaultUserData(_data: _result["TermID"]!, _key: define.STORE_TID)
                Setting.shared.setDefaultUserData(_data: _result["BsnNo"]!, _key: define.STORE_BSN)
                Setting.shared.setDefaultUserData(_data: serialNumberTextField.text!, _key: define.STORE_SERIAL)
                
                //가맹점 정보 저장
                Setting.shared.setDefaultUserData(_data: _result["ShpNm"]!, _key: define.STORE_NAME) //업체명
                Setting.shared.setDefaultUserData(_data: _result["ShpTel"]!, _key: define.STORE_PHONE) //업체 전화번호
                Setting.shared.setDefaultUserData(_data: _result["PreNm"]!, _key: define.STORE_OWNER) //업체 대표자명
                Setting.shared.setDefaultUserData(_data: _result["ShpAdr"]!, _key: define.STORE_ADDR) //업체 주소
                
                let _key = _result["HardwareKey"] ?? ""
                //하드웨어키값 저장. 부정취소방지를 위해 서버에서 보낸 내용 해당값은 base64 인코딩하여 저장하고 이후 신용 승인/취소 시 사용한다
                Utils.setPosKeyChainUUIDtoBase64(Target: .KocesICIOSPay, Tid: (_result["TermID"] ?? "").replacingOccurrences(of: " ", with: ""), PosKeyChain: _key)
                bisNumberTextField.text = ""
                serialNumberTextField.text = ""
                
//                setStoreInfo()
                alertLoading.dismiss(animated: true){ [self] in
                    AlertBox(title: "결과", message: "가맹점 등록 다운로드가 완료 되었습니다.", text: "확인")
                }
            }
            backStoreDownload()
        } else {
            alertLoading.dismiss(animated: true){ [self] in
                AlertBox(title: "결과", message: "가맹점 등록 다운로드를 실패 하였습니다.", text: "확인")
            }
        }

    }

    /**
     글자수 제한을 위한 함수
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength:Int = CharMaxLength
        switch textField {
        case tidNumberTextField:
            maxLength = CharMaxLength
        case bisNumberTextField:
            maxLength = CharMaxLength
        case serialNumberTextField:
            maxLength = CharMaxLength
        default:
            break
        }
        let newLength = (textField.text?.count)! + string.count - range.length
                return !(newLength > maxLength)
    }
}
