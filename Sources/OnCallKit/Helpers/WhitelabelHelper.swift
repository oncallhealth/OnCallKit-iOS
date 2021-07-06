//import Foundation
//
//// MARK: - Country
//
//enum Country: String {
//    case CA, US
//}
//
//// MARK: - WhitelabelHelper
//
//class WhitelabelHelper {
//    
//    // MARK: Name
//    
//    struct Name {
//        
//        // MARK: Lifecycle
//        
//        init(english: String, french: String?) {
//            self.english = english
//            self.french = french
//        }
//        
//        // MARK: Internal
//        
//        var inDeviceLanguage: String {
//            if Locale.current.languageCode == "fr" {
//                return french ?? english
//            } else {
//                return english
//            }
//        }
//        
//        // MARK: Private
//        
//        private let english: String
//        private let french: String?
//        
//    }
//    
////    // MARK: BrandingColor
////
////    struct BrandingColor {
////        let light: String
////        let dark: String
////    }
//    
//    // MARK: SignupButtonType
//    
//    enum SignupButtonType {
//        case bookingPage
//        case custom(URL)
//        case none
//    }
//    
//    // MARK: Lifecycle
//    
//    init() {
//        #if DEBUG
//        
//        let customEnvironment = UserDefaults.standard.string(forKey: "custom_environment")
//        let orgId = UserDefaults.standard.string(forKey: "organization_id")
//        
//        let devEnvironment = (customEnvironment?.isEmpty ?? true) ?
//            (UserDefaults.standard.string(forKey: "dev_environment") ?? "staging.oncallhealth.com") : customEnvironment!
//        
//        config = ["domain": devEnvironment, "domain_us": "app.oncallhealth.us"]
//        
//        name = Name(english: "OnCall Health", french: nil)
//        domain = devEnvironment
//        primaryColor = BrandingColor(light: "#2C4E69", dark: "#407A8D")
//        secondaryColor = BrandingColor(light: "#A53232", dark: "#A53232")
//        ssoEnabled = true
//        organizationId = orgId?.isEmpty == false ? orgId : nil
//        signupButtonType = .none
//        darkModeEnabled = true
//        zendeskUrl = "https://support.oncallhealth.ca/"
//        
//        #else
//        
//        if let path = Bundle.main.path(forResource: "config", ofType: "plist") {
//            config = NSDictionary(contentsOfFile: path)!
//        } else {
//            fatalError("Could not open plist file for whitelabel config")
//        }
//        
//        let baseDomain = config["domain"]! as! String
//        let lightPrimaryColor = config["color_primary"]! as! String
//        let lightSecondaryColor = config["color_secondary"]! as! String
//        
//        name = Name(english: config["name"]! as! String, french: config["name_fr"] as? String)
//        domain = baseDomain
//        primaryColor = BrandingColor(light: lightPrimaryColor, dark: config["color_primary_dark"] as? String ?? lightPrimaryColor)
//        secondaryColor = BrandingColor(light: lightSecondaryColor, dark: config["color_secondary_dark"] as? String ?? lightSecondaryColor)
//        organizationId = config["organization_id"] as? String
//        darkModeEnabled = config["dark_mode_enabled"] as? Bool ?? false
//        zendeskUrl = config["zendesk_url"] as? String ?? "https://support.oncallhealth.ca/"
//        
//        if config["booking_page_enabled"] as? Bool == false {
//            signupButtonType = .none
//        } else if let signupUrl = URL(string: config["booking_page_url"] as? String ?? "") {
//            signupButtonType = .custom(signupUrl)
//        } else {
//            signupButtonType = .bookingPage
//        }
//        
//        ssoEnabled = config["sso_enabled"] as? Bool ?? false
//        
//        #endif
//    }
//    
//    // MARK: Internal
//    
//    static let shared: WhitelabelHelper! = WhitelabelHelper()
//    
//    let name: Name
//    private(set) var domain: String
//    let primaryColor: BrandingColor
//    let secondaryColor: BrandingColor
//    let ssoEnabled: Bool
//    let organizationId: String?
//    let signupButtonType: SignupButtonType
//    let darkModeEnabled: Bool
//    let zendeskUrl: String
//    
//    var country: Country = .CA {
//        didSet {
//            if country == .CA {
//                let baseDomain = config["domain"]! as! String
//                domain = baseDomain
//            } else if country == .US, let domainUS = config["domain_us"] as? String {
//                domain = domainUS
//            }
//        }
//    }
//    
//    /// Avoid using this function. This function only exists due to the hacky solution required for the "forgot password" flow
//    func domain(for country: Country) -> String? {
//        if country == .CA {
//            let baseDomain = config["domain"]! as! String
//            return baseDomain
//        } else if country == .US, let domainUS = config["domain_us"] as? String {
//            return domainUS
//        } else {
//            return nil
//        }
//    }
//    
//    // MARK: Private
//    
//    private let config: NSDictionary
//    
//}
