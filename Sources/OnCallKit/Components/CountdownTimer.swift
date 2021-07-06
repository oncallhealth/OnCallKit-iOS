//
//  CountdownTimer.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-09-08.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - CountdownTimer

class CountdownTimer: UIView {
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        let timeRemainingLabel = UILabel()
        
        addSubview(timeRemainingLabel)
        addSubview(countdownLabel)
        
        timeRemainingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(
                UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.height)
            
            $0.leading.equalToSuperview().offset(padding)
            $0.trailing.equalToSuperview().offset(-padding)
        }
        
        countdownLabel.snp.makeConstraints {
            $0.top.equalTo(timeRemainingLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(padding)
            $0.trailing.equalToSuperview().offset(-padding)
            $0.bottom.equalToSuperview().offset(-5)
        }
        
        timeRemainingLabel.text = "time_remaining".localized()
        
        timeRemainingLabel.textColor = .white
        countdownLabel.textColor = .white
        
        timeRemainingLabel.font = .systemFont(ofSize: 10)
        countdownLabel.font = .systemFont(ofSize: 18)
        
        timeRemainingLabel.textAlignment = .center
        countdownLabel.textAlignment = .center
        
        backgroundColor = UIColor.black.withAlphaComponent(0.50)
        clipsToBounds = true
        layer.cornerRadius = 30
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    private(set) var secondsRemaining: Int = 0 {
        didSet {
            updateCountdownLabel()
        }
    }
    
    func startTimer(secondsRemaining: Int) {
        self.secondsRemaining = secondsRemaining
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: Private
    
    private let countdownLabel = UILabel()
    private let padding = 30
    
    private var timer: Timer?
    
    private func updateCountdownLabel() {
        let minutes = secondsRemaining / 60 % 60
        let seconds = secondsRemaining % 60
        
        if minutes == 0 && seconds == 0 {
            timer?.invalidate()
            timer = nil
        }
        
        countdownLabel.text = String(format:"%02i:%02i", minutes, seconds)
    }
    
    @objc private func updateCounter() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
        }
    }
}
