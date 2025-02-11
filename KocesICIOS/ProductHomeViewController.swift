//
//  ProductHomeViewController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/11/25.
//

import Foundation
import UIKit

// 장바구니 항목 모델
struct BasketItem {
    var product: Product
    var quantity: Int
}

// MARK: - ProductHomeViewController

class ProductHomeViewController: UIViewController {
    
    // 데이터
    var categories: [String] = []
    var products: [Product] = []
    var filteredProducts: [Product] = []
    // 장바구니: product.id를 key로 사용
    var basket: [Int: BasketItem] = [:]
    
    // 좌측, 우측 컨테이너
    let leftContainer = UIView()
    let rightContainer = UIView()
    
    // 좌측 화면 UI
    let categoryScrollView = UIScrollView()
    let categoryStackView = UIStackView()
    var selectedCategory: String? = nil
    var productCollectionView: UICollectionView!
    
    // 우측 화면 UI (장바구니)
    let basketTopView = UIView()
    let addBasketButton = UIButton(type: .system)
    let removeBasketButton = UIButton(type: .system)
    var basketTableView: UITableView!
    let basketSummaryView = UIView()
    let basketSummaryLabel = UILabel()
    let paymentButton = UIButton(type: .system)
    
    // 우측 장바구니에서 선택된 상품 (optional)
    var basketSelectedProductID: Int? = nil
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Landscape 전용으로 사용 (supportedInterfaceOrientations 재정의)
        
