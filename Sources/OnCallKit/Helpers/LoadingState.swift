//
//  LoadingState.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import Foundation

// MARK: - LoadingState

enum LoadingState<T> {
    /// Specify `T` when you want the old results to still be displayed on screen (for example when pagination exists)
    case loading(T?)
    case loaded(T)
    case error
    
    // MARK: Internal
    
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    var isError: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }
}
