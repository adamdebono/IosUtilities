import UIKit

extension UIScrollView {
    public func scrollToTop(animated: Bool) {
        let offset = CGPoint(
            x: 0,
            y: -self.contentInset.top
        )

        self.setContentOffset(offset, animated: animated)
    }
}
