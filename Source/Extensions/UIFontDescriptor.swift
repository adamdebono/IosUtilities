import UIKit

extension UIFontDescriptor {
    public var monospacedDigitFontDescriptor: UIFontDescriptor {
        let featureSettings = [[
            UIFontDescriptor.FeatureKey.featureIdentifier: kTextSpacingType,
            UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedTextSelector
        ]]
        let attributes = [UIFontDescriptor.AttributeName.featureSettings: featureSettings]
        return self.addingAttributes(attributes)
    }

    public var bolded: UIFontDescriptor {
        return self.withSymbolicTraits([.traitBold])!
    }

    public var italicised: UIFontDescriptor {
        return self.withSymbolicTraits([.traitItalic])!
    }
}
