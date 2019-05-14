import UIKit

open class ScrollView: UIScrollView {
    open override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
}
