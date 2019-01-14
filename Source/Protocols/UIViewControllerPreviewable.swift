import UIKit

public protocol UIViewControllerPreviewable: class {
    var canBePreviewed: Bool { get }

    func prepareForPreviewing()
}
