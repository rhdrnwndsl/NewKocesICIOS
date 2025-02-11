//
//  CustomPresentationController.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 2/11/25.
//

import Foundation
import UIKit

class CustomPresentationController: UIPresentationController {
    
    // 배경 디밍 뷰(옵션)
    private var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        // 디밍 뷰를 추가하고 전체 크기로 설정
        dimmingView.frame = containerView.bounds
        containerView.insertSubview(dimmingView, at: 0)
        
        // 전환 애니메이션에 맞춰 디밍 뷰 애니메이션
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            })
        } else {
            dimmingView.alpha = 1
        }
    }
    
    override func dismissalTransitionWillBegin() {
        // 디밍 뷰 애니메이션 아웃
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            })
        } else {
            dimmingView.alpha = 0
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        // 제시된 뷰와 디밍 뷰 모두 컨테이너 크기에 맞게 업데이트
        dimmingView.frame = containerView?.bounds ?? CGRect.zero
        if let presentedView = presentedView {
            presentedView.frame = frameOfPresentedViewInContainerView
            // 라운드 처리 및 보더 적용
            presentedView.layer.cornerRadius = define.pading_wight
            presentedView.layer.masksToBounds = true
            presentedView.layer.borderWidth = 1
//            presentedView.layer.borderColor = UIColor.lightGray.cgColor
        }
        
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerBounds = containerView?.bounds else { return CGRect.zero }
        // 좌우는 전체, 상하는 전체보다 90% 높이 (즉, 위/아래에 margin이 생김)
        let width = containerBounds.width * 0.98
        let height = containerBounds.height * 0.95
        let originX = (containerBounds.width - width) / 2
        let originY = (containerBounds.height - height) / 2
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}
