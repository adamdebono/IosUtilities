import UIKit

open class FormViewController: StackViewController, FormInputDelegate {

    // MARK: -

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.alwaysBounceVertical = false
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.prepareInputs()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.activeInput = nil
    }

    // MARK: - Other Elements

    open func appendElement(_ element: FormElement) {
        self.appendToStack(element.view)

        element.didMoveToForm(self)
    }

    open func presentFormError(_ message: String) {
        let alertController = UIAlertController(title: self.navigationItem.title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Inputs

    public private(set) var inputs: [FormInput] = []

    public var activeInput: FormInput? {
        didSet {
            guard oldValue !== self.activeInput else { return }

            if let newValue = self.activeInput {
                newValue.becomeActive()
            } else if let oldValue = oldValue {
                oldValue.resignActive()
            }
        }
    }

    open func appendInput(_ input: FormInput) {
        self.inputs.append(input)
        self.appendElement(input)
    }

    open func prepareInputs() {
        self.inputs.enumerated().forEach { (arg0) in
            let (i, input) = arg0

            input.inputDelegate = self
            if i == self.inputs.count - 1 {
                input.returnKeyType = .go
            } else {
                input.returnKeyType = .next
            }
        }
    }

    @objc
    public func submitActionOccured(sender: Any) {
        self.validateAndSubmit()
    }

    // MARK: - Form Input Delegate

    open func inputDidBecomeActive(_ input: FormInput) {
        self.activeInput = input
    }

    open func inputDidReturn(_ input: FormInput) {
        guard let index = self.inputs.firstIndex(where: { $0 === input }) else { return }

        #if os(tvOS)
        if index == self.inputs.count - 1 {
            DispatchQueue.main.async {
                self.validateAndSubmit()
            }
        }
        #else
        if index == self.inputs.count - 1 {
            self.validateAndSubmit()
        } else {
            let nextElement = self.inputs[index+1]
            self.activeInput = nextElement
        }
        #endif
    }

    // MARK: - Submission

    open func validateAndSubmit() {
        if let validationError = self.validateForm() {
            self.presentFormError(validationError)
        } else {
            self.activeInput = nil
            self.submitForm()
        }
    }

    open func validateForm() -> String? { return nil }
    open func submitForm() {}
}
