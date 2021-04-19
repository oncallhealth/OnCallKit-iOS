//
//  ConstraintMakerExtensions.swift
//  OnCall Health
//
//  Created by Domenic Bianchi on 2020-05-04.
//  Copyright © 2020 Arsham. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - ConstraintMaker

extension ConstraintMaker {
    
    // MARK: SafeAreaEdge
    
    enum SafeAreaEdge {
        case top
        case bottom
        case leading
        case trailing
    }
    
    // MARK: Internal

    @discardableResult
    func equalTo(
        safeAreaEdge edge: SafeAreaEdge,
        of viewController: UIViewController) -> ConstraintMakerEditable
    {
        switch edge {
        case .top:
            return top.equalTo(viewController.view.safeAreaLayoutGuide.snp.top)
        case .bottom:
            return bottom.equalTo(viewController.view.safeAreaLayoutGuide.snp.bottom)
        case .leading:
            return leading.equalTo(viewController.view.safeAreaLayoutGuide.snp.leading)
        case .trailing:
            return trailing.equalTo(viewController.view.safeAreaLayoutGuide.snp.trailing)
        }
    }
    
    @discardableResult
    func widthBasedOnDevice() -> ConstraintMakerEditable {
        // For iPads, we don't want the UI to stretch to the full width of the screen
        if UIDevice.current.isIpad {
            return width.equalTo(UIScreen.main.bounds.width / 1.5)
        } else {
            return width.equalToSuperview()
        }
    }
}
