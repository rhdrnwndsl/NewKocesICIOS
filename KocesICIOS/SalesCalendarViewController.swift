//
//  SalesCalendarViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/19/25.
//

import Foundation
import UIKit

class SalesCalendarViewController: UIViewController {
    
    // MARK: - UI Components
    
    // 상단 타이틀 & Segmented Control 영역
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "매출정보"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    
    private let segmentControl: UISegmentedControl = {
        let items = ["매출캘린더", "결제수단별\n매출현황", "상품별\n매출현황"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0  // 기본값은 "매출캘린더"
        return sc
    }()
    
    // 컨텐츠 영역 (세그먼트에 따라 보일 내용)
    // (1) 매출캘린더 화면 (달력 + 상세)
    private let calendarContainerView = UIView()
    private let detailContainerView = UIView()
    
    // (2) 기타: 임시 로그 메시지
    private let paymentMethodView: UILabel = {
        let label = UILabel()
        label.text = "결제수단별 매출현황 선택됨"
        label.textAlignment = .center
        return label
    }()
    private let productSalesView: UILabel = {
        let label = UILabel()
        label.text = "상품별 매출현황 선택됨"
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - 매출캘린더 화면 구성
    
    // 달력 뷰 – 왼쪽 영역에 들어갈 내용 (헤더, 요일, 날짜 그리드, 하단 요약)
    private let calendarView = UIView()
    
    // 달력 헤더 내 버튼 및 라벨
    private let prevMonthButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("<", for: .normal)
        return btn
    }()
    private let nextMonthButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(">", for: .normal)
        return btn
    }()
    private let todayButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("오늘", for: .normal)
        return btn
    }()
    private let monthYearLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // 요일 헤더 (일~토)
    private let weekdayStackView: UIStackView = {
        let days = ["일", "월", "화", "수", "목", "금", "토"]
        let labels = days.map { day -> UILabel in
            let lbl = UILabel()
            lbl.text = day
            lbl.textAlignment = .center
            if day == "일" { lbl.textColor = .red }
            else if day == "토" { lbl.textColor = .blue }
            return lbl
        }
        let stack = UIStackView(arrangedSubviews: labels)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    // 달력 뷰 구성 관련 UI
    private let calendarGridView = UIView()
    // 각 날짜 셀을 담은 배열 (실제 앱에서는 UICollectionView 등으로 구성해도 됨)
    private var dateCells: [DateCellView] = []
    // 현재 선택된 날짜와 현재 표시되는 달(기준 날짜)
    private var selectedDate: Date = Date()
    private var currentDate: Date = Date()
    
    // 하단 요약 라벨 (월 매출/환불 금액)
    private let monthSummaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        // 예시 텍스트
        label.text = "월 매출금액: xx,xxx 원    월 환불금액: -x,xxx 원"
        return label
    }()
    
    // 상세 정보 영역 – 오른쪽 영역(가로) 또는 달력 아래 (세로)
    // 스크롤 뷰 내에 상세 정보 컨텐츠
    private let detailScrollView = UIScrollView()
    private let detailContentView = UIView()
    
    // orientation 관련 제약 모음
    private var contentConstraints = [NSLayoutConstraint]()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //네비게이션 바의 배경색 rgb 변경
