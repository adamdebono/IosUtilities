import UIKit

// MARK: - Popover

#if !os(tvOS)

extension UIViewController: UIPopoverPresentationControllerDelegate {

    public func presentPopover(_ viewController: UIViewController, from view: UIView) {
        self.presentPopover(viewController)

        if let popoverController = viewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = view.bounds
        }
    }

    public func presentPopover(_ viewController: UIViewController, from barButtonItem: UIBarButtonItem) {
        self.presentPopover(viewController)

        if let popoverController = viewController.popoverPresentationController {
            popoverController.barButtonItem = barButtonItem
        }
    }

    private func presentPopover(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .popover

        if let popoverController = viewController.popoverPresentationController {
            popoverController.delegate = viewController
            if let viewController = viewController as? ViewController {
                popoverController.permittedArrowDirections = viewController.popoverArrowDirections
            }
        }

        if let viewController = viewController as? ViewController {
            viewController.prepareForPopover()
        }

        self.present(viewController, animated: true, completion: nil)
    }

    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

#endif
