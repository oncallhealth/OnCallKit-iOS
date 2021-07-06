//
//  AttachmentsPageViewController.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - AttachmentsPageViewControllerDelegate

protocol AttachmentsPageViewControllerDelegate: AnyObject {
    
    func didChangeViewController(to index: Int)
    func openFile(url: URL)
    func openForm(id: Int)
    func presentFileMenu(for attachment: Attachment, sender: UIView)
    func presentFormMenu(for form: Form, sender: UIView)
}

// MARK: - AttachmentsPageViewController

class AttachmentsPageViewController: OCPageViewController {
    
    // MARK: Lifecycle
    
    init(appointment: OnCallAppointment?, canEditAttachments: Bool) {
        
        let formsViewType: FormsViewModel.ViewType
        
        if let appointment = appointment {
            if let pendingAppointment = appointment as? PendingAppointmentModel {
                formsViewType = .pendingAppointment(requestId: pendingAppointment.id)
            } else {
                formsViewType = .appointment(id: appointment.id)
            }
        } else {
            formsViewType = .tab
        }
        
        let filesViewController = FilesViewController(appointment: appointment)
        let formsViewController = FormsViewController(
            viewModel: FormsViewModel(viewType: formsViewType, canEdit: canEditAttachments))
        
        super.init(orderedViewControllers: [formsViewController, filesViewController])
        
        filesViewController.filesDelegate = self
        formsViewController.formsDelegate = self
        
        pageViewDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var attachmentsPageDelegate: AttachmentsPageViewControllerDelegate?
    
    func refreshFileViewController(removeOldForms: Bool = false) {
        let viewController = orderedViewControllers.first { $0 is FilesViewController } as? FilesViewController
        viewController?.refresh(removeOldAttachments: removeOldForms)
    }
    
    func refreshFormViewController(removeOldForms: Bool = false) {
        let viewController = orderedViewControllers.first { $0 is FormsViewController } as? FormsViewController
        viewController?.refresh(removeOldAttachments: removeOldForms)
    }
}

// MARK: FilesViewControllerDelegate

extension AttachmentsPageViewController: FilesViewControllerDelegate {
    
    func openFile(url: URL) {
        attachmentsPageDelegate?.openFile(url: url)
    }
    
    func presentMenu(for attachment: Attachment, sender: UIView) {
        attachmentsPageDelegate?.presentFileMenu(for: attachment, sender: sender)
    }
}

// MARK: FormsViewControllerDelegate

extension AttachmentsPageViewController: FormsViewControllerDelegate {
    
    func openForm(id: Int) {
        attachmentsPageDelegate?.openForm(id: id)
    }
    
    func presentMenu(for form: Form, sender: UIView) {
        attachmentsPageDelegate?.presentFormMenu(for: form, sender: sender)
    }
}

// MARK: OCPageViewControllerDelegate

extension AttachmentsPageViewController: OCPageViewControllerDelegate {
    func didChangeViewController(to index: Int) {
        attachmentsPageDelegate?.didChangeViewController(to: index)
    }
}
