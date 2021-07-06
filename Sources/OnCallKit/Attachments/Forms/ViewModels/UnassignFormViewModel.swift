//
//  UnassignFormViewModel.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-10.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - UnassignFormViewModel

class UnassignFormViewModel {
    
    // MARK: Lifecycle
    
    init(form: Form) {
        self.form = form
    }
    
    // MARK: Private
    
    private let form: Form
    
}

// MARK: SheetViewModelable

extension UnassignFormViewModel: SheetViewModelable {
    func viewForHeader() -> UIView? {
        let header = NavigationHeader()
        header.backgroundColor = .secondaryBackground
        
        header.configure(
            title: form.title,
            subtitle: nil,
            hideCloseButton: true,
            hideSeperator: false)
        
        return header
    }
    
    func numberOfRows(in section: Int) -> Int {
        return 1
    }
    
    func didSelectRow(
        at indexPath: IndexPath,
        dismissSheet: () -> Void,
        complete: @escaping (Bool, String?) -> Void)
    {
        dismissSheet()
        SessionManager.shared.apiManager.unassignForm(id: form.id) { success in
            if success {
                complete(true, "form_unassigned".localized())
            } else {
                complete(false, "unassign_form_error".localized())
            }
        }
    }
}
