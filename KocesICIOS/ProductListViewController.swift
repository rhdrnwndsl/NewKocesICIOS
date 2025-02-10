//
//  ProductListViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/9/25.
//

import Foundation
import UIKit


class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let mKocesSdk:KocesSdk = KocesSdk.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "상품리스트"
        setupTableView()
               
        // 내비게이션 바에 '나가기' 버튼 추가 (모달 dismiss)
        let backImage = UIImage(systemName: "chevron.backward")
        let backButton = UIButton()
        backButton.setImage(backImage, for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(define.txt_blue, for: .normal)
        backButton.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        let backNav = UIBarButtonItem(customView: backButton)

        navigationItem.leftBarButtonItem = backNav
        navigationItem.titleView?.backgroundColor = .black
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
        navController.modalPresentationStyle = .fullScreen  // 필요에 따라 .overFullScreen 또는 다른 스타일로 변경 가능
        self.present(navController, animated: true, completion: nil)
    }
}
