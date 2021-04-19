//
//  MessageThreadParticipantsViewController.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-08-26.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - MessageThreadParticipantsViewController

class MessageThreadParticipantsViewController: SheetViewController {
    
    // MARK: Lifecycle
    
    init(viewModel: MessageThreadParticipantsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: ComponentType.detailedTextRow.rawValue,
            for: indexPath) as? DetailedTextRow
        {
            let user = viewModel.threadUsers[indexPath.row]
            cell.configure(title: user.fullName, subtitle: user.email ?? "")
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: Private
    
    private let viewModel: MessageThreadParticipantsViewModel
    
}
