//
//  LoadingOverlayViewController.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-09-28.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - LoadingOverlayViewController

class LoadingOverlayViewController: UIViewController {
    
    // MARK: Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        modalPresentationStyle = .overFullScreen
        
        view.addSubview(loadingToast)
        
        loadingToast.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            centerYConstraint = $0.centerY.equalToSuperview().constraint
            topConstraint = $0.top.equalTo(view.snp.bottom).constraint
        }
        
        centerYConstraint?.deactivate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal

    func present(on parentViewController: UIViewController) {
        parentViewController.present(self, animated: false) {
            self.showLoadingIndicator()
        }
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        dismissLoadingIndicator {
            self.dismiss(animated: false) {
                completion?()
            }
        }
    }
    
    // MARK: Private
    
    private let loadingToast = LoadingToast()
    
    private var centerYConstraint: Constraint?
    private var topConstraint: Constraint?
    
    private func showLoadingIndicator() {
        centerYConstraint?.activate()
        topConstraint?.deactivate()
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.view.layoutIfNeeded()
        }
    }
    
    private func dismissLoadingIndicator(completion: @escaping () -> Void) {
        centerYConstraint?.deactivate()
        topConstraint?.activate()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            self.view.backgroundColor = .clear
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }
}
