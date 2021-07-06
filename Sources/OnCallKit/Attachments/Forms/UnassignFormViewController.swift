//
//  UnassignFormViewController.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-07-23.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - UnassignFormViewController

class UnassignFormViewController: SheetViewController {
    
    // MARK: Lifecycle
    
    init(viewModel: UnassignFormViewModel) {
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ComponentType.textIconRow.rawValue,
            for: indexPath) as? TextIconRow else
        {
            return UITableViewCell()
        }
        
        cell.configure(text: "unassign_form".localized(), icon: "ic-trash-bold", tintColor: .error)
        return cell
    }
}
