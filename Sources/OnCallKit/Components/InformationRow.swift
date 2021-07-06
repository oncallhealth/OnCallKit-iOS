//
//  InformationRow.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-06-26.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - InformationRow

class InformationRow: UIView {

    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)

        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }

        stackView.spacing = 5
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal
    
    func configure(_ textArray: [String]) {
        stackView.removeSubviews()

        for (index, text) in textArray.enumerated() {

            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 12)
            label.textColor = .subtitle

            stackView.addArrangedSubview(label)

            if index != textArray.count - 1 {
                let view = UILabel()
                view.text = "•"
                view.font = .systemFont(ofSize: 12)
                view.textColor = .subtitle

                stackView.addArrangedSubview(view)
            }
        }
    }

    // MARK: Private
    
    private let stackView = UIStackView()
}

// MARK: InformationRowCell

class InformationRowCell: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(infoRow)
        
        infoRow.snp.makeConstraints {
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
    
    static let reuseIdentifier = "InformationRow"
    
    func configure(_ textArray: [String]) {
        infoRow.configure(textArray)
    }
    
    // MARK: Private
    
    private let infoRow = InformationRow()
    
}
