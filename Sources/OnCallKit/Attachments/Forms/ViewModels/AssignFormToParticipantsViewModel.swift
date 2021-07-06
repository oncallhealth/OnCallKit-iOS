//
//  AssignFormToParticipantsViewModel.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-10.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - AssignFormToParticipantsViewModel

class AssignFormToParticipantsViewModel {
    
    // MARK: Users
    
    struct User: Hashable {
        
        // MARK: Internal
        
        let url: String
        let name: String
    }
    
    // MARK: Lifecycle
    
    init(form: Form, allUsers: [User]) {
        self.form = form
        self.allUsers = allUsers
        self.visibleTo = Set(allUsers)
    }
    
    // MARK: Internal
    
    let form: Form
    let allUsers: [User]
    private(set) var visibleTo = Set<AssignFormToParticipantsViewModel.User>()
    
    func addUser(_ participant: AssignFormToParticipantsViewModel.User) {
        visibleTo.insert(participant)
    }
    
    func removeUser(_ participant: AssignFormToParticipantsViewModel.User) {
        visibleTo.remove(participant)
    }
    
    // MARK: Private
    
//    private let source: MixpanelSource.AttachmentAssignedSource
    
    private func assignForm(complete: @escaping (Bool) -> Void) {
        let dispatchGroup = DispatchGroup()
        var wasSucessful = true
        
        for participant in Array(visibleTo) {
            dispatchGroup.enter()
            
            SessionManager.shared.apiManager.assignForm(to: participant, formUrl: form.formUrl) { success in
                if !success {
                    wasSucessful = false
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if wasSucessful {
//                MixpanelTracking.track(
//                    event: .formAssigned(
//                        source: self.source,
//                        assignmentType: self.visibleTo.count == 1 ? .single : .multiple))
            }
            
            complete(wasSucessful)
        }
    }
}

// MARK: SheetViewModelable

extension AssignFormToParticipantsViewModel: SheetViewModelable {
    func viewForHeader() -> UIView? {
        let header = NavigationHeader()
        header.backgroundColor = .secondaryBackground
        
        header.configure(
            title: form.title,
            subtitle: "assign_form_instructions".localized(),
            hideCloseButton: true,
            hideSeperator: false)
        
        return header
    }
    
    func numberOfRows(in section: Int) -> Int {
        return allUsers.count + 1
    }
    
    func didSelectRow(
        at indexPath: IndexPath,
        dismissSheet: () -> Void,
        complete: @escaping (Bool, String?) -> Void)
    {
        if indexPath.row == numberOfRows(in: indexPath.section) - 1 {
            if visibleTo.isEmpty {
                complete(false, "assign_form_error_no_selection".localized())
            } else {
                dismissSheet()
                
                assignForm { success in
                    if success {
                        complete(true, "form_assigned".localized())
                    } else {
                        complete(false, "assign_form_error".localized())
                    }
                }
            }
        }
    }
}
