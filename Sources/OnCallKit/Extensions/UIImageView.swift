import UIKit

// MARK: - UIImageView

extension UIImageView {
    
    // MARK: Internal
    
    func configureAccessibilityLabel(label: String, hint: String? = nil) {
        accessibilityLabel = label
        accessibilityHint = hint
    }
}
