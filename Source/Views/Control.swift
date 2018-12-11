import UIKit

open class Control: UIControl, FontTraitEnvironment {

    public override init(frame: CGRect) {
        super.init(frame: frame)

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
