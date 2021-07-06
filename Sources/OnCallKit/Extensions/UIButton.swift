import UIKit

extension UIButton {
    func setIcon(_ image: UIImage?, color: UIColor) {
        self.setImage(image?.template(), for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.imageView?.tintColor = color
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
    }
    
    func configureAccessibilityLabel(label: String, hint: String? = nil) {
        accessibilityLabel = label
        accessibilityHint = hint
    }
}
