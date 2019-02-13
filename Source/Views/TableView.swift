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

    public override var canBecomeFirstResponder: Bool {
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

    // MARK: - Focus

    public private(set) var focusedIndexPath: IndexPath?

    public func focus(indexPath: IndexPath?, animated: Bool) {
        if let focusedIndexPath = self.focusedIndexPath {
            if let cell = self.cellForRow(at: focusedIndexPath) as? _TableViewCell {
                cell.isFocusedCell = false
            }
        }

        if let indexPath = indexPath {
            if let cell = self.cellForRow(at: indexPath) as? _TableViewCell {
                cell.isFocusedCell = true
            }
            self.scrollToRow(at: indexPath, at: .none, animated: animated)
        }

        self.focusedIndexPath = indexPath
    }

    public func selectFocusedCell() {
        guard let focusedIndexPath = self.focusedIndexPath else { return }

        self.selectRow(at: focusedIndexPath, animated: false, scrollPosition: .none)
        self.delegate?.tableView?(self, didSelectRowAt: focusedIndexPath)
    }

    // MARK: Move Focus

    public func moveFocusTop() {
        var section = 0
        while self.numberOfRows(inSection: section) == 0 {
            section += 1

            if section >= self.numberOfSections {
                return
            }
        }

        let indexPath = IndexPath(row: 0, section: section)
        self.focus(indexPath: indexPath, animated: true)
    }

    public func moveFocusUp() {
        guard let indexPath = self.focusedIndexPath else {
            if let lastVisibleIndexPath = self.indexPathsForVisibleRows?.last {
                self.focus(indexPath: lastVisibleIndexPath, animated: true)
            }
            return
        }

        if indexPath.row-1 >= 0 {
            let newIndexPath = IndexPath(row: indexPath.row-1, section: indexPath.section)
            self.focus(indexPath: newIndexPath, animated: true)
        } else if indexPath.section-1 >= 0 {
            var section = indexPath.section - 1
            while self.numberOfRows(inSection: section) == 0 {
                section -= 1

                if section == 0 {
                    return
                }
            }

            let row = self.numberOfRows(inSection: section) - 1
            let newIndexPath = IndexPath(row: row, section: section)
            self.focus(indexPath: newIndexPath, animated: true)
        }
    }

    public func moveFocusDown() {
        guard let indexPath = self.focusedIndexPath else {
            if let firstVisibleIndexPath = self.indexPathsForVisibleRows?.first {
                self.focus(indexPath: firstVisibleIndexPath, animated: true)
            }
            return
        }

        if indexPath.row+1 < self.numberOfRows(inSection: indexPath.section) {
            let newIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
            self.focus(indexPath: newIndexPath, animated: true)
        } else if indexPath.section+1 < self.numberOfSections {
            var section = indexPath.section + 1
            while self.numberOfRows(inSection: section) == 0 {
                section += 1

                if section >= self.numberOfSections {
                    return
                }
            }

            let newIndexPath = IndexPath(row: 0, section: section)
            self.focus(indexPath: newIndexPath, animated: true)
        }
    }

    public func moveFocusBottom() {
        var section = self.numberOfSections - 1
        while self.numberOfRows(inSection: section) == 0 {
            section -= 1

            if section == 0 {
                return
            }
        }

        let row = self.numberOfRows(inSection: section) - 1

        let indexPath = IndexPath(row: row, section: section)
        self.focus(indexPath: indexPath, animated: true)
    }
}
