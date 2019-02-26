
import UIKit

public protocol ScrollViewController: class {

    var mainView: UIView { get }
    var scrollView: UIScrollView { get }

    var usesFullWidth: Bool { get }
    var verticallyPadded: Bool { get }

    var scrollViewContentSize: CGSize { get }
    func updateContentInset()
    func additionalContentInset(forScrollView scrollView: UIScrollView) -> UIEdgeInsets
}

extension ScrollViewController {

    public func updateContentInset() {
        var additionalInset = self.additionalContentInset(forScrollView: self.scrollView)
        var indicatorInset = additionalInset

        if #available(iOS 11.0, tvOS 11.0, *) {
            let safeAreaInsets = self.mainView.safeAreaInsets
            indicatorInset.top += safeAreaInsets.top
            indicatorInset.left += safeAreaInsets.left
            indicatorInset.bottom += safeAreaInsets.bottom
            indicatorInset.right += safeAreaInsets.right
        }

        if self.verticallyPadded {
            let verticalOffset = (self.mainView.bounds.size.height - self.scrollViewContentSize.height) / 2
            if verticalOffset > 0 {
                additionalInset.top += verticalOffset
            }
        }

        if let extensionViewController = self as? ViewControllerExtensions {
            let extensionInsets = extensionViewController.extend_additionalContentInset(forScrollView: scrollView)

            additionalInset.top += extensionInsets.top
            additionalInset.left += extensionInsets.left
            additionalInset.bottom += extensionInsets.bottom
            additionalInset.right += extensionInsets.right
        }

        self.scrollView.contentInset = additionalInset
        self.scrollView.scrollIndicatorInsets = indicatorInset

        if let viewController = self as? ViewController, !viewController.viewHasAppeared {
            self.scrollView.scrollToTop(animated: false)
        }
    }
}

extension ScrollViewController where Self: UIViewController {
    public var mainView: UIView {
        return self.view
    }
}
