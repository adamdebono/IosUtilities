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

    var isFocusedCell: Bool { get set }

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

        self.setupFocusedCellView()
        self.updateFonts()
        self.updateUserInterfaceStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupFocusedCellView()
        self.updateFonts()
        self.updateUserInterfaceStyle()
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

    public private(set) var focusedCellView = UIView()
    open func setupFocusedCellView() {
        self.focusedCellView.alpha = 0
        self.focusedCellView.layer.borderColor = UIColor.black.cgColor
        self.focusedCellView.layer.borderWidth = 2

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

    // MARK: - 3D Touch Previewing

    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return nil
    }
}

extension TableViewCell: _TableViewCell {}
