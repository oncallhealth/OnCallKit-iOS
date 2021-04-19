import UIKit
import SnapKit

// MARK: - OCViewController

class OCViewController: UIViewController {
    
    // MARK: Lifecycle
    
    init(titleIcon: UIImage?,
         titleIconColour: UIColor = .primary,
         title: String,
         canTruncateTitle: Bool = true,
         titleButtons: [UIView]?,
         toggleValues: (left: String, right: String)? = nil,
         tabBarIcon: UIImage? = nil,
         //tabIdentifier: TabIdentifier? = nil,
         fullWidth: Bool = false)
    {
        self.titleIcon = titleIcon
        self.titleIconColour = titleIconColour
        self.titleButtons = titleButtons
        self.fullWidth = fullWidth
        
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem.image = tabBarIcon
        //tabBarItem.tag = tabIdentifier?.rawValue ?? -1
        
        view.backgroundColor = .background
        
        titleIconImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTitleIcon))
        titleIconImageView.isUserInteractionEnabled = true
        titleIconImageView.addGestureRecognizer(tapGesture)
        
        titleLabel.text = title
        
        if canTruncateTitle {
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.50
        }
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    let contentView = UIView()
    var leftPaddingConstraint: Constraint?
    var rightPaddingConstraint: Constraint?
    
    @objc func didTapTitleIcon(_ sender: Any?) {
        // Override me
    }
    
    func layout() {
        view.addSubview(titleStackView)
        titleStackView.spacing = 10
        
        if let titleIcon = self.titleIcon {
            titleIconImageView.image = titleIcon.withRenderingMode(.alwaysTemplate)
            titleIconImageView.contentMode = .scaleAspectFit
            titleIconImageView.tintColor = titleIconColour
            titleStackView.addArrangedSubview(titleIconImageView)
        }
        
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleStackView.addArrangedSubview(titleLabel)
        
        if let titleButtons = self.titleButtons {
            view.addSubview(titleButtonStackView)
            titleButtonStackView.snp.makeConstraints {
                $0.centerY.equalTo(titleStackView)
                $0.equalTo(safeAreaEdge: .trailing, of: self).offset(-10)
            }
            
            titleButtons.forEach { titleButtonStackView.addArrangedSubview($0) }
        }
        
        titleStackView.snp.makeConstraints {
            $0.equalTo(safeAreaEdge: .leading, of: self).offset(24)
            $0.equalTo(safeAreaEdge: .top, of: self).offset(24)
            if titleButtons == nil {
                $0.equalTo(safeAreaEdge: .trailing, of: self).offset(-24)
            } else {
                $0.trailing.equalTo(titleButtonStackView.snp.leading).offset(-24)
            }
        }
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.equalTo(safeAreaEdge: .bottom, of: self)
            leftPaddingConstraint = $0.equalTo(safeAreaEdge: .leading, of: self).offset(fullWidth ? 0 : 12).constraint
            rightPaddingConstraint = $0.equalTo(safeAreaEdge: .trailing, of: self).offset(fullWidth ? 0 : -12).constraint
        }
        
//        if let toggle = toggle {
//            view.addSubview(toggle)
//
//            toggle.snp.makeConstraints {
//                $0.width.equalTo(200)
//            }
//
//            contentView.snp.makeConstraints {
//                $0.top.equalTo(toggle.snp.bottom).offset(24)
//            }
//
//            if UIDevice.current.isIpad {
//                toggle.snp.makeConstraints {
//                    $0.centerX.equalToSuperview()
//                    $0.centerY.equalTo(titleStackView)
//                }
//            } else {
//                toggle.snp.makeConstraints {
//                    $0.leading.equalTo(titleStackView)
//                    $0.top.equalTo(titleStackView.snp.bottom).offset(20)
//                }
//            }
//        } else {
//            contentView.snp.makeConstraints {
//                $0.top.equalTo(titleStackView.snp.bottom)
//            }
//        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom)
        }
    }
    
    func showButtons(_ show: Bool) {
        titleButtonStackView.isHidden = !show
    }
    
    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
    
//    func setToggleDelegate(_ delegate: DualToggleSwitchDelegate) {
//        toggle?.delegate = delegate
//    }
    
    // MARK: Private
    
    private let titleIcon: UIImage?
    private let titleButtons: [UIView]?
    private let titleLabel = UILabel()
    private let titleIconImageView = UIImageView()
    private let titleIconColour: UIColor
    private let fullWidth: Bool
    private let titleStackView = UIStackView()
    private let titleButtonStackView = UIStackView()
    
    //private let toggle: DualToggleSwitchView?
    
}
