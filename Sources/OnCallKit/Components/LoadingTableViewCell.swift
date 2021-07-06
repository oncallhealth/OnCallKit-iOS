import UIKit

// MARK: - LoadingTableViewCell

class LoadingTableViewCell: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(indicator)
        
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        indicator.startAnimating()
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "LoadingTableViewCell"
    
    // MARK: Private
    
    private let indicator = UIActivityIndicatorView(indicatorStyle: .small)
    
}