        setupUI()
        loadData()
        updateLeftSide()
        updateBasketSummary()
    }
    
    // 오직 가로 모드만 지원
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    // MARK: - UI Setup
    
    func setupUI() {
        leftContainer.translatesAutoresizingMaskIntoConstraints = false
        rightContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftContainer)
        view.addSubview(rightContainer)
        
        // 좌측 70%, 우측 30% 분할 (좌우 비율은 7:3)
        NSLayoutConstraint.activate([
            leftContainer.topAnchor.constraint(equalTo: view.topAnchor),
            leftContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            
            rightContainer.topAnchor.constraint(equalTo: view.topAnchor),
            rightContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3)
        ])
        
        // 중앙 구분선
        let divider = UIView()
        divider.backgroundColor = .lightGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider)
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: view.topAnchor),
            divider.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: leftContainer.trailingAnchor)
        ])
        
        setupLeftSide()
        setupRightSide()
    }
    
    func setupLeftSide() {
        // 카테고리 스크롤뷰 (상단, 고정 높이 50)
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.showsHorizontalScrollIndicator = false
        leftContainer.addSubview(categoryScrollView)
        categoryStackView.axis = .horizontal
        categoryStackView.spacing = 8
        categoryStackView.alignment = .center
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.addSubview(categoryStackView)
        
        // 상품 그리드를 위한 UICollectionView (아래 부분)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        productCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        productCollectionView.backgroundColor = .white
        productCollectionView.translatesAutoresizingMaskIntoConstraints = false
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
        productCollectionView.register(ProductCollectionCell.self, forCellWithReuseIdentifier: "ProductCell")
        leftContainer.addSubview(productCollectionView)
        
        // 제약조건
        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: leftContainer.topAnchor),
            categoryScrollView.leadingAnchor.constraint(equalTo: leftContainer.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: leftContainer.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 50),
            
            categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor, constant: 5),
            categoryStackView.bottomAnchor.constraint(equalTo: categoryScrollView.bottomAnchor, constant: -5),
            categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor, constant: 10),
            categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor, constant: -10),
            
            productCollectionView.topAnchor.constraint(equalTo: categoryScrollView.bottomAnchor, constant: 10),
            productCollectionView.leadingAnchor.constraint(equalTo: leftContainer.leadingAnchor, constant: 10),
            productCollectionView.trailingAnchor.constraint(equalTo: leftContainer.trailingAnchor, constant: -10),
            productCollectionView.bottomAnchor.constraint(equalTo: leftContainer.bottomAnchor, constant: -10)
        ])
    }
    
    func setupRightSide() {
        // 우측 상단: basketTopView (높이 50)
        basketTopView.translatesAutoresizingMaskIntoConstraints = false
        rightContainer.addSubview(basketTopView)
        
        addBasketButton.setTitle("상품추가", for: .normal)
        addBasketButton.translatesAutoresizingMaskIntoConstraints = false
        addBasketButton.addTarget(self, action: #selector(basketAddButtonTapped), for: .touchUpInside)
        basketTopView.addSubview(addBasketButton)
        
        removeBasketButton.setTitle("상품제거", for: .normal)
        removeBasketButton.translatesAutoresizingMaskIntoConstraints = false
        removeBasketButton.addTarget(self, action: #selector(basketRemoveButtonTapped), for: .touchUpInside)
        basketTopView.addSubview(removeBasketButton)
        
        NSLayoutConstraint.activate([
            addBasketButton.leadingAnchor.constraint(equalTo: basketTopView.leadingAnchor, constant: 10),
            addBasketButton.centerYAnchor.constraint(equalTo: basketTopView.centerYAnchor),
            
            removeBasketButton.trailingAnchor.constraint(equalTo: basketTopView.trailingAnchor, constant: -10),
            removeBasketButton.centerYAnchor.constraint(equalTo: basketTopView.centerYAnchor)
        ])
        
        // 우측 중간: basketTableView (장바구니 항목 목록)
        basketTableView = UITableView()
        basketTableView.translatesAutoresizingMaskIntoConstraints = false
        basketTableView.dataSource = self
        basketTableView.delegate = self
        basketTableView.register(BasketItemCell.self, forCellReuseIdentifier: "BasketItemCell")
        rightContainer.addSubview(basketTableView)
        
        // 우측 하단: basketSummaryView (요약 및 결제금액 버튼, 높이 80)
        basketSummaryView.translatesAutoresizingMaskIntoConstraints = false
        rightContainer.addSubview(basketSummaryView)
        basketSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        basketSummaryLabel.font = UIFont.systemFont(ofSize: 16)
        basketSummaryView.addSubview(basketSummaryLabel)
        paymentButton.setTitle("결제금액", for: .normal)
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        paymentButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)
        basketSummaryView.addSubview(paymentButton)
        
        NSLayoutConstraint.activate([
            basketTopView.topAnchor.constraint(equalTo: rightContainer.topAnchor),
            basketTopView.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor),
            basketTopView.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor),
            basketTopView.heightAnchor.constraint(equalToConstant: 50),
            
            basketSummaryView.bottomAnchor.constraint(equalTo: rightContainer.bottomAnchor),
            basketSummaryView.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor),
            basketSummaryView.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor),
            basketSummaryView.heightAnchor.constraint(equalToConstant: 80),
            
            basketTableView.topAnchor.constraint(equalTo: basketTopView.bottomAnchor, constant: 5),
            basketTableView.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor),
            basketTableView.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor),
            basketTableView.bottomAnchor.constraint(equalTo: basketSummaryView.topAnchor, constant: -5),
            
            basketSummaryLabel.topAnchor.constraint(equalTo: basketSummaryView.topAnchor, constant: 10),
            basketSummaryLabel.leadingAnchor.constraint(equalTo: basketSummaryView.leadingAnchor, constant: 10),
            basketSummaryLabel.trailingAnchor.constraint(equalTo: basketSummaryView.trailingAnchor, constant: -10),
            
            paymentButton.topAnchor.constraint(equalTo: basketSummaryLabel.bottomAnchor, constant: 10),
            paymentButton.centerXAnchor.constraint(equalTo: basketSummaryView.centerXAnchor),
            paymentButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Data Loading and UI Update
    
    func loadData() {
        // 예시 데이터 로드. 실제 DB나 네트워크에서 불러오도록 구현
        categories = sqlite.instance.getCategoryList()
        // 예시 상품 생성
        products = KocesSdk.instance.listProducts
        // 초기 선택 카테고리는 "전체"
        selectedCategory = categories[0]
        updateFilteredProducts()
    }
    
    func updateFilteredProducts() {
        if selectedCategory == "전체" || selectedCategory == nil {
            filteredProducts = products.filter { $0.category == categories[0] }
        } else {
            filteredProducts = products.filter { $0.category == selectedCategory }
        }
        productCollectionView.reloadData()
    }
    
    func updateLeftSide() {
        // 카테고리 버튼 생성
        categoryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for cat in categories {
            let button = UIButton(type: .system)
            button.setTitle(cat, for: .normal)
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            // 선택된 카테고리일 경우 색상 변경
            if cat == selectedCategory {
                button.setTitleColor(.systemBlue, for: .normal)
            } else {
                button.setTitleColor(.darkGray, for: .normal)
            }
            categoryStackView.addArrangedSubview(button)
        }
    }
    
    @objc func categoryButtonTapped(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            selectedCategory = title
            updateLeftSide()
            updateFilteredProducts()
        }
    }
    
    // MARK: - Basket Actions
    
    // 상품이 왼쪽 그리드에서 선택되면 호출
    func productSelected(_ product: Product) {
        if let existing = basket[product.id] {
            basket[product.id]?.quantity = existing.quantity + 1
        } else {
            basket[product.id] = BasketItem(product: product, quantity: 1)
        }
        basketTableView.reloadData()
        updateBasketSummary()
    }
    
    @objc func basketAddButtonTapped() {
        if let selectedID = basketSelectedProductID, let item = basket[selectedID] {
            basket[selectedID]?.quantity = item.quantity + 1
            basketTableView.reloadData()
            updateBasketSummary()
        } else {
            print("선택된 장바구니 상품이 없습니다")
        }
    }
    
    @objc func basketRemoveButtonTapped() {
        if let selectedID = basketSelectedProductID {
            basket.removeValue(forKey: selectedID)
            basketSelectedProductID = nil
            basketTableView.reloadData()
            updateBasketSummary()
        } else {
            basket.removeAll()
            basketTableView.reloadData()
            updateBasketSummary()
        }
    }
    
    @objc func paymentButtonTapped() {
        let totalPayment = basket.values.reduce(0) { $0 + ($1.product.price * $1.quantity) }
        print("결제금액: \(totalPayment)")
        // 결제 버튼 클릭 시 다음 화면으로 전환(로그 남김)
    }
    
    func updateBasketSummary() {
        let totalItems = basket.count
        let totalQuantity = basket.values.reduce(0) { $0 + $1.quantity }
        let totalPayment = basket.values.reduce(0) { $0 + ($1.product.price * $1.quantity) }
        basketSummaryLabel.text = "상품 수: \(totalItems), 수량 합계: \(totalQuantity)"
        paymentButton.setTitle("결제금액: \(totalPayment)", for: .normal)
    }
}

