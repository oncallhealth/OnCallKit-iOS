//
//  UIActivityIndicatorViewExtensions.swift
//  Development
//
//  Created by Domenic Bianchi on 2021-01-29.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - UIActivityIndicatorView

extension UIActivityIndicatorView {
    
    // MARK: IndicatorStyle
    
    enum IndicatorStyle {
        case small
        case large
    }
    
    // MARK: Lifecycle
    
    convenience init(indicatorStyle: IndicatorStyle) {
        if #available(iOS 13.0, *) {
            self.init(style: indicatorStyle == .small ? .medium : .large)
        } else {
            self.init(style: indicatorStyle == .small ? .white : .whiteLarge)
            color = .gray
        }
    }
}
