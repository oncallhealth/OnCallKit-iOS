//
//  FilesViewController.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-07-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import PanModal
import UIKit

// MARK: - FilesViewControllerDelegate

protocol FilesViewControllerDelegate: AnyObject {
    
    func openFile(url: URL)
    func presentMenu(for attachment: Attachment, sender: UIView)
}

// MARK: - FilesViewController

class FilesViewController: AttachmentsBaseViewController<FilesViewModel> {
    
    // MARK: Lifecycle
    
    init(appointment: OnCallAppointment? = nil) {
        if let appointmentId = appointment?.id {
            super.init(viewModel: FilesViewModel(viewType: .appointment(id: appointmentId)))
        } else {
            super.init(viewModel: FilesViewModel(viewType: .patient))
        }
        
        baseDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var filesDelegate: FilesViewControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLoad {
            firstLoad = false
            refresh()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.loadingState {
        case .loading(let attachments):
            guard let attachments = attachments else {
                return UITableViewCell()
            }
            
            if indexPath.row == attachments.count {
                return tableView.dequeueReusableCell(
                    withIdentifier: LoadingTableViewCell.reuseIdentifier,
                    for: indexPath)
            }
            
            return attachmentCell(at: indexPath, for: tableView, attachments: attachments)
        case .loaded(let attachments):
            if attachments.isEmpty {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: NoFileAttachmentsTableViewCell.reuseIdentifier,
                    for: indexPath) as! NoFileAttachmentsTableViewCell
                
                cell.configure(text: "no_files".localized())
                return cell
            }
            
            return attachmentCell(at: indexPath, for: tableView, attachments: attachments)
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: Private
    
    private var firstLoad = true
    
    private func attachmentCell(at indexPath: IndexPath, for tableView: UITableView, attachments: [Attachment]) -> UITableViewCell {
        let attachment = attachments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: AttachmentRow.reuseIdentifier, for: indexPath) as! AttachmentRow
        
        let position: AttachmentRow.Position
        
        if indexPath.row == 0 {
            position = .top(onlyCell: attachments.count == 1)
        } else if indexPath.row == attachments.count - 1 {
            position = .bottom
        } else {
            position = .middle
        }
        
        let subtitle: String?
        
        if let createdAt = attachment.createdAt {
            subtitle = Date.mediumDate.string(from: createdAt)
        } else {
            subtitle = nil
        }
        
        cell.configure(
            id: attachment.id,
            name: attachment.displayName,
            subtitle: subtitle,
            position: position,
            style: .file(type: AttachmentRow.FileType(rawValue: attachment.fileExtension) ?? .other),
            isEditable: attachment.isEditable)
        
        cell.setInteraction { [weak self] id, sender in
            guard let id = id else {
                return
            }
            
            self?.baseDelegate?.didTapMenu(id: id, menu: sender)
        }
        
        return cell
    }
    
    private func loadNextPage() {
        guard !viewModel.loadingState.isLoading, viewModel.allFiles.last?.next != nil else {
            return
        }
        
        if case let .loaded(files) = viewModel.loadingState {
            viewModel.loadingState = .loading(files)
        } else {
            viewModel.loadingState = .loading(nil)
        }
        
        refresh(showLoadingIndicator: false, removeOldAttachments: false)
    }
}

// MARK: AttachmentsBaseViewController

extension FilesViewController: AttachmentsBaseViewControllerDelegate {
    func didSelectRow(at indexPath: IndexPath, sender: UIView) {
        viewModel.getDownloadAttachmentLink(for: indexPath.row) { url in
            if let url = url {
                self.filesDelegate?.openFile(url: url)
            }
        }
    }
    
    func didTapMenu(id: Int, menu: UIView) {
        if let attachment = viewModel.getAttachment(with: id) {
            filesDelegate?.presentMenu(for: attachment, sender: menu)
        }
    }
    
    func reachedBottomOfList() {
        guard !viewModel.loadingState.isLoading else {
            return
        }
        
        loadNextPage()
    }
}
