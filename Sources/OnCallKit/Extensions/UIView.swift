import Foundation
import UIKit

// MARK: - UIView

extension UIView {
    
    // MARK: Internal
    
    func addShadow(offsetX: CGFloat, offsetY: CGFloat, opacity: Float, radius: CGFloat? = nil) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: offsetX, height: offsetY)
        layer.shadowOpacity = opacity
        
        if let radius = radius {
            layer.shadowRadius = radius
        }
    }
    
    func addGradient(color: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [color.cgColor, color.withAlphaComponent(0.0).cgColor]
        layer.addSublayer(gradient)
    }
}
