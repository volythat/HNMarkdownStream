import UIKit

public class HNMarkdownTableView: UIView {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let theme: HNMarkdownTheme
    
    public init(headers: [NSAttributedString], rows: [[NSAttributedString]], theme: HNMarkdownTheme) {
        self.theme = theme
        super.init(frame: .zero)
        setup(headers: headers, rows: rows)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(headers: [NSAttributedString], rows: [[NSAttributedString]]) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // Add border to scrollview/content
        scrollView.layer.borderWidth = 1
        scrollView.layer.borderColor = UIColor.opaqueSeparator.cgColor
        scrollView.layer.cornerRadius = 4
        addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 1 // Horizontal grid lines
        contentStack.backgroundColor = .opaqueSeparator
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // Allow horizontal scrolling if needed, but try to fit width
            contentStack.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Self-sizing height
            scrollView.heightAnchor.constraint(equalTo: contentStack.heightAnchor)
        ])
        
        update(headers: headers, rows: rows)
    }
    
    public func update(headers: [NSAttributedString], rows: [[NSAttributedString]]) {
        // Simple rebuild of content implementation to ensure correctness
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Headers
        if !headers.isEmpty {
            let headerRow = createRow(cells: headers, isHeader: true)
            contentStack.addArrangedSubview(headerRow)
        }
        
        // Rows
        for (index, row) in rows.enumerated() {
            let rowView = createRow(cells: row, isHeader: false, rowIndex: index)
            contentStack.addArrangedSubview(rowView)
        }
    }
    
    private func createRow(cells: [NSAttributedString], isHeader: Bool, rowIndex: Int = 0) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 1 // Vertical grid lines
        stack.distribution = .fillEqually
        stack.backgroundColor = .opaqueSeparator
        
        let backgroundColor: UIColor
        if isHeader {
            backgroundColor = .systemGray6
        } else {
            backgroundColor = (rowIndex % 2 == 0) ? .systemBackground : .systemGray6
        }
        
        for cellText in cells {
            let labelContainer = UIView()
            labelContainer.backgroundColor = backgroundColor
            
            let label = UILabel()
            
            if isHeader {
                let mutable = NSMutableAttributedString(attributedString: cellText)
                mutable.enumerateAttribute(.font, in: NSRange(location: 0, length: mutable.length), options: []) { value, range, stop in
                    if let font = value as? UIFont, let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
                        mutable.addAttribute(.font, value: UIFont(descriptor: descriptor, size: font.pointSize), range: range)
                    }
                }
                label.attributedText = mutable
            } else {
                label.attributedText = cellText
            }
            label.numberOfLines = 0
            label.textAlignment = isHeader ? .center : .left
            label.translatesAutoresizingMaskIntoConstraints = false
            
            labelContainer.addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: labelContainer.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor, constant: -8),
                label.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 12),
                label.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -12),
                labelContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
            ])
            
            stack.addArrangedSubview(labelContainer)
        }
        
        return stack
    }
}
