//
//  ProductListCell.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/9/25.
//

import Foundation
import UIKit

class ProductListCell: UITableViewCell {
    let nameLabel = UILabel()
    let uniqueIDLabel = UILabel()
    let categoryLabel = UILabel()
    let registeredPriceLabel = UILabel()
    let paymentAmountLabel = UILabel()
    let lastModifiedLabel = UILabel()
    let usageStatusLabel = UILabel()
    
    let stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         setupUI()
    }
    
    required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
         stackView.axis = .horizontal
         stackView.distribution = .fillEqually
         stackView.alignment = .center
         stackView.spacing = 8
         stackView.translatesAutoresizingMaskIntoConstraints = false
         contentView.addSubview(stackView)
         
         for label in [nameLabel, uniqueIDLabel, categoryLabel, registeredPriceLabel, paymentAmountLabel, lastModifiedLabel, usageStatusLabel] {
              label.font = UIFont.systemFont(ofSize: 14)
              label.textAlignment = .center
              stackView.addArrangedSubview(label)
         }
         
         NSLayoutConstraint.activate([
              stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
              stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
              stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
              stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
         ])
    }
    
    func configure(with product: Product) {
        nameLabel.text = product.name
        uniqueIDLabel.text = product.productSeq
        categoryLabel.text = product.category
        registeredPriceLabel.text = String(product.price)
        paymentAmountLabel.text = product.totalPrice
        lastModifiedLabel.text = product.pDate
        usageStatusLabel.text = product.isUse == 1 ? "사용":"미사용"
    }
}

