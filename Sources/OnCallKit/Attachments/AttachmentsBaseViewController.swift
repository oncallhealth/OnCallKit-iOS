//
//  AttachmentsBaseViewController.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-08.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import MaterialComponents
import UIKit

// MARK: - AttachmentsViewModelable

protocol AttachmentsViewModelable {
    
    func loadAttachments(removeOldAttachments: Bool, complete: @escaping (Bool) -> Void)
    func numberOfRows(in section: Int) -> Int
}

// MARK: - AttachmentsBaseViewControllerDelegate

protocol AttachmentsBaseViewControllerDelegate: AnyObject {
    
    func didSelectRow(at indexPath: IndexPath, sender: UIView)
    func didTapMenu(id: Int, menu: UIView)
    func reachedBottomOfList()
}

// MARK: - AttachmentsBaseViewController

class AttachmentsBaseViewController<ViewModel: AttachmentsViewModelable>:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource
{
    // MARK: Lifecycle
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        tableViewContainer.delegate = self
        tableViewContainer.tableView.delegate = self
        tableViewContainer.tableView.dataSource = self
        tableViewContainer.tableView.separatorStyle = .none
        tableViewContainer.tableView.showsVerticalScrollIndicator = false
        tableViewContainer.tableView.rowHeight = UITableView.automaticDimension
        tableViewContainer.tableView.estimatedRowHeight = 44
        tableViewContainer.tableView.backgroundColor = .clear
        (tableViewContainer.tableView as? RefreshableTableView)?.refreshableDelegate = self
        tableViewContainer.tableView.register(
            AttachmentRow.self,
            forCellReuseIdentifier: AttachmentRow.reuseIdentifier)
        tableViewContainer.tableView.register(
            NoFileAttachmentsTableViewCell.self,
            forCellReuseIdentifier: NoFileAttachmentsTableViewCell.reuseIdentifier)
        tableViewContainer.tableView.register(
            LoadingTableViewCell.self,
            forCellReuseIdentifier: LoadingTableViewCell.reuseIdentifier)
        
        view.addSubview(tableViewContainer)
        view.addSubview(topGradient)
        view.addSubview(activityIndicator)
        
        tableViewContainer.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-4)
            $0.leading.equalToSuperview().offset(4)
        }
        
        topGradient.snp.makeConstraints {
            $0.top.equalTo(tableViewContainer)
            $0.leading.trailing.equalTo(tableViewContainer)
            $0.height.equalTo(32)
        }
        
        activityIndicator.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(100)
            $0.center.equalToSuperview()
        }
        
        tableViewContainer.configureErrorView(title: "could_not_fetch_attachments".localized())
        
        topGradient.alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var baseDelegate: AttachmentsBaseViewControllerDelegate?
    
    let viewModel: ViewModel
    
    func refresh(showLoadingIndicator: Bool = true, removeOldAttachments: Bool = true) {
        if showLoadingIndicator {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        
        viewModel.loadAttachments(removeOldAttachments: removeOldAttachments) { success in
            DispatchQueue.main.async {
                self.tableViewContainer.endRefreshing()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.tableViewContainer.reloadData(showErrorView: !success)
            }
        }
        
        tableViewContainer.reloadData()
    }
    
    // MARK: Private
    
    private let tableViewContainer = FailableTableView(canPullToRefresh: true)
    private let activityIndicator = UIActivityIndicatorView(indicatorStyle: .large)
    private let topGradient = GradientView(direction: .topToBottom)
    
    private var animating = false
    
    private func showFade(_ show: Bool) {
        animating = true
        UIView.animate(withDuration: 0.5, animations: {
            self.topGradient.alpha = show ? 1 : 0
        }) { _ in
            self.animating = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        baseDelegate?.didSelectRow(at: indexPath, sender: cell)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottom = scrollView.contentSize.height - scrollView.frame.size.height - 60 // buffer
        if scrollView.contentOffset.y > bottom {
            baseDelegate?.reachedBottomOfList()
        }
        
        guard !animating else {
            return
        }

        showFade(scrollView.contentOffset.y > 10)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Override me
        return UITableViewCell()
    }
}

// MARK: FailableTableViewDelegate

extension AttachmentsBaseViewController: FailableTableViewDelegate {
    func didTapActionButton() {
        refresh()
    }
}

// MARK: RefreshableTableViewDelegate

extension AttachmentsBaseViewController: RefreshableTableViewDelegate {
    func didPullToRefresh() {
        refresh(showLoadingIndicator: false)
    }
}
