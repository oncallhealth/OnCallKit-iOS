import UIKit

// MARK: - UIImage

extension UIImage {
    
    // MARK: Internal
    
    func template() -> UIImage {
        return self.withRenderingMode(.alwaysTemplate)
    }
    
    func compress() -> Data? {
       return jpegData(compressionQuality: 0.8)
    }
}
