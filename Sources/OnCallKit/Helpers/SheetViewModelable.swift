//
//  SheetViewModelableable.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-10.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - SheetViewModelable

protocol SheetViewModelable {
    
    var seperatorStyle: UITableViewCell.SeparatorStyle { get }
    
    func viewForHeader() -> UIView?
    func numberOfRows(in section: Int) -> Int
    
    //@available(*, deprecated, message: "Override didSelectRowAt in the SheetViewController instead")
    func didSelectRow(
        at indexPath: IndexPath,
        dismissSheet: () -> Void,
        complete: @escaping (Bool, String?) -> Void)
    
    func viewDismissed(complete: @escaping (Bool, String?) -> Void)
}

extension SheetViewModelable {
    
    var seperatorStyle: UITableViewCell.SeparatorStyle {
        return .none
    }
    
    func viewDismissed(complete: @escaping (Bool, String?) -> Void) {}
    func didSelectRow(
        at indexPath: IndexPath,
        dismissSheet: () -> Void,
        complete: @escaping (Bool, String?) -> Void) {}
}
