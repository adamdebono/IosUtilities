import UIKit

public protocol UserInterfaceStyleTraitEnvironment: UITraitEnvironment {
    func updateUserInterfaceStyle()
}

extension UserInterfaceStyleTraitEnvironment {
    @available(iOS 12.0, *)
    public func checkUserInterfaceStyleTraits(from previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            self.updateUserInterfaceStyle()
        }
    }
}
