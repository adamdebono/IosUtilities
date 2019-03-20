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

    // MARK: - 3D Touch Previewing

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return nil
    }
}

extension CollectionViewCell: _CollectionViewCell {}
