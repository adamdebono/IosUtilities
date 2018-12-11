import UIKit

open class ViewController: UIViewController, FontTraitEnvironment {

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.updateFonts()
    }

    // MARK: - Traits

    open func updateFonts() {}

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.checkFontTraits(from: previousTraitCollection)
    }
}
