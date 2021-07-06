import UIKit

// MARK: - HairlineView

class HairlineView: UIView {
    
    // MARK: Lifecycle
    
    init(color: UIColor = .customGray) {
        super.init(frame: .zero)
        
        backgroundColor = color
        
        snp.makeConstraints {
            $0.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - HairlineCell

class HairlineCell: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let hairline = HairlineView()
        let containerView = UIView()
        
        containerView.addSubview(hairline)
        contentView.addSubview(containerView)
        
        hairline.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        selectionStyle = .none
        backgroundColor = .background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "HairlineCell"
    
}
