import UIKit

public protocol ViewControllerExtensions {
    func extend_init()
    func extend_viewDidLoad()
    func extend_viewDidAppear(animated: Bool)

    func extend_updateUserInterfaceStyle()

    func extend_additionalContentInset(forScrollView scrollView: UIScrollView) -> UIEdgeInsets

    #if !os(tvOS)
    func extend_prepareForPopover()
    #endif
}

open class ViewController: UIViewController,
    FontTraitEnvironment, UserInterfaceStyleTraitEnvironment,
    UIViewControllerPreviewingDelegate {

    public init() {
        super.init(nibName: nil, bundle: nil)

        (self as? ViewControllerExtensions)?.extend_init()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        (self as? ViewControllerExtensions)?.extend_init()
    }

    // MARK: - View Lifecycle

    public private(set) var viewHasAppeared = false
    public private(set) var viewIsActive = false
    public private(set) var viewIsPreviewing = false
    private var viewWasPreviewing = false

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.setupKeyCommands()
        self.updateFonts()
        self.updateUserInterfaceStyle()

        if let scrollViewController = self as? ScrollViewController {
            if scrollViewController.usesFullWidth {
                if #available(iOS 11.0, tvOS 11.0, *) {
                    self.viewRespectsSystemMinimumLayoutMargins = false
                    scrollViewController.scrollView.insetsLayoutMarginsFromSafeArea = false
                }
            }

            scrollViewController.updateContentInset()
        }

        (self as? ScrollViewController)?.updateContentInset()
        (self as? ViewControllerExtensions)?.extend_viewDidLoad()
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

        (self as? ViewControllerExtensions)?.extend_viewDidAppear(animated: animated)
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

        self.updateUserActivity()

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

    @available(iOS 11.0, tvOS 11.0, *)
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        (self as? ScrollViewController)?.updateContentInset()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let scrollViewController = self as? ScrollViewController, scrollViewController.verticallyPadded {
            scrollViewController.updateContentInset()
        }
    }

    #if os(tvOS)

    open func viewWillExit() {}

    #endif

    open func additionalContentInset(forScrollView scrollView: UIScrollView) -> UIEdgeInsets {
        return .zero
    }

    // MARK: - Activity

    public func updateUserActivity() {
        if let activity = self.userActivity {
            activity.invalidate()
            self.userActivity = nil
        }

        if let activities = self as? UIViewControllerActivities, let activity = activities.createUserActivity() {
            self.userActivity = activity
            activity.becomeCurrent()
        }
    }

    // MARK: - Traits

    open func updateFonts() {}
    open func updateUserInterfaceStyle() {
        (self as? ViewControllerExtensions)?.extend_updateUserInterfaceStyle()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.checkPreviewingContext()

        self.checkFontTraits(from: previousTraitCollection)
        if #available(iOS 12.0, *) {
            self.checkUserInterfaceStyleTraits(from: previousTraitCollection)
        }
    }

    // MARK: - Popover

    #if !os(tvOS)

    public private(set) var isPopover: Bool = false

    open func prepareForPopover() {
        self.isPopover = true

        (self as? ViewControllerExtensions)?.extend_prepareForPopover()
    }

    open var popoverArrowDirections: UIPopoverArrowDirection {
        return .any
    }

    #endif

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

    public var loadedDataExpiry: Date? {
        didSet {
            if let dataLoadable = self as? DataLoadable {
                dataLoadable.updateDataExpiryTimer()
            }
        }
    }
    open var isDataExpired: Bool {
        guard let loadedDataExpiry = self.loadedDataExpiry else { return true }
        return loadedDataExpiry.isPast
    }

    public var dataExpiryTimer: Timer?

    // MARK: - Loading UI

    public var activityIndicatorController: UIViewController? = nil

    open func showModalLoadingUI(completion: (() -> Void)? = nil) {
        guard self.activityIndicatorController == nil else { return }

        let activityIndicatorController = ActivityIndicatorController()
        self.present(activityIndicatorController, animated: true, completion: completion)
        self.activityIndicatorController = activityIndicatorController
    }

    open func hideModalLoadingUI(completion: (() -> Void)? = nil) {
        guard let activityIndicatorController = self.activityIndicatorController else { return }

        activityIndicatorController.dismiss(animated: true, completion: completion)
        self.activityIndicatorController = nil
    }

    // MARK: - Status Bar

    #if os(iOS)
    
    public var showStatusBar: Bool = true {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override open var prefersStatusBarHidden: Bool {
        return !self.showStatusBar
    }

    #endif

    // MARK: - Keyboard Commands

    open func setupKeyCommands() {}

    @discardableResult
    public func addKeyCommand(input: String, modifierFlags: UIKeyModifierFlags, action: Selector, discoverabilityTitle: String? = nil) -> UIKeyCommand {
        let command: UIKeyCommand

        if let discoverabilityTitle = discoverabilityTitle {
            command = UIKeyCommand(input: input, modifierFlags: modifierFlags, action: action, discoverabilityTitle: discoverabilityTitle)
        } else {
            command = UIKeyCommand(input: input, modifierFlags: modifierFlags, action: action)
        }

        self.addKeyCommand(command)

        return command
    }

    // MARK: - Gestures

    #if os(tvOS)

    public func setupMenuPressGesture() {
        let menuPressGesture = UITapGestureRecognizer()
        menuPressGesture.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        menuPressGesture.addTarget(self, action: #selector(menuGesturePressed(sender:)))
        self.view.addGestureRecognizer(menuPressGesture)
    }

    @objc
    private func menuGesturePressed(sender: UITapGestureRecognizer) {
        self.viewWillExit()

        self.popOrDismiss(animated: true)
    }

    #endif
}
