//
//  MaterialTabBar.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import MaterialTabs
import SnapKit
import UIKit

// MARK: - MaterialTabBar

class MaterialTabBar: UIView {
    
    // MARK: Lifecycle
    
    init(alignment: MDCTabBarAlignment = .justified) {
        super.init(frame: .zero)
        
        tabBar.itemAppearance = .titles
        tabBar.alignment = alignment
        tabBar.tintColor = .primary
        tabBar.selectedItemTintColor = .primary
        tabBar.unselectedItemTintColor = .labelText
        tabBar.inkColor = .clear
        tabBar.delegate = self
        
        addSubview(tabBar)
        
        tabBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    func configure(options: [String], capitalized: Bool = true) {
        tabBar.items.removeAll()
        tabBar.displaysUppercaseTitles = capitalized
        
        options.enumerated().forEach {
            tabBar.items.append(UITabBarItem(title: $1, image: nil, tag: $0))
        }
    }
    
    func setSelected(index: Int) {
        guard tabBar.items.count > index else {
            return
        }
        
        tabBar.setSelectedItem(tabBar.items[index], animated: true)
    }
    
    func setInteraction(didTap: @escaping (Int) -> Void) {
        self.didTap = didTap
    }
    
    // MARK: Private
    
    private let tabBar = MDCTabBar()
    private var didTap: ((Int) -> Void)?
    
}

// MARK: MDCTabBarDelegate

extension MaterialTabBar: MDCTabBarDelegate {
    func tabBar(_ tabBar: MDCTabBar, didSelect item: UITabBarItem) {
        didTap?(item.tag)
    }
}
