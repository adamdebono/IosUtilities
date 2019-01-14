import UIKit

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
    }

    public required init?(coder aDecoder: NSCoder) {
        // TODO
        fatalError("init(coder:) has not been implemented")
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
    }

    #if !os(tvOS)
    open override func prepareForPopover() {
        super.prepareForPopover()

        self.tableView.backgroundColor = .clear
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .prominent))
    }
    #endif

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
        print("check previewing view controller")
        let position = self.tableView.convert(location, from: self.view)
        guard let indexPath = self.tableView.indexPathForRow(at: position) else { return nil }
        guard let cell = self.tableView.cellForRow(at: indexPath) as? _TableViewCell else { return nil }

        previewingContext.sourceRect = self.view.convert(cell._cell.frame, from: cell._cell.superview)

        guard let previewingViewController = cell.previewingContext(previewingContext, viewControllerForLocation: location) else { return nil }
        print(previewingViewController)
        guard let previewable = previewingViewController as? UIViewControllerPreviewable else { return nil }
        guard previewable.canBePreviewed else { return nil }
        previewable.prepareForPreviewing()

        print("prepare for previewing")

        return previewingViewController
    }
}
