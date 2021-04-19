//
//  SheetViewController.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-10.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import PanModal
import UIKit

// MARK: - SheetViewControllerDelegate

protocol SheetViewControllerDelegate: AnyObject {
    func actionComplete(message: String?)
    func actionFailed(message: String?)
}

// MARK: - SheetViewController

class SheetViewController: UITableViewController, PanModalPresentable {
    
    // MARK: Lifecycle
    
    init(viewModel: SheetViewModelable) {
        self.viewModel = viewModel
        self.header = viewModel.viewForHeader()
        
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .secondaryBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = viewModel.seperatorStyle
        tableView.alwaysBounceVertical = false
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        
        ComponentType.allCases.forEach {
            tableView.register($0.cellClass, forCellReuseIdentifier: $0.rawValue)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var delegate: SheetViewControllerDelegate?
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
    
    var scrollIndicatorInsets: UIEdgeInsets {
        return UIEdgeInsets(
            top: header?.frame.size.height ?? 0,
            left: 0,
            bottom: view.safeAreaInsets.bottom,
            right: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewDismissed()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return header == nil ? 0 : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Override me!
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath, dismissSheet: {
            self.dismiss(animated: true)
        }) { success, message in
            if success {
                self.delegate?.actionComplete(message: message)
            } else {
                self.delegate?.actionFailed(message: message)
            }
        }
    }
    
    // MARK: Private
    
    private let viewModel: SheetViewModelable
    private let header: UIView?
    
    private func viewDismissed() {
        viewModel.viewDismissed { success, message in
            if success {
                self.delegate?.actionComplete(message: message)
            } else {
                self.delegate?.actionFailed(message: message)
            }
        }
    }
}
