//
//  FileVisibilityViewModel.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-07-08.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - FileVisibilityViewModel

class FileVisibilityViewModel {
    
    // MARK: Users
    
    struct User {
        
        // MARK: Internal
        
        let id: Int
        let name: String
    }
    
    // MARK: Lifecycle
    
    init(
        attachment: Attachment,
        allUsers: [User],
        canEditVisibility: Bool)
    {
        self.attachment = attachment
        self.allUsers = allUsers
        self.canEditVisibility = canEditVisibility
        
        visibleTo = Set(allUsers
            .filter { attachment.accessibleTo.contains($0.id) }
            .map { $0.id })
        
        originalVisibleTo = visibleTo
    }
    
    // MARK: Internal
    
    let attachment: Attachment
    let allUsers: [User]
    private(set) var visibleTo: Set<Int>
    
    var pendingChangesExist: Bool {
        return visibleTo != originalVisibleTo
    }
    
    func addUser(_ id: Int) {
        visibleTo.insert(id)
    }
    
    func removeUser(_ id: Int) {
        visibleTo.remove(id)
    }
    
    // MARK: Private
    
    private let originalVisibleTo: Set<Int>
    private let canEditVisibility: Bool
    
}

// MARK: SheetViewModelable

extension FileVisibilityViewModel: SheetViewModelable {
    
    func viewForHeader() -> UIView? {
        let header = NavigationHeader()
        header.backgroundColor = .secondaryBackground
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let subtitle: String?
        
        if let createdAt = attachment.createdAt {
            subtitle = "uploaded".localized() + " " + dateFormatter.string(from: createdAt)
        } else {
            subtitle = nil
        }
        
        header.configure(
            title: attachment.displayName,
            subtitle: subtitle,
            hideCloseButton: true,
            hideSeperator: false)
        
        return header
    }
    
    func numberOfRows(in section: Int) -> Int {
        if canEditVisibility {
            return allUsers.count + 1
        } else {
            return 1
        }
    }
    
    func didSelectRow(
        at indexPath: IndexPath,
        dismissSheet: () -> Void,
        complete: @escaping (Bool, String?) -> Void)
    {
        if indexPath.row == numberOfRows(in: indexPath.section) - 1 {
            dismissSheet()
            
            let completion: (Bool) -> Void = { success in
                if success {
                    complete(true, "file_deleted".localized())
                } else {
                    complete(false, "remove_file_error".localized())
                }
            }
            
            if attachment.appointment == nil {
                SessionManager.shared.apiManager.deleteContactAttachment(id: attachment.id, complete: completion)
            } else {
                SessionManager.shared.apiManager.deleteAttachment(id: attachment.id, complete: completion)
            }
        }
    }
    
    func viewDismissed(complete: @escaping (Bool, String?) -> Void) {
        if pendingChangesExist {
            SessionManager.shared.apiManager.updateAttachmentVisibility(
                id: attachment.id,
                visible: Array(visibleTo),
                hidden: allUsers
                    .filter { !visibleTo.contains($0.id) }
                    .compactMap { $0.id })
            { success in
                if success {
                    complete(true, nil)
                } else {
                    complete(false, "update_file_visibility_error".localized())
                }
            }
        }
    }
}
