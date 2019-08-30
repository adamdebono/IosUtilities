import UIKit

public protocol TextTableHeaderViewExtensions {
    var extend_titleColor: UIColor { get }
}

open class TextTableHeaderView: TableHeaderFooterView {

    static var estimatedHeight: CGFloat {
        return UIFont.preferredFontSize(forTextStyle: .subheadline) + 28
    }

    public static let TableViewReuseIdentifier = "textHeader"

    public let titleLabel = UILabel()

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.titleLabel.textAlignment = .left
        self.titleLabel.numberOfLines = 0
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(self.titleLabel)
        self.setupConstraints()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setupConstraints() {
        self.contentView.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 20))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 20))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .trailing, relatedBy: .equal, toItem: self.titleLabel, attribute: .trailing, multiplier: 1, constant: 20))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .bottom, relatedBy: .equal, toItem: self.titleLabel, attribute: .bottom, multiplier: 1, constant: 8))
    }

    open override func updateFonts() {
        super.updateFonts()

        self.titleLabel.font = UIFont.preferred(forTextStyle: .subheadline)
    }

    open override func updateUserInterfaceStyle() {
        super.updateUserInterfaceStyle()

        self.titleLabel.textColor = (self as? TextTableHeaderViewExtensions)?.extend_titleColor ?? .darkGray
    }
}
