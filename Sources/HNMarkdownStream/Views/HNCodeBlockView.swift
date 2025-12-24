import UIKit
import Splash
import Foundation

public class HNCodeBlockView: UIView {
    private let containerStack = UIStackView()
    private let headerView = UIView()
    private let languageLabel = UILabel()
    private let copyButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let codeLabel = UILabel()
    
    private var codeContent: String
    private let theme: HNMarkdownTheme
    
    public init(code: String, language: String?, theme: HNMarkdownTheme) {
        self.codeContent = code
        self.theme = theme
        super.init(frame: .zero)
        setup(code: code, language: language)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(code: String, language: String?) {
        // backgroundColor = theme.codeBackgroundColor // Moved to contentWrapper to support transparent gap
        layer.cornerRadius = 8
        clipsToBounds = true
        
        // Main Container
        containerStack.axis = .vertical
        containerStack.spacing = 2
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerStack)
        
        // Header
        headerView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8) // Slightly different header color
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Language Label
        languageLabel.font = .systemFont(ofSize: 11, weight: .bold)
        languageLabel.textColor = .secondaryLabel
        if let lang = language, !lang.isEmpty {
            languageLabel.text = lang.uppercased()
        } else {
            languageLabel.text = ""
        }
        languageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Copy Button
        // Using SF Symbols if available (iOS 13+)
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .regular, scale: .medium)
        let copyImage = UIImage(systemName: "doc.on.doc", withConfiguration: config)
        copyButton.setImage(copyImage, for: .normal)
        copyButton.tintColor = .secondaryLabel
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.addTarget(self, action: #selector(copyToClipboard), for: .touchUpInside)
        
        headerView.addSubview(languageLabel)
        headerView.addSubview(copyButton)
        
        NSLayoutConstraint.activate([
            languageLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            languageLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            copyButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -4),
            copyButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 44),
            copyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        containerStack.addArrangedSubview(headerView)
        
        // Code Content Area
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeLabel.numberOfLines = 0
        
        let splashFormat = AttributedStringOutputFormat(theme: .defaultTheme(font: theme.codeFont))
        let highlighter = SyntaxHighlighter(format: splashFormat)
        let attributedCode = highlighter.highlight(code)
        
        // Ensure default color matches theme if Splash misses anything
        let mutable = NSMutableAttributedString(attributedString: attributedCode)
        let fullRange = NSRange(location: 0, length: mutable.length)
        
        // Enforce monospaced font while preventing loss of bold traits from syntax highlighting
        mutable.enumerateAttribute(.font, in: fullRange, options: []) { value, range, stop in
            let currentFont = value as? UIFont ?? theme.codeFont
            let isBold = currentFont.fontDescriptor.symbolicTraits.contains(.traitBold)
            let weight: UIFont.Weight = isBold ? .bold : .regular
            let newFont = UIFont.monospacedSystemFont(ofSize: theme.codeFont.pointSize, weight: weight)
            mutable.addAttribute(.font, value: newFont, range: range)
        }
        
        codeLabel.attributedText = mutable
        // codeLabel.font = theme.codeFont // handled by Splash format
        // codeLabel.textColor = theme.bodyColor // handled by Splash format
        
        scrollView.addSubview(codeLabel)
        
        // Wrap scroll view in a wrapper to provide padding
        let contentWrapper = UIView()
        contentWrapper.backgroundColor = theme.codeBackgroundColor
        contentWrapper.addSubview(scrollView)
        containerStack.addArrangedSubview(contentWrapper)
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // ScrollView constraints within wrapper with padding
            scrollView.topAnchor.constraint(equalTo: contentWrapper.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: contentWrapper.leadingAnchor, constant: 12), // Indent code
            scrollView.trailingAnchor.constraint(equalTo: contentWrapper.trailingAnchor, constant: -12),
            scrollView.bottomAnchor.constraint(equalTo: contentWrapper.bottomAnchor, constant: -8),
            
            // CodeLabel constraints inside ScrollView
            codeLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            codeLabel.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            codeLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            codeLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // Self-sizing
            codeLabel.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
    
    @objc private func copyToClipboard() {
        UIPasteboard.general.string = codeContent
        
        // Feedback animation
        let originalImage = copyButton.image(for: .normal)
        copyButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.copyButton.setImage(originalImage, for: .normal)
        }
    }
    
    public func update(code: String, language: String?) {
        self.codeContent = code
        
        if let lang = language, !lang.isEmpty {
            languageLabel.text = lang.uppercased()
        } else {
            languageLabel.text = ""
        }
        
        let splashFormat = AttributedStringOutputFormat(theme: .defaultTheme(font: theme.codeFont))
        let highlighter = SyntaxHighlighter(format: splashFormat)
        let attributedCode = highlighter.highlight(code)
        
        let mutable = NSMutableAttributedString(attributedString: attributedCode)
        let fullRange = NSRange(location: 0, length: mutable.length)
        
        mutable.enumerateAttribute(.font, in: fullRange, options: []) { value, range, stop in
            let currentFont = value as? UIFont ?? theme.codeFont
            let isBold = currentFont.fontDescriptor.symbolicTraits.contains(.traitBold)
            let weight: UIFont.Weight = isBold ? .bold : .regular
            let newFont = UIFont.monospacedSystemFont(ofSize: theme.codeFont.pointSize, weight: weight)
            mutable.addAttribute(.font, value: newFont, range: range)
        }
        
        codeLabel.attributedText = mutable
    }
}
