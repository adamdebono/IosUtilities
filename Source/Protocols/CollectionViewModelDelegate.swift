import UIKit

public protocol CollectionViewModelDelegate: class, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionView: CollectionView { get }
    var collectionViewLayout: UICollectionViewLayout { get }

    var enclosingViewController: UIViewController? { get }

    func collectionView(_ collectionView: CollectionView, viewModelForItemAt indexPath: IndexPath) -> CollectionViewCellModel
}
public extension CollectionViewModelDelegate where Self: UIViewController {
    var enclosingViewController: UIViewController? {
        return self
    }
}

public extension CollectionViewModelDelegate {

    // MARK: - Collection View

    func registerCellModelTypes(_ modelTypes: [CollectionViewCellModel.Type]) {
        modelTypes.forEach { (modelType) in
            self.collectionView.register(modelType.cellType, forCellWithReuseIdentifier: modelType.reuseIdentifier)
        }
    }

    // MARK: - Protocol Methods

    func _cv(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionView = collectionView as? CollectionView ?? self.collectionView
        let model = self.collectionView(collectionView, viewModelForItemAt: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.collectionReuseIdentifier, for: indexPath)

        if let viewController = self as? CollectionViewController, let cell = cell as? _CollectionViewCell {
            cell.viewController = viewController
        }

        model.captureCell(cell)

        return cell
    }

    func _cv(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collectionView = collectionView as? CollectionView ?? self.collectionView
        let model = self.collectionView(collectionView, viewModelForItemAt: indexPath)
        if let parentViewController = self.enclosingViewController, let viewController = model.collectionView(collectionView, selectionViewControllerForIndexPath: indexPath) {
            parentViewController.presentOrPush(viewController, animated: true)
        } else {
            model.collectionView(collectionView, performActionForIndexPath: indexPath)
        }
    }

    func _cv(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionView = collectionView as? CollectionView ?? self.collectionView
        let model = self.collectionView(collectionView, viewModelForItemAt: indexPath)

        return model.calculateSize(inCollectionView: collectionView, layout: collectionViewLayout)
    }
}
