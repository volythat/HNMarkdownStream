import Foundation
import Markdown
import UIKit

public struct HNMarkdownLayoutEngine: MarkupWalker {
    private let theme: HNMarkdownTheme
    private var results: [HNRenderNode] = []
    
    public init(theme: HNMarkdownTheme) {
        self.theme = theme
    }
    
    public mutating func layout(_ document: Document) -> [HNRenderNode] {
        results = []
        visit(document)
//        print("DEBUG: Layout generated \(results.count) nodes")
//        for node in results { print("DEBUG: Node type: \(node.type)") }
        return results
    }
    
    
    // MARK: - Block Visits
    
    // MARK: - Block Visits
    
    public mutating func visitUnorderedList(_ unorderedList: UnorderedList) {
        let items = processListItems(unorderedList.children, level: 0)
        results.append(HNListRenderNode(items: items, isOrdered: false))
    }
    
    public mutating func visitOrderedList(_ orderedList: OrderedList) {
        let items = processListItems(orderedList.children, level: 0)
        results.append(HNListRenderNode(items: items, isOrdered: true))
    }
    
    private func processListItems(_ children: MarkupChildren, level: Int) -> [HNListItemContent] {
        var items: [HNListItemContent] = []
        
        for child in children {
            guard let listItem = child as? ListItem else { continue }
            
            var currentText = NSMutableAttributedString()
            var hasText = false
            
            for itemChild in listItem.children {
                let builder = HNAttributedTextBuilder(theme: theme)
                
                if let paragraph = itemChild as? Paragraph {
                    if hasText { currentText.append(NSAttributedString(string: "\n")) }
                    let inlines = Array(paragraph.inlineChildren.compactMap { $0 as? InlineMarkup })
                    currentText.append(builder.build(from: inlines))
                    hasText = true
                    
                } else if let heading = itemChild as? Heading {
                    if hasText { currentText.append(NSAttributedString(string: "\n")) }
                    let inlines = Array(heading.inlineChildren.compactMap { $0 as? InlineMarkup })
                    let attrText = builder.build(from: inlines)
                    
                    let mutable = NSMutableAttributedString(attributedString: attrText)
                    let size = theme.bodyFont.pointSize * (heading.level == 1 ? 2.0 : 1.5)
                    mutable.addAttribute(.font, value: UIFont.systemFont(ofSize: size, weight: .bold), range: NSRange(location: 0, length: mutable.length))
                    currentText.append(mutable)
                    hasText = true
                    
                } else if let nestedUnordered = itemChild as? UnorderedList {
                    // Flush current text if any
                    if hasText {
                        items.append(HNListItemContent(text: currentText, level: level))
                        currentText = NSMutableAttributedString()
                        hasText = false
                    }
                    // Process nested
                    items.append(contentsOf: processListItems(nestedUnordered.children, level: level + 1))
                    
                } else if let nestedOrdered = itemChild as? OrderedList {
                    // Flush current text
                    if hasText {
                        items.append(HNListItemContent(text: currentText, level: level))
                        currentText = NSMutableAttributedString()
                        hasText = false
                    }
                    // Process nested
                    items.append(contentsOf: processListItems(nestedOrdered.children, level: level + 1))
                }
            }
            
            // Flush remaining text
            if hasText {
                items.append(HNListItemContent(text: currentText, level: level))
            }
        }
        
        return items
    }
    
    public mutating func visitTable(_ table: Table) {
        var headers: [NSAttributedString] = []
        var rows: [[NSAttributedString]] = []
        
        let builder = HNAttributedTextBuilder(theme: theme)
        
        for child in table.children {
            if let head = child as? Table.Head {
                for cell in head.cells {
                   let inlines = Array(cell.inlineChildren.compactMap { $0 as? InlineMarkup })
                   headers.append(builder.build(from: inlines))
                }
            } else if let body = child as? Table.Body {
                for row in body.rows {
                    var rowItems: [NSAttributedString] = []
                    for cell in row.cells {
                        let inlines = Array(cell.inlineChildren.compactMap { $0 as? InlineMarkup })
                        rowItems.append(builder.build(from: inlines))
                    }
                    rows.append(rowItems)
                }
            }
        }
        results.append(HNTableRenderNode(headers: headers, rows: rows))
    }
    
    public mutating func visitParagraph(_ paragraph: Paragraph) {
        // Iterate through children to detect images mixed with text
        var currentInlines: [InlineMarkup] = []
        
        for child in paragraph.inlineChildren {
            if let image = child as? Image {
                // If we have accumulated text, flush it first
                if !currentInlines.isEmpty {
                    let builder = HNAttributedTextBuilder(theme: theme)
                    let attrText = builder.build(from: currentInlines)
                    results.append(HNTextRenderNode(text: attrText, type: .text))
                    currentInlines = []
                }
                
                // Add Image Node
                results.append(HNImageRenderNode(source: image.source, altText: image.title))
            } else {
                currentInlines.append(child)
            }
        }
        
        // Flush remaining text
        if !currentInlines.isEmpty {
            let builder = HNAttributedTextBuilder(theme: theme)
            let attrText = builder.build(from: currentInlines)
            results.append(HNTextRenderNode(text: attrText, type: .text))
        }
    }
    
    public mutating func visitHeading(_ heading: Heading) {
        let inlines = Array(heading.inlineChildren.compactMap { $0 as? InlineMarkup })
        let builder = HNAttributedTextBuilder(theme: theme)
        let attrText = builder.build(from: inlines)
        
        // Apply header scaling
        let mutable = NSMutableAttributedString(attributedString: attrText)
        let size = theme.bodyFont.pointSize * (heading.level == 1 ? 2.0 : 1.5)
        mutable.addAttribute(.font, value: UIFont.systemFont(ofSize: size, weight: .bold), range: NSRange(location: 0, length: mutable.length))
        
        results.append(HNTextRenderNode(text: mutable, type: .text))
    }
    
    public mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        if let lang = codeBlock.language?.lowercased(), (lang == "math" || lang == "latex") {
            results.append(HNLatexRenderNode(latex: codeBlock.code))
        } else {
            results.append(HNCodeBlockRenderNode(code: codeBlock.code, language: codeBlock.language))
        }
    }
    
    public mutating func visitImage(_ image: Image) {
        results.append(HNImageRenderNode(source: image.source, altText: image.title))
    }
    
    public mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) {
        results.append(HNRenderNode(type: .thematicBreak))
    }
    
    public mutating func visitBlockQuote(_ blockQuote: BlockQuote) {
        let builder = HNAttributedTextBuilder(theme: theme)
        let accumulatedText = NSMutableAttributedString()
        
        for child in blockQuote.children {
            if let paragraph = child as? Paragraph {
                let inlines = Array(paragraph.inlineChildren.compactMap { $0 as? InlineMarkup })
                accumulatedText.append(builder.build(from: inlines))
                // Add newline if not last? For simple quotes, just append.
                if child.indexInParent < blockQuote.childCount - 1 {
                    accumulatedText.append(NSAttributedString(string: "\n"))
                }
            }
        }
        
        // Apply monospace font and color for quotes
        let fullRange = NSRange(location: 0, length: accumulatedText.length)
        let quoteSize = max(10.0, theme.bodyFont.pointSize - 1)
        accumulatedText.addAttribute(.font, value: UIFont.monospacedSystemFont(ofSize: quoteSize, weight: .regular), range: fullRange)
        accumulatedText.addAttribute(.foregroundColor, value: theme.bodyColor.withAlphaComponent(0.9), range: fullRange)
        
        results.append(HNTextRenderNode(text: accumulatedText, type: .quote))
    }
}
