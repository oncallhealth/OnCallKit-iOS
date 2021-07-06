//
//  FormsViewController.swift
//  OnCall Health
//
//  Created by Domenic Bianchi on 2020-07-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - FormsViewControllerDelegate

protocol FormsViewControllerDelegate: AnyObject {
    
    func openForm(id: Int)
    func presentMenu(for form: Form, sender: UIView)
}

// MARK: - FormsViewController

class FormsViewController: AttachmentsBaseViewController<FormsViewModel> {
    
    // MARK: Lifecycle
    
    override init(viewModel: FormsViewModel) {
        super.init(viewModel: viewModel)
        baseDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var formsDelegate: FormsViewControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLoad {
            firstLoad = false
            refresh()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.loadingState {
        case .loading(let forms):
            guard let forms = forms else {
                return UITableViewCell()
            }
            
            if indexPath.row == forms.count {
                return tableView.dequeueReusableCell(
                    withIdentifier: LoadingTableViewCell.reuseIdentifier,
                    for: indexPath)
            }
            
            return formCell(at: indexPath, for: tableView, forms: forms)
        case .loaded(let forms):
            if forms.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: NoFileAttachmentsTableViewCell.reuseIdentifier, for: indexPath) as! NoFileAttachmentsTableViewCell
                cell.configure(text: "no_files".localized())
                return cell
            }
            
            return formCell(at: indexPath, for: tableView, forms: forms)
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: Private
    
    private var firstLoad = true
    
    private func formCell(at indexPath: IndexPath, for tableView: UITableView, forms: [Form]) -> UITableViewCell {
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
        
        let isComplete = form.response != nil
        
        cell.configure(
            id: form.id,
            name: form.title,
            subtitle: form.participantName,
            position: position,
            style: .form(isComplete: isComplete),
            isEditable: !isComplete && viewModel.canEdit)
        
        cell.setInteraction { [weak self] id, sender in
            guard let id = id else {
                return
            }
            
            self?.baseDelegate?.didTapMenu(id: id, menu: sender)
        }
        
        return cell
    }
    
    private func loadNextPage() {
        guard !viewModel.loadingState.isLoading, viewModel.allForms.last?.next != nil else {
            return
        }
        
        if case let .loaded(forms) = viewModel.loadingState {
            viewModel.loadingState = .loading(forms)
        } else {
            viewModel.loadingState = .loading(nil)
        }
        
        refresh(showLoadingIndicator: false, removeOldAttachments: false)
    }
}

// MARK: AttachmentsBaseViewController

extension FormsViewController: AttachmentsBaseViewControllerDelegate {
    func didSelectRow(at indexPath: IndexPath, sender: UIView) {
        guard let form = viewModel.getForm(at: indexPath) else {
            return
        }
        
        formsDelegate?.openForm(id: form.id)
    }
    
    func didTapMenu(id: Int, menu: UIView) {
        guard let form = viewModel.getForm(with: id) else {
            return
        }
        
        formsDelegate?.presentMenu(for: form, sender: menu)
    }
    
    func reachedBottomOfList() {
        guard !viewModel.loadingState.isLoading else {
            return
        }
        
        loadNextPage()
    }
}
