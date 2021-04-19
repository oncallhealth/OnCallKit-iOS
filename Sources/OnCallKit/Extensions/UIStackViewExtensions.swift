//
//  UIStackViewExtensions.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//
import UIKit

// MARK: - UIStackView
extension UIStackView {

    // MARK: Internal
    
    func removeSubviews() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}
