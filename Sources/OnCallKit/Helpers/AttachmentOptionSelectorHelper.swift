//
//  AttachmentOptionSelectorHelper.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-06-08.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import MobileCoreServices
import UIKit

// MARK: - AttachmentOptionSelectorHelper

class AttachmentOptionSelectorHelper {
    
    // MARK: Internal
    
    static let supportedDocumentTypes = [
        kUTTypeRTF,
        kUTTypeTIFF,
        kUTTypeJPEG,
        kUTTypePNG,
        kUTTypePDF,
        kUTTypeGIF,
        kUTTypeMP3,
        kUTTypePresentation,
        kUTTypeSpreadsheet,
        kUTTypeMPEG4,
        kUTTypePlainText,
        "com.microsoft.word.doc" as CFString,
        "org.openxmlformats.wordprocessingml.document" as CFString,
        "com.apple.iwork.pages.pages" as CFString,
        "com.apple.iwork.pages.sffpages" as CFString,
        "ca.oncallhealth.app.OnCall.dss" as CFString,
        "ca.oncallhealth.app.OnCall.ds2" as CFString
    ] as [String]
    
    static let supportedMediaTypes = ["public.image"]
    
    static func present(
        on viewController: UIViewController,
        sender: UIView,
        allowFormAttachments: Bool = true,
        imageAction: @escaping () -> Void,
        documentAction: @escaping () -> Void,
        formsAction: (() -> Void)? = nil)
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let imagesAction = UIAlertAction(title: "attach_image".localized(), style: .default) { _ in
            imageAction()
        }
        
        let documentsAction = UIAlertAction(title: "attach_document".localized(), style: .default) { _ in
            documentAction()
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel)
        
        alert.addAction(imagesAction)
        alert.addAction(documentsAction)
        
        if allowFormAttachments {
            let formsAction = UIAlertAction(title: "assign_form".localized(), style: .default) { _ in
                formsAction?()
            }
            
            alert.addAction(formsAction)
        }
        
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
