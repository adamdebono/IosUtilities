import UIKit

open class TableHeaderFooterView: UITableViewHeaderFooterView,
    FontTraitEnvironment, UserInterfaceStyleTraitEnvironment {

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

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

    // MARK: -

    open func willDisplay(inTableView tableView: UITableView, usesFullWidth: Bool) {}
}
