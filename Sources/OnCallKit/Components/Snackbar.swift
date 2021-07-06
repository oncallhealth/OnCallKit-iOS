//
//  Snackbar.swift
//  OnCallHealthiOS
//
//  Created by Domenic Bianchi on 2021-05-07.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - Snackbar

class Snackbar: UIView {
    
    // MARK: SnackbarType
    
    enum SnackbarType {
        case success(message: String)
        case error(message: String)
    }
    
    // MARK: Lifecycle
    
    init(type: SnackbarType) {
        super.init(frame: .zero)
        
        addSubview(label)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        label.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(15)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-15)
            $0.trailing.equalToSuperview().offset(-15)
        }
        
        snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        switch type {
        case .success(let message):
            label.text = message
            backgroundColor = UIColor.snackbarSuccess
        case .error(let message):
            label.text = message
            backgroundColor = UIColor.snackbarError
        }
        
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        
        hapticGenerator.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal

    func present(completion: (() -> Void)? = nil) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: self.label.text)
        }
        
        window.addSubview(self)
        layer.zPosition = .greatestFiniteMagnitude
        
        constraint = topAnchor.constraint(equalTo: window.bottomAnchor)
        constraint?.isActive = true
        
        window.layoutIfNeeded()
        
        hapticGenerator.generate()
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            self.constraint?.constant = -self.frame.height
            window.layoutIfNeeded()
        } completion: { finished in
            if finished {
                guard let window = UIApplication.shared.keyWindow else {
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
                        self.constraint?.constant = 0
                        window.layoutIfNeeded()
                    } completion: { finished in
                        if finished {
                            self.removeFromSuperview()
                            
                            if let completion = completion {
                                completion()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func dismiss() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }

        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            self.constraint?.constant = 0
            window.layoutIfNeeded()
        } completion: { finished in
            if finished {
                self.removeFromSuperview()
            }
        }
    }
    
    // MARK: Private
    
    private var constraint: NSLayoutConstraint? = nil
    private let hapticGenerator = HapticFeedbackGenerator(kind: .error)
    private let label = UILabel()
    
}
