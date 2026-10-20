import UIKit

/// Forces a two-button `UIAlertController` into a vertical stack.
///
/// UIKit has no public axis for alert buttons: with exactly two it lays them
/// side by side whenever both titles fit. It counts trailing no-break spaces
/// when choosing the axis but not when centring the label, so padding the end
/// of a title flips the layout without moving the visible text. Measured on
/// iOS 26.5 (iPhone 17): the stack starts near 125pt of title width, and past
/// roughly 185pt the alert widens and the label shrinks. `targetWidth` sits
/// inside that window at both the default and extra-large Dynamic Type sizes.
enum CNVerticalActions {
    private static let targetWidth: CGFloat = 150
    private static let space = "\u{00A0}"

    static func pad(_ title: String) -> String {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let spaceWidth = (space as NSString).size(withAttributes: [.font: font]).width
        let width = (title as NSString).size(withAttributes: [.font: font]).width
        guard spaceWidth > 0, width < targetWidth else { return title }
        let count = Int(((targetWidth - width) / spaceWidth).rounded(.up))
        return title + String(repeating: space, count: count)
    }

    /// Below iOS 26 the layout is left to UIKit.
    static func applies(requested: Bool, buttonCount: Int) -> Bool {
        guard requested, buttonCount == 2 else { return false }
        if #available(iOS 26.0, *) { return true }
        return false
    }
}

extension UIAlertAction {
    /// The padded title would otherwise be read out with its spaces.
    convenience init(cnTitle title: String,
                     padded: Bool,
                     style: UIAlertAction.Style,
                     handler: ((UIAlertAction) -> Void)?) {
        self.init(title: padded ? CNVerticalActions.pad(title) : title,
                  style: style,
                  handler: handler)
        if padded { accessibilityLabel = title }
    }
}
