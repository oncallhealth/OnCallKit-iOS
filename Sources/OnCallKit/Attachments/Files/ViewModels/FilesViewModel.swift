//
//  FilesViewModel.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - FilesViewModel

class FilesViewModel {
    
    // MARK: ViewType
    
    enum ViewType {
        case appointment(id: Int)
        case patient
    }
    
    // MARK: Lifecycle
    
    init(viewType: ViewType) {
        self.viewType = viewType
    }
    
    // MARK: Internal
    
    var loadingState: LoadingState<[Attachment]> = .loading(nil)
    
    func getDownloadAttachmentLink(for index: Int, complete: @escaping (URL?) -> Void) {
        if case let .loaded(attachments) = loadingState, index < attachments.count {
            SessionManager.shared.apiManager.getDownloadAttachmentLink(attachmentId: attachments[index].id) { result in
                switch result {
                case .success(let url):
                    complete(url)
                case .failure:
                    SessionManager.shared.apiManager.getDownloadContactAttachmentLink(attachmentId: attachments[index].id) { contactResult in
                        switch contactResult {
                        case .success(let url):
                            complete(url)
                        case .failure:
                            complete(nil)
                        }
                    }
                }
            }
        } else {
            complete(nil)
        }
    }
    
    func getAttachment(with id: Int) -> Attachment? {
        if case let .loaded(attachments) = loadingState {
            return attachments.first { $0.id == id }
        }
        
        return nil
    }
    
    // MARK: Private
    
    private let viewType: ViewType
    private(set) var allFiles: [AttachmentPage] = []
    
}

// MARK: AttachmentsViewModelable

extension FilesViewModel: AttachmentsViewModelable {

    // MARK: Internal
    
    func loadAttachments(removeOldAttachments: Bool, complete: @escaping (Bool) -> Void) {
        let completion: (AttachmentPage?) -> Void = { page in
            guard let page = page else {
                self.loadingState = .error
                complete(false)
                return
            }
            
            self.allFiles.append(page)
            self.loadingState = .loaded(self.allFiles.flatMap { $0.results })
            
            complete(true)
        }
        
        if removeOldAttachments {
            self.allFiles.removeAll()
        }
        
        if case let .appointment(id) = viewType {
            SessionManager.shared.apiManager.getAttachments(for: id, complete: completion)
        } else {
            SessionManager.shared.apiManager.getPatientAttachments(page: allFiles.count + 1, complete: completion)
        }
    }
    
    func numberOfRows(in section: Int) -> Int {
        switch loadingState {
        case .loaded(let attachments):
            return attachments.count == 0 ? 1 : attachments.count
        case .loading(let attachments):
            guard let attachments = attachments else {
                return 0
            }
            
            return attachments.count + 1
        case .error:
            return 0
        }
    }
}
