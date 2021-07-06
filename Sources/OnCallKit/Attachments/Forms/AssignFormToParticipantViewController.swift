//
//  AssignFormToParticipantViewController.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-07-23.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - AssignFormToParticipantViewController

class AssignFormToParticipantViewController: SheetViewController {
    
    // MARK: Lifecycle
    
    init(viewModel: AssignFormToParticipantsViewModel) {
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
            cell.configure(text: "assign_form".localized(), icon: "", tintColor: .primary)
            return cell
        } else if let cell = tableView.dequeueReusableCell(
            withIdentifier: ComponentType.toggleRow.rawValue,
            for: indexPath) as? ToggleRow
        {
            let user = viewModel.allUsers[indexPath.row]
            
            cell.configure(text: user.name, isOn: true)
            //cell.setAccessibilityLabel(accessibilityLabel: "Switch to determine if \(user.name) can view file")
            
            cell.setInteraction { isOn in
                if isOn {
                    self.viewModel.addUser(user)
                } else {
                    self.viewModel.removeUser(user)
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: Private
    
    private let viewModel: AssignFormToParticipantsViewModel
    
}
