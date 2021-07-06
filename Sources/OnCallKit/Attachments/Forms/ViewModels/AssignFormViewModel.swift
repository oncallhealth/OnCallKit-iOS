//
//  AssignFormViewModel.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-10.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import Foundation

// MARK: - AssignFormViewModel

class AssignFormViewModel {
    
    // MARK: State
    
    enum State {
        case appointment(participants: [AppointmentParticipantModel])
        case rosterContact(contact: RosterContactModel)
    }
    
    // MARK: Lifecycle
    
    init(state: State) {
        self.state = state
    }
    
    // MARK: Internal
    
    let state: State
    
    private(set) var loadingState: LoadingState<[Form]> = .loading(nil)
    
    func getForm(at index: Int) -> Form? {
        if case let .loaded(forms) = loadingState {
            return forms[index]
        }
        
        return nil
    }
    
}

// MARK: AttachmentsViewModelable

extension AssignFormViewModel: AttachmentsViewModelable {
    func loadAttachments(removeOldAttachments: Bool, complete: @escaping (Bool) -> Void) {
        loadingState = .loading(nil)
        
        SessionManager.shared.apiManager.getAllForms { page in
            guard let forms = page?.results else {
                self.loadingState = .error
                complete(false)
                return
            }

            self.loadingState = .loaded(forms)
            complete(true)
        }
    }
    
    func numberOfRows(in section: Int) -> Int {
        switch loadingState {
        case .loaded(let forms):
            return forms.count == 0 ? 1 : forms.count
        case .loading:
            return 0
        case .error:
            return 1
        }
    }
}
