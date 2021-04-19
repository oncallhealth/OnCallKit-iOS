//
//  UILabelExtensions.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2021-01-25.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - UILabel

extension UILabel {
    
    // MARK: Internal
    
    var isTruncated: Bool {
        guard let labelText = text else {
            return false
        }
        
        layoutIfNeeded()
        
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font ?? UIFont()],
            context: nil).size
        
        return labelTextSize.height > bounds.size.height
    }
}