// MARK: - UICollectionViewDataSource & DelegateFlowLayout

extension ProductHomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCollectionCell
        let product = filteredProducts[indexPath.item]
        cell.configure(with: product)
        return cell
    }
    
    // 셀 사이즈는 150x200
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = filteredProducts[indexPath.item]
        productSelected(product)
    }
}

// MARK: - UITableViewDataSource & Delegate (Basket)

extension ProductHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basket.values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasketItemCell", for: indexPath) as! BasketItemCell
        let basketItem = Array(basket.values)[indexPath.row]
        cell.configure(with: basketItem)
        // 선택된 항목 표시 (예: 배경색)
        cell.backgroundColor = (basketItem.product.id == basketSelectedProductID) ? UIColor.systemGray4 : UIColor.white
        cell.plusButtonAction = { [weak self] in
            guard let self = self, let item = self.basket[basketItem.product.id] else { return }
            self.basket[basketItem.product.id]?.quantity = item.quantity + 1
            tableView.reloadData()
            self.updateBasketSummary()
        }
        cell.minusButtonAction = { [weak self] in
            guard let self = self, let item = self.basket[basketItem.product.id] else { return }
            let newQuantity = item.quantity - 1
            if newQuantity <= 0 {
                self.basket.removeValue(forKey: basketItem.product.id)
            } else {
                self.basket[basketItem.product.id]?.quantity = newQuantity
            }
            tableView.reloadData()
            self.updateBasketSummary()
        }
        return cell
    }
    
    // 선택 시 토글 처리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = Array(basket.values)[indexPath.row]
        if basketSelectedProductID == selectedItem.product.id {
            basketSelectedProductID = nil
        } else {
            basketSelectedProductID = selectedItem.product.id
        }
        tableView.reloadData()
    }
}

// MARK: - Custom UICollectionViewCell (Product)

class ProductCollectionCell: UICollectionViewCell {
    let imageView = UIImageView()
    let nameLabel = UILabel()
    let priceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFit
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textAlignment = .center
        priceLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.textAlignment = .center
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    func configure(with product: Product) {
        nameLabel.text = product.name
        priceLabel.text = "\(product.price)원"
        if let img = product.image {
            imageView.image = img
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
}

// MARK: - Custom UITableViewCell (Basket)

class BasketItemCell: UITableViewCell {
    let nameLabel = UILabel()
    let priceLabel = UILabel()
    let plusButton = UIButton(type: .system)
    let minusButton = UIButton(type: .system)
    let quantityLabel = UILabel()
    
    var plusButtonAction: (() -> Void)?
    var minusButtonAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.font = UIFont.systemFont(ofSize: 14)
        quantityLabel.font = UIFont.systemFont(ofSize: 14)
        quantityLabel.textAlignment = .center
        
        plusButton.setTitle("+", for: .normal)
        minusButton.setTitle("-", for: .normal)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(plusButton)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(minusButton)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            plusButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            plusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            plusButton.widthAnchor.constraint(equalToConstant: 30),
            plusButton.heightAnchor.constraint(equalToConstant: 30),
            
            quantityLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            quantityLabel.leadingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: 10),
            quantityLabel.widthAnchor.constraint(equalToConstant: 30),
            
            minusButton.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            minusButton.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 10),
            minusButton.widthAnchor.constraint(equalToConstant: 30),
            minusButton.heightAnchor.constraint(equalToConstant: 30),
            
            minusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
    }
    
    @objc func plusTapped() {
        plusButtonAction?()
    }
    
    @objc func minusTapped() {
        minusButtonAction?()
    }
    
    func configure(with basketItem: BasketItem) {
        nameLabel.text = basketItem.product.name
        priceLabel.text = "\(basketItem.product.price)원"
        quantityLabel.text = "\(basketItem.quantity)"
    }
}
