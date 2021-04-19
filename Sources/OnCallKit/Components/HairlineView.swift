import UIKit

class HairlineView: UIView {
    init(color: UIColor = .customGray) {
        super.init(frame: .zero)
        backgroundColor = color
        self.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
