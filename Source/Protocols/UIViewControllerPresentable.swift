import UIKit

public protocol UIViewControllerPresentable: class {
    var prefersModalPresentation: Bool { get }
    var preferredModalPresentationStyle: UIModalPresentationStyle { get }

    func viewControllerForModalPresentation() -> UIViewController
}

extension UIViewController {
    public func presentOrPush(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        let presentable = viewController as? UIViewControllerPresentable
        let navigationController = self as? UINavigationController ?? self.navigationController

        if let navigationController = navigationController, presentable?.prefersModalPresentation != true {
            navigationController.pushViewController(viewController, animated: animated)
        } else {
            let viewControllerToPresent = presentable?.viewControllerForModalPresentation() ?? viewController
            self.present(viewControllerToPresent, animated: animated, completion: completion)
        }
    }

    public func popOrDismiss(animated: Bool) {
        if (self is UINavigationController) {
            self.dismiss(animated: animated, completion: nil)
        } else if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: animated)
        } else {
            self.dismiss(animated: animated, completion: nil)
        }
    }
}
