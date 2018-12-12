import UIKit

open class ImageView: UIImageView,
    UserInterfaceStyleTraitEnvironment {

    public override init(image: UIImage?, highlightedImage: UIImage? = nil) {
        super.init(image: image, highlightedImage: highlightedImage)

        self.updateUserInterfaceStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.updateUserInterfaceStyle()
    }

    // MARK: - Traits

    open func updateUserInterfaceStyle() {}

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 12.0, *) {
            self.checkUserInterfaceStyleTraits(from: previousTraitCollection)
        }
    }
}
