//
//  MessageAnnouncementViewController.swift
//  OnCall Health iOS
//
//  Created by Josh on 2021-01-20.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - MessageAnnouncementViewControllerDelegate

protocol MessageAnnouncementViewControllerDelegate: AnyObject {
    func updateAnnouncement(announcementText: String)
}

// MARK: - MessageAnnouncementViewController

class MessageAnnouncementViewController: UIViewController {
    
    // MARK: Lifecycle
    
    init(messagingThread: MessagingThread? = nil, announcementText: String, isEditable: Bool) {
        self.messagingThread = messagingThread
        self.announcementText = announcementText
        self.isEditable = isEditable
        super.init(nibName: nil, bundle: nil)
        
        let announcementDivider = HairlineView()
        
        view.backgroundColor = .background
        
        view.addSubview(titleStackView)
        view.addSubview(contentView)
        
        titleStackView.addArrangedSubview(closeButton)
        titleStackView.addArrangedSubview(header)
        titleStackView.addArrangedSubview(saveButton)
        
        contentView.addSubview(announcementDivider)
        contentView.addSubview(announcementTextView)
        
        closeButton.setTitle(isEditable ? "cancel".localized() : "close".localized(), for: .normal)
        closeButton.setTitleColor(.primaryWhite, for: .normal)
        closeButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        closeButton.titleLabel?.textAlignment = .center
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        header.text = "announcement".localized() + (isEditable ? " (\(announcementText.count))" : "")
        header.textAlignment = .center
        header.font = .boldSystemFont(ofSize: 14)
        header.accessibilityLabel = "announcement".localized()
        
        saveButton.setTitle(isEditable ? "save".localized() : "", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        saveButton.titleLabel?.textAlignment = .center
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        saveButton.setTitleColor(.gray, for: .normal)
        saveButton.isEnabled = false
        
        titleStackView.snp.makeConstraints {
            $0.equalTo(safeAreaEdge: .leading, of: self).offset(24)
            $0.equalTo(safeAreaEdge: .trailing, of: self).offset(-24)
            $0.equalTo(safeAreaEdge: .top, of: self).offset(24)
        }
        
        titleStackView.axis = .horizontal
        titleStackView.spacing = 10
        titleStackView.distribution = .equalCentering
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom)
            $0.equalTo(safeAreaEdge: .leading, of: self)
            $0.equalTo(safeAreaEdge: .trailing, of: self)
            $0.equalTo(safeAreaEdge: .bottom, of: self)
        }
        
        announcementDivider.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleStackView.snp.bottom).offset(24)
        }
        
        announcementTextView.delegate = self
        announcementTextView.backgroundColor = .background
        announcementTextView.text = announcementText
        announcementTextView.font = .systemFont(ofSize: 14)
        announcementTextView.isEditable = isEditable
        announcementTextView.isSelectable = isEditable
        announcementTextView.snp.makeConstraints {
            $0.top.equalTo(announcementDivider.snp.bottom).offset(24)
            $0.equalTo(safeAreaEdge: .leading, of: self).offset(24)
            $0.equalTo(safeAreaEdge: .trailing, of: self).offset(-24)
            $0.equalTo(safeAreaEdge: .bottom, of: self).offset(24)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var delegate: MessageAnnouncementViewControllerDelegate?
    
    // MARK: Private
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }

    @objc private func didTapSaveButton() {
        
        dismissKeyboard()
        guard announcementTextView.text != announcementText else {
            self.dismiss(animated: true)
            self.presentSnackbar(.success(message: "announcement_updated".localized()))
            return
        }
        
        let loadingIndicator = self.presentLoadingIndicator()
        SessionManager.shared.apiManager.updateThreadAnnouncement(threadId: messagingThread?.id ?? 0, announcementText: announcementTextView.text) { success, errorMessage in
            loadingIndicator.dismiss {
                guard success else {
                    self.presentSnackbar(.error(message: errorMessage ?? "something_went_wrong".localized()))
                    self.dismiss(animated: true)
                    return
                }
                
                self.delegate?.updateAnnouncement(announcementText: self.announcementTextView.text)
                self.dismiss(animated: true)
                self.presentSnackbar(.success(message: "announcement_updated".localized()))
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private let messagingThread: MessagingThread?
    private let announcementText: String
    private let isEditable: Bool
    private let contentView = UIView()
    private let titleStackView = UIStackView()
    private let closeButton = UIButton()
    private let saveButton = UIButton()
    private let header = UILabel()
    private let announcementTextView = UITextView()

}

// MARK: UITextViewDelegate
extension MessageAnnouncementViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        header.text = "announcement".localized() + " (" + String(textView.text.count) + ")"
        if (textView.text.count == 0){
            saveButton.isEnabled = false
            saveButton.setTitleColor(.gray, for: .normal)
        } else {
            saveButton.isEnabled = true
            saveButton.setTitleColor(.primaryWhite, for: .normal)
        }
    }
}
