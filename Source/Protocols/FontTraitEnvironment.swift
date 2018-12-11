import UIKit

public protocol FontTraitEnvironment: UITraitEnvironment {
    func updateFonts()
}

extension FontTraitEnvironment {
    public func checkFontTraits(from previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            self.updateFonts()
        }
    }
}
