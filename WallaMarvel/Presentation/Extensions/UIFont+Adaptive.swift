import UIKit

extension UIFont {
    static func adaptive(textStyle: TextStyle, weight: Weight? = nil) -> UIFont {
        let baseSize = UIFont.preferredFont(forTextStyle: textStyle).pointSize
        let resolvedSize = UIDevice.current.userInterfaceIdiom == .pad
            ? (baseSize * 1.4).rounded()
            : baseSize

        let base = UIFont.systemFont(ofSize: resolvedSize, weight: weight ?? .regular)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
    }
}
