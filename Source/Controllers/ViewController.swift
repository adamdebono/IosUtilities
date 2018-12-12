import UIKit

open class ViewController: UIViewController,
    FontTraitEnvironment, UserInterfaceStyleTraitEnvironment {

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.updateFonts()
        self.updateUserInterfaceStyle()
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
}
