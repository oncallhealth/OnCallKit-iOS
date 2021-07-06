//
//  PDFViewController.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-08-26.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import PDFKit
import SnapKit
import UIKit

// MARK: - PDFViewController

class PDFViewController: UIViewController {
    
    // MARK: Lifecycle
    
    init(url: URL, title: String, savedMessage: String, sentMessage: String) {
        self.url = url
        self.savedMessage = savedMessage
        self.sentMessage = sentMessage
        
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .background
        navigationItem.title = title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShareButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancelButton))
        
        view.addSubview(pdfView)
        pdfView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        pdfView.displayMode = .singlePageContinuous
        pdfView.autoScales = true
        pdfView.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard pdfView.document == nil else {
            return
        }
        
        if !url.isFileURL {
            // https://stackoverflow.com/a/57494112
            
            let loadingIndicator = presentLoadingIndicator()
            DispatchQueue.global(qos: .background).async {
                if #available(iOS 14, *) {
                    self.document = PDFDocument(url: self.url)
                } else {
                    guard let data = try? Data(contentsOf: self.url) else {
                        return
                    }
                    
                    self.document = PDFDocument(data: data)
                }
                
                DispatchQueue.main.async {
                    self.pdfView.document = self.document
                    loadingIndicator.dismiss()
                }
            }
        } else {
            document = PDFDocument(url: url)
            pdfView.document = document
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    private var document: PDFDocument?
    private let pdfView = PDFView()
    private let savedMessage: String
    private let sentMessage: String
    private let url: URL
    
    @objc private func didTapShareButton() {
        guard let documentURL = document?.documentURL else {
            return
        }
        
        let vc = UIActivityViewController(activityItems: [documentURL], applicationActivities: [])
        vc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF]
        vc.completionWithItemsHandler = { [weak self] activityType, completed, _, _ in
            guard let `self` = self, let activityType = activityType, completed else {
                return
            }
            
            switch activityType {
            case .init(rawValue: "com.apple.DocumentManagerUICore.SaveToFiles"):
                self.presentSnackbar(.success(message: self.savedMessage))
            case .copyToPasteboard:
                return
            default:
                self.presentSnackbar(.success(message: self.sentMessage))
            }
        }
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(vc, animated: true)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
}
