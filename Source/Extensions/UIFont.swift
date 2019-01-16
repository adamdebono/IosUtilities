import UIKit

extension UIFont {

    // MARK: - Alternative Styles

    public var monospacedDigitFont: UIFont {
        let newFontDescriptor = self.fontDescriptor.monospacedDigitFontDescriptor
        return UIFont(descriptor: newFontDescriptor, size: newFontDescriptor.pointSize)
    }

    public var bolded: UIFont {
        let newFontDescriptor = self.fontDescriptor.bolded
        return UIFont(descriptor: newFontDescriptor, size: newFontDescriptor.pointSize)
    }

    public var italicised: UIFont {
        let newFontDescriptor = self.fontDescriptor.italicised
        return UIFont(descriptor: newFontDescriptor, size: newFontDescriptor.pointSize)
    }

    // MARK: - Font Selection

    private class func descriptor(forTextStyle textStyle: UIFont.TextStyle, compatibleWith traitCollection: UITraitCollection?) -> UIFontDescriptor {
        return UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle, compatibleWith: traitCollection)
    }
    private class func font(_ fontName: String, forTextStyle textStyle: UIFont.TextStyle, compatibleWith traitCollection: UITraitCollection?) -> UIFont {
        let preferredDescriptor = self.descriptor(forTextStyle: textStyle, compatibleWith: traitCollection)
        let descriptor = UIFontDescriptor(name: fontName, size: preferredDescriptor.pointSize)
            .withSymbolicTraits(preferredDescriptor.symbolicTraits)!

        return UIFont(descriptor: descriptor, size: descriptor.pointSize)
    }

    public class func preferredFontSize(forTextStyle textStyle: UIFont.TextStyle) -> CGFloat {
        return self.descriptor(forTextStyle: textStyle, compatibleWith: nil).pointSize
    }
    public class func preferredFont(_ fontName: String, forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        return self.font(fontName, forTextStyle: textStyle, compatibleWith: nil)
    }

    public class func fixedFontSize(forTextStyle textStyle: UIFont.TextStyle) -> CGFloat {
        let traitCollection = UITraitCollection(preferredContentSizeCategory: .large)
        return self.descriptor(forTextStyle: textStyle, compatibleWith: traitCollection).pointSize
    }
    public class func fixedFont(_ fontName: String, forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        let traitCollection = UITraitCollection(preferredContentSizeCategory: .large)
        return self.font(fontName, forTextStyle: textStyle, compatibleWith: traitCollection)
    }
}
