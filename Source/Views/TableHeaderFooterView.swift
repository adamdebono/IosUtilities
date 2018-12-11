import UIKit

open class TableHeaderFooterView: UITableViewHeaderFooterView, FontTraitEnvironment {

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

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
