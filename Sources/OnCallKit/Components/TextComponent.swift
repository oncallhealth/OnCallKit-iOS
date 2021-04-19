//
//  TextComponent.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-05-29.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - TextComponent

class TextComponent: UIView {
    
    // MARK: TextType
    
    enum TextType {
        case normal(bolded: Bool)
        case subtitle(bolded: Bool)
    }

    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)

        addSubview(label)

        label.lineBreakMode = .byWordWrapping

        translatesAutoresizingMaskIntoConstraints = false
        
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal
    
    func configure(
        text: String?,
        textColor: UIColor? = nil,
        alignment: NSTextAlignment = .left,
        numberOfLines: Int = 0,
        type: TextType = .normal(bolded: false),
        fontSize: CGFloat = 14)
    {
        label.text = text
        label.numberOfLines = numberOfLines
        
        if numberOfLines == 0 {
            label.lineBreakMode = .byWordWrapping
        } else {
            label.lineBreakMode = .byTruncatingTail
        }
        
        setLabelAttributes(fontSize: fontSize, alignment: alignment, type: type, textColor: textColor)
    }

    func configure(
        attributedText: NSAttributedString?,
        textColor: UIColor? = nil,
        alignment: NSTextAlignment = .left,
        type: TextType = .normal(bolded: false),
        fontSize: CGFloat = 14)
    {
        label.attributedText = attributedText
        setLabelAttributes(fontSize: fontSize, alignment: alignment, type: type, textColor: textColor)
    }

    // MARK: Private
    
    private func setLabelAttributes(fontSize: CGFloat, alignment: NSTextAlignment, type: TextType, textColor: UIColor?) {
        switch type {
        case .normal(let bolded):
            label.font = bolded ? .boldSystemFont(ofSize: fontSize) : .systemFont(ofSize: fontSize)
            label.textColor = textColor ?? .labelText
        case .subtitle(let bolded):
            label.font = bolded ? .boldSystemFont(ofSize: fontSize) : .systemFont(ofSize: fontSize)
            label.textColor = textColor ?? .subtitle
        }
        
        label.textAlignment = alignment
    }
    
    private let label = UILabel()

}
