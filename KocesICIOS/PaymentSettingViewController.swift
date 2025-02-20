//
//  PaymentSettingViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2/13/25.
//

import Foundation
import UIKit

class PaymentSettingViewController: UIViewController {

    // MARK: - 상단 헤더 (결제설정, 저장 버튼)
    private let headerView = UIView()
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "결제설정"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - ScrollView 및 Content StackView (상단 헤더 아래 스크롤)
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    // MARK: - Section 1: 거래방식설정
    private let transTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "거래방식설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let transUnderline = PaymentSettingViewController.createUnderline()
    private let transContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let transLabel: UILabel = {
        let label = UILabel()
        label.text = "거래방식"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var transSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["일반거래", "상품거래", "APPTOAPP"])
        seg.selectedSegmentIndex = 0 // 기본 "일반거래"
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.addTarget(self, action: #selector(transSegmentChanged(_:)), for: .valueChanged)
        return seg
    }()

    // MARK: - Section 2: 팝업대기시간
    private let popupTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "팝업대기시간"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let popupUnderline = PaymentSettingViewController.createUnderline()
    private let popupContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let cardWaitLabel: UILabel = {
        let label = UILabel()
        label.text = "카드대기시간"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let cardWaitTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "입력"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    private let signWaitLabel: UILabel = {
        let label = UILabel()
        label.text = "서명대기시간"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let signWaitTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "입력"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // MARK: - Section 3: 부가세설정
    private let vatTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "부가세설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let vatUnderline = PaymentSettingViewController.createUnderline()
    private let vatContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // 부가세적용 행
    private let vatApplyLabel: UILabel = {
        let label = UILabel()
        label.text = "부가세적용"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let vatApplySwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.addTarget(self, action: #selector(vatSwitchChanged(_:)), for: .valueChanged)
        return sw
    }()
    // 부가세방식 행
    private let vatModeLabel: UILabel = {
        let label = UILabel()
        label.text = "부가세방식"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var vatModeSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["자동", "통합"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    // 부가세계산방식 행
    private let vatCalcLabel: UILabel = {
        let label = UILabel()
        label.text = "부가세계산방식"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var vatCalcSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["포함", "미포함"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    // 부가세율 행
    private let vatRateLabel: UILabel = {
        let label = UILabel()
        label.text = "부가세율"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let vatRateTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "입력"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // MARK: - Section 4: 봉사료설정
    private let svcTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "봉사료설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let svcUnderline = PaymentSettingViewController.createUnderline()
    private let svcContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // 봉사료적용 행
    private let svcApplyLabel: UILabel = {
        let label = UILabel()
        label.text = "봉사료적용"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let svcApplySwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.addTarget(self, action: #selector(svcSwitchChanged(_:)), for: .valueChanged)
        return sw
    }()
    // 봉사료방식 행
    private let svcModeLabel: UILabel = {
        let label = UILabel()
        label.text = "봉사료방식"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var svcModeSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["자동", "통합"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    // 봉사료계산방식 행
    private let svcCalcLabel: UILabel = {
        let label = UILabel()
        label.text = "봉사료계산방식"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var svcCalcSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["포함", "미포함"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()
    // 봉사료율 행
    private let svcRateLabel: UILabel = {
        let label = UILabel()
        label.text = "봉사료율"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let svcRateTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "입력"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // MARK: - Section 5: 할부설정
    private let installmentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "할부설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let installmentUnderline = PaymentSettingViewController.createUnderline()
    private let installmentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let installmentMinLabel: UILabel = {
        let label = UILabel()
        label.text = "할부최소금액"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let installmentMinTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "입력"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // MARK: - Section 6: 무서명설정
    private let nonSignatureTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "무서명설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let nonSignatureUnderline = PaymentSettingViewController.createUnderline()
    private let nonSignatureContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let nonSignatureLabel: UILabel = {
        let label = UILabel()
        label.text = "무서명설정금액"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let nonSignatureTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "입력"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // MARK: - Section 7: FALLBACK설정
    private let fallbackTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "FALLBACK설정"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let fallbackUnderline = PaymentSettingViewController.createUnderline()
    private let fallbackContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let fallbackUsageLabel: UILabel = {
        let label = UILabel()
        label.text = "폴백사용여부"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var fallbackSegmented: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["사용", "미사용"])
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()

    // MARK: - Header 아래 하단 버튼 영역
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
//    private let testButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("테스트", for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    private let finalSaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // 텍스트필드 delegate 설정
        nonSignatureTextField.delegate = self
        installmentMinTextField.delegate = self
        vatRateTextField.delegate = self
        svcRateTextField.delegate = self
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("ScrollView content size: \(scrollView.contentSize)")
    }

    // MARK: - UI Setup
    private func setupUI() {
        // 상단 헤더 (결제설정, 저장 버튼)
        let headerStack = UIStackView(arrangedSubviews: [headerLabel, finalSaveButton])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerStack.heightAnchor.constraint(equalToConstant: 40)
        ])
        finalSaveButton.addTarget(self, action: #selector(finalSaveButtonTapped), for: .touchUpInside)

        // ScrollView 및 Main StackView 설정
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        // Section: 거래방식설정
        contentStackView.addArrangedSubview(transTitleLabel)
        contentStackView.addArrangedSubview(transUnderline)
        contentStackView.addArrangedSubview(transContainer)
        NSLayoutConstraint.activate([
            transContainer.heightAnchor.constraint(equalToConstant: 40)
        ])
        let transRow = UIStackView(arrangedSubviews: [transLabel, transSegmented])
        transRow.axis = .horizontal
        transRow.spacing = 10
        transRow.distribution = .fillProportionally
        transRow.translatesAutoresizingMaskIntoConstraints = false
        transContainer.addSubview(transRow)
        NSLayoutConstraint.activate([
            transRow.topAnchor.constraint(equalTo: transContainer.topAnchor, constant: 5),
            transRow.leadingAnchor.constraint(equalTo: transContainer.leadingAnchor, constant: 10),
            transRow.trailingAnchor.constraint(equalTo: transContainer.trailingAnchor, constant: -10),
            transRow.bottomAnchor.constraint(equalTo: transContainer.bottomAnchor, constant: -5)
        ])

        // Section: 팝업대기시간
        contentStackView.addArrangedSubview(popupTitleLabel)
        contentStackView.addArrangedSubview(popupUnderline)
        contentStackView.addArrangedSubview(popupContainer)
        NSLayoutConstraint.activate([
            popupContainer.heightAnchor.constraint(equalToConstant: 80)
        ])
        let cardRow = UIStackView(arrangedSubviews: [cardWaitLabel, cardWaitTextField])
        cardRow.axis = .horizontal
        cardRow.spacing = 10
        cardRow.distribution = .fillProportionally
        cardRow.translatesAutoresizingMaskIntoConstraints = false
        let signRow = UIStackView(arrangedSubviews: [signWaitLabel, signWaitTextField])
        signRow.axis = .horizontal
        signRow.spacing = 10
        signRow.distribution = .fillProportionally
        signRow.translatesAutoresizingMaskIntoConstraints = false
        let popupStack = UIStackView(arrangedSubviews: [cardRow, signRow])
        popupStack.axis = .vertical
        popupStack.spacing = 10
        popupStack.translatesAutoresizingMaskIntoConstraints = false
        popupContainer.addSubview(popupStack)
        NSLayoutConstraint.activate([
            popupStack.topAnchor.constraint(equalTo: popupContainer.topAnchor, constant: 10),
            popupStack.leadingAnchor.constraint(equalTo: popupContainer.leadingAnchor, constant: 10),
            popupStack.trailingAnchor.constraint(equalTo: popupContainer.trailingAnchor, constant: -10),
            popupStack.bottomAnchor.constraint(equalTo: popupContainer.bottomAnchor, constant: -10)
        ])

        // Section: 부가세설정
        contentStackView.addArrangedSubview(vatTitleLabel)
        contentStackView.addArrangedSubview(vatUnderline)
        contentStackView.addArrangedSubview(vatContainer)
        NSLayoutConstraint.activate([
            vatContainer.heightAnchor.constraint(equalToConstant: 140)
        ])
        let vatApplyRow = UIStackView(arrangedSubviews: [vatApplyLabel, vatApplySwitch])
        vatApplyRow.axis = .horizontal
        vatApplyRow.spacing = 10
        vatApplyRow.distribution = .fillProportionally
        vatApplyRow.translatesAutoresizingMaskIntoConstraints = false
        let vatModeRow = UIStackView(arrangedSubviews: [vatModeLabel, vatModeSegmented])
        vatModeRow.axis = .horizontal
        vatModeRow.spacing = 10
        vatModeRow.distribution = .fillProportionally
        vatModeRow.translatesAutoresizingMaskIntoConstraints = false
        let vatCalcRow = UIStackView(arrangedSubviews: [vatCalcLabel, vatCalcSegmented])
        vatCalcRow.axis = .horizontal
        vatCalcRow.spacing = 10
        vatCalcRow.distribution = .fillProportionally
        vatCalcRow.translatesAutoresizingMaskIntoConstraints = false
        let vatRateRow = UIStackView(arrangedSubviews: [vatRateLabel, vatRateTextField])
        vatRateRow.axis = .horizontal
        vatRateRow.spacing = 10
        vatRateRow.distribution = .fillProportionally
        vatRateRow.translatesAutoresizingMaskIntoConstraints = false
        let vatStack = UIStackView(arrangedSubviews: [vatApplyRow, vatModeRow, vatCalcRow, vatRateRow])
        vatStack.axis = .vertical
        vatStack.spacing = 10
        vatStack.translatesAutoresizingMaskIntoConstraints = false
        vatContainer.addSubview(vatStack)
        NSLayoutConstraint.activate([
            vatStack.topAnchor.constraint(equalTo: vatContainer.topAnchor, constant: 10),
            vatStack.leadingAnchor.constraint(equalTo: vatContainer.leadingAnchor, constant: 10),
            vatStack.trailingAnchor.constraint(equalTo: vatContainer.trailingAnchor, constant: -10),
            vatStack.bottomAnchor.constraint(equalTo: vatContainer.bottomAnchor, constant: -10)
        ])

        // Section: 봉사료설정
        contentStackView.addArrangedSubview(svcTitleLabel)
        contentStackView.addArrangedSubview(svcUnderline)
        contentStackView.addArrangedSubview(svcContainer)
        NSLayoutConstraint.activate([
            svcContainer.heightAnchor.constraint(equalToConstant: 140)
        ])
        let svcApplyRow = UIStackView(arrangedSubviews: [svcApplyLabel, svcApplySwitch])
        svcApplyRow.axis = .horizontal
        svcApplyRow.spacing = 10
        svcApplyRow.distribution = .fillProportionally
        svcApplyRow.translatesAutoresizingMaskIntoConstraints = false
        let svcModeRow = UIStackView(arrangedSubviews: [svcModeLabel, svcModeSegmented])
        svcModeRow.axis = .horizontal
        svcModeRow.spacing = 10
        svcModeRow.distribution = .fillProportionally
        svcModeRow.translatesAutoresizingMaskIntoConstraints = false
        let svcCalcRow = UIStackView(arrangedSubviews: [svcCalcLabel, svcCalcSegmented])
        svcCalcRow.axis = .horizontal
        svcCalcRow.spacing = 10
        svcCalcRow.distribution = .fillProportionally
        svcCalcRow.translatesAutoresizingMaskIntoConstraints = false
        let svcRateRow = UIStackView(arrangedSubviews: [svcRateLabel, svcRateTextField])
        svcRateRow.axis = .horizontal
        svcRateRow.spacing = 10
        svcRateRow.distribution = .fillProportionally
        svcRateRow.translatesAutoresizingMaskIntoConstraints = false
        let svcStack = UIStackView(arrangedSubviews: [svcApplyRow, svcModeRow, svcCalcRow, svcRateRow])
        svcStack.axis = .vertical
        svcStack.spacing = 10
        svcStack.translatesAutoresizingMaskIntoConstraints = false
        svcContainer.addSubview(svcStack)
        NSLayoutConstraint.activate([
            svcStack.topAnchor.constraint(equalTo: svcContainer.topAnchor, constant: 10),
            svcStack.leadingAnchor.constraint(equalTo: svcContainer.leadingAnchor, constant: 10),
            svcStack.trailingAnchor.constraint(equalTo: svcContainer.trailingAnchor, constant: -10),
            svcStack.bottomAnchor.constraint(equalTo: svcContainer.bottomAnchor, constant: -10)
        ])

        // Section: 할부설정
        contentStackView.addArrangedSubview(installmentTitleLabel)
        contentStackView.addArrangedSubview(installmentUnderline)
        contentStackView.addArrangedSubview(installmentContainer)
        NSLayoutConstraint.activate([
            installmentContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
        let installmentRow = UIStackView(arrangedSubviews: [installmentMinLabel, installmentMinTextField])
        installmentRow.axis = .horizontal
        installmentRow.spacing = 10
        installmentRow.distribution = .fillProportionally
        installmentRow.translatesAutoresizingMaskIntoConstraints = false
        installmentContainer.addSubview(installmentRow)
        NSLayoutConstraint.activate([
            installmentRow.topAnchor.constraint(equalTo: installmentContainer.topAnchor, constant: 10),
            installmentRow.leadingAnchor.constraint(equalTo: installmentContainer.leadingAnchor, constant: 10),
            installmentRow.trailingAnchor.constraint(equalTo: installmentContainer.trailingAnchor, constant: -10),
            installmentRow.bottomAnchor.constraint(equalTo: installmentContainer.bottomAnchor, constant: -10)
        ])

        // Section: 무서명설정
        contentStackView.addArrangedSubview(nonSignatureTitleLabel)
        contentStackView.addArrangedSubview(nonSignatureUnderline)
        contentStackView.addArrangedSubview(nonSignatureContainer)
        NSLayoutConstraint.activate([
            nonSignatureContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
        let nonSignatureRow = UIStackView(arrangedSubviews: [nonSignatureLabel, nonSignatureTextField])
        nonSignatureRow.axis = .horizontal
        nonSignatureRow.spacing = 10
        nonSignatureRow.distribution = .fillProportionally
        nonSignatureRow.translatesAutoresizingMaskIntoConstraints = false
        nonSignatureContainer.addSubview(nonSignatureRow)
        NSLayoutConstraint.activate([
            nonSignatureRow.topAnchor.constraint(equalTo: nonSignatureContainer.topAnchor, constant: 10),
            nonSignatureRow.leadingAnchor.constraint(equalTo: nonSignatureContainer.leadingAnchor, constant: 10),
            nonSignatureRow.trailingAnchor.constraint(equalTo: nonSignatureContainer.trailingAnchor, constant: -10),
            nonSignatureRow.bottomAnchor.constraint(equalTo: nonSignatureContainer.bottomAnchor, constant: -10)
        ])

        // Section: FALLBACK설정
        contentStackView.addArrangedSubview(fallbackTitleLabel)
        contentStackView.addArrangedSubview(fallbackUnderline)
        contentStackView.addArrangedSubview(fallbackContainer)
        NSLayoutConstraint.activate([
            fallbackContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
        let fallbackRow = UIStackView(arrangedSubviews: [fallbackUsageLabel, fallbackSegmented])
        fallbackRow.axis = .horizontal
        fallbackRow.spacing = 10
        fallbackRow.distribution = .fillProportionally
        fallbackRow.translatesAutoresizingMaskIntoConstraints = false
        fallbackContainer.addSubview(fallbackRow)
        NSLayoutConstraint.activate([
            fallbackRow.topAnchor.constraint(equalTo: fallbackContainer.topAnchor, constant: 10),
            fallbackRow.leadingAnchor.constraint(equalTo: fallbackContainer.leadingAnchor, constant: 10),
            fallbackRow.trailingAnchor.constraint(equalTo: fallbackContainer.trailingAnchor, constant: -10),
            fallbackRow.bottomAnchor.constraint(equalTo: fallbackContainer.bottomAnchor, constant: -10)
        ])

        // Section: 하단 버튼 영역
        contentStackView.addArrangedSubview(buttonStack)
        buttonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        buttonStack.addArrangedSubview(testButton)
        buttonStack.addArrangedSubview(finalSaveButton)
//        testButton.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
        finalSaveButton.addTarget(self, action: #selector(finalSaveButtonTapped), for: .touchUpInside)
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
        vatRateLabel.isHidden = !show
        vatRateTextField.isHidden = !show
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
        svcRateLabel.isHidden = !show
        svcRateTextField.isHidden = !show
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
    static func createUnderline() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createRowLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createRowValueLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