//        UISetting.navigationTitleSetting(navigationBar: navigationController?.navigationBar ?? UINavigationBar())
//        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 상단, segmented, 달력, 상세 등 UI 초기 설정 (setupTopArea(), setupSegmentedContent(), setupCalendarView(), setupDetailView() 등)
        setupTopArea()
        setupSegmentedContent()
        setupCalendarView()
        setupDetailView()
        
        // segmentedControl 초기 상태: "매출캘린더" 선택
        updateSegmentedView()
        
        // 버튼 액션 연결
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        prevMonthButton.addTarget(self, action: #selector(moveToPrevMonth), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(moveToNextMonth), for: .touchUpInside)
        todayButton.addTarget(self, action: #selector(moveToToday), for: .touchUpInside)
        
        // 달력 날짜 그리드 구성 (예시: 35셀)
//        setupCalendarGrid()
        updateCalendarHeader()
        updateCalendarGrid()  // 셀 내용 및 선택 상태 업데이트
        
        // 시작 시 화면 크기 기준 레이아웃 적용
        let isLandscape = view.bounds.width > view.bounds.height
        activateContentConstraints(isLandscape: isLandscape)
    }
    
    // 회전 시 새 사이즈에 맞게 레이아웃 업데이트
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            let isLandscape = size.width > size.height
            self.activateContentConstraints(isLandscape: isLandscape)
        })
    }
    
    func setupNavigationBar() {
        // 왼쪽에 커스텀 백 버튼 생성: "chevron.backward" 이미지 + "BACK" 텍스트
        let backButton = UIButton(type: .system)
        if let backImage = UIImage(systemName: "chevron.backward") {
            backButton.setImage(backImage, for: .normal)
        }
        // 이미지와 텍스트 사이에 약간의 공백을 주기 위해 앞에 공백 추가
        backButton.setTitle(" Back", for: .normal)
        
        // 아이콘과 텍스트 모두 흰색으로 설정
        backButton.tintColor = define.txt_blue
        backButton.setTitleColor(define.txt_blue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        // 크기 조정
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(BackMainView), for: .touchUpInside)
        
        // 커스텀 버튼을 좌측 바 버튼 아이템으로 설정
        let leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem

    }
    
    // MARK: - Top Area Setup (타이틀 + SegmentedControl)
    
    private func setupTopArea() {
        view.addSubview(titleLabel)
        view.addSubview(segmentControl)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            segmentControl.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentControl.widthAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    // MARK: - Segmented Content Setup
    
    private func setupSegmentedContent() {
        // 매출캘린더 관련 컨테이너
        view.addSubview(calendarContainerView)
        view.addSubview(detailContainerView)
        
        calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        detailContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // 기타 다른 세그먼트용 로그 라벨 (중심에 배치)
        view.addSubview(paymentMethodView)
        view.addSubview(productSalesView)
        paymentMethodView.translatesAutoresizingMaskIntoConstraints = false
        productSalesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paymentMethodView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentMethodView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            productSalesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            productSalesView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Calendar View Setup
    
    private func setupCalendarView() {
        // 달력 컨테이너에 달력뷰 추가
        calendarContainerView.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.backgroundColor = UIColor.systemGray6
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor)
        ])
        
        // 달력 헤더: 이전, 현재연월, 다음, 오늘 버튼을 담은 스택뷰
        let headerStack = UIStackView(arrangedSubviews: [prevMonthButton, monthYearLabel, nextMonthButton, todayButton])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        calendarView.addSubview(headerStack)
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: calendarView.topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 8),
            headerStack.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -8)
        ])
        
        // 요일 헤더
        calendarView.addSubview(weekdayStackView)
        weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weekdayStackView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            weekdayStackView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 8),
            weekdayStackView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -8),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // 날짜 그리드 추가 (아래에서 구성)
        calendarView.addSubview(calendarGridView)
        calendarGridView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarGridView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 8),
            calendarGridView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 8),
            calendarGridView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -8)
        ])
        
        // 하단 월 요약 라벨
        calendarView.addSubview(monthSummaryLabel)
        monthSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthSummaryLabel.topAnchor.constraint(equalTo: calendarGridView.bottomAnchor, constant: 8),
            monthSummaryLabel.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 8),
            monthSummaryLabel.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -8),
            monthSummaryLabel.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -8)
        ])
    }
    
    // 달력 그리드 – 5행×7열 (총 35셀) 구성 예시
    private func setupCalendarGrid() {
        // 이전에 생성한 셀이 있다면 제거
        dateCells.forEach { $0.removeFromSuperview() }
        dateCells.removeAll()
        
        // 5행 7열 그리드를 구성하기 위해 수직 스택뷰 사용
        let rowsStack = UIStackView()
        rowsStack.axis = .vertical
        rowsStack.distribution = .fillEqually
        rowsStack.spacing = 4
        calendarGridView.addSubview(rowsStack)
        rowsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowsStack.topAnchor.constraint(equalTo: calendarGridView.topAnchor),
            rowsStack.leadingAnchor.constraint(equalTo: calendarGridView.leadingAnchor),
            rowsStack.trailingAnchor.constraint(equalTo: calendarGridView.trailingAnchor),
            rowsStack.bottomAnchor.constraint(equalTo: calendarGridView.bottomAnchor)
        ])
        
        // 35셀 생성 (셀 내부에 날짜, 매출금액(파란색), 환불금액(빨간색) 표시)
        var cellIndex = 0
        for _ in 0..<5 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 4
            for _ in 0..<7 {
                let cell = DateCellView()
                cell.tag = cellIndex  // 셀 구분용 태그
                // 탭 제스처로 날짜 선택 액션 연결
                let tap = UITapGestureRecognizer(target: self, action: #selector(dateCellTapped(_:)))
                cell.addGestureRecognizer(tap)
                dateCells.append(cell)
                rowStack.addArrangedSubview(cell)
                cellIndex += 1
            }
            rowsStack.addArrangedSubview(rowStack)
        }
    }
    
    // MARK: - Detail View Setup (상세 매출 내역)
    
    private func setupDetailView() {
        // 상세 내용은 스크롤뷰 내부에 넣습니다.
        detailContainerView.addSubview(detailScrollView)
        detailScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailScrollView.topAnchor.constraint(equalTo: detailContainerView.topAnchor),
            detailScrollView.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor),
            detailScrollView.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor),
            detailScrollView.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor)
        ])
        
        detailScrollView.addSubview(detailContentView)
        detailContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailContentView.topAnchor.constraint(equalTo: detailScrollView.topAnchor),
            detailContentView.leadingAnchor.constraint(equalTo: detailScrollView.leadingAnchor),
            detailContentView.trailingAnchor.constraint(equalTo: detailScrollView.trailingAnchor),
            detailContentView.bottomAnchor.constraint(equalTo: detailScrollView.bottomAnchor),
            detailContentView.widthAnchor.constraint(equalTo: detailScrollView.widthAnchor)
        ])
        
        // 세로로 여러 섹션을 쌓기 위한 스택뷰 생성
        let detailStack = UIStackView()
        detailStack.axis = .vertical
        detailStack.spacing = 12
        detailContentView.addSubview(detailStack)
        detailStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailStack.topAnchor.constraint(equalTo: detailContentView.topAnchor, constant: 16),
            detailStack.leadingAnchor.constraint(equalTo: detailContentView.leadingAnchor, constant: 16),
            detailStack.trailingAnchor.constraint(equalTo: detailContentView.trailingAnchor, constant: -16),
            detailStack.bottomAnchor.constraint(lessThanOrEqualTo: detailContentView.bottomAnchor, constant: -16)
        ])
        
        // 예시 섹션 추가: 카드결제, 현금결제, 간편결제, 현금IC결제, 일별합계
        detailStack.addArrangedSubview(makeDetailSection(title: "카드결제", rows: [("카드승인", "x건  x,xxx 원"), ("카드환불", "x건  x,xxx 원")]))
        detailStack.addArrangedSubview(makeDetailSection(title: "현금결제", rows: [("현금승인", "x건  x,xxx 원"), ("현금환불", "x건  x,xxx 원")]))
        detailStack.addArrangedSubview(makeDetailSection(title: "간편결제", rows: [("간편승인", "x건  x,xxx 원"), ("간편환불", "x건  x,xxx 원")]))
        detailStack.addArrangedSubview(makeDetailSection(title: "현금IC결제", rows: [("현금IC승인", "x건  x,xxx 원"), ("현금IC환불", "x건  x,xxx 원")]))
        detailStack.addArrangedSubview(makeDetailSection(title: "일별합계", rows: [("일별승인", "x건  x,xxx 원"), ("일별환불", "x건  x,xxx 원"), ("합계", "x건  x,xxx 원")]))
    }
    
    private func makeDetailSection(title: String, rows: [(String, String)]) -> UIView {
        let sectionView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        let boxView = UIView()
        boxView.backgroundColor = UIColor.systemGray5
        boxView.layer.cornerRadius = 8
        
        sectionView.addSubview(titleLabel)
        sectionView.addSubview(boxView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        boxView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            
            boxView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            boxView.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            boxView.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            boxView.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor),
            boxView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        // 박스 내부에 행을 쌓기 위한 수직 스택뷰
        let rowStack = UIStackView()
        rowStack.axis = .vertical
        rowStack.spacing = 4
        boxView.addSubview(rowStack)
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: boxView.topAnchor, constant: 8),
            rowStack.leadingAnchor.constraint(equalTo: boxView.leadingAnchor, constant: 8),
            rowStack.trailingAnchor.constraint(equalTo: boxView.trailingAnchor, constant: -8),
            rowStack.bottomAnchor.constraint(equalTo: boxView.bottomAnchor, constant: -8)
        ])
        
        for (labelText, valueText) in rows {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .equalSpacing
            let lbl = UILabel()
            lbl.text = labelText
            let val = UILabel()
            val.text = valueText
            row.addArrangedSubview(lbl)
            row.addArrangedSubview(val)
            rowStack.addArrangedSubview(row)
        }
        
        return sectionView
    }
    
    // MARK: - Layout: Orientation 대응
    // 가로모드: 달력 컨테이너와 상세 컨테이너를 좌우 배치
    // 세로모드: 달력 컨테이너가 위, 상세 컨테이너가 아래
    private func activateContentConstraints(isLandscape: Bool) {
        NSLayoutConstraint.deactivate(contentConstraints)
        contentConstraints.removeAll()
        
        // 상단 타이틀, segmentedControl 아래부터 컨텐츠 배치 (이미 상단은 고정)
        let topAnchorView = segmentControl
        
        if isLandscape {
            // 가로 모드: 좌우 배치
            contentConstraints.append(contentsOf: [
                calendarContainerView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 8),
                calendarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                calendarContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
                calendarContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
                
                detailContainerView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
                detailContainerView.leadingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor, constant: 8),
                detailContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                detailContainerView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
            ])
        } else {
            // 세로 모드: 위아래 배치
            contentConstraints.append(contentsOf: [
                calendarContainerView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 8),
                calendarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                calendarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                calendarContainerView.heightAnchor.constraint(equalToConstant: 300),
                
                detailContainerView.topAnchor.constraint(equalTo: calendarContainerView.bottomAnchor, constant: 8),
                detailContainerView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
                detailContainerView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
                detailContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
            ])
        }
        
        NSLayoutConstraint.activate(contentConstraints)
    }
    
    // MARK: - Segmented Control Action
    
    @objc func BackMainView() {
        let storyboard = getMainStoryBoard()
        let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBar")
        mainTabBarController.modalPresentationStyle = .fullScreen
        self.present(mainTabBarController, animated: true, completion: nil)
    }
    
    private func getMainStoryBoard() -> UIStoryboard {
        var storyboard:UIStoryboard?
        if UIDevice.current.userInterfaceIdiom == .phone {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "pad", bundle: Bundle.main)
        }
        return storyboard!
    }
    
    @objc private func segmentChanged() {
        updateSegmentedView()
    }
    
    // segmentedControl 값에 따라 관련 컨텐츠 보이기/숨기기
    private func updateSegmentedView() {
        let index = segmentControl.selectedSegmentIndex
        if index == 0 {
            // 매출캘린더 선택: 달력+상세 영역 보임
            calendarContainerView.isHidden = false
            detailContainerView.isHidden = false
            paymentMethodView.isHidden = true
            productSalesView.isHidden = true
        } else if index == 1 {
            // 결제수단별 매출현황: 달력+상세 영역 숨김, 임시 로그 보임
            calendarContainerView.isHidden = true
            detailContainerView.isHidden = true
            paymentMethodView.isHidden = false
            productSalesView.isHidden = true
        } else {
            // 상품별 매출현황: 달력+상세 영역 숨김, 임시 로그 보임
            calendarContainerView.isHidden = true
            detailContainerView.isHidden = true
            paymentMethodView.isHidden = true
            productSalesView.isHidden = false
        }
    }
    
    // MARK: - 달력 그리드 계산 및 업데이트
    
    // 현재 currentDate 값을 기준으로 헤더 갱신 (예: "2025년 02월")
    private func updateCalendarHeader() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월"
        monthYearLabel.text = formatter.string(from: currentDate)
    }
    
    // 달력 그리드 셀 업데이트 (예시로 셀의 tag 값을 이용하여 날짜번호 표시)
    // 실제 달력 날짜들을 계산하여 grid에 표시 (셀 재구성 포함)
    private func updateCalendarGrid() {
        let calendar = Calendar.current
               
        // 현재 표시할 달의 첫 날 계산 (연/월 정보만 사용)
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return
        }
        
        // 첫 날의 요일 (기본: Sunday = 1)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        // calendar.firstWeekday는 보통 1 (일요일)로 가정 → 이전 달에서 채워야 할 셀 수 = firstWeekday - 1
        let previousDays = firstWeekday - 1
        
        // 현재 달의 일 수
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 0
        
        // 전체 셀 수는 (이전 달 채움 + 당월 일수)을 7로 나눈 뒤 올림하여 구한 주 수 * 7
        let totalCells = Int(ceil(Double(previousDays + daysInMonth) / 7.0)) * 7
        
        // 만약 기존에 생성된 셀의 개수가 달라지면 grid를 다시 구성
        if dateCells.count != totalCells {
            // 기존 셀 제거
            dateCells.forEach { $0.removeFromSuperview() }
            dateCells.removeAll()
            calendarGridView.subviews.forEach { $0.removeFromSuperview() }
            
            // 수직 스택뷰로 행 구성
            let rowsStack = UIStackView()
            rowsStack.axis = .vertical
            rowsStack.distribution = .fillEqually
            rowsStack.spacing = 4
            calendarGridView.addSubview(rowsStack)
            rowsStack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                rowsStack.topAnchor.constraint(equalTo: calendarGridView.topAnchor),
                rowsStack.leadingAnchor.constraint(equalTo: calendarGridView.leadingAnchor),
                rowsStack.trailingAnchor.constraint(equalTo: calendarGridView.trailingAnchor),
                rowsStack.bottomAnchor.constraint(equalTo: calendarGridView.bottomAnchor)
            ])
            
            let numberOfRows = totalCells / 7
            var cellIndex = 0
            for _ in 0..<numberOfRows {
                let rowStack = UIStackView()
                rowStack.axis = .horizontal
                rowStack.distribution = .fillEqually
                rowStack.spacing = 4
                for _ in 0..<7 {
                    let cell = DateCellView()
                    cell.tag = cellIndex
                    // 셀 탭 제스처 연결
                    let tap = UITapGestureRecognizer(target: self, action: #selector(dateCellTapped(_:)))
                    cell.addGestureRecognizer(tap)
                    dateCells.append(cell)
                    rowStack.addArrangedSubview(cell)
                    cellIndex += 1
                }
                rowsStack.addArrangedSubview(rowStack)
            }
        }
        
        // 각 셀에 해당 날짜를 채워 넣습니다.
        for (i, cell) in dateCells.enumerated() {
            let offset = i - previousDays
            if let cellDate = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) {
                cell.cellDate = cellDate  // DateCellView에 추가한 프로퍼티
                let day = calendar.component(.day, from: cellDate)
                cell.dateLabel.text = "\(day)"
                
                // 현재 표시 중인 달과 동일한지 여부
                let isCurrentMonth = calendar.component(.month, from: cellDate) == calendar.component(.month, from: currentDate)
                
                // 색상: 현재 월이면 요일에 따라, 아니면 회색
                if isCurrentMonth {
                    let weekday = calendar.component(.weekday, from: cellDate)
                    if weekday == 1 {
                        cell.dateLabel.textColor = .red
                    } else if weekday == 7 {
                        cell.dateLabel.textColor = .blue
                    } else {
                        cell.dateLabel.textColor = .black
                    }
                } else {
                    cell.dateLabel.textColor = .gray
                }
                
                // 매출금액, 환불금액 (더미 데이터; 실제 데이터 연동 시 변경)
                cell.salesLabel.text = "1,000"
                cell.refundLabel.text = "-100"
                
                // 선택된 날짜 처리: 같은 날이면 녹색 배경, 아니면 흰색
                if calendar.isDate(cellDate, inSameDayAs: selectedDate) {
                    cell.backgroundColor = UIColor.green.withAlphaComponent(0.3)
                } else {
                    cell.backgroundColor = .white
                }
            }
        }
        
        // 하단 요약 라벨 업데이트 (예시)
        monthSummaryLabel.text = "월 매출금액: 123,456 원    월 환불금액: -12,345 원"
    }
    
    // MARK: - 날짜 이동/선택 액션
    
    @objc private func moveToPrevMonth() {
        // currentDate에 대해 한 달 전으로 이동
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
            updateCalendarHeader()
            updateCalendarGrid()
        }
    }
    
    @objc private func moveToNextMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
            updateCalendarHeader()
            updateCalendarGrid()
        }
    }
    
    @objc private func moveToToday() {
        currentDate = Date()
        selectedDate = Date()
        updateCalendarHeader()
        updateCalendarGrid()
    }
    
    @objc private func dateCellTapped(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? DateCellView,
              let cellDate = cell.cellDate else { return }
        selectedDate = cellDate
        updateCalendarGrid()
        // 이곳에서 오른쪽 상세 정보 업데이트 처리 가능 (선택된 날짜에 따른 매출/환불 내역 등)
        
//        if let cell = sender.view as? DateCellView {
//            // 예시: 셀의 tag + 1을 선택한 날짜의 "일"로 가정 (실제 구현 시 연/월 반영)
//            let day = cell.tag + 1
//            var comps = Calendar.current.dateComponents([.year, .month], from: currentDate)
//            comps.day = day
//            if let newDate = Calendar.current.date(from: comps) {
//                selectedDate = newDate
//                updateCalendarGrid()
//                // 여기서 오른쪽 상세 정보는 선택된 날짜에 맞게 업데이트 (실제 매출/환불 내역 갱신)
//            }
//        }
    }
}

// MARK: - DateCellView (날짜 셀 커스텀 뷰)
// 하나의 날짜 셀에는 날짜 번호, 매출금액(파란색), 환불금액(빨간색)이 표시됩니다.
class DateCellView: UIView {
    // cellDate 프로퍼티: 해당 셀이 표시하는 날짜
    var cellDate: Date?
    
    let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textAlignment = .center
        return lbl
    }()
    
    let salesLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10)
        lbl.textColor = .blue
        lbl.textAlignment = .center
        return lbl
    }()
    
    let refundLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10)
        lbl.textColor = .red
        lbl.textAlignment = .center
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        let stack = UIStackView(arrangedSubviews: [dateLabel, salesLabel, refundLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2)
        ])
    }
}
