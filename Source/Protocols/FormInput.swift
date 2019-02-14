import UIKit

public protocol FormInput: class, FormElement {
    /// This property should be weak
    var inputDelegate: FormInputDelegate? { get set }

    func becomeActive()
    func resignActive()
    var returnKeyType: UIReturnKeyType { get set }
}

public protocol FormInputDelegate: class {
    func inputDidBecomeActive(_ input: FormInput)
    func inputDidReturn(_ input: FormInput)
}
