//
//  IconButton.swift
//  OnCallKit
//
//  Created by Domenic Bianchi on 2021-01-21.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

//import EasyNotificationBadge
import SnapKit
import UIKit

// MARK: - IconButton

class IconButton: UIButton {
    
    // MARK: Size
    
    enum Size: CGFloat {
        case small = 40
        case large = 44
    }
    
    // MARK: Lifecycle
    
    init(size: Size = .large) {
        super.init(frame: .zero)
        
        imageView?.contentMode = .scaleAspectFit
        addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        
        snp.makeConstraints {
            $0.width.height.equalTo(size.rawValue).priority(.high)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    func setContent(icon: UIImage?, isEnabled: Bool = true, badgeNumber: Int? = nil) {
        setImage(icon, for: .normal)
        self.isEnabled = isEnabled
        self.badgeNumber = badgeNumber
    }
    
    func setInteractions(didTap: @escaping () -> Void) {
        self.didTap = didTap
    }
    
    // MARK: Private
    
    private var didTap: (() -> Void)? = nil
    private var badgeNumber: Int? = nil {
        didSet {
//            guard let badgeNumber = badgeNumber, badgeNumber != 0 else {
//                UIView.performWithoutAnimation {
//                    badge(text: nil)
//                }
//
//                return
//            }
//
//            var badgeAppearance = BadgeAppearance()
//            badgeAppearance.font = .systemFont(ofSize: 10)
//            badgeAppearance.distanceFromCenterX = 8
//            badgeAppearance.distanceFromCenterY = -2
//
//            UIView.performWithoutAnimation {
//                badge(text: String(badgeNumber), appearance: badgeAppearance)
//            }
        }
    }
    
    @objc private func didTapAction() {
        didTap?()
    }
}
