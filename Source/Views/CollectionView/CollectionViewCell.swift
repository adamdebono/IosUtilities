import UIKit

public protocol CollectionViewCellModel {
    static var reuseIdentifier: String { get }
    var reuseIdentifier: String? { get }

    static var cellType: UICollectionViewCell.Type { get }

    func captureCell(_ cell: UICollectionViewCell)
    func calculateSize(inCollectionView collectionView: CollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGSize

    func collectionView(_ collectionView: CollectionView, performActionForIndexPath indexPath: IndexPath)
    func collectionView(_ collectionView: CollectionView, selectionViewControllerForIndexPath indexPath: IndexPath) -> UIViewController?
}

public extension CollectionViewCellModel {
    var collectionReuseIdentifier: String {
        return self.reuseIdentifier ?? type(of: self).reuseIdentifier
    }

    func collectionView(_ collectionView: CollectionView, performActionForIndexPath indexPath: IndexPath) {}
    func collectionView(_ collectionView: CollectionView, selectionViewControllerForIndexPath indexPath: IndexPath) -> UIViewController? {
        return nil
    }
}

protocol _CollectionViewCell: class {
    var viewController: CollectionViewController? { get set }
    var _cell: UICollectionViewCell { get }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?
}
extension _CollectionViewCell where Self: UICollectionViewCell {
    var _cell: UICollectionViewCell {
        return self
    }
}

open class CollectionViewCell<Model: CollectionViewCellModel>: UICollectionViewCell,
    FontTraitEnvironment, UserInterfaceStyleTraitEnvironment {

    public internal(set) weak var viewController: CollectionViewController?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.updateFonts()
        self.updateUserInterfaceStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

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
    open func updateFromModel(_ model: Model) {}

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

    #endif

    // MARK: - 3D Touch Previewing

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return nil
    }
}

extension CollectionViewCell: _CollectionViewCell {}
