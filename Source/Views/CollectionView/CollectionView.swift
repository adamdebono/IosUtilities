import UIKit

open class CollectionView: UICollectionView {

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        self.remembersLastFocusedIndexPath = true
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
}
