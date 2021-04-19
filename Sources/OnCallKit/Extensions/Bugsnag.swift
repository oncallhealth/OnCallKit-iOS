import Foundation
import Bugsnag

// MARK: - Bugsnag

extension Bugsnag {
    
    // MARK: Internal
    
    static func report(title: String, body: String) {
        let exception = NSException(name: NSExceptionName(title), reason: body, userInfo: nil)
        Bugsnag.notify(exception)
    }
    
    static func report(exceptionName: String, description: String, metadata: [String: String]? = nil) {
        let exception = NSException(name: NSExceptionName(exceptionName),
                                    reason: description,
                                    userInfo: nil)
        
        Bugsnag.notify(exception) { (report) in
            report.addMetadata(metadata)
            
            return true
        }
    }
    
    static func reportApiError(_ error: Error, apiCall: String = #function) {
        guard let apiError = error as? NetworkError else {
            Bugsnag.notifyError(error)
            return
        }
        
        switch apiError {
        case let .standardError(code, jsonData):
            // We don't need to report 403 errors since these occur when an invalid auth token is used
            if code != 403 {
                let json = try? JSONSerialization.jsonObject(with: jsonData ?? Data(), options: []) as? JSON
                Bugsnag.notifyError(NSError(domain: "API Error - \(apiCall)", code: code, userInfo: nil)) { report in
                    report.addMetadata(json)

                    return true
                }
            }
        }
    }
}

// MARK - BugsnagMetadataStore

private extension BugsnagMetadataStore {
    
    // MARK: Internal
    
    func addMetadata(_ metadata: [String: Any]?) {
        if let metadata = metadata {
            addMetadata(metadata, section: "metadata")
        }
    }
}
