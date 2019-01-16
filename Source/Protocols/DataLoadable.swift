import Foundation

public enum DataLoadableResult {
    case success
    case failure
}

public protocol DataLoadable: class {
    var loadedDataExpiry: Date? { get }
    var dataExpiryTimer: Timer? { get set }

    var isDataExpired: Bool { get }
    var isDataActive: Bool { get }

    func loadCachedData()
    func requestData(completion: @escaping ((DataLoadableResult) -> Void))
    func cancelDataRequest()

    func dataDidBeginLoading()
    func dataDidEndLoading()
    func displayLoadedData()
    func displayLoadFailure()
}

extension DataLoadable {
    internal func cancelDataExpiryTimer() {
        if let dataExpiryTimer = self.dataExpiryTimer {
            dataExpiryTimer.invalidate()
            self.dataExpiryTimer = nil
        }
    }
    internal func updateDataExpiryTimer() {
        self.cancelDataExpiryTimer()

        guard self.isDataActive else { return }

        if let loadedDataExpiry = self.loadedDataExpiry, !loadedDataExpiry.isPast {
            let timer = Timer(fire: loadedDataExpiry, interval: 0, repeats: false) { [weak self] (timer) in
                self?.updateDataIfNeeded()
                self?.dataExpiryTimer = nil
            }
            RunLoop.main.add(timer, forMode: .common)

            self.dataExpiryTimer = timer
        }
    }

    public func updateDataIfNeeded() {
        if self.isDataExpired {
            self.performDataRequest()
        } else {
            self.updateDataExpiryTimer()
        }
    }
    public func reloadData() {
        self.performDataRequest()
    }

    private func performDataRequest() {
        self.cancelDataRequest()
        self.cancelDataExpiryTimer()

        self.dataDidBeginLoading()
        self.requestData { (result) in
            self.dataDidEndLoading()

            switch result {
            case .success:
                self.displayLoadedData()
            case .failure:
                self.displayLoadFailure()
            }
        }
    }
}
