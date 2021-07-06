//
//  AssignFormViewController.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-10.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import PanModal
import UIKit

// MARK: - AssignFormViewControllerDelegate

protocol AssignFormViewControllerDelegate: AnyObject {
    func presentFormSheet(for form: Form, participants: [AssignFormToParticipantsViewModel.User], sender: UIView)
    func assign(form: Form, to contact: RosterContactModel)
}

// MARK: AssignFormViewController

class AssignFormViewController: AttachmentsBaseViewController<AssignFormViewModel> {
    
    // MARK: Lifeycycle
    
    override init(viewModel: AssignFormViewModel) {
        super.init(viewModel: viewModel)
        baseDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var delegate: AssignFormViewControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.loadingState {
        case .loaded(let forms):
            if forms.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: NoFileAttachmentsTableViewCell.reuseIdentifier, for: indexPath) as! NoFileAttachmentsTableViewCell
                cell.configure(text: "no_files".localized())
                return cell
            }
            
            let form = forms[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: AttachmentRow.reuseIdentifier, for: indexPath) as! AttachmentRow
            
            let position: AttachmentRow.Position
            
            if indexPath.row == 0 {
                position = .top(onlyCell: forms.count == 1)
            } else if indexPath.row == forms.count - 1 {
                position = .bottom
            } else {
                position = .middle
            }
            
            cell.configure(
                id: form.id,
                name: form.title,
                subtitle: nil,
                position: position,
                style: .form(isComplete: nil),
                isEditable: false)
            
            return cell
        case .error:
            let cell = tableView.dequeueReusableCell(withIdentifier: NoFileAttachmentsTableViewCell.reuseIdentifier, for: indexPath) as! NoFileAttachmentsTableViewCell
            cell.configure(text: "loading_forms_error".localized())
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: AttachmentsBaseViewController

extension AssignFormViewController: AttachmentsBaseViewControllerDelegate {
    func didSelectRow(at indexPath: IndexPath, sender: UIView) {
        guard let form = viewModel.getForm(at: indexPath.row) else {
            return
        }
        
        if case let .appointment(participants) = viewModel.state {
            let participants: [AssignFormToParticipantsViewModel.User] = participants.compactMap {
                guard let url = $0.url else {
                    return nil
                }
                
                return AssignFormToParticipantsViewModel.User(url: url, name: $0.name)
            }
            
            delegate?.presentFormSheet(for: form, participants: participants, sender: sender)
        } else if case let .rosterContact(contact) = viewModel.state {
            delegate?.assign(form: form, to: contact)
        }
    }
    
    func didTapMenu(id: Int, menu: UIView) {}
    func reachedBottomOfList() {}
}
