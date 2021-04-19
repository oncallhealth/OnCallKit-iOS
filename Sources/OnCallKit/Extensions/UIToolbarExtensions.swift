//
//  UIToolbarExtensions.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-11-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - UIToolbar

extension UIToolbar {
    
    // MARK: Internal
    
    static func createToolbar(with button: UIBarButtonItem) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            button
        ]
        
        toolbar.sizeToFit()
        return toolbar
    }
}
