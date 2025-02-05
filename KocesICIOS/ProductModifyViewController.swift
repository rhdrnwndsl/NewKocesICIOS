//
//  ProductModifyViewController.swift
//  KocesICIOS
//
//  Created by 신진우 on 2/5/25.
//

import Foundation
import UIKit

class ProductModifyViewController: UIViewController {
    private let titleStackView = UIStackView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        title = "상품 수정"
//        
//        // 내비게이션 바에 '나가기' 버튼 추가 (뒤로가기와 동일하게 동작)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "나가기", style: .plain, target: self, action: #selector(exitButtonTapped))
        
        setupUI()
    }
    
    private func setupUI() {
        var registrationView: UIView? = createRegistrationView()
        titleStackView.addArrangedSubview(registrationView!)
        // 예시로 중앙에 간단한 라벨을 추가
        let infoLabel = UILabel()
        infoLabel.text = "상품 수정 화면 입니다."
        infoLabel.textAlignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)
        view.addSubview(titleStackView)
        
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func createRegistrationView() -> UIView {
        // registrationView는 새로 등록 요청 관련 UI를 구성합니다.
        let registrationStack = UIStackView()
        registrationStack.axis = .vertical
        registrationStack.alignment = .fill
        registrationStack.distribution = .fill
        registrationStack.spacing = 16
        
        // 등록요청 버튼 (우측정렬)
        let regRequestButton = UIButton(type: .system)
        regRequestButton.setTitle("나가기", for: .normal)
        regRequestButton.setTitleColor(.white, for: .normal)
        regRequestButton.backgroundColor = .systemBlue
        regRequestButton.titleLabel?.font = UIFont.systemFont(ofSize: Utils.getHeadingFontSize(), weight: .medium)
        regRequestButton.layer.cornerRadius = 8
        regRequestButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [UIView(), regRequestButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.spacing = 8
        registrationStack.addArrangedSubview(buttonStack)
        // 타이틀의 폭(예: 150 정도)을 고정해도 되지만, 이미 setContentHuggingPriority를 줬다면
        // 필요 시 아래처럼 고정 폭 설정 가능:
        regRequestButton.widthAnchor.constraint(equalToConstant: Utils.getRowWidth()).isActive = true
        regRequestButton.heightAnchor.constraint(equalToConstant: Utils.getRowHeight()).isActive = true
        return registrationStack
    }
    
    @objc private func exitButtonTapped() {
        // '나가기' 버튼을 클릭하면 이전 화면(ProductSetViewController)으로 돌아갑니다.
        navigationController?.popViewController(animated: true)
    }
}
