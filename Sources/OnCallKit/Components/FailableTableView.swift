//
//  FailableTableView.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-09-28.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - FailableTableViewDelegate

protocol FailableTableViewDelegate: AnyObject {
    func didTapActionButton()
}

// MARK: - FailableTableView

class FailableTableView: UIView {
    
    // MARK: Lifecycle
    
    init(canPullToRefresh: Bool = true) {
        self.tableView = canPullToRefresh ? RefreshableTableView() : UITableView()
        
        super.init(frame: .zero)
        
        addSubview(tableView)
        addSubview(errorView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        errorView.snp.makeConstraints {
            $0.edges.equalTo(tableView)
        }
        
        errorView.isHidden = true
        
        errorView.setInteraction { [weak self] in
            self?.delegate?.didTapActionButton()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var delegate: FailableTableViewDelegate?
    
    let tableView: UITableView
    
    func configureErrorView(
        title: String,
        buttonText: String = "try_again".localized(),
        iconName: String = "ic-exclamation-circle")
    {
        errorView.configure(title: title, buttonText: buttonText, iconName: iconName)
    }
    
    func reloadData(showErrorView: Bool = false) {
        tableView.reloadData()
        
        if showErrorView {
            errorView.isHidden = false
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            errorView.isHidden = true
        }
    }
    
    func endRefreshing() {
        (tableView as? RefreshableTableView)?.endRefreshing()
    }
    
    // MARK: Private
    
    private let errorView = ListErrorView()
    
}
