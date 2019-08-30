import UIKit

public protocol ActivityIndicatorControllerExtensions {
    func extend_createIndicator() -> UIView
}

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

        self.addConstraints(toIndicator: activityIndicator)
    }

    private weak var previousSuperview: UIView? = nil
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Fix view alignment on iOS 13
        if #available(iOS 13, *) {
            guard let view = self.view, let superview = view.superview else { return }

            if superview != self.previousSuperview {
                self.previousSuperview = superview

                if let constraint = superview.constraints.first(where: {
                    $0.firstItem as? UIView == view &&
                    $0.secondItem as? UIView == superview &&
                    $0.firstAttribute == .bottom &&
                    $0.secondAttribute == .bottom &&
                    $0.relation == .equal
                }) {
                    constraint.isActive = false
                }


                // superview.centerX == view.centerX
                superview.addConstraint(
                    NSLayoutConstraint(
                        item: superview,
                        attribute: .centerX,
                        relatedBy: .equal,
                        toItem: view,
                        attribute: .centerX,
                        multiplier: 1,
                        constant: -1
                    )
                )
                // superview.centerY == view.centerY
                superview.addConstraint(
                    NSLayoutConstraint(
                        item: superview,
                        attribute: .centerY,
                        relatedBy: .equal,
                        toItem: view,
                        attribute: .centerY,
                        multiplier: 1,
                        constant: -1
                    )
                )
            }
        }
    }

    // Attempt to remove the current constraint setting the width of the
    // view. Do this before adding the other constraints so we don't get a
    // conflict in constraints.
    private func removeContraints() {
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

        if let view = self.view {
            if let constraint = view.constraints.first(where: {
                $0.firstItem as? UIView == view &&
                $0.secondItem == nil &&
                $0.firstAttribute == .bottom &&
                $0.secondAttribute == .bottom &&
                $0.relation == .equal
            }) {
                constraint.isActive = false
            }
        }
    }

    open func createIndicator() -> UIView {
        if let extended = self as? ActivityIndicatorControllerExtensions {
            return extended.extend_createIndicator()
        }

        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .black
        indicator.startAnimating()
        return indicator
    }

    open func addConstraints(toIndicator activityIndicator: UIView) {
        guard let view = self.view else { return }

        // view.centerX == activityIndicator.centerX
        view.addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: activityIndicator,
                attribute: .centerX,
                multiplier: 1,
                constant: -1
            )
        )
        // view.centerY == activityIndicator.centerY
        view.addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: activityIndicator,
                attribute: .centerY,
                multiplier: 1,
                constant: -1
            )
        )

        // view.width == 80
        view.addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 80
            )
        )
        // view.height == 80
        view.addConstraint(
            NSLayoutConstraint(
                item: view,
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
