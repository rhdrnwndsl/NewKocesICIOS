//
//  ProductModifyViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2/5/25.
//

import Foundation
import UIKit
class ProductModifyViewController: UIViewController {
    var product: Product?  // 수정할 상품 정보
    
    override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .white
         title = "상품 수정"
         setupUI()
        
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
    
    func setupUI() {
         // 수정할 상품 정보를 표시 및 수정할 UI 구성
         let infoLabel = UILabel()
         infoLabel.text = "여기서 상품 정보를 수정합니다."
         infoLabel.textAlignment = .center
         infoLabel.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(infoLabel)
         
         NSLayoutConstraint.activate([
              infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
         ])
    }
}
