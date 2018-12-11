import UIKit

open class TableViewCell: UITableViewCell, FontTraitEnvironment {

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

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
