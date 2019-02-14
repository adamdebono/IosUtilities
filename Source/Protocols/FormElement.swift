import UIKit

public protocol FormElement {
    var view: UIView { get }

    func didMoveToForm(_ formViewController: FormViewController)
}

public extension FormElement where Self: UIView {
    var view: UIView { return self }
}
