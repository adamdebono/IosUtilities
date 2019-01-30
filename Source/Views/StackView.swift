import UIKit

open class StackView: UIStackView {
    override public init(frame: CGRect) {
        super.init(frame: .zero)

        self.isUserInteractionEnabled = false
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
