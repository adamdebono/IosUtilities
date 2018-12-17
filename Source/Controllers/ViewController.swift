import UIKit

open class ViewController: UIViewController,
    FontTraitEnvironment, UserInterfaceStyleTraitEnvironment,
    UIViewControllerPreviewingDelegate {

    // MARK: - View Lifecycle

    public private(set) var viewHasAppeared = false
    public private(set) var viewIsActive = false
    public private(set) var viewIsPreviewing = false
    private var viewWasPreviewing = false

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.updateFonts()
        self.updateUserInterfaceStyle()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !self.viewHasAppeared {
            self.viewWillFirstAppear(animated)

            if self.viewIsPreviewing {
                self.viewWillPeek()
            }
        } else {
            if self.viewIsPreviewing {
                self.viewWasPreviewing = true
                self.viewIsPreviewing = false
                self.viewWillPop()
            }
        }
    }

    open func viewWillFirstAppear(_ animated: Bool) {
        if let dataLoadable = self as? DataLoadable {
            dataLoadable.loadCachedData()
            dataLoadable.displayLoadedData()
        }
    }
    open func viewWillPeek() {}
    open func viewWillPop() {}

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewIsActive = true

        if !self.viewHasAppeared {
            self.viewHasAppeared = true

            self.viewDidFirstAppear(animated)

            if self.viewIsPreviewing {
                self.viewDidPeek()
            }
        } else {
            if (self.viewWasPreviewing) {
                self.viewWasPreviewing = false
                self.viewIsPreviewing = false
                self.viewDidPop()
            }
        }

        if let dataLoadable = self as? DataLoadable {
            dataLoadable.updateDataIfNeeded()
        }
    }

    open func viewDidFirstAppear(_ animated: Bool) {}
    open func viewDidPeek() {}
    open func viewDidPop() {}

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.viewIsActive = false

        if let dataLoadable = self as? DataLoadable {
            dataLoadable.cancelDataRequest()
            dataLoadable.cancelDataExpiryTimer()
        }
    }

    // MARK: - Traits

    open func updateFonts() {}
    open func updateUserInterfaceStyle() {}

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.checkPreviewingContext()

        self.checkFontTraits(from: previousTraitCollection)
        if #available(iOS 12.0, *) {
            self.checkUserInterfaceStyleTraits(from: previousTraitCollection)
        }
    }

    // MARK: - Popover

    @available(tvOS, unavailable)
    open func prepareForPopover() {}

    @available(tvOS, unavailable)
    open var popoverArrowDirections: UIPopoverArrowDirection {
        return .any
    }

    // MARK: - Previewing

    private var previewingContext: UIViewControllerPreviewing?

    open func checkPreviewingContext() {
        if self.traitCollection.forceTouchCapability == .available {
            if self.previewingContext == nil {
                self.previewingContext = self.registerForPreviewing(with: self, sourceView: self.view)
            }
        } else {
            if let previewingContext = self.previewingContext {
                self.unregisterForPreviewing(withContext: previewingContext)
                self.previewingContext = nil
            }
        }
    }

    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return nil
    }

    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.presentOrPush(viewControllerToCommit, animated: true)
    }

    open func prepareForPreviewing() {
        self.viewIsPreviewing = true
    }

    // MARK: - Data Loadable

    public var isDataActive: Bool {
        return self.viewIsActive
    }

    var loadedDataExpiry: Date? {
        didSet {
            if let dataLoadable = self as? DataLoadable {
                dataLoadable.updateDataExpiryTimer()
            }
        }
    }
    var isDataExpired: Bool {
        guard let loadedDataExpiry = self.loadedDataExpiry else { return true }
        return loadedDataExpiry.isPast
    }

    public var dataExpiryTimer: Timer?
}
