import UIKit

public protocol TableViewCellModel {
    static var reuseIdentifier: String { get }
    var reuseIdentifier: String? { get }

    static var cellType: UITableViewCell.Type { get }
    static var estimatedHeight: CGFloat { get }

    var calculatedHeight: CGFloat? { get }

    func captureCell(_ cell: UITableViewCell)
    func tableViewController(_ viewController: TableViewController, estimatedHeightForIndexPath indexPath: IndexPath) -> CGFloat
    func tableViewController(_ viewController: TableViewController, selectionViewControllerForIndexPath indexPath: IndexPath) -> UIViewController?
    func tableViewController(_ viewController: TableViewController, performActionForIndexPath indexPath: IndexPath)
}
public extension TableViewCellModel {
    var tableReuseIdentifier: String {
        return self.reuseIdentifier ?? type(of: self).reuseIdentifier
    }

    func tableViewController(_ viewController: TableViewController, estimatedHeightForIndexPath indexPath: IndexPath) -> CGFloat { return type(of: self).estimatedHeight }
    func tableViewController(_ viewController: TableViewController, selectionViewControllerForIndexPath indexPath: IndexPath) -> UIViewController? { return nil }
    func tableViewController(_ viewController: TableViewController, performActionForIndexPath indexPath: IndexPath) {}
}

protocol _TableViewCell: class {
    var viewController: TableViewController? { get set }
    var _cell: UITableViewCell { get }

    #if !os(tvOS)
    var isFocusedCell: Bool { get set }
    #endif

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?
}
extension _TableViewCell where Self: UITableViewCell {
    var _cell: UITableViewCell {
        return self
    }
}

open class TableViewCell<Model: TableViewCellModel>: UITableViewCell,
    FontTraitEnvironment, UserInterfaceStyleTraitEnvironment {

    public internal(set) weak var viewController: TableViewController?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        #if !os(tvOS)
        self.setupFocusedCellView()
        #endif

        self.updateFonts()
        self.updateUserInterfaceStyle()

        #if os(tvOS)
        self.applyFocusState(animated: false)
        #endif
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        #if !os(tvOS)
        self.setupFocusedCellView()
        #endif

        self.updateFonts()
        self.updateUserInterfaceStyle()

        #if os(tvOS)
        self.applyFocusState(animated: false)
        #endif
    }

    @discardableResult
    open func addMinimumHeightConstraint(_ height: CGFloat = TableView.standardRowHeight) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self.contentView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        constraint.priority = UILayoutPriority(rawValue: 999)
        self.contentView.addConstraint(constraint)

        return constraint
    }

    // MARK: - Model

    public var model: Model? {
        didSet {
            if let model = self.model {
                self.updateFromModel(model)
            }
        }
    }

    open func updateFromModel(_ model: Model) {
        #if !os(tvOS)
        self.separatorInset = UIEdgeInsets(top: 0, left: self.separatorInset(for: model), bottom: 0, right: 0)
        #endif
    }

    open func separatorInset(for model: Model) -> CGFloat {
        return 0
    }

    // MARK: - Traits

    open func updateFonts() {}
    open func updateUserInterfaceStyle() {}

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.checkFontTraits(from: previousTraitCollection)
        if #available(iOS 12.0, *) {
            self.checkUserInterfaceStyleTraits(from: previousTraitCollection)
        }
    }

    // MARK: - Focus

    #if os(tvOS)

    public private(set) var focusState: FocusState = .normal {
        didSet {
            self.applyFocusState()
        }
    }

    open func applyFocusState(animated: Bool = true) {}

    open override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)

        if context.nextFocusedView == self {
            if self.focusState != .focused {
                if #available(tvOS 11.0, *) {
                    coordinator.addCoordinatedFocusingAnimations({ (context) in
                        self.focusState = .focused
                    }, completion: nil)
                } else {
                    coordinator.addCoordinatedAnimations({
                        self.focusState = .focused
                    }, completion: nil)
                }
            }
        } else if let nextFocusedView = context.nextFocusedView, nextFocusedView.isDescendant(of: self) {
            if self.focusState != .focused {
                if #available(tvOS 11.0, *) {
                    coordinator.addCoordinatedFocusingAnimations({ (context) in
                        self.focusState = .subviewFocused
                    }, completion: nil)
                } else {
                    coordinator.addCoordinatedAnimations({
                        self.focusState = .subviewFocused
                    }, completion: nil)
                }
            }
        } else {
            if self.focusState != .normal {
                if #available(tvOS 11.0, *) {
                    coordinator.addCoordinatedUnfocusingAnimations({ (context) in
                        self.focusState = .normal
                    }, completion: nil)
                } else {
                    coordinator.addCoordinatedAnimations({
                        self.focusState = .normal
                    }, completion: nil)
                }
            }
        }
    }

    open override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)

        guard let press = presses.first else { return }
        switch press.type {
        case .select:
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
                self.focusState = .pressed
            }, completion: nil)
        case .playPause:
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
                self.focusState = .playPressed
            }, completion: nil)
        default:
            break
        }
    }
    open override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)

        guard let press = presses.first else { return }
        switch press.type {
        case .select, .playPause:
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
                self.focusState = .focused
            }, completion: nil)
        default:
            break
        }
    }
    open override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesCancelled(presses, with: event)

        guard let press = presses.first else { return }
        switch press.type {
        case .select, .playPause:
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
                self.focusState = .focused
            }, completion: nil)
        default:
            break
        }
    }

    @available(tvOS 11.0, *)
    open override func soundIdentifierForFocusUpdate(in context: UIFocusUpdateContext) -> UIFocusSoundIdentifier? {
        guard context.nextFocusedView == self else { return nil }

        return .default
    }

    #else

    public private(set) var focusedCellView = UIView()
    open func setupFocusedCellView() {
        self.focusedCellView.alpha = 0
        self.focusedCellView.backgroundColor = .lightGray

        self.focusedCellView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.focusedCellView)
        self.sendSubviewToBack(self.focusedCellView)

        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.focusedCellView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.focusedCellView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.focusedCellView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.focusedCellView, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }

    public internal(set) var isFocusedCell: Bool = false {
        didSet {
            self.didChangeFocus()
        }
    }

    open func didChangeFocus() {
        if self.isFocusedCell {
            self.focusedCellView.alpha = 1
        } else {
            self.focusedCellView.alpha = 0
        }
    }

    #endif

    // MARK: - 3D Touch Previewing

    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return nil
    }
}

extension TableViewCell: _TableViewCell {}
