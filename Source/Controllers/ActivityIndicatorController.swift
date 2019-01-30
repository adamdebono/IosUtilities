import UIKit

open class ActivityIndicatorController: UIAlertController {

    open override var preferredStyle: UIAlertController.Style {
        return .alert
    }

    public init() {
        super.init(nibName: nil, bundle: nil)

        self.title = ""
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - View Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.removeContraints()

        let activityIndicator = self.createIndicator()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()

        self.addConstraints(toIndicator: activityIndicator)
    }

    private func removeContraints() {
        // Attempt to remove the current constraint setting the width of the
        // view. Do this before adding the other constraints so we don't get a
        // conflict in constraints.
        if let subView = self.view.subviews.first {
            if let constraint = subView.constraints.first(where: {
                $0.firstItem as? UIView == subView &&
                    $0.secondItem == nil &&
                    $0.firstAttribute == .width &&
                    $0.secondAttribute == .notAnAttribute &&
                    $0.relation == .equal
            }) {
                constraint.isActive = false
            }
        }
    }

    open func createIndicator() -> UIView {
        let indicator = TintedActivityIndicator(style: .whiteLarge)
        indicator.startAnimating()
        return indicator
    }

    open func addConstraints(toIndicator activityIndicator: UIView) {
        // view.centerX == activityIndicator.centerX
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.view,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: activityIndicator,
                attribute: .centerX,
                multiplier: 1,
                constant: -1
            )
        )
        // view.centerY == activityIndicator.centerY
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.view,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: activityIndicator,
                attribute: .centerY,
                multiplier: 1,
                constant: -1
            )
        )

        // view.width == 80
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.view,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 80
            )
        )
        // view.height == 80
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.view,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 80
            )
        )
    }
}

private class TintedActivityIndicator: UIActivityIndicatorView {
    override func tintColorDidChange() {
        super.tintColorDidChange()

        self.color = self.tintColor
    }
}
