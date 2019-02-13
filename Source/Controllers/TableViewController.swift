import UIKit

private let ContentSizeKeyPath = "contentSize"

open class TableViewController: ViewController,
    UITableViewDataSource, UITableViewDelegate {

    public let tableView: TableView

    public let usesFullHeight: Bool

    public init(style: UITableView.Style = .plain, usesFullHeight: Bool = false) {
        self.usesFullHeight = usesFullHeight
        self.tableView = TableView(frame: .zero, style: style, usesFullHeight: usesFullHeight)

        super.init(nibName: nil, bundle: nil)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.addObserver(self, forKeyPath: ContentSizeKeyPath, options: [.new], context: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        // TODO
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.tableView.removeObserver(self, forKeyPath: ContentSizeKeyPath)
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == ContentSizeKeyPath {
            self.timePreferredContentSize()
        }
    }

    // MARK: - View Lifecycle

    open override func loadView() {
        super.loadView()

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)

        self.view.addConstraints([
            NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.tableView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: self.tableView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: self.tableView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.tableView, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = self.tableView.indexPathForSelectedRow, let transitionCoordinator = self.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { (context) in
                self.tableView.deselectRow(at: selectedIndexPath, animated: true)
            }) { (context) in
                if context.isCancelled {
                    self.tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
                }
            }
        }

        self.updatePreferredContentSize()
    }

    #if !os(tvOS)
    open override func prepareForPopover() {
        super.prepareForPopover()

        self.tableView.backgroundColor = .clear
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .prominent))
    }
    #endif

    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)

        if viewControllerToPresent.modalPresentationStyle == .formSheet || viewControllerToPresent.modalPresentationStyle == .pageSheet, let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    // MARK: - Layout

    private var preferredContentSizeTimer: Timer? = nil
    private func timePreferredContentSize() {
        if let preferredContentSizeTimer = self.preferredContentSizeTimer {
            preferredContentSizeTimer.invalidate()
        }

        self.preferredContentSizeTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.updatePreferredContentSize()
            self.preferredContentSizeTimer = nil
        })
    }

    public func updatePreferredContentSize() {
        self.preferredContentSize = self.calculatePreferredContentSize()
    }
    open func calculatePreferredContentSize() -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        let contentSize = self.tableView.contentSize
        return CGSize(
            width: min(screenSize.width, max(320, contentSize.width)),
            height: min(screenSize.height, min(44, contentSize.height))
        )
    }

    // MARK: - Table View

    public func registerCellModelTypes(_ modelTypes: [TableViewCellModel.Type]) {
        modelTypes.forEach { (modelType) in
            self.tableView.register(modelType.cellType, forCellReuseIdentifier: modelType.reuseIdentifier)
        }
    }

    // MARK: Sections

    open func numberOfSections(in tableView: UITableView) -> Int {
        fatalError("This function must be overridden in a subclass")
    }

    // MARK: Cells

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("This function must be overridden in a subclass")
    }

    open func tableView(_ tableView: UITableView, viewModelForRowAt indexPath: IndexPath) -> TableViewCellModel {
        fatalError("This function must be overridden in a subclass")
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.tableView(tableView, viewModelForRowAt: indexPath)

        return model.calculatedHeight ?? UITableView.automaticDimension
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.tableView(tableView, viewModelForRowAt: indexPath)

        return model.tableViewController(self, estimatedHeightForIndexPath: indexPath)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.tableView(tableView, viewModelForRowAt: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: model.tableReuseIdentifier, for: indexPath)
        if let cell = cell as? _TableViewCell {
            cell.viewController = self
        }

        model.captureCell(cell)

        return cell
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.tableView(tableView, viewModelForRowAt: indexPath)
        if let viewController = model.tableViewController(self, selectionViewControllerForIndexPath: indexPath) {
            self.presentOrPush(viewController, animated: true)
        } else {
            model.tableViewController(self, performActionForIndexPath: indexPath)
        }
    }

    // MARK: - 3D Touch Previewing

    open override func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let position = self.tableView.convert(location, from: self.view)
        guard let indexPath = self.tableView.indexPathForRow(at: position) else { return nil }
        guard let cell = self.tableView.cellForRow(at: indexPath) as? _TableViewCell else { return nil }

        previewingContext.sourceRect = self.view.convert(cell._cell.frame, from: cell._cell.superview)

        guard let previewingViewController = cell.previewingContext(previewingContext, viewControllerForLocation: location) else { return nil }
        guard let previewable = previewingViewController as? UIViewControllerPreviewable else { return nil }
        guard previewable.canBePreviewed else { return nil }
        previewable.prepareForPreviewing()

        return previewingViewController
    }
}
