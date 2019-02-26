import UIKit

open class StackViewController: ViewController, ScrollViewController {

    public let scrollView = UIScrollView()
    public let stackView = StackView()

    public let usesFullWidth: Bool
    public let verticallyPadded: Bool

    public init(usesFullWidth: Bool = false, verticallyPadded: Bool = false) {
        self.usesFullWidth = usesFullWidth
        self.verticallyPadded = verticallyPadded

        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        // TODO
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override open func loadView() {
        super.loadView()

        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.scrollView)

        self.view.addConstraints([
            NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.scrollView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: self.scrollView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: self.scrollView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.scrollView, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.alwaysBounceVertical = true

        self.stackView.isUserInteractionEnabled = true
        self.stackView.axis = .vertical
        self.stackView.alignment = .fill
        self.stackView.distribution = .equalSpacing
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        self.scrollView.addSubview(self.stackView)
        self.setupStackViewConstraints()
    }

    open func setupStackViewConstraints() {
        self.scrollView.addConstraints([
            NSLayoutConstraint(item: self.scrollView, attribute: .top, relatedBy: .equal, toItem: self.stackView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.scrollView, attribute: .leading, relatedBy: .equal, toItem: self.stackView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.scrollView, attribute: .trailing, relatedBy: .equal, toItem: self.stackView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.scrollView, attribute: .bottom, relatedBy: .equal, toItem: self.stackView, attribute: .bottom, multiplier: 1, constant: 0),
        ])

        self.scrollView.addConstraint(NSLayoutConstraint(item: self.scrollView, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1, constant: 0))
    }

    public var scrollViewContentSize: CGSize {
        return self.stackView.bounds.size
    }

    // MARK: - Stack

    open func appendToStack(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }

    open func appendSpacer(ofSize size: CGFloat) {
        let spacer = StackSpacerView(size: size)
        self.appendToStack(spacer)
    }
}

private class StackSpacerView: View {
    init(size: CGFloat) {
        super.init()

        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
