//import AVFoundation
//import UIKit
//
//// MARK: - CallScreenDelegate
//
//protocol CallScreenDelegate: AnyObject {
//    func didHangUp(appointment: AppointmentModel)
//    func didFailToConnect()
//}
//
//// MARK: - VidyoCallViewController
//
//public class VidyoCallViewController: UIViewController {
//
//    // MARK: Lifecycle
//
//    public init(appointment: AppointmentModel) {
//        self.appointment = appointment
//
//        super.init(nibName: nil, bundle: nil)
//
//        let settingsButton = IconButton()
//
//        view.addSubview(videoView)
//        view.addSubview(controlStackView)
//        view.addSubview(settingsButton)
//        //view.addSubview(countdownTimer)
//
//        controlStackView.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.height.equalTo(44)
//
//            if UIDevice.current.hasBottomSafearea {
//                make.equalTo(safeAreaEdge: .bottom, of: self)
//            } else {
//                make.equalTo(safeAreaEdge: .bottom, of: self).offset(-10)
//            }
//        }
//
//        videoView.snp.makeConstraints {
//            $0.leading.trailing.top.equalToSuperview()
//            $0.bottom.equalTo(controlStackView.snp.top).offset(-10)
//        }
//
//        settingsButton.snp.makeConstraints {
//            $0.equalTo(safeAreaEdge: .top, of: self)
//            $0.trailing.equalToSuperview().offset(-10)
//        }
//
//        settingsButton.alpha = 0.8
//        settingsButton.setContent(icon: AssetProvider.asset(named: "ic-cog"))
////        settingsButton.setInteractions { [weak self] in
////            guard let `self` = self else {
////                return
////            }
////
////            let viewController = VidyoQualitySettingsViewController(
////                viewModel: VidyoQualitySettingsViewModel(selectedQuality: self.connector?.getVideoQuality() ?? .medium))
////
////            viewController.videoQualityDelegate = self
////            self.presentPanModal(viewController, sourceView: settingsButton, sourceRect: settingsButton.bounds)
////        }
//
////        countdownTimer.snp.makeConstraints {
////            $0.centerX.equalToSuperview()
////            $0.top.equalTo(view)
////        }
////
////        countdownTimer.isHidden = true
//
//        controlStackView.axis = .horizontal
//        controlStackView.spacing = 25
//
//        chatButton.setContent(icon: AssetProvider.asset(named: "callbutton-chat"), isEnabled: false)
//        chatButton.setInteractions { [weak self] in
//            self?.presentChatView()
//        }
//
//        cycleCameraButton.setContent(icon: AssetProvider.asset(named: "callbutton-cameraflip"))
//        cycleCameraButton.setInteractions { [weak self] in
//            self?.connector?.cycleCamera()
//        }
//
//        muteButton.setContent(icon: AssetProvider.asset(named: "callbutton-mic-on"))
//        muteButton.setInteractions { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//
//            self.muted.toggle()
//            self.connector?.setMicrophonePrivacy(self.muted)
//            self.muteButton.setContent(icon: self.muted ? AssetProvider.asset(named: "callbutton-mic-off") : AssetProvider.asset(named: "callbutton-mic-on"))
//        }
//
//        endCallButton.setContent(icon: AssetProvider.asset(named: "callbutton-end"), isEnabled: false)
//        endCallButton.setInteractions { [weak self] in
//            guard let `self` = self, self.connector?.isConnected ?? false else {
//                return
//            }
//
//            self.disconnect()
//        }
//
//        cameraButton.setContent(icon: AssetProvider.asset(named: "callbutton-camera-on"))
//        cameraButton.setInteractions { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//
//            self.cameraDisabled.toggle()
//            self.cameraButton.setContent(icon: self.cameraDisabled ? AssetProvider.asset(named: "callbutton-camera-off") : AssetProvider.asset(named: "callbutton-camera-on"))
//            self.connector?.setCameraPrivacy(self.cameraDisabled)
//        }
//
//        controlStackView.addArrangedSubview(chatButton)
//        controlStackView.addArrangedSubview(cameraButton)
//        controlStackView.addArrangedSubview(muteButton)
//        controlStackView.addArrangedSubview(cycleCameraButton)
//        controlStackView.addArrangedSubview(endCallButton)
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(didReceiveMessage(_:)),
//            name: Notification.Name.didReceiveWebsocketMessage,
//            object: nil)
//
//        self.connector = OCVidyoConnector(with: videoView, numberOfParticipants: appointment.allParticipants.count)
//        self.connector?.delegate = self
//
//        view.backgroundColor = .black
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(appWillResign),
//            name: UIApplication.willResignActiveNotification,
//            object: nil)
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(appDidBecomeActive),
//            name: UIApplication.didBecomeActiveNotification,
//            object: nil)
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    public override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        UIApplication.shared.isIdleTimerDisabled = true
//
//        guard !viewAppearedOnce else {
//            return
//        }
//
//        viewAppearedOnce = true
//
//        connector?.set(size: videoView.frame.size)
//        checkCameraAndMicrophoneStatus()
//        updateUnreadThread()
//
////        if let user = SessionManager.shared.user,
////           user.ownsAppointment(appointment),
////           let appointmentDate = appointment.date,
////           let fireDate = Calendar.current.date(byAdding: .minute, value: appointment.duration - 5, to: appointmentDate)
////        {
////            // The timer must be captured within the block, otherwise the weak self reference will be nil.
////            Timer.scheduledTimer(withTimeInterval: fireDate.timeIntervalSinceNow, repeats: false) { [weak self] timer in
////                guard let `self` = self,
////                      let appointmentDate = self.appointment.date,
////                      let endDate = Calendar.current.date(byAdding: .minute, value: self.appointment.duration, to: appointmentDate) else
////                {
////                    return
////                }
////
////                self.countdownTimer.startTimer(secondsRemaining: Int(endDate.timeIntervalSinceNow))
////                self.countdownTimer.isHidden = false
////            }
////        }
//
//        loadingOverlay = presentLoadingIndicator()
//    }
//
//    public override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        UIApplication.shared.isIdleTimerDisabled = false
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: Internal
//
//    weak var delegate: CallScreenDelegate?
//
//    public func connect(to platform: OCVidyoConnector.Platform) {
//        connector?.connect(to: platform)
//    }
//
//    // MARK: Private
//
//    private let videoView = UIView(frame: .zero)
//    private var connector: OCVidyoConnector?
//
//    //private let countdownTimer = CountdownTimer()
//    private let endCallButton = IconButton()
//    private let cycleCameraButton = IconButton()
//    private let muteButton = IconButton()
//    private let chatButton = IconButton()
//    private let cameraButton = IconButton()
//    private let controlStackView = UIStackView()
//    private let appointment: AppointmentModel
//    private var cameraDisabled = false
//    private var muted = false
//    private var thread: MessagingThread?
//    private var viewingMessages: Bool = false
//    private var viewAppearedOnce = false
//    private var handlerFor403: (() -> Void)? = nil
//
//    private var loadingOverlay: LoadingOverlayViewController?
//
//    private func checkCameraAndMicrophoneStatus() {
//        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
//        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
//
//        var message = ""
//
//        if cameraStatus != .notDetermined && cameraStatus != .authorized {
//            message = String(format: "no_camera_access".localized(), Bundle.main.displayName ?? "")
//        }
//
//        if microphoneStatus != .notDetermined && microphoneStatus != .authorized {
//            if message.isEmpty {
//                message = String(format: "no_microphone_access".localized(), Bundle.main.displayName ?? "")
//            } else {
//                message = String(format: "no_camera_microphone_access".localized(), Bundle.main.displayName ?? "")
//            }
//        }
//
//        if !message.isEmpty {
//            let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "cancel".localized(), style: .default) { _ in
//                alert.dismiss(animated: true, completion: nil)
//            })
//
//            alert.addAction(UIAlertAction(title: "settings".localized(), style: .default) { _ in
//                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//                    return
//                }
//
//                UIApplication.shared.open(settingsUrl)
//            })
//
//            present(alert, animated: true, completion: nil)
//        }
//    }
//
//    private func updateUnreadThread() {
//        guard let messageThreadId = appointment.messageThreadId else {
//            return
//        }
//
//        SessionManager.shared.apiManager.fetchThreadMessages(threadId: messageThreadId) { thread in
//            self.thread = thread
//
//            guard let latestMessage = thread?.getLatestMessage() else {
//                self.chatButton.setContent(icon: AssetProvider.asset(named: "callbutton-chat"))
//                return
//            }
//
//            let lastSeenMessages = UserDefaults.standard.dictionary(
//                forKey: "last_read_messages_in_call_\(self.appointment.id)") as? [String : Int] ?? [:]
//
//            if lastSeenMessages[String(messageThreadId)] != Int(latestMessage.messageId)! {
//                self.chatButton.setContent(icon: AssetProvider.asset(named: "callbutton-chat-unread"))
//            } else {
//                self.chatButton.setContent(icon: AssetProvider.asset(named: "callbutton-chat"))
//            }
//        }
//    }
//
//    private func markThreadRead(_ thread: MessagingThread) {
//        var lastSeenMessages = UserDefaults.standard.dictionary(
//            forKey: "last_read_messages_in_call_\(appointment.id)") as? [String : Int] ?? [:]
//
//        lastSeenMessages[String(thread.id)] = Int(thread.getLatestMessage()?.messageId ?? "0")!
//
//        UserDefaults.standard.set(lastSeenMessages, forKey: "last_read_messages_in_call_\(appointment.id)")
//    }
//
//    private func presentChatView() {
//        guard let thread = thread else {
//            return
//        }
//
//        markThreadRead(thread)
//        chatButton.setContent(icon: AssetProvider.asset(named: "callbutton-chat"))
//
//        let viewController = MessageThreadContainerViewController(
//            threadStub: thread,
//            presentationType: .modal(fromDeeplink: false),
//            hideCompleteButton: true)
//
//        viewController.delegate = self
//        viewingMessages = true
//
//        present(viewController, animated: true)
//    }
//
//    private func disconnect() {
//        self.loadingOverlay = self.presentLoadingIndicator()
//        //self.countdownTimer.stopTimer()
//        self.connector?.disconnect()
//    }
//
//    @objc private func didReceiveMessage(_ notification: Notification) {
//        guard let message = notification.userInfo?["message"] as? WebsocketMessageModel,
//              message.threadId == appointment.messageThreadId,
//              !viewingMessages else
//        {
//            return
//        }
//
//        updateUnreadThread()
//    }
//
//    @objc private func appWillResign() {
//        connector?.setCameraPrivacy(true)
//        connector?.setMode(.background)
//    }
//
//    @objc private func appDidBecomeActive() {
//        connector?.setMode(.foreground)
//        connector?.setCameraPrivacy(false)
//    }
//
//    private func dismiss(didEncounterError: Bool = false) {
//        dismiss(animated: true) {
//            if didEncounterError {
//                self.delegate?.didFailToConnect()
//            } else {
//                self.delegate?.didHangUp(appointment: self.appointment)
//            }
//        }
//    }
//
//    private func handle403Error(_ handler: @escaping () -> Void) {
//        handlerFor403 = handler
//        self.disconnect()
//    }
//}
//
//// MARK: MessageThreadContainerViewControllerDelegate
//
//extension VidyoCallViewController: MessageThreadContainerViewControllerDelegate {
//    func didClose() {
//        viewingMessages = false
//    }
//
//    func threadUpdated(_ thread: MessagingThread) {
//        markThreadRead(thread)
//    }
//
//    func didReceive403Error(handler: @escaping () -> Void) {
//        handle403Error(handler)
//    }
//}
//
//// MARK: OCVidyoConnectorDelegate
//
//extension VidyoCallViewController: OCVidyoConnectorDelegate {
//    func didConnect() {
//        loadingOverlay?.dismiss()
//        loadingOverlay = nil
//        endCallButton.setContent(icon: AssetProvider.asset(named: "callbutton-end"), isEnabled: true)
//    }
//
//    func didDisconnect() {
//        if let handler = handlerFor403 {
//            loadingOverlay?.dismiss { handler() } ?? handler()
//        } else {
//            loadingOverlay?.dismiss { self.dismiss() } ?? dismiss()
//        }
//    }
//
//    func didFail() {
//        loadingOverlay?.dismiss { self.dismiss(didEncounterError: true) } ?? self.dismiss(didEncounterError: true)
//    }
//}
//
//// MARK: VidyoQualitySettingsViewControllerDelegate
////
////extension VidyoCallViewController: VidyoQualitySettingsViewControllerDelegate {
////    func didUpdateVideoSettings(videoQuality: OCVidyoConnector.VideoQuality) {
////        connector?.setVideoQuality(videoQuality)
////    }
////}
//
//// MARK: TokenExpiryHandler
//
//extension VidyoCallViewController: TokenExpiryHandleable {
//    func didReceive403(handler: @escaping () -> Void) {
//        handle403Error(handler)
//    }
//}
