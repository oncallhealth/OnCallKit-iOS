//
//  RefreshableTableView.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-07-23.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - RefreshableTableViewDelegate

protocol RefreshableTableViewDelegate: AnyObject {
    
    func didPullToRefresh()
}

// MARK: - RefreshableTableView

class RefreshableTableView: UITableView {
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero, style: .plain)
        
        tableRefreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        refreshControl = tableRefreshControl
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var refreshableDelegate: RefreshableTableViewDelegate?
    
    func endRefreshing() {
        tableRefreshControl.endRefreshing()
    }
    
    // MARK: Private
    
    private let tableRefreshControl = UIRefreshControl()
    
    @objc private func didPullToRefresh() {
        if let refreshableDelegate = refreshableDelegate {
            refreshableDelegate.didPullToRefresh()
        } else {
            endRefreshing()
        }
    }
}
