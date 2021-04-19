//
//  MessageThreadParticipantsViewModel.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-08-26.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - MessageThreadParticipantsViewModel

class MessageThreadParticipantsViewModel {

    // MARK: Lifecycle
    
    init(threadUsers: [MessagingUser]) {
        self.threadUsers = threadUsers
    }
    
    // MARK: Internal
    
    let threadUsers: [MessagingUser]
    
}

// MARK: SheetViewModelable

extension MessageThreadParticipantsViewModel: SheetViewModelable {
    func viewForHeader() -> UIView? {
        let header = NavigationHeader()
        header.backgroundColor = .secondaryBackground
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        header.configure(
            title: "participant_list".localized(),
            hideCloseButton: true,
            hideSeperator: false)
        
        return header
    }
    
    func numberOfRows(in section: Int) -> Int {
        return threadUsers.count
    }
    
    func didSelectRow(at indexPath: IndexPath, dismissSheet: () -> Void, complete: @escaping (Bool, String?) -> Void) {}
}
