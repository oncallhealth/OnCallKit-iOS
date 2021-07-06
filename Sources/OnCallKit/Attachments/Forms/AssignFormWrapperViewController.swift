//
//  AssignFormWrapperViewController.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-07-23.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - AssignFormWrapperViewControllerDelegate

protocol AssignFormWrapperViewControllerDelegate: AnyObject {
    func formAssigned()
}

// MARK: - AssignFormWrapperViewController

class AssignFormWrapperViewController: OCViewController {
    
    // MARK: Lifecycle
    
    init(viewModel: AssignFormViewModel) {
        self.baseViewController = AssignFormViewController(viewModel: viewModel)
        
        super.init(
            titleIcon: "ic-close".icon(),
            titleIconColour: .primary,
            title: "assign_form".localized(),
            titleButtons: nil,
            tabBarIcon: nil)
        
        contentView.addSubview(baseViewController.view)
        baseViewController.didMove(toParent: self)
        baseViewController.delegate = self
        
        baseViewController.view.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var delegate: AssignFormWrapperViewControllerDelegate?
    
    override func didTapTitleIcon(_ sender: Any?) {
        dismiss(animated: true)
    }
    
    // MARK: Private
    
    private let baseViewController: AssignFormViewController
    //private let source: MixpanelSource.AttachmentAssignedSource
}

// MARK: AssignFormViewControllerDelegate

extension AssignFormWrapperViewController: AssignFormViewControllerDelegate {
    func presentFormSheet(for form: Form, participants: [AssignFormToParticipantsViewModel.User], sender: UIView) {
        let viewController = AssignFormToParticipantViewController(
            viewModel: AssignFormToParticipantsViewModel(form: form, allUsers: participants))
        
        viewController.delegate = self
        presentPanModal(viewController, sourceView: sender, sourceRect: sender.bounds)
    }
    
    func assign(form: Form, to contact: RosterContactModel) {
        SessionManager.shared.apiManager.assignForm(to: contact, formUrl: form.formUrl) { success in
            if success {
                self.presentSnackbar(.success(message: "form_assigned".localized()))
                self.dismiss(animated: true) {
                    self.delegate?.formAssigned()
                }
            } else {
                self.presentSnackbar(.error(message: "assign_form_error".localized()))
            }
        }
    }
}

// MARK: SheetViewController

extension AssignFormWrapperViewController: SheetViewControllerDelegate {
    func actionComplete(message: String?) {
        if let message = message {
            presentSnackbar(.success(message: message))
        }
        
        dismiss(animated: true) {
            self.delegate?.formAssigned()
        }
    }
    
    func actionFailed(message: String?) {
        if let message = message {
            topViewController?.presentAlert(title: "basic_error_title".localized(), body: message)
        }
    }
}
