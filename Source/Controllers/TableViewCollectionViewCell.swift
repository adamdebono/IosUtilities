import UIKit

open class TableViewCollectionViewCell<Model: TableViewCellModel, Layout: UICollectionViewLayout>: TableViewCell<Model>, CollectionViewModelDelegate {

    public let collectionView: CollectionView
    public let collectionViewLayout: UICollectionViewLayout

    public var enclosingViewController: UIViewController? {
        return self.viewController
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.collectionViewLayout = Layout()
        if let collectionViewLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .horizontal
        }

        self.collectionView = CollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.collectionView.backgroundColor = .clear
        self.collectionView.alwaysBounceVertical = false
        self.collectionView.canCancelContentTouches = true
        self.collectionView.clipsToBounds = false
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(self.collectionView)
        self.contentView.addConstraints([
            NSLayoutConstraint(item: self.contentView, attribute: .top, relatedBy: .equal, toItem: self.collectionView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.contentView, attribute: .leading, relatedBy: .equal, toItem: self.collectionView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.contentView, attribute: .trailing, relatedBy: .equal, toItem: self.collectionView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.contentView, attribute: .bottom, relatedBy: .equal, toItem: self.collectionView, attribute: .bottom, multiplier: 1, constant: 0),
            ])

        if #available(iOS 11.0, tvOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        // TODO
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()

        self.collectionViewLayout.invalidateLayout()
    }

    override open func updateFonts() {
        super.layoutSubviews()

        self.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Collection View

    // Sections

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        fatalError("This function must be overridden in a subclass")
    }

    // Cells

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
        self._cv(collectionView, didSelectItemAt: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self._cv(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
}
