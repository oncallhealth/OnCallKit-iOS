import UIKit
import SnapKit

// MARK: - OCViewControllerDelegate

protocol OCViewControllerDelegate: AnyObject {
    func didSelectToggleIndex(_ index: Int)
}

// MARK: - OCViewController

class OCViewController: UIViewController {
    
    // MARK: Lifecycle
    
    init(titleIcon: UIImage? = nil,
         titleIconColour: UIColor = .primary,
         title: String,
         canTruncateTitle: Bool = true,
         titleButtons: [UIView]? = nil,
         toggleValues: [String]? = nil,
         tabBarIcon: UIImage? = nil,
         //tabIdentifier: TabIdentifier? = nil,
         fullWidth: Bool = false)
    {
        self.titleIcon = titleIcon
        self.titleIconColour = titleIconColour
        self.titleButtons = titleButtons
        self.fullWidth = fullWidth
        
        if let toggleValues = toggleValues {
            //self.toggle = MaterialTabBar(alignment: UIDevice.current.isIpad ? .center : .leading)
            //self.toggle?.configure(options: toggleValues, capitalized: false)
            self.toggle = nil
        } else {
            self.toggle = nil
        }
        
        super.init(nibName: nil, bundle: nil)
        
//        self.toggle?.setInteraction { [weak self] selectedIndex in
//            self?.ocViewControllerDelegate?.didSelectToggleIndex(selectedIndex)
//        }
        
        tabBarItem.image = tabBarIcon
        //tabBarItem.tag = tabIdentifier?.rawValue ?? -1
        
        view.backgroundColor = .background
        
        titleIconImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTitleIcon))
        titleIconImageView.isUserInteractionEnabled = true
        titleIconImageView.addGestureRecognizer(tapGesture)
        
        titleIconImageView.isAccessibilityElement = true
        titleIconImageView.accessibilityLabel = "Go back"
        titleIconImageView.accessibilityHint = "Tap to go back"
        titleIconImageView.accessibilityTraits = .button
        
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
    
    weak var ocViewControllerDelegate: OCViewControllerDelegate? = nil
    
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
            
            titleButtons.forEach {
                titleButtonStackView.addArrangedSubview($0)
                $0.isAccessibilityElement = false
            }
            
            titleStackView.snp.makeConstraints {
                $0.trailing.equalTo(titleButtonStackView.snp.leading).offset(-10)
            }
        } else {
            titleStackView.snp.makeConstraints {
                $0.equalTo(safeAreaEdge: .trailing, of: self).offset(-10)
            }
        }
        
        titleStackView.snp.makeConstraints {
            $0.equalTo(safeAreaEdge: .leading, of: self).offset(24)
            $0.equalTo(safeAreaEdge: .top, of: self).offset(24)
        }
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.equalTo(safeAreaEdge: .bottom, of: self)
            leftPaddingConstraint = $0.equalTo(safeAreaEdge: .leading, of: self).offset(fullWidth ? 0 : 12).constraint
            rightPaddingConstraint = $0.equalTo(safeAreaEdge: .trailing, of: self).offset(fullWidth ? 0 : -12).constraint
        }
        
        if let toggle = toggle {
            view.addSubview(toggle)
            
            contentView.snp.makeConstraints {
                $0.top.equalTo(toggle.snp.bottom).offset(24)
            }
            
            toggle.snp.makeConstraints {
                if UIDevice.current.isIpad {
                    $0.centerY.equalTo(titleStackView)
                    $0.centerX.equalToSuperview()
                    $0.width.equalTo(500)
                } else {
                    $0.top.equalTo(titleStackView.snp.bottom).offset(20)
                    $0.leading.trailing.equalToSuperview()
                }
            }
        } else {
            contentView.snp.makeConstraints {
                $0.top.equalTo(titleStackView.snp.bottom)
            }
        }
    }
    
    func showButtons(_ show: Bool) {
        titleButtonStackView.isHidden = !show
    }
    
    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
    
    // MARK: Private
    
    private let titleIcon: UIImage?
    private let titleButtons: [UIView]?
    private let titleLabel = UILabel()
    private let titleIconImageView = UIImageView()
    private let titleIconColour: UIColor
    private let fullWidth: Bool
    private let titleStackView = UIStackView()
    private let titleButtonStackView = UIStackView()
    
    private let toggle: UIView?
    //private let toggle: MaterialTabBar?
    
}
