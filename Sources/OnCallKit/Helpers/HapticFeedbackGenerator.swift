//
//  HapticFeedbackGenerator.swift
//  Development
//
//  Created by Domenic Bianchi on 2020-08-12.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - HapticFeedbackGenerator

final class HapticFeedbackGenerator {
    
    // MARK: Kind
    
    enum Kind {
        case error
        case success
        case warning
        
        case light
        case medium
        case heavy
        
        // MARK: Fileprivate
        
        fileprivate var feedbackType: Int {
            switch self {
            case .error:
                return UINotificationFeedbackGenerator.FeedbackType.error.rawValue
            case .success:
                return UINotificationFeedbackGenerator.FeedbackType.success.rawValue
            case .warning:
                return UINotificationFeedbackGenerator.FeedbackType.warning.rawValue
            case .light:
                return UIImpactFeedbackGenerator.FeedbackStyle.light.rawValue
            case .medium:
                return UIImpactFeedbackGenerator.FeedbackStyle.medium.rawValue
            case .heavy:
                return UIImpactFeedbackGenerator.FeedbackStyle.heavy.rawValue
            }
        }
    }
    
    // MARK: Lifecycle
    
    init(kind: Kind) {
        self.kind = kind
        
        switch kind {
        case .error, .success, .warning:
            generator = UINotificationFeedbackGenerator()
        case .light, .medium, .heavy:
            generator = UIImpactFeedbackGenerator(
                style: UIImpactFeedbackGenerator.FeedbackStyle(rawValue: kind.feedbackType) ?? .light)
        }
    }
    
    // MARK: Internal
    
    func prepare() {
        generator.prepare()
    }
    
    func generate() {
        if let generator = generator as? UINotificationFeedbackGenerator,
            let feedbackType = UINotificationFeedbackGenerator.FeedbackType(rawValue: kind.feedbackType)
        {
            generator.notificationOccurred(feedbackType)
        } else if let generator = generator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
    }
    
    // MARK: Private
    
    private let generator: UIFeedbackGenerator
    private let kind: Kind
    
}
