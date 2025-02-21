//
//  PaymentSettingViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2/13/25.
//

import Foundation
import UIKit
import ObjectiveC.runtime  // associated object 사용을 위함

private struct AssociatedKeys {
    static var valueLabelKey = "valueLabelKey"
}

class PaymentSettingViewController: UIViewController {

    // MARK: - 상단 헤더 (결제설정, 저장 버튼)
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "결제설정"
        label.font = Utils.getTitleFont()
        label.textColor = .darkGray
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let headerUnderline: UIView = {
        return createUnderline()
    }()
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Utils.getSubTitleFont()
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - ScrollView 및 ContentView
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Section 1: 거래방식설정
    private let transTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "거래방식설정"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let transUnderline: UIView = {
        return createUnderline()
    }()
    private let transContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let transLabel: UILabel = {
        let label = UILabel()
        label.text = "거래방식"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var transSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["일반거래", "상품거래", "APPTOAPP"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .normal)
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: define.txt_blue,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .selected)
        seg.addTarget(self, action: #selector(transSegmentChanged(_:)), for: .valueChanged)
        return seg
    }()
    
    // MARK: - Section 2: 팝업대기시간
    private let popupTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "팝업대기시간"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let popupUnderline: UIView = {
        return createUnderline()
    }()
    private let popupContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Section 3: 부가세설정
    private let vatTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "부가세설정"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let vatUnderline: UIView = {
        return createUnderline()
    }()
    private let vatContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // 부가세적용 행
    private let vatApplyLabel: UILabel = {
        let label = UILabel()
        label.text = "부가세적용"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let vatApplySwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.addTarget(PaymentSettingViewController.self, action: #selector(vatSwitchChanged(_:)), for: .valueChanged)
        return sw
    }()
    // 부가세방식 행
    private let vatModeLabel: UILabel = {
        let label = UILabel()
        label.text = "부가세방식"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var vatModeSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["자동", "통합"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .normal)
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: define.txt_blue,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .selected)
        return seg
    }()
    // 부가세계산방식 행
    private let vatCalcLabel: UILabel = {
        let label = UILabel()
        label.text = "부가세계산방식"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var vatCalcSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["포함", "미포함"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .normal)
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: define.txt_blue,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .selected)
        return seg
    }()
    // 부가세율 편집 셀
    private lazy var vatRateRow: UIView = {
        return self.createEditableRow(key: "부가세율", initialValue: "", placeholder: "예: 10%")
    }()
    
    // MARK: - Section 4: 봉사료설정
    private let svcTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "봉사료설정"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let svcUnderline: UIView = {
        return createUnderline()
    }()
    private let svcContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // 봉사료적용 행
    private let svcApplyLabel: UILabel = {
        let label = UILabel()
        label.text = "봉사료적용"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let svcApplySwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.addTarget(PaymentSettingViewController.self, action: #selector(svcSwitchChanged(_:)), for: .valueChanged)
        return sw
    }()
    // 봉사료방식 행
    private let svcModeLabel: UILabel = {
        let label = UILabel()
        label.text = "봉사료방식"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var svcModeSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["자동", "통합"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .normal)
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: define.txt_blue,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .selected)
        return seg
    }()
    // 봉사료계산방식 행
    private let svcCalcLabel: UILabel = {
        let label = UILabel()
        label.text = "봉사료계산방식"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var svcCalcSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["포함", "미포함"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .normal)
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: define.txt_blue,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .selected)
        return seg
    }()
    // 봉사료율 편집 셀
    private lazy var svcRateRow: UIView = {
        return self.createEditableRow(key: "봉사료율", initialValue: "", placeholder: "예: 5%")
    }()
    
    // MARK: - Section 5: 할부설정
    private let installmentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "할부설정"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let installmentUnderline: UIView = {
        return createUnderline()
    }()
    private let installmentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Section 6: 무서명설정
    private let nonSignatureTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "무서명설정"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let nonSignatureUnderline: UIView = {
        return createUnderline()
    }()
    private let nonSignatureContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Section 7: FALLBACK설정
    private let fallbackTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "FALLBACK설정"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let fallbackUnderline: UIView = {
        return createUnderline()
    }()
    private let fallbackContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let fallbackUsageLabel: UILabel = {
        let label = UILabel()
        label.text = "폴백사용여부"
        label.font = Utils.getSubTitleFont()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var fallbackSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["사용", "미사용"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .normal)
        seg.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: define.txt_blue,
            NSAttributedString.Key.font: Utils.getSubTitleFont()
        ], for: .selected)
        return seg
    }()
    
    // MARK: - 하단 버튼 영역
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let finalSaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Utils.getSubTitleFont()
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = define.layout_border_lightgrey
        title = "결제설정"
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("ScrollView content size: \(scrollView.contentSize)")
    }

    // MARK: - UI Setup
    private func setupUI() {
        // scrollView 및 contentView 추가
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let margin: CGFloat = 10
        
        // 기존 UI 요소들을 contentView에 추가 (일괄 관리)
        [headerLabel, headerUnderline,
         transTitleLabel, transUnderline, transContainer,
         popupTitleLabel, popupUnderline, popupContainer,
         vatTitleLabel, vatUnderline, vatContainer,
         svcTitleLabel, svcUnderline, svcContainer,
         installmentTitleLabel, installmentUnderline, installmentContainer,
         nonSignatureTitleLabel, nonSignatureUnderline, nonSignatureContainer,
         fallbackTitleLabel, fallbackUnderline, fallbackContainer,
         buttonStack
        ].forEach {
            contentView.addSubview($0)
        }
        // 각 영역 내부 추가 뷰 설정
        // 거래방식 영역: segmented row
        let transRow = createSegmentedRow(key: "거래방식", seg: transSegmented, initialValue: 0)
        transContainer.addSubview(transRow)
        
        // 팝업대기시간 영역: 카드대기시간, 서명대기시간 편집 셀
        let cardRow = createEditableRow(key: "카드대기시간", initialValue: "", placeholder: "예: 30초")
        let signRow = createEditableRow(key: "서명대기시간", initialValue: "", placeholder: "예: 30초")
        popupContainer.addSubview(cardRow)
        popupContainer.addSubview(signRow)
        
        // 부가세설정 영역: 스택뷰로 묶기
        let vatApplyRow = UIStackView(arrangedSubviews: [vatApplyLabel, vatApplySwitch])
        vatApplyRow.axis = .horizontal; vatApplyRow.spacing = margin; vatApplyRow.distribution = .fillProportionally; vatApplyRow.translatesAutoresizingMaskIntoConstraints = false
        let vatModeRow = UIStackView(arrangedSubviews: [vatModeLabel, vatModeSegmented])
        vatModeRow.axis = .horizontal; vatModeRow.spacing = margin; vatModeRow.distribution = .fillProportionally; vatModeRow.translatesAutoresizingMaskIntoConstraints = false
        let vatCalcRow = UIStackView(arrangedSubviews: [vatCalcLabel, vatCalcSegmented])
        vatCalcRow.axis = .horizontal; vatCalcRow.spacing = margin; vatCalcRow.distribution = .fillProportionally; vatCalcRow.translatesAutoresizingMaskIntoConstraints = false
        let vatStack = UIStackView(arrangedSubviews: [vatApplyRow, vatModeRow, vatCalcRow, vatRateRow])
        vatStack.axis = .vertical; vatStack.spacing = margin; vatStack.translatesAutoresizingMaskIntoConstraints = false
        vatContainer.addSubview(vatStack)
        
        // 봉사료설정 영역: 스택뷰로 묶기
        let svcApplyRow = UIStackView(arrangedSubviews: [svcApplyLabel, svcApplySwitch])
        svcApplyRow.axis = .horizontal; svcApplyRow.spacing = margin; svcApplyRow.distribution = .fillProportionally; svcApplyRow.translatesAutoresizingMaskIntoConstraints = false
        let svcModeRow = UIStackView(arrangedSubviews: [svcModeLabel, svcModeSegmented])
        svcModeRow.axis = .horizontal; svcModeRow.spacing = margin; svcModeRow.distribution = .fillProportionally; svcModeRow.translatesAutoresizingMaskIntoConstraints = false
        let svcCalcRow = UIStackView(arrangedSubviews: [svcCalcLabel, svcCalcSegmented])
        svcCalcRow.axis = .horizontal; svcCalcRow.spacing = margin; svcCalcRow.distribution = .fillProportionally; svcCalcRow.translatesAutoresizingMaskIntoConstraints = false
        let svcStack = UIStackView(arrangedSubviews: [svcApplyRow, svcModeRow, svcCalcRow, svcRateRow])
        svcStack.axis = .vertical; svcStack.spacing = margin; svcStack.translatesAutoresizingMaskIntoConstraints = false
        svcContainer.addSubview(svcStack)
        
        // FALLBACK설정 영역: 스택뷰
        let fallbackRow = createSegmentedRow(key: "폴백사용여부", seg: fallbackSegmented, initialValue: 0)
        fallbackContainer.addSubview(fallbackRow)
        
        // 하단 버튼 영역
        buttonStack.addArrangedSubview(finalSaveButton)
        
        // 제약조건은 별도 함수에서 설정
        setupConstraints(cardRow: cardRow, signRow: signRow, transRow: transRow, vatStack: vatStack, svcStack: svcStack, fallbackRow: fallbackRow)
        
        finalSaveButton.addTarget(self, action: #selector(finalSaveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup Constraints (모든 제약조건 일괄 관리)
    private func setupConstraints(cardRow: UIView,
                                  signRow: UIView,
                                  transRow: UIView,
                                  vatStack: UIStackView,
                                  svcStack: UIStackView,
                                  fallbackRow: UIView) {
        let margin: CGFloat = 10
        
        NSLayoutConstraint.activate([
            // scrollView: view의 safeArea 채우기
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // contentView: scrollView의 contentLayoutGuide에 맞추고, frameLayoutGuide의 너비와 동일하게
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Header 영역
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            headerLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            headerUnderline.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 2),
            headerUnderline.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            headerUnderline.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: -margin),
            headerUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            // 거래방식 영역
            transTitleLabel.topAnchor.constraint(equalTo: headerUnderline.bottomAnchor, constant: margin),
            transTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            transTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            transTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            transUnderline.topAnchor.constraint(equalTo: transTitleLabel.bottomAnchor, constant: 2),
            transUnderline.leadingAnchor.constraint(equalTo: transTitleLabel.leadingAnchor),
            transUnderline.trailingAnchor.constraint(equalTo: transTitleLabel.trailingAnchor, constant: -margin),
            transUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            transContainer.topAnchor.constraint(equalTo: transUnderline.bottomAnchor, constant: define.pading_wight),
            transContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            transContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
//            transContainer.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            // transRow 내부: transRow가 transContainer에 채워지도록
            transRow.topAnchor.constraint(equalTo: transContainer.topAnchor, constant: define.pading_wight),
            transRow.leadingAnchor.constraint(equalTo: transContainer.leadingAnchor, constant: define.pading_wight),
            transRow.trailingAnchor.constraint(equalTo: transContainer.trailingAnchor, constant: -define.pading_wight),
            transRow.bottomAnchor.constraint(equalTo: transContainer.bottomAnchor, constant: -define.pading_wight),
            
            // 팝업대기시간 영역
            popupTitleLabel.topAnchor.constraint(equalTo: transContainer.bottomAnchor, constant: margin),
            popupTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            popupTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            popupTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            popupUnderline.topAnchor.constraint(equalTo: popupTitleLabel.bottomAnchor, constant: 2),
            popupUnderline.leadingAnchor.constraint(equalTo: popupTitleLabel.leadingAnchor),
            popupUnderline.trailingAnchor.constraint(equalTo: popupTitleLabel.trailingAnchor, constant: -margin),
            popupUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            popupContainer.topAnchor.constraint(equalTo: popupUnderline.bottomAnchor, constant: define.pading_wight),
            popupContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            popupContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
//            popupContainer.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            // cardRow & signRow: 팝업 영역 내 수직 배치 (상하 10, 중간 10)
            cardRow.topAnchor.constraint(equalTo: popupContainer.topAnchor, constant: define.pading_wight),
            cardRow.leadingAnchor.constraint(equalTo: popupContainer.leadingAnchor, constant: define.pading_wight),
            cardRow.trailingAnchor.constraint(equalTo: popupContainer.trailingAnchor, constant: -define.pading_wight),
//            cardRow.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            signRow.topAnchor.constraint(equalTo: cardRow.bottomAnchor, constant: 2),
            signRow.leadingAnchor.constraint(equalTo: popupContainer.leadingAnchor, constant: define.pading_wight),
            signRow.trailingAnchor.constraint(equalTo: popupContainer.trailingAnchor,  constant: -define.pading_wight),
            signRow.bottomAnchor.constraint(equalTo: popupContainer.bottomAnchor,  constant: -define.pading_wight),
//            signRow.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            // 부가세설정 영역
            vatTitleLabel.topAnchor.constraint(equalTo: popupContainer.bottomAnchor, constant: margin),
            vatTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            vatTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            vatTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            vatUnderline.topAnchor.constraint(equalTo: vatTitleLabel.bottomAnchor, constant: 2),
            vatUnderline.leadingAnchor.constraint(equalTo: vatTitleLabel.leadingAnchor),
            vatUnderline.trailingAnchor.constraint(equalTo: vatTitleLabel.trailingAnchor, constant: -margin),
            vatUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            vatContainer.topAnchor.constraint(equalTo: vatUnderline.bottomAnchor, constant: define.pading_wight),
            vatContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            vatContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
//            vatContainer.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            vatStack.topAnchor.constraint(equalTo: vatContainer.topAnchor, constant: define.pading_wight),
            vatStack.leadingAnchor.constraint(equalTo: vatContainer.leadingAnchor, constant: define.pading_wight),
            vatStack.trailingAnchor.constraint(equalTo: vatContainer.trailingAnchor, constant: -define.pading_wight),
//            vatStack.bottomAnchor.constraint(equalTo: vatContainer.bottomAnchor, constant: -margin),
            
            // 봉사료설정 영역
            svcTitleLabel.topAnchor.constraint(equalTo: vatContainer.bottomAnchor, constant: margin),
            svcTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            svcTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            svcTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            svcUnderline.topAnchor.constraint(equalTo: svcTitleLabel.bottomAnchor, constant: 2),
            svcUnderline.leadingAnchor.constraint(equalTo: svcTitleLabel.leadingAnchor),
            svcUnderline.trailingAnchor.constraint(equalTo: svcTitleLabel.trailingAnchor, constant: -margin),
            svcUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            svcContainer.topAnchor.constraint(equalTo: svcUnderline.bottomAnchor, constant: define.pading_wight),
            svcContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            svcContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
//            svcContainer.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            svcStack.topAnchor.constraint(equalTo: svcContainer.topAnchor, constant: define.pading_wight),
            svcStack.leadingAnchor.constraint(equalTo: svcContainer.leadingAnchor, constant: define.pading_wight),
            svcStack.trailingAnchor.constraint(equalTo: svcContainer.trailingAnchor, constant: -define.pading_wight),
//            svcStack.bottomAnchor.constraint(equalTo: svcContainer.bottomAnchor, constant: -margin),
            
            // 할부설정 영역
            installmentTitleLabel.topAnchor.constraint(equalTo: svcContainer.bottomAnchor, constant: margin),
            installmentTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            installmentTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            installmentTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            installmentUnderline.topAnchor.constraint(equalTo: installmentTitleLabel.bottomAnchor, constant: 2),
            installmentUnderline.leadingAnchor.constraint(equalTo: installmentTitleLabel.leadingAnchor),
            installmentUnderline.trailingAnchor.constraint(equalTo: installmentTitleLabel.trailingAnchor, constant: -margin),
            installmentUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            installmentContainer.topAnchor.constraint(equalTo: installmentUnderline.bottomAnchor, constant: margin),
            installmentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            installmentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
//            installmentContainer.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            // 할부설정 내부 편집 셀
            // installmentRow는 installmentContainer의 모든 면에 10pt inset
//            installmentContainer.subviews.first!.topAnchor.constraint(equalTo: installmentContainer.topAnchor, constant: 10),
//            installmentContainer.subviews.first!.leadingAnchor.constraint(equalTo: installmentContainer.leadingAnchor, constant: 10),
//            installmentContainer.subviews.first!.trailingAnchor.constraint(equalTo: installmentContainer.trailingAnchor, constant: -10),
//            installmentContainer.subviews.first!.bottomAnchor.constraint(equalTo: installmentContainer.bottomAnchor, constant: -10),
            
            // 무서명설정 영역
            nonSignatureTitleLabel.topAnchor.constraint(equalTo: installmentContainer.bottomAnchor, constant: margin),
            nonSignatureTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            nonSignatureTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            nonSignatureTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            nonSignatureUnderline.topAnchor.constraint(equalTo: nonSignatureTitleLabel.bottomAnchor, constant: 2),
            nonSignatureUnderline.leadingAnchor.constraint(equalTo: nonSignatureTitleLabel.leadingAnchor),
            nonSignatureUnderline.trailingAnchor.constraint(equalTo: nonSignatureTitleLabel.trailingAnchor, constant: -margin),
            nonSignatureUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            nonSignatureContainer.topAnchor.constraint(equalTo: nonSignatureUnderline.bottomAnchor, constant: margin),
            nonSignatureContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            nonSignatureContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
//            nonSignatureContainer.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            // 무서명설정 내부 편집 셀
//            nonSignatureContainer.subviews.first!.topAnchor.constraint(equalTo: nonSignatureContainer.topAnchor, constant: 10),
//            nonSignatureContainer.subviews.first!.leadingAnchor.constraint(equalTo: nonSignatureContainer.leadingAnchor, constant: 10),
//            nonSignatureContainer.subviews.first!.trailingAnchor.constraint(equalTo: nonSignatureContainer.trailingAnchor, constant: -10),
//            nonSignatureContainer.subviews.first!.bottomAnchor.constraint(equalTo: nonSignatureContainer.bottomAnchor, constant: -10),
            
            // FALLBACK설정 영역
            fallbackTitleLabel.topAnchor.constraint(equalTo: nonSignatureContainer.bottomAnchor, constant: margin),
            fallbackTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            fallbackTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            fallbackTitleLabel.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            fallbackUnderline.topAnchor.constraint(equalTo: fallbackTitleLabel.bottomAnchor, constant: 2),
            fallbackUnderline.leadingAnchor.constraint(equalTo: fallbackTitleLabel.leadingAnchor),
            fallbackUnderline.trailingAnchor.constraint(equalTo: fallbackTitleLabel.trailingAnchor, constant: -margin),
            fallbackUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            fallbackContainer.topAnchor.constraint(equalTo: fallbackUnderline.bottomAnchor, constant: define.pading_wight),
            fallbackContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            fallbackContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
//            fallbackContainer.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            
            fallbackRow.topAnchor.constraint(equalTo: fallbackContainer.topAnchor, constant: define.pading_wight),
            fallbackRow.leadingAnchor.constraint(equalTo: fallbackContainer.leadingAnchor, constant: define.pading_wight),
            fallbackRow.trailingAnchor.constraint(equalTo: fallbackContainer.trailingAnchor, constant: -define.pading_wight),
            fallbackRow.bottomAnchor.constraint(equalTo: fallbackContainer.bottomAnchor, constant: -define.pading_wight),
            
            // 하단 버튼 영역
            buttonStack.topAnchor.constraint(equalTo: fallbackContainer.bottomAnchor, constant: margin),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            buttonStack.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()),
            // 마지막 요소가 contentView의 bottom에 닿도록
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin)
        ])
        
        if let separator = transRow.viewWithTag(1001)?.subviews.last {
            separator.isHidden = true
        }
        if let separator = signRow.viewWithTag(1001)?.subviews.last {
            separator.isHidden = true
        }
        if let separator = fallbackRow.viewWithTag(1001)?.subviews.last {
            separator.isHidden = true
        }
        
    }
    
    // MARK: - Helper: Underline 생성
    static func createUnderline() -> UIView {
        let view = UIView()
        view.backgroundColor = define.underline_grey
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }
    
    // MARK: - 새 편집 셀 생성 함수
    func createEditableRow(key: String, initialValue: String, placeholder: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false

        let keyLabel = UILabel()
        keyLabel.text = key
        keyLabel.font = Utils.getSubTitleFont()
        keyLabel.textColor = .darkGray
        keyLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = initialValue.isEmpty ? placeholder : initialValue
        valueLabel.font = Utils.getSubTitleFont()
        valueLabel.textColor = initialValue.isEmpty ? UIColor.lightGray : .darkGray
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevronImage = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImage.tintColor = .lightGray
        chevronImage.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(keyLabel)
        container.addSubview(valueLabel)
        container.addSubview(chevronImage)
        
        // 하단 separator 라인
        let separator = UIView()
        separator.backgroundColor = define.underline_grey
        separator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(separator)

        NSLayoutConstraint.activate([
            keyLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            keyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            
            chevronImage.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronImage.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -define.pading_wight * 2),
        
            
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//            valueLabel.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor, constant: 10),
            valueLabel.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -10),
            
            // separator: 하단 전체 폭, 높이 1
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // tag를 부여해서 나중에 숨김 처리 가능하게 함
        container.tag = 1001
        
        container.accessibilityLabel = key
        container.accessibilityHint = placeholder
        objc_setAssociatedObject(container, &AssociatedKeys.valueLabelKey, valueLabel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        container.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()).isActive = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEditableRowTap(_:)))
        container.addGestureRecognizer(tapGesture)
        
        return container
    }
    
    func createSegmentedRow(key: String, seg: UISegmentedControl, initialValue: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let keyLabel = UILabel()
        keyLabel.text = key
        keyLabel.font = Utils.getSubTitleFont()
        keyLabel.textColor = .darkGray
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        seg.selectedSegmentIndex = initialValue
        
        container.addSubview(keyLabel)
        container.addSubview(seg)
        
        // 하단 separator 라인
        let separator = UIView()
        separator.backgroundColor = define.underline_grey
        separator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(separator)
        
        NSLayoutConstraint.activate([
            keyLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            keyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            
            seg.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            seg.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            
            // separator: 하단 전체 폭, 높이 1
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // tag를 부여해서 나중에 숨김 처리 가능하게 함
        container.tag = 1001
        
        container.accessibilityLabel = key
        seg.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()).isActive = true
        container.heightAnchor.constraint(equalToConstant: Utils.getRowSubHeight()).isActive = true
        
        return container
    }
    
    // MARK: - 편집 셀 탭 처리
    @objc func handleEditableRowTap(_ sender: UITapGestureRecognizer) {
        guard let container = sender.view else { return }
        let key = container.accessibilityLabel ?? ""
        let placeholder = container.accessibilityHint ?? ""
        let valueLabel = objc_getAssociatedObject(container, &AssociatedKeys.valueLabelKey) as? UILabel

        let alert = UIAlertController(title: key, message: "\(key) 을 입력해 주세요", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = placeholder
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                // 입력이 없으면 placeholder로, 있으면 입력값으로 갱신
                valueLabel?.text = text.isEmpty ? placeholder : text
                valueLabel?.textColor = text.isEmpty ? UIColor.lightGray : .darkGray
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    

    // MARK: - Action Methods
    @objc func transSegmentChanged(_ sender: UISegmentedControl) {
        // 거래방식이 "상품거래" 또는 "APPTOAPP"인 경우 부가세설정, 봉사료설정을 숨김
        if sender.selectedSegmentIndex == 0 {
            vatContainer.isHidden = false
            svcContainer.isHidden = false
        } else {
            vatContainer.isHidden = true
            svcContainer.isHidden = true
        }
    }

    @objc func vatSwitchChanged(_ sender: UISwitch) {
        updateVATVisibility()
    }

    func updateVATVisibility() {
        let show = vatApplySwitch.isOn
        vatModeLabel.isHidden = !show
        vatModeSegmented.isHidden = !show
        vatCalcLabel.isHidden = !show
        vatCalcSegmented.isHidden = !show
        // 편집 셀은 스위치에 따라 보이거나 숨길 수 있도록 처리 (예: vatRateRow.superview?.isHidden = !show)
        // 필요시 추가 처리
        vatRateRow.superview?.isHidden = !show
        
//        let show = vatApplySwitch.isOn
//        vatModeLabel.isHidden = !show
//        vatModeSegmented.isHidden = !show
//        vatCalcLabel.isHidden = !show
//        vatCalcSegmented.isHidden = !show
//        vatRateLabel.isHidden = !show
//        vatRateTextField.isHidden = !show
    }

    @objc func svcSwitchChanged(_ sender: UISwitch) {
        updateSVCVisibility()
    }

    func updateSVCVisibility() {
        let show = svcApplySwitch.isOn
        svcModeLabel.isHidden = !show
        svcModeSegmented.isHidden = !show
        svcCalcLabel.isHidden = !show
        svcCalcSegmented.isHidden = !show
        // svcRateRow 관련 편집 셀 처리
        svcRateRow.superview?.isHidden = !show
        
//        let show = svcApplySwitch.isOn
//        svcModeLabel.isHidden = !show
//        svcModeSegmented.isHidden = !show
//        svcCalcLabel.isHidden = !show
//        svcCalcSegmented.isHidden = !show
//        svcRateLabel.isHidden = !show
//        svcRateTextField.isHidden = !show
    }


    @objc func finalSaveButtonTapped() {
        print("최종 저장 버튼 클릭 - 결제설정 저장")
        // 저장 로직 구현
        switch (transSegmented.selectedSegmentIndex) {
        case 0: //일반거래
            Setting.shared.setDefaultUserData(_data: define.UIMethod.Common.rawValue, _key: define.APP_UI_CHECK)
            break
        case 1: //상품거래
            Setting.shared.setDefaultUserData(_data: define.UIMethod.Product.rawValue, _key: define.APP_UI_CHECK)
            break
        case 2: //앱투앱거래
            Setting.shared.setDefaultUserData(_data: define.UIMethod.AppToApp.rawValue, _key: define.APP_UI_CHECK)
            break
        default:
            break
        }
       
    }
}

// MARK: - UITextFieldDelegate
extension PaymentSettingViewController: UITextFieldDelegate {
    // 필요한 경우 구현
}

// MARK: - Helper: Underline 생성 및 Row 생성
extension PaymentSettingViewController {
//    static func createUnderline() -> UIView {
//        let view = UIView()
//        view.backgroundColor = .black
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
    
    static func createRowLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = Utils.getSubTitleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createRowValueLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = Utils.getSubTitleFont()
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createInputRow(labelText: String, valueText: String) -> UIStackView {
        let label = createRowLabel(text: labelText)
        let valueLabel = createRowValueLabel(text: valueText)
        let stack = UIStackView(arrangedSubviews: [label, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    static func createActionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Utils.getSubTitleFont()
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
