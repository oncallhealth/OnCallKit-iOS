import UIKit

public extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localizedPlural(_ value: Int) -> String {
        return String.localizedStringWithFormat(localized(), value)
    }
    
    public func icon() -> UIImage? {
        return UIImage(named: self, in: Bundle.module, compatibleWith: nil)
    }
    
    func iconTemplate() -> UIImage? {
        return icon()?.template()
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func attributed(size: Int = 12) -> NSAttributedString {
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(size))
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }
    
    func bold(size: Int = 12) -> NSAttributedString {
        let boldAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: CGFloat(size))
        ]
        
        return NSAttributedString(string: self, attributes: boldAttributes)
    }
    
    var htmlDecoded: String {
         let decoded = try? NSAttributedString(data: Data(utf8), options: [
             .documentType: NSAttributedString.DocumentType.html,
             .characterEncoding: String.Encoding.utf8.rawValue
         ], documentAttributes: nil).string

         return decoded ?? self
    }
}
