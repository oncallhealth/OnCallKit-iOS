////
////  OnCallVideoConnector.swift
////  OnCallKit
////
////  Created by OnCall Health on 2021-01-20.
////  Copyright © 2021 OnCall Health. All rights reserved.
////
//
//import UIKit
//
//// MARK: - OCVidyoConnectorDelegate
//
//protocol OCVidyoConnectorDelegate: AnyObject {
//    func didConnect()
//    func didDisconnect()
//    func didFail()
//}
//
//// MARK: - OCVidyoConnector
//
//public class OCVidyoConnector {
//    
//    // MARK: Platform
//    
//    public enum Platform {
//        case vidyoIO(name: String, token: String, resourceId: String)
//        case hunterGuest(displayName: String, key: String, pin: String)
//        case hunterHost(username: String, password: String, key: String, pin: String)
//        
//        // MARK: Fileprivate
//        
//        fileprivate var domain: String {
//            switch self {
//            case .vidyoIO:
//                return "prod.vidyo.io"
//            case .hunterGuest, .hunterHost:
//                return "oncallhealth.health4.vidyoconnect.com"
//            }
//        }
//    }
//    
//    // MARK: VideoQuality
//    
//    public enum VideoQuality: Int, CaseIterable {
//        case high
//        case medium
//        case low
//        
//        // MARK: Fileprivate
//        
//        fileprivate var cpuTradeOffProfile: VCConnectorTradeOffProfile {
//            switch self {
//            case .low:
//                return .low
//            case .medium:
//                return .medium
//            case .high:
//                return .high
//            }
//        }
//        
//        fileprivate var cameraTradeOffProfile: VCLocalCameraTradeOffProfile {
//            switch self {
//            case .low:
//                return .low
//            case .medium:
//                return .medium
//            case .high:
//                return .high
//            }
//        }
//    }
//    
//    // MARK: Lifecycle
//    
//    public init(with view: UIView, numberOfParticipants: Int) {
//        self.view = view
//        self.connector = VCConnector(
//            &self.view,
//            viewStyle: .default,
//            remoteParticipants: UInt32(exactly: numberOfParticipants) ?? 1,
//            logFileFilter: nil,
//            logFileName: nil,
//            userData: 0)
//    }
//    
//    // MARK: Internal
//    
//    weak var delegate: OCVidyoConnectorDelegate?
//    
//    public var isConnected: Bool {
//        return connector.getState() == .connected
//    }
//    
//    public static func initialize() {
//        VCConnectorPkg.vcInitialize()
//    }
//    
//    public func set(size: CGSize) {
//        guard let view = view else {
//            return
//        }
//        
//        var mutableView = view
//        
//        connector.showView(
//            at: &mutableView,
//            x: 0,
//            y: 0,
//            width: UInt32(exactly: size.width) ?? 0,
//            height: UInt32(exactly: size.height) ?? 0)
//    }
//    
//    public func connect(to platform: Platform) {
//        connector.showPreview(true)
//        
//        switch platform {
//        case let .vidyoIO(name, token, resourceId):
//            connector.connect(
//                platform.domain,
//                token: token,
//                displayName: name,
//                resourceId: resourceId,
//                connectorIConnect: self)
//        case let .hunterHost(username, password, key, pin):
//            connector.connectToRoom(
//                withKey: platform.domain,
//                userName: username,
//                password: password,
//                roomKey: key,
//                roomPin: pin,
//                connectorIConnect: self)
//        case let .hunterGuest(displayName, key, pin):
//            connector.connectToRoom(
//                asGuest: platform.domain,
//                displayName: displayName,
//                roomKey: key,
//                roomPin: pin,
//                connectorIConnect: self)
//        }
//        
//        connector.registerLocalCameraEventListener(self)
//    }
//    
//    public func setMicrophonePrivacy(_ on: Bool) {
//        connector.setMicrophonePrivacy(on)
//    }
//    
//    public func setCameraPrivacy(_ on: Bool) {
//        connector.setCameraPrivacy(on)
//    }
//    
//    public func cycleCamera() {
//        connector.cycleCamera()
//    }
//    
//    public func disconnect() {
//        guard connector.getState() == .connected else {
//            return
//        }
//        
//        connector.unregisterLocalCameraEventListener()
//        
//        DispatchQueue.main.async {
//            self.connector.disconnect()
//        }
//    }
//    
//    public func setMode(_ mode: VCConnectorMode) {
//        connector.setMode(mode)
//    }
//    
//    public func setVideoQuality(_ quality: VideoQuality) {
//        connector.setCpuTradeOffProfile(quality.cpuTradeOffProfile)
//        selectedCamera?.setFramerateTradeOffProfile(quality.cameraTradeOffProfile)
//        selectedCamera?.setResolutionTradeOffProfile(quality.cameraTradeOffProfile)
//    }
//    
//    public func getVideoQuality() -> VideoQuality {
//        switch connector.getCpuTradeOffProfile() {
//        case .low:
//            return .low
//        case .medium:
//            return .medium
//        case .high:
//            return .high
//        @unknown default:
//            return .medium
//        }
//    }
//    
//    // MARK: Private
//    
//    private let connector: VCConnector
//    private var selectedCamera: VCLocalCamera?
//    private weak var view: UIView?
//    
//}
//
//// MARK: VCConnectorIConnect
//
//extension OCVidyoConnector: VCConnectorIConnect {
//    public func onFailure(_ reason: VCConnectorFailReason) {
//        DispatchQueue.main.async {
//            self.delegate?.didFail()
//        }
//    }
//    
//    public func onSuccess() {
//        DispatchQueue.main.async {
//            self.delegate?.didConnect()
//        }
//    }
//
//    public func onDisconnected(_ reason: VCConnectorDisconnectReason) {
//        DispatchQueue.main.async {
//            self.connector.disable()
//            self.delegate?.didDisconnect()
//        }
//    }
//}
//
//// MARK: VCConnectorIRegisterLocalCameraEventListener
//
//extension OCVidyoConnector: VCConnectorIRegisterLocalCameraEventListener {
//    public func onLocalCameraAdded(_ localCamera: VCLocalCamera) {}
//    public func onLocalCameraRemoved(_ localCamera: VCLocalCamera) {}
//    public func onLocalCameraStateUpdated(_ localCamera: VCLocalCamera, state: VCDeviceState) {}
//    
//    public func onLocalCameraSelected(_ localCamera: VCLocalCamera) {
//        selectedCamera = localCamera
//        //selectedCamera?.setPreviewLabel("preview".localized())
//    }
//}
//
