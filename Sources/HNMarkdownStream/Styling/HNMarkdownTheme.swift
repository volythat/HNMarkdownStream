import UIKit

public struct HNMarkdownTheme {
    public var bodyFont: UIFont = .systemFont(ofSize: 16)
    public var bodyColor: UIColor = .label
    public var boldFont: UIFont = .boldSystemFont(ofSize: 16)
    public var italicFont: UIFont = .italicSystemFont(ofSize: 16)
    public var codeFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    public var codeBackgroundColor: UIColor = .secondarySystemBackground
    public var quoteColor: UIColor = .secondaryLabel
    public var linkColor: UIColor = .systemBlue
    
    public init() {}
}
