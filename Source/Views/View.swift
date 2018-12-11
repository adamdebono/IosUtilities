import UIKit

open class View: UIView, FontTraitEnvironment {

    public init() {
        super.init(frame: .zero)

        self.updateFonts()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.updateFonts()
    }

    // MARK: - Traits

    open func updateFonts() {}

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.checkFontTraits(from: previousTraitCollection)
    }
}
