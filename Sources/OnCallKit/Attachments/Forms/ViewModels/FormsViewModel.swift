//
//  FormsViewModel.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - FormsViewModel

class FormsViewModel {
    
    // MARK: ViewType
    
    enum ViewType {
        case appointment(id: Int)
        case pendingAppointment(requestId: Int)
        case tab
    }
    
    // MARK: Lifecycle
    
    init(viewType: ViewType, canEdit: Bool) {
        self.viewType = viewType
        self.canEdit = canEdit
    }
    
    // MARK: Internal
    
    var loadingState: LoadingState<[Form]> = .loading(nil)
    let canEdit: Bool
    
    func getForm(with id: Int) -> Form? {
        if case let .loaded(form) = loadingState {
            return form.first { $0.id == id }
        }
        
        return nil
    }
    
    func getForm(at indexPath: IndexPath) -> Form? {
        if case let .loaded(forms) = loadingState, indexPath.row < forms.count {
            return forms[indexPath.row]
        }
        
        return nil
    }
    
    // MARK: Private
    
    private let viewType: ViewType
    private(set) var allForms: [FormPage] = []
    
}

// MARK: AttachmentsViewModelable

extension FormsViewModel: AttachmentsViewModelable {

    // MARK: Internal
    
    func loadAttachments(removeOldAttachments: Bool, complete: @escaping (Bool) -> Void) {
        let completion: (FormPage?) -> Void = { page in
            guard let page = page else {
                self.loadingState = .error
                complete(false)
                return
            }

            self.allForms.append(page)
            self.loadingState = .loaded(self.allForms.flatMap { $0.results })
            
            complete(true)
        }
        
        if removeOldAttachments {
            self.allForms.removeAll()
        }
        
        if case let .pendingAppointment(requestId) = viewType {
            SessionManager.shared.apiManager.getIntakeForms(for: requestId, completion: completion)
        } else if case let .appointment(id) = viewType {
            SessionManager.shared.apiManager.getAssignedForms(for: id, completion: completion)
        } else {
            SessionManager.shared.apiManager.getPatientAssignedForms(page: allForms.count + 1, completion: completion)
        }
    }
    
    func numberOfRows(in section: Int) -> Int {
        switch loadingState {
        case .loaded(let forms):
            return forms.count == 0 ? 1 : forms.count
        case .loading(let forms):
            guard let forms = forms else {
                return 0
            }
            
            return forms.count + 1
        case .error:
            return 0
        }
    }
}
