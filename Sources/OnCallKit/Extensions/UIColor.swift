import UIKit

// MARK: - UIColor

extension UIColor {
    
    // MARK: Internal
    
    /*
        Adapted from https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
    */
    static func from(hexString: String, alpha: CGFloat) -> UIColor {
        func intFromHexString(hexStr: String) -> UInt32 {
            var hexInt: UInt32 = 0
            let scanner: Scanner = Scanner(string: hexStr)
            scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
            scanner.scanHexInt32(&hexInt)
            return hexInt
        }
        
        let hexint = Int(intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    static func from(hexString: String) -> UIColor {
        return UIColor.from(hexString: hexString, alpha: 1)
    }
    
    // https://stackoverflow.com/a/38435309
    func darker(by percentage: CGFloat = 15.0) -> UIColor? {
        return adjust(by: -1 * abs(percentage) )
    }
    
    func brighter(by percentage: CGFloat = 15.0) -> UIColor? {
        return adjust(by: abs(percentage) )
    }
    
    // MARK: Private
    
    private func adjust(by percentage: CGFloat = 15.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

// MARK: Constants

extension UIColor {

    // MARK: Internal
    
    static let error = UIColor.from(hexString: "#CD0000")
    static let success = UIColor.from(hexString: "#81BF66")
    
    static let snackbarError = UIColor(red: 0.90, green: 0.31, blue: 0.26, alpha:1.00)
    static let snackbarSuccess = UIColor(red: 0.22, green: 0.80, blue: 0.46, alpha: 1.00)
    
    static var background: UIColor {
        guard #available(iOS 13.0, *) else {
            return .from(hexString: "#f9f9f9")
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .systemBackground : .from(hexString: "#f9f9f9") }
    }
    
    static var toastBackground: UIColor {
        guard #available(iOS 13.0, *) else {
            return .from(hexString: "#f9f9f9")
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .secondarySystemBackground : .from(hexString: "#f9f9f9") }
    }
    
    static var backgroundAlternate: UIColor {
        guard #available(iOS 13.0, *) else {
            return .white
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .systemBackground : .white }
    }
    
    static var secondaryBackground: UIColor {
        guard #available(iOS 13.0, *) else {
            return .white
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .secondarySystemBackground : .white }
    }
    
    static var tertiaryBackground: UIColor {
        guard #available(iOS 13.0, *) else {
            return .white
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .tertiarySystemBackground : .white }
    }
    
    static var primary: UIColor {
        guard #available(iOS 13.0, *) else {
            return .from(hexString: SessionManager.shared.primaryColor.light)
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .from(hexString: SessionManager.shared.primaryColor.dark) : .from(hexString: SessionManager.shared.primaryColor.light) }
    }
    
    static var primaryWhite: UIColor {
        guard #available(iOS 13.0, *) else {
            return .from(hexString: SessionManager.shared.primaryColor.light)
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .white : .from(hexString: SessionManager.shared.primaryColor.light) }
    }
    
    static var secondary: UIColor {
        guard #available(iOS 13.0, *) else {
            return .from(hexString: SessionManager.shared.secondaryColor.light)
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .white : .from(hexString: SessionManager.shared.secondaryColor.light) }
    }
    
    static var labelText: UIColor {
        guard #available(iOS 13.0, *) else {
            return .black
        }
        
        return .label
    }
    
    static var subtitle: UIColor {
        guard #available(iOS 13.0, *) else {
            return .from(hexString: "#727272")
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .secondaryLabel : .from(hexString: "#727272") }
    }
    
    static var border: UIColor {
        guard #available(iOS 13.0, *) else {
            return .from(hexString: "#DEDEDE")
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .systemGray : .from(hexString: "#cbcbcb") }
    }
    
    static var darkBorder: UIColor {
        guard #available(iOS 13.0, *) else {
            return .black
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .white : .black }
    }
    
    static var iconTintColor: UIColor {
        guard #available(iOS 13.0, *) else {
            return .black
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .white : .black }
    }
    
    static var customGray: UIColor {
        return .from(hexString: "#a0a09e")
    }
    
    static var toggleSelectedColor: UIColor {
        guard #available(iOS 13.0, *) else {
            return .from(hexString: "#4a4a4a")
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .white : .from(hexString: "#4a4a4a") }
    }
    
    static var toggleDeselectedColor: UIColor {
        guard #available(iOS 13.0, *) else {
            return .from(hexString: "#f9f9f9")
        }
        
        return UIColor { $0.userInterfaceStyle == .dark ? .secondarySystemBackground : .from(hexString: "#f9f9f9") }
    }
    
    static var messageColor: UIColor {
        return .from(hexString: "#1982FC")
    }
}
