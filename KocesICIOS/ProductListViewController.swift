//
//  ProductListViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/9/25.
//

import Foundation
import UIKit


class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIViewControllerTransitioningDelegate {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let mKocesSdk:KocesSdk = KocesSdk.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // UI 설정
        setupNavigationBar()
        setupTableView()
        
        // Observer 등록
          NotificationCenter.default.addObserver(self, selector: #selector(handleProductModified), name: Notification.Name("ProductModified"), object: nil)
    }
    
    @objc private func handleProductModified(_ notification: Notification) {
        // UI 갱신 작업 수행 (예: 테이블뷰 리로드)
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        backButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        // 커스텀 버튼을 좌측 바 버튼 아이템으로 설정
        let leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        // 중앙 타이틀 설정
        navigationItem.title = "상품리스트"
        
        // 네비게이션바의 배경 및 타이틀 색상 설정 (모든 텍스트 흰색, 배경 검정)
        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = .black
            navBar.backgroundColor = .black
            navBar.tintColor = .white
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
    
    @objc private func exitButtonTapped() {
        // 모달로 present된 경우 dismiss 처리
        dismiss(animated: true, completion: nil)
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProductListCell.self, forCellReuseIdentifier: "ProductListCell")
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        // 테이블 헤더 구성 (열 제목 및 언더라인)
        tableView.tableHeaderView = createTableHeaderView()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func createTableHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let headerTitle = UILabel()
        headerTitle.text = "상품리스트"
        headerTitle.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerTitle)
        
        let underline1 = UIView()
        underline1.backgroundColor = .lightGray
        underline1.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(underline1)
        
        // 열 제목들
        let columns = ["상품 명", "상품고유번호", "상품분류", "등록가격", "결제금액", "최종수정일자", "사용유무"]
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        for title in columns {
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
        headerView.addSubview(stackView)
        
        let underline2 = UIView()
        underline2.backgroundColor = .lightGray
        underline2.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(underline2)
        
        // AutoLayout 제약조건
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            headerTitle.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            underline1.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 5),
            underline1.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            underline1.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            underline1.heightAnchor.constraint(equalToConstant: 1),
            
            stackView.topAnchor.constraint(equalTo: underline1.bottomAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 30),
            
            underline2.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 5),
            underline2.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            underline2.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            underline2.heightAnchor.constraint(equalToConstant: 1),
            underline2.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)
        ])
        
        // 헤더 뷰의 높이는 고정하거나, 내부 요소의 총 높이로 결정됨
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 110)
        return headerView
    }
    
    // MARK: - TableView DataSource / Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mKocesSdk.listProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

         let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell", for: indexPath) as! ProductListCell
         let product = mKocesSdk.listProducts[indexPath.row]
         cell.configure(with: product)
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
         let product = mKocesSdk.listProducts[indexPath.row]
         let modifyVC = ProductModifyViewController()
         modifyVC.product = product   // 수정할 상품 정보를 전달
//         navigationController?.pushViewController(modifyVC, animated: true)
        let navController = UINavigationController(rootViewController: modifyVC)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = modifyVC  // 또는 별도로 지정
        self.present(navController, animated: true, completion: nil)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
