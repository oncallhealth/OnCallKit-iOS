//
//  UIDeviceExtensions.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-05-26.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

extension UIDevice {
    var hasBottomSafearea: Bool {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0 > 0
    }
    
    var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
