import UIKit

public enum FocusState {
    case normal
    case focused
    case subviewFocused
    case pressed
    case playPressed
}

open class Control: UIControl,
    FontTraitEnvironment, UserInterfaceStyleTraitEnvironment {

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
