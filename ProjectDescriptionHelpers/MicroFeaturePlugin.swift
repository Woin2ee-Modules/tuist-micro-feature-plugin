import Foundation

extension String {
    
    /// Makes the string to be available in the `Bundle Identifier`.
    func toValidInBundleIdentifier() -> String {
        return replacingOccurrences(of: "[^a-zA-Z0-9.-]", with: "-", options: .regularExpression)
    }
}
