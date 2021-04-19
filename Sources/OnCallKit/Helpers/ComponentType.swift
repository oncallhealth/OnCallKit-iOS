//
//  ComponentType.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-07-11.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - ComponentType

enum ComponentType: String, CaseIterable {
    case toggleRow
    case textIconRow
    case detailedTextRow
    
    // MARK: Internal
    
    var cellClass: UITableViewCell.Type {
        switch self {
        case .toggleRow:
            return ToggleRow.self
        case .textIconRow:
            return TextIconRow.self
        case .detailedTextRow:
            return DetailedTextRow.self
        }
    }
}
