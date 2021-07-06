//
//  LoadingToast.swift
//  Development Simulator
//
//  Created by Domenic Bianchi on 2020-09-28.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - LoadingToast

class LoadingToast: UIView {
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        let loadingIndicator = UIActivityIndicatorView(indicatorStyle: .large)
        
        addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        
        snp.makeConstraints {
            $0.width.height.equalTo(100)
        }
        
        layer.cornerRadius = 10
        backgroundColor = .toastBackground
        
        loadingIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
