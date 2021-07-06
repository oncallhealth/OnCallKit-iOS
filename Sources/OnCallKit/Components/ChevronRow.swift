//
//  ChevronRow.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-06-17.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - ChevronRow

class ChevronRow: UIControl {

    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)

        addSubview(label)
        addSubview(indicatorImageView)

        indicatorImageView.snp.makeConstraints {
            $0.height.width.equalTo(10)
            $0.leading.equalTo(label.snp.trailing).offset(5)
            $0.centerY.equalTo(label.snp.centerY)
        }

        label.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }

        label.font = .boldSystemFont(ofSize: 14)

        indicatorImageView.contentMode = .scaleAspectFit
        indicatorImageView.image = "ic-chevron-right-bold".iconTemplate()

        shouldHighlight(false)

        addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override var isHighlighted: Bool {
        didSet {
            shouldHighlight(isHighlighted)
        }
    }

    func configure(text: String, hideChevron: Bool = false, didTap: @escaping () -> Void) {
        indicatorImageView.isHidden = hideChevron

        label.text = text
        label.sizeToFit()

        self.hideChevron = hideChevron
        self.didTap = didTap

        shouldHighlight(false)
    }
    
    func configureAccessibilityLabel(label: String, hint: String? = nil) {
        self.accessibilityLabel = label
        self.accessibilityHint = hint
    }

    // MARK: Private
    
    private let indicatorImageView = UIImageView()
    private let label = UILabel()
    private var hideChevron: Bool = false
    private var didTap: (() -> Void)? = nil

    private func shouldHighlight(_ highlight: Bool) {
        let color: UIColor = hideChevron ? .labelText : .primaryWhite

        indicatorImageView.tintColor = highlight ? color.darker() : color
        label.textColor = highlight ? color.darker() : color
    }

    @objc private func didTapAction() {
        didTap?()
    }
}
