//
//  GradientView.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-06-19.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - GradientView

final class GradientView: UIView {
    
    // MARK: Direction
    
    enum Direction {
        case topToBottom
        case bottomToTop
    }
    
    // MARK: Lifecycle
    
    init(direction: Direction) {
        self.direction = direction
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradientLayer = CAGradientLayer()
        
        let colours = [UIColor.background.cgColor, gradientColor.cgColor]
        
        gradientLayer.colors = direction == .bottomToTop ? colours : colours.reversed()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds

        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: Private
    
    private let direction: Direction
    
    private var gradientColor: UIColor {
        guard #available(iOS 13.0, *) else {
            return UIColor(white: 1, alpha: 0)
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0, alpha: 0) : UIColor(white: 1, alpha: 0) }
    }
}
