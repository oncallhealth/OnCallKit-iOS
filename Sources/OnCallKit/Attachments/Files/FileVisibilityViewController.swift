//
//  FileVisibilityViewController.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-07-23.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - FileVisibilityViewController

class FileVisibilityViewController: SheetViewController {
    
    // MARK: Lifecycle
    
    init(viewModel: FileVisibilityViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == viewModel.numberOfRows(in: indexPath.section) - 1,
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ComponentType.textIconRow.rawValue,
                for: indexPath) as? TextIconRow
        {
            cell.configure(text: "remove_file".localized(), icon: "ic-trash-bold", tintColor: .error)
            return cell
        } else if let cell = tableView.dequeueReusableCell(
            withIdentifier: ComponentType.toggleRow.rawValue,
            for: indexPath) as? ToggleRow
        {
            let user = viewModel.allUsers[indexPath.row]
            cell.configure(
                text: user.name,
                isOn: viewModel.attachment.accessibleTo.contains { $0 == user.id })
            
            //cell.setAccessibilityLabel(accessibilityLabel: "Switch to determine if \(user.name) can view file")
            cell.setInteraction { isOn in
                if isOn {
                    self.viewModel.addUser(user.id)
                } else {
                    self.viewModel.removeUser(user.id)
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: Private
    
    private let viewModel: FileVisibilityViewModel
    
}
