//
//  UITextFieldExtensions.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-11-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - UITextField

extension UITextField {
    
    // MARK: Internal
    
    func addDoneToolbar(with doneButton: UIBarButtonItem) {
        inputAccessoryView = UIToolbar.createToolbar(with: doneButton)
    }
}
