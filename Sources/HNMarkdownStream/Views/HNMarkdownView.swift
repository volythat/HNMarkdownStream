import UIKit
import SwiftMath

public class HNMarkdownView: UIView, UITextViewDelegate {
    public var onLinkTapped: ((URL) -> Void)?
    public var onImageTapped: ((UIImage?, String) -> Void)?

    private let stackView = UIStackView()

    private let theme: HNMarkdownTheme
    private let parser = HNMarkdownParser()
    private lazy var layoutEngine = HNMarkdownLayoutEngine(theme: theme)
    
    public init(theme: HNMarkdownTheme = HNMarkdownTheme()) {
        self.theme = theme
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.theme = HNMarkdownTheme()
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public func update(with markdown: String) {
        let doc = parser.parse(markdown)
        let nodes = layoutEngine.layout(doc)
        render(nodes)
    }
    
    private func render(_ nodes: [HNRenderNode]) {
        // Diffing and Reuse Logic
        let currentViews = stackView.arrangedSubviews
        let count = nodes.count
        
        for (index, node) in nodes.enumerated() {
            if index < currentViews.count {
                let existingView = currentViews[index]
                if canReuse(existingView, with: node) {
                    updateView(existingView, with: node)
                } else {
                    // Type mismatch, replace
                    existingView.removeFromSuperview()
                    let newView = createView(for: node)
                    stackView.insertArrangedSubview(newView, at: index)
                }
            } else {
                // New node, append
                let newView = createView(for: node)
                stackView.addArrangedSubview(newView)
            }
        }
        
        // Remove trailing views
        if currentViews.count > count {
            for i in (count..<currentViews.count).reversed() {
                currentViews[i].removeFromSuperview()
            }
        }
    }
    
    private func canReuse(_ view: UIView, with node: HNRenderNode) -> Bool {
        switch node.type {
        case .text: return view is UITextView && view.tag == 0 // Tag 0 for plain text
        case .quote: return view.tag == 1 // Tag 1 for quote container
        case .codeBlock: return view is HNCodeBlockView
        case .image: return view.tag == 4
        case .thematicBreak: return view.tag == 2 // Tag 2 for divider
        case .list: return view is UIStackView && view.tag == 3 // Tag 3 for list container
        case .table: return view is HNMarkdownTableView
        case .latex: return view is MTMathUILabel
        default: return false
        }
    }
    
    private func updateView(_ view: UIView, with node: HNRenderNode) {
        switch node.type {
        case .text:
            if let textView = view as? UITextView, let textNode = node as? HNTextRenderNode {
                textView.attributedText = textNode.text
                textView.invalidateIntrinsicContentSize()
            }
            
        case .quote:
            // Quote container(tag 1) -> labels/textViews inside
            if let container = view as? UIView, let textNode = node as? HNTextRenderNode {
                // Assuming simple structure: Line + TextView. TextView is index 1.
                if container.subviews.count > 1, let textView = container.subviews[1] as? UITextView {
                    textView.attributedText = textNode.text
                }
            }
            
        case .codeBlock:
            if let codeView = view as? HNCodeBlockView, let codeNode = node as? HNCodeBlockRenderNode {
                // Only update if code changed to avoid scroll jumping?
                // For now, straightforward update
                codeView.update(code: codeNode.code, language: codeNode.language)
            }
            
        case .image:
            if let imgNode = node as? HNImageRenderNode, let source = imgNode.source {
                // Wrapper check (Tag 4)
                if view.tag == 4, let imageView = view.subviews.first as? UIImageView {
                    // Same logic as before but on inner image view
                     if imageView.accessibilityIdentifier == source {
                        return 
                    }
                    imageView.accessibilityIdentifier = source
                    
                    if let cached = HNImageLoader.shared.image(from: source) {
                        imageView.image = cached
                        updateAspectRatio(for: imageView, image: cached)
                    } else if source.lowercased().hasPrefix("http"), let url = URL(string: source) {
                        imageView.image = nil 
                        HNImageLoader.shared.loadImage(from: url) { image in
                            if let image = image {
                                imageView.image = image
                                self.updateAspectRatio(for: imageView, image: image)
                            }
                        }
                    } else {
                        let filename = (source as NSString).lastPathComponent
                        if let image = UIImage(named: filename) ?? UIImage(named: (filename as NSString).deletingPathExtension) {
                             imageView.image = image
                             updateAspectRatio(for: imageView, image: image)
                        }
                    }
                }
            }
            
        case .list:
             // Full rebuild for list for now, as diffing internal stackview is complex
             // But we can check if content changed?
             // Simplest: If we reused the container, we might need to rebuild children.
             // Given lists structure, easiest to just rebuild content if reused.
             if let stack = view as? UIStackView, let listNode = node as? HNListRenderNode {
                 stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
                 // Re-populate
                 populateList(stack, with: listNode)
             }
             
        case .table:
             // Table view update
             if let tableView = view as? HNMarkdownTableView, let tableNode = node as? HNTableRenderNode {
                 tableView.update(headers: tableNode.headers, rows: tableNode.rows)
             }
             
        case .latex:
             if let label = view as? MTMathUILabel, let latexNode = node as? HNLatexRenderNode {
                 label.latex = latexNode.latex
             }
             
        default: break
        }
    }
    
    private func updateAspectRatio(for imageView: UIImageView, image: UIImage) {
        guard image.size.width > 0 else { return }
        let ratio = image.size.height / image.size.width
        
        // Find existing ratio constraint
        var ExistingConstraint: NSLayoutConstraint?
        for constraint in imageView.constraints {
             // Heuristic: constraints usually set on self
             if constraint.firstAttribute == .height && constraint.secondAttribute == .width {
                  ExistingConstraint = constraint
                  break
             }
        }
        
        if let existing = ExistingConstraint {
            if existing.multiplier != ratio {
                imageView.removeConstraint(existing)
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio).isActive = true
            }
        } else {
             // Remove fixed height placeholder if exists (priority check or just by attribute)
             imageView.constraints.filter { $0.firstAttribute == .height && $0.relation == .equal }.forEach { imageView.removeConstraint($0) }
             imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio).isActive = true
        }
    }

    private func createView(for node: HNRenderNode) -> UIView {
        switch node.type {
        case .text:
            let textView = UITextView()
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.tag = 0
            textView.delegate = self
            if let textNode = node as? HNTextRenderNode {
                textView.attributedText = textNode.text
            }
            return textView
            
        case .quote:
            let container = UIView()
            container.tag = 1
            
            let line = UIView()
            line.backgroundColor = theme.codeBackgroundColor
            line.translatesAutoresizingMaskIntoConstraints = false
            
            let textView = UITextView()
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.delegate = self
            if let textNode = node as? HNTextRenderNode {
                textView.attributedText = textNode.text
            }
            textView.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(line)
            container.addSubview(textView)
            
            NSLayoutConstraint.activate([
                line.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                line.topAnchor.constraint(equalTo: container.topAnchor),
                line.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                line.widthAnchor.constraint(equalToConstant: 4),
                
                textView.leadingAnchor.constraint(equalTo: line.trailingAnchor, constant: 12),
                textView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                textView.topAnchor.constraint(equalTo: container.topAnchor),
                textView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            return container
            
        case .codeBlock:
            if let codeNode = node as? HNCodeBlockRenderNode {
                let view = HNCodeBlockView(code: codeNode.code, language: codeNode.language, theme: theme)
                return view
            }
            return UIView()

        case .image:
            if let imgNode = node as? HNImageRenderNode, let source = imgNode.source {
                // Image Wrapper
                let container = UIView()
                container.tag = 4
                container.translatesAutoresizingMaskIntoConstraints = false
                
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                imageView.backgroundColor = .secondarySystemBackground
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:))))
                
                container.addSubview(imageView)
                
                // Static Constraints
                let trailingPriority = imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
                trailingPriority.priority = .defaultHigh // Try to fill width, but yield to aspect ratio + height limit
                
                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: container.topAnchor),
                    imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                    imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                    imageView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
                    trailingPriority,
                    imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 300)
                ])
                
                container.clipsToBounds = true // Prevent overlap
                
                // Placeholder
                let placeholderHeight = imageView.heightAnchor.constraint(equalToConstant: 200)
                placeholderHeight.priority = .defaultHigh // Lower than max height? No, placeholder.
                placeholderHeight.isActive = true
                
                // Trigger Load
                // Since createView returns container, we need to manually trigger load logic or call updateView immediately?
                // render() calls updateView if reusing. If creating, it just inserts.
                // We should call the load logic here or factor it out.
                // Factoring out to updateView is cleanest but render doesn't call updateView for new views in my previous logic logic?
                // Wait, previous render loop:
                // if reusing -> updateView.
                // else -> createView.
                // createView must populate content.
                // So I need to duplicate the load logic or call a helper.
                // I'll call updateView(container, with: node) inside createView after setup? 
                // That's standard pattern.
                
                updateView(container, with: node)
                return container
            }
            return UIView()
            
        case .thematicBreak:
            let divider = UIView()
            divider.backgroundColor = .separator
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            divider.tag = 2
            return divider
            
        case .list:
            if let listNode = node as? HNListRenderNode {
                let container = UIStackView()
                container.axis = .vertical
                container.spacing = 4
                container.tag = 3
                populateList(container, with: listNode)
                return container
            }
            return UIView()

        case .table:
            if let tableNode = node as? HNTableRenderNode {
                return HNMarkdownTableView(headers: tableNode.headers, rows: tableNode.rows, theme: theme)
            }
            return UIView()

        case .latex:
            if let latexNode = node as? HNLatexRenderNode {
                let mathLabel = MTMathUILabel()
                mathLabel.latex = latexNode.latex
                mathLabel.labelMode = .display
                mathLabel.fontSize = theme.bodyFont.pointSize
                mathLabel.textColor = theme.bodyColor
                return mathLabel
            }
            return UIView()
            
        default:
            return UIView()
        }
    }
    
    private func populateList(_ container: UIStackView, with listNode: HNListRenderNode) {
        for (index, item) in listNode.items.enumerated() {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.alignment = .top
            
            // Indentation
            if item.level > 0 {
                row.isLayoutMarginsRelativeArrangement = true
                // Standard indent step
                let indent = CGFloat(item.level * 24)
                row.layoutMargins = UIEdgeInsets(top: 0, left: indent, bottom: 0, right: 0)
            }
            
            let bullet = UILabel()
            bullet.font = theme.bodyFont
            bullet.textColor = theme.bodyColor
            
            if listNode.isOrdered {
                bullet.text = "\(index + 1)."
            } else {
                bullet.text = (item.level % 2 == 0) ? "•" : "◦"
            }
            
            bullet.setContentHuggingPriority(.required, for: .horizontal)
            
            let content = UITextView()
            content.isEditable = false
            content.isScrollEnabled = false
            content.backgroundColor = .clear
            content.textContainerInset = .zero
            content.textContainer.lineFragmentPadding = 0
            content.delegate = self
            content.attributedText = item.text
            
            row.addArrangedSubview(bullet)
            row.addArrangedSubview(content)
            container.addArrangedSubview(row)
        }
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        onLinkTapped?(URL)
        return false
    }
    
    @objc private func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView,
              let source = imageView.accessibilityIdentifier else { return }
        onImageTapped?(imageView.image, source)
    }
}
