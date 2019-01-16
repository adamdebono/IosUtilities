import UIKit

open class CollectionViewController: ViewController, CollectionViewModelDelegate {

    public let collectionView: CollectionView
    public let collectionViewLayout: UICollectionViewLayout

    public init(layout collectionViewLayout: UICollectionViewLayout) {
        self.collectionViewLayout = collectionViewLayout
        self.collectionView = CollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

        super.init(nibName: nil, bundle: nil)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        // TODO
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    open override func loadView() {
        super.loadView()

        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)

        self.view.addConstraints([
            NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.collectionView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: self.collectionView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: self.collectionView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.collectionView, attribute: .bottom, multiplier: 1, constant: 0),
            ])
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.alwaysBounceVertical = true
        self.collectionView.canCancelContentTouches = true
    }

    // MARK: - Traits

    override open func updateFonts() {
        super.updateFonts()

        self.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Collection View

    // MARK: Sections

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        fatalError("This function must be overridden in a subclass")
    }

    // MARK: Cells

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("This function must be overridden in a subclass")
    }

    open func collectionView(_ collectionView: CollectionView, viewModelForItemAt indexPath: IndexPath) -> CollectionViewCellModel {
        fatalError("This function must be overridden in a subclass")
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self._cv(collectionView, cellForItemAt: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        return self._cv(collectionView, didSelectItemAt: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self._cv(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }

    // MARK: - 3D Touch Previewing

    open override func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let position = self.collectionView.convert(location, from: self.view)
        guard let indexPath = self.collectionView.indexPathForItem(at: position) else { return nil }
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? _CollectionViewCell else { return nil }

        previewingContext.sourceRect = self.view.convert(cell._cell.frame, from: cell._cell.superview)

        guard let previewingViewController = cell.previewingContext(previewingContext, viewControllerForLocation: location) else { return nil }
        guard let previewable = previewingViewController as? UIViewControllerPreviewable else { return nil }
        guard previewable.canBePreviewed else { return nil }
        previewable.prepareForPreviewing()

        return previewingViewController
    }
}
