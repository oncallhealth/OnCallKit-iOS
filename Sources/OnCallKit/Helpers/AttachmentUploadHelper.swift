//
//  AttachmentUploadHelper.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-06-02.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - AttachmentUploadHelper

class AttachmentUploadHelper {
    
    // MARK: UploadMode
    
    enum UploadMode: Equatable {
        case appointment(url: String, participantIds: [Int])
        case rosterContact(url: String)
        
        // MARK: Fileprivate
        
        fileprivate var forAppointment: Bool {
            switch self {
            case .appointment:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: Internal
    
    func promptForAttachmentName(viewController: UIViewController, name: String, completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(
            title: "attachment_name".localized(),
            message: "enter_attachment_name".localized(),
            preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.text = name
            textField.placeholder = "attachment_name".localized()
            textField.addTarget(self, action: #selector(self.textDidChange), for: .editingChanged)
        }

        confirmAction = UIAlertAction(title: "submit".localized(), style: .default) { _ in
            completion(alertController.textFields![0].text ?? "")
        }

        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)

        alertController.addAction(confirmAction!)
        alertController.addAction(cancelAction)

        viewController.present(alertController, animated: true)
    }
    
    func upload(
        mode: UploadMode,
        document data: Data,
        displayName: String,
        pathExtension: String,
        completion: @escaping (Bool) -> Void)
    {
        SessionManager.shared.apiManager.getAttachmentDetails(forAppointment: mode.forAppointment) { details in
            guard let details = details else {
                completion(false)
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
            
            let filename = "uploads/\(details.keyPrefix)\(formatter.string(from: Date()) + "." + pathExtension)"
            
            SessionManager.shared.apiManager.uploadFileS3(filename: filename, data: details, file: data) { success in
                guard success else {
                    completion(false)
                    return
                }
                
                if case let .appointment(url, participantIds) = mode {
                    SessionManager.shared.apiManager.attachToAppointment(
                        appointmentUrl: url,
                        filename: filename,
                        displayname: displayName,
                        participants: participantIds)
                    { success in                         
                        completion(success)
                    }
                } else if case let .rosterContact(url) = mode {
                    SessionManager.shared.apiManager.attachToContact(
                        contactUrl: url,
                        filename: filename,
                        displayName: displayName)
                    {
                        completion($0)
                    }
                }
            }
        }
    }
    
    // MARK: Private
    
    private var confirmAction: UIAlertAction?
    
    @objc private func textDidChange(sender: UITextField) {
        confirmAction?.isEnabled = !(sender.text?.isEmpty ?? true)
    }
}
