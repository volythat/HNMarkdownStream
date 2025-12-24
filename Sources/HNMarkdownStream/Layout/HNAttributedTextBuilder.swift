import UIKit
import Markdown

class HNAttributedTextBuilder {
    private let theme: HNMarkdownTheme
    
    init(theme: HNMarkdownTheme) {
        self.theme = theme
    }
    
    func build(from inlineMarkup: [InlineMarkup]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        var textBuffer: String = ""
        
        func flushBuffer() {
            if !textBuffer.isEmpty {
                // Parse the accumulated text for Latex
                result.append(parseTextForLatex(textBuffer, baseAttributes: [
                    .font: theme.bodyFont,
                    .foregroundColor: theme.bodyColor
                ]))
                textBuffer = ""
            }
        }
        
        for child in inlineMarkup {
            if let text = child as? Text {
                textBuffer += text.string
            } else if child is SoftBreak {
                textBuffer += " " // SoftBreak usually renders as space
            } else if child is LineBreak {
                textBuffer += "\n"
            } else {
                // Non-text node (Bold, Italic, Link, etc.)
                flushBuffer()
                result.append(visit(child))
            }
        }
        flushBuffer() // Flush remainder
        
        return result
    }
    
    private func visit(_ node: InlineMarkup) -> NSAttributedString {
        var baseAttributes: [NSAttributedString.Key: Any] = [
            .font: theme.bodyFont,
            .foregroundColor: theme.bodyColor
        ]
        
        if let text = node as? Text {
            let string = text.string
            let master = NSMutableAttributedString(string: "")
            
            // We need to parse 'string' for multiple regex patterns
            // This is complex because we have multiple patterns.
            // Simplified approach: Find the first match across all patterns, process, recurse on remainder.
            
            // Combine patterns? Or iterate?
            // Let's implement a recursive parser for the string.
            
            master.append(parseTextForLatex(string, baseAttributes: baseAttributes))
            return master
        } else if let strong = node as? Strong {
            baseAttributes[.font] = theme.boldFont
            let attributed = NSMutableAttributedString()
            for child in strong.inlineChildren {
                attributed.append(visit(child)) // Recursive visit
            }
            // Apply bold to children - simplified, actually need to apply trait
            // For now, simpler implementation:
            return applyAttribute(.font, value: theme.boldFont, to: visitChildren(Array(strong.inlineChildren)))
        } else if let emphasis = node as? Emphasis {
             return applyAttribute(.font, value: theme.italicFont, to: visitChildren(Array(emphasis.inlineChildren)))
        } else if let strikethrough = node as? Strikethrough {
             return applyAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, to: visitChildren(Array(strikethrough.inlineChildren)))
        } else if let code = node as? InlineCode {
            baseAttributes[.font] = theme.codeFont
            baseAttributes[.backgroundColor] = theme.codeBackgroundColor
            return NSAttributedString(string: code.code, attributes: baseAttributes)
        } else if let link = node as? Link {
            baseAttributes[.foregroundColor] = theme.linkColor
            baseAttributes[.font] = UIFont.monospacedSystemFont(ofSize: theme.bodyFont.pointSize, weight: .regular)
            if let dest = link.destination {
                baseAttributes[.link] = dest
            }
            return NSAttributedString(string: link.plainText, attributes: baseAttributes)
        }
        
        // Fallback for others
        return NSAttributedString(string: node.plainText, attributes: baseAttributes)
    }
    
    private func visitChildren(_ children: [InlineMarkup]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for child in children {
            result.append(visit(child))
        }
        return result
    }
    
    private func applyAttribute(_ key: NSAttributedString.Key, value: Any, to attrString: NSAttributedString) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: attrString)
        mutable.addAttribute(key, value: value, range: NSRange(location: 0, length: mutable.length))
        return mutable
    }
    
    private func parseTextForLatex(_ text: String, baseAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        // Find best match (earliest start index) among all patterns
        var bestMatch: (range: Range<String.Index>, type: HNLatexRegex.LatexType, content: String)? = nil
        
        // print("DEBUG: Parsing text for Latex: \(text.prefix(20))...")
        
        for patternDef in HNLatexRegex.patterns {
            if let regex = try? NSRegularExpression(pattern: patternDef.pattern, options: []) {
                let range = NSRange(location: 0, length: text.utf16.count)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    if let rangeRange = Range(match.range, in: text) {
                        // Check if this match is earlier than current best
                        if bestMatch == nil || rangeRange.lowerBound < bestMatch!.range.lowerBound {
                            if let contentRange = Range(match.range(at: patternDef.groupIndex), in: text) {
                                let foundContent = String(text[contentRange])
                                // print("DEBUG: Found Latex match: \(foundContent) type: \(patternDef.type)")
                                bestMatch = (range: rangeRange, type: patternDef.type, content: foundContent)
                            }
                        }
                    }
                }
            }
        }
        
        guard let match = bestMatch else {
            return NSAttributedString(string: text, attributes: baseAttributes)
        }
        
        let result = NSMutableAttributedString()
        
        // Append text before match
        let preText = String(text[..<match.range.lowerBound])
        if !preText.isEmpty {
            result.append(NSAttributedString(string: preText, attributes: baseAttributes))
        }
        
        // Render Latex
        let fontSize = (baseAttributes[.font] as? UIFont)?.pointSize ?? theme.bodyFont.pointSize
        let textColor = baseAttributes[.foregroundColor] as? UIColor ?? theme.bodyColor
        
        if let image = HNLatexImageGenerator.shared.image(from: match.content, fontSize: fontSize, textColor: textColor) {
//            print("DEBUG: Generated Latex Image size: \(image.size)")
            let attachment = NSTextAttachment()
            attachment.image = image
            // Adjust bounds for inline alignment logic if needed
            // For now, simple attachment
            attachment.bounds = CGRect(x: 0, y: -5, width: image.size.width, height: image.size.height)
            result.append(NSAttributedString(attachment: attachment))
        } else {
            print("DEBUG: Failed to generate Latex Image for: \(match.content)")
            // Fallback if render failed
            result.append(NSAttributedString(string: String(text[match.range]), attributes: baseAttributes))
        }
        
        // Recurse on remainder
        let remainingText = String(text[match.range.upperBound...])
        if !remainingText.isEmpty {
            result.append(parseTextForLatex(remainingText, baseAttributes: baseAttributes))
        }
        
        return result
    }
}

extension Link {
    var plainText: String {
        return children.compactMap { ($0 as? Text)?.string }.joined() 
    }
}
