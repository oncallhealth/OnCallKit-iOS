//
//  BasicButton.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-05-14.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - BasicButton

class BasicButton: UIControl {
    
    // MARK: Style
    
    enum Style: Equatable {
        /// Width is only as wide as need to fit the content
        case small
        /// Width is extended to the width of the screen minus padding
        case primary(bolded: Bool, roundedCorners: Bool)
        /// Width is extended to the width of the screen minus padding but primary color is the border
        case secondary(bolded: Bool, roundedCorners: Bool)
        /// No border
        case tertiary(alignment: NSTextAlignment)
        
        // MARK: Fileprivate
        
        fileprivate var isTertiary: Bool {
            if case .tertiary = self {
                return true
            }
            
            return false
        }
        
        fileprivate var isSecondary: Bool {
            if case .secondary = self {
                return true
            }
            
            return false
        }
    }
    
    // MARK: LoadingState
    
    enum LoadingState {
        case loaded
        case error
    }
    
    // MARK: Lifecycle
    
    init(style: Style) {
        super.init(frame: .zero)
        
        addSubview(stackView)
    
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75

        stackView.spacing = 5
        stackView.isUserInteractionEnabled = false
        stackView.alignment = .center
        
        snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(38).priority(.high)
        }
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(label)
        
        if style == .small || style.isTertiary {
            stackView.snp.makeConstraints {
                $0.bottom.top.equalToSuperview()
                $0.leading.equalToSuperview().offset(10)
                $0.trailing.equalToSuperview().offset(-10)
            }
        } else {
            stackView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.lessThanOrEqualTo(snp.width)
            }
        }
        
        setStyle(style)
        
        addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        isAccessibilityElement = true
        accessibilityTraits = .button
        label.accessibilityTraits = .button
        iconImageView.accessibilityTraits = .button
        
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    override var isHighlighted: Bool {
        didSet {
            switch style {
            case .tertiary:
                label.textColor = isHighlighted ? primaryColor.darker() : primaryColor
            case .secondary:
                backgroundColor = isHighlighted ? UIColor.clear.darker() : .clear
            default:
                backgroundColor = isHighlighted ? primaryColor.darker() : primaryColor
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            switch style {
            case .secondary:
                let color = isEnabled ? UIColor.primaryWhite : .lightGray
                layer.borderColor = color.cgColor
                label.textColor = color
            case .tertiary:
                label.textColor = isEnabled ? primaryColor : .lightGray
            case .primary, .small:
                backgroundColor = isEnabled ? primaryColor : .lightGray
            }
        }
    }
    
    func configure(
        text: String?,
        fontSize: CGFloat = 14,
        loadingState: LoadingState = .loaded,
        backgroundColor: UIColor = .primary,
        textColor: UIColor = .white,
        iconName: String? = nil,
        isEnabled: Bool = true)
    {
        if let image = iconName?.iconTemplate() {
            iconImageView.snp.makeConstraints {
                $0.height.width.equalTo(15)
            }
            
            iconImageView.image = image
            iconImageView.isHidden = false
            iconImageView.tintColor = style.isTertiary ? .primary : textColor
        } else {
            iconImageView.isHidden = true
            iconImageView.image = nil
            iconImageView.snp.removeConstraints()
        }
        
        switch loadingState {
        case .loaded:
            label.layer.opacity = 1
            iconImageView.layer.opacity = 1
            primaryColor = backgroundColor
        case .error:
            primaryColor = .error
        }
        
        switch style {
        case .secondary, .tertiary:
            label.textColor = primaryColor
        default:
            label.textColor = textColor
        }
        
        if let text = text {
            label.text = text
            label.isHidden = false
            configureAccessibilityLabel(label: text)
        } else {
            label.isHidden = true
        }
        
        if case .primary(let bolded, let roundedCorners) = style {
            applyBoldAndCornerRadius(bolded: bolded, roundedCorners: roundedCorners, fontSize: fontSize)
        } else if case .secondary(let bolded, let roundedCorners) = style {
            applyBoldAndCornerRadius(bolded: bolded, roundedCorners: roundedCorners, fontSize: fontSize)
        } else if case .tertiary = style {
            applyBoldAndCornerRadius(bolded: true, roundedCorners: false, fontSize: fontSize)
        } else {
            applyBoldAndCornerRadius(bolded: false, roundedCorners: true, fontSize: fontSize)
        }
        
        if traitCollection.userInterfaceStyle == .dark, !style.isTertiary, primaryColor != .clear {
            layer.borderWidth = 1
            layer.borderColor = UIColor.white.cgColor
        } else {
            layer.borderWidth = style.isSecondary ? 2 : 0
            layer.borderColor = style.isSecondary ? UIColor.primaryWhite.cgColor : nil
        }
        
        self.isEnabled = isEnabled
    }
    
    func setInteraction(didTap: @escaping () -> Void) {
        self.didTap = didTap
    }
    
    func configureAccessibilityLabel(label: String, hint: String? = nil) {
        accessibilityLabel = label
        accessibilityHint = hint
    }
    
    // MARK: Private
    
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    private let label = UILabel()
    
    private var style: BasicButton.Style = .small
    private var primaryColor: UIColor = .primary
    
    private var didTap: (() -> Void)? = nil
    
    private func setStyle(_ style: BasicButton.Style) {
        self.style = style
        
        if case .tertiary(let alignment) = style {
            label.font = .boldSystemFont(ofSize: 14.0)
            label.textAlignment = alignment
        } else {
            label.textAlignment = .center
            
            if case .primary(let bolded, let roundedCorners) = style {
                applyBoldAndCornerRadius(bolded: bolded, roundedCorners: roundedCorners)
            } else if case .secondary(let bolded, let roundedCorners) = style {
                applyBoldAndCornerRadius(bolded: bolded, roundedCorners: roundedCorners)
            }
        }
        
        stackView.layoutMargins = style == .small ? UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) : .zero
        
        switch style {
        case .secondary:
            backgroundColor = isEnabled ? .clear : .lightGray
        case .tertiary:
            backgroundColor = .clear
        default:
            backgroundColor = isEnabled ? primaryColor : .lightGray
        }
    }
    
    private func applyBoldAndCornerRadius(bolded: Bool, roundedCorners: Bool, fontSize: CGFloat = 14) {
        label.font = bolded ? .boldSystemFont(ofSize: fontSize) : .systemFont(ofSize: fontSize)
        layer.cornerRadius = roundedCorners ? 8 : 0
    }
    
    @objc private func didTapAction() {
        didTap?()
    }
}

// MARK: - BasicButtonCell

class BasicButtonCell: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(basicButton)
        
        basicButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(-5)
        }
        
        selectionStyle = .none
        backgroundColor = .background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "BasicButtonCell"
    
    func configure(
        text: String?,
        fontSize: CGFloat = 14,
        loadingState: BasicButton.LoadingState = .loaded,
        backgroundColor: UIColor = .primary,
        textColor: UIColor = .white,
        iconName: String? = nil,
        isEnabled: Bool = true)
    {
        basicButton.configure(
            text: text,
            fontSize: fontSize,
            loadingState: loadingState,
            backgroundColor: backgroundColor,
            textColor: textColor,
            iconName: iconName,
            isEnabled: isEnabled)
    }
    
    func setInteraction(didTap: @escaping () -> Void) {
        basicButton.setInteraction(didTap: didTap)
    }
    
    // MARK: Private
    
    private let basicButton = BasicButton(style: .primary(bolded: false, roundedCorners: true))
    
}
