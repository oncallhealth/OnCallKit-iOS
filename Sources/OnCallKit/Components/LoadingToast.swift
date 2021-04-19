//
//  LoadingToast.swift
//  OnCallKit
//
//  Created by Domenic Bianchi on 2021-01-21.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - LoadingToast

class LoadingToast: UIView {
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        let loadingIndicator = UIActivityIndicatorView()
        
        if #available(iOS 13.0, *) {
            loadingIndicator.style = .large
        } else {
            loadingIndicator.style = .whiteLarge
            loadingIndicator.color = .gray
        }
        
        addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        
        snp.makeConstraints {
            $0.width.height.equalTo(100)
        }
        
        layer.cornerRadius = 10
        //backgroundColor = .toastBackground
        backgroundColor = .white
        
        loadingIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
