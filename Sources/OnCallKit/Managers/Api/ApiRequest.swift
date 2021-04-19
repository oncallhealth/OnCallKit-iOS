//
//  ApiRequest.swift
//  Development
//
//  Created by Domenic Bianchi on 2020-08-21.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - ApiRequest

final class ApiRequest {
    
    // MARK: Status
    
    enum Status {
        case success(response: ApiResponse)
        case error(code: Int, jsonData: Data?)
        case cancelled
    }
    
    // MARK: MetadataKeys
    
    private struct MetadataKeys {
        static let method = "method"
        static let path = "path"
        static let description = "description"
    }
    
    // MARK: Internal
    
    var completion: ((Status) -> Void)?
    
    func createRequest(
        endpoint: String,
        method: HTTPMethod,
        body: JSON?,
        headers: HTTPHeaders?)
    {
        print("\(method.rawValue) to \(endpoint)")
        
        dataRequest = AF.request(
            endpoint,
            method: method,
            parameters: body,
            encoding: method == .get ? URLEncoding.default : JSONEncoding.default,
            headers: headers).responseJSON { response in
                guard let responseCode = response.response?.statusCode, response.error == nil else {
                    switch response.error {
                    case .explicitlyCancelled:
                        print("CANCELLED: \(method.rawValue) to \(endpoint)")
                        self.completion?(.cancelled)
                    default:
                        let jsonData = try? JSONSerialization.data(withJSONObject: [
                            MetadataKeys.path: endpoint,
                            MetadataKeys.method: method.rawValue,
                            MetadataKeys.description: response.error?.localizedDescription ?? ""
                        ])
                        
                        self.completion?(.error(code: response.response?.statusCode ?? 0, jsonData: jsonData))
                    }
                    
                    return
                }
                
                if responseCode == 403 && method == .get && SessionManager.shared.tokenInKeychain() {
                    SessionManager.shared.clearTokenFromKeychain()
                    NotificationCenter.default.post(name: Notification.Name.did403, object: nil)
                    self.completion?(.error(code: 403, jsonData: nil))
                    return
                }
                
                var data: Data? = nil
                
                if let responseJson = response.value as? JSON {
                    data = try? JSONSerialization.data(withJSONObject: responseJson, options: [])
                } else if let responseJson = response.value as? [JSON] {
                    data = try? JSONSerialization.data(withJSONObject: responseJson, options: [])
                }
                
                guard responseCode >= 200 && responseCode < 400 else {
                    if var responseJson = response.value as? JSON {
                        responseJson[MetadataKeys.path] = endpoint
                        responseJson[MetadataKeys.method] = method.rawValue
                        data = try? JSONSerialization.data(withJSONObject: responseJson, options: [])
                    }
                    // This is hacky but is required because the API does not have a standard error message format
                    else if let responseArray = response.value as? [String] {
                        data = try? JSONSerialization.data(withJSONObject: responseArray, options: [])
                    }
                    
                    self.completion?(.error(code: responseCode, jsonData: data))
                    return
                }
                
                self.completion?(.success(response: ApiResponse(code: responseCode, body: data ?? Data())))
            }
    }
    
    func cancel() {
        dataRequest?.cancel()
    }
    
    // MARK: Private
    
    private var dataRequest: DataRequest?
    
}
