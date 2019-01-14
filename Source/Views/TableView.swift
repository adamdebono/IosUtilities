import UIKit

public class TableView: UITableView {

    public init(frame: CGRect, style: UITableView.Style, usesFullHeight: Bool) {
        self.usesFullHeight = usesFullHeight

        super.init(frame: frame, style: style)

        self.remembersLastFocusedIndexPath = true
    }

    public required init?(coder aDecoder: NSCoder) {
        // TODO
        fatalError("init(coder:) has not been implemented")
    }

    public override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }

    // MARK: - Layout

    public let usesFullHeight: Bool
    @available(iOS 11.0, tvOS 11.0, *)
    public override var adjustedContentInset: UIEdgeInsets {
        if self.usesFullHeight {
            return .zero
        } else {
            return super.adjustedContentInset
        }
    }
}
