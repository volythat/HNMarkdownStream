import Foundation
import Markdown

public class HNMarkdownParser {
    public init() {}

    public func parse(_ text: String) -> Document {
        // Parse the markdown string into a Document AST
        return Document(parsing: text)
    }

    public func stripMarkdown(_ text: String) -> String {
        let document = Document(parsing: text)
        var walker = PlainTextWalker(source: text)
        walker.visit(document)
        return walker.plainText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func getFirstParagraph(_ text: String) -> String {
        let document = Document(parsing: text)
        // Find the first paragraph node
        guard let firstParagraph = document.children.first(where: { $0 is Paragraph }) else {
            return ""
        }
        
        var walker = PlainTextWalker(source: text)
        walker.visit(firstParagraph)
        return walker.plainText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct PlainTextWalker: MarkupWalker {
    var plainText = ""
    let source: String
    
    // Helper to map lines for index calculation
    // Note: swift-markdown SourceLocation is 1-based line, 1-based column
    private let sourceLines: [Substring] 
    private let lineOffsets: [String.Index]

    init(source: String) {
        self.source = source
        // Split keeping separators to calculate correct offsets, but swift split(omittingEmptySubsequences:false) doesn't keep separators by default easily in a way that maps perfectly to visual lines if we aren't careful.
        // Better approach: calculate line start indices upfront.
        
        var offsets = [String.Index]()
        var currentIndex = source.startIndex
        offsets.append(currentIndex)
        
        source.enumerateLines { line, stop in
            // iterate to find newlines? enumerateLines strips newlines.
             // Let's iterate manually or use a different strategy.
            // Actually, we can just use the source directly if we had offsets.
            // Let's build a map of line number -> start index
        }
        
        // Simpler approach for 1-off extraction:
        // Re-locate indices on demand or build a quick lookup table
        var lines = [Substring]()
        source.enumerateSubstrings(in: source.startIndex..<source.endIndex, options: [.byLines, .substringNotRequired]) { _, range, _, _ in
             lines.append(source[range]) // This gives ranges of lines without newline characters typically, or we can use options to include them?
             // .byLines doesn't include the newline.
        }
        // This is getting complicated to reverse engineer exactly what swift-markdown considers a "line" vs "column". 
        // Assuming standard unix newlines given source checks.
        
        // Let's try a different simpler approach:
        // Use the visitor to just grab the raw text by reconstructing it from the AST if possible? No, we need the raw source.
        
        // Let's just create line ranges.
        // We will compute line ranges including newlines to be safe for offsets.
        var lineRanges = [Range<String.Index>]()
        var index = source.startIndex
        while index < source.endIndex {
            let lineRange = source.lineRange(for: index..<index)
            lineRanges.append(lineRange)
            index = lineRange.upperBound
        }
        self.sourceLines = lineRanges.map { source[$0] }
        var starts = [String.Index]()
        for range in lineRanges {
            starts.append(range.lowerBound)
        }
        self.lineOffsets = starts
    }

    mutating func visitText(_ text: Text) {
        plainText += text.string
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        if !plainText.isEmpty { plainText += "\n" }
        plainText += codeBlock.code
        plainText += "\n"
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) {
        plainText += inlineCode.code
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) {
        plainText += " "
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) {
        plainText += "\n"
    }

    mutating func visitParagraph(_ paragraph: Paragraph) {
        if !plainText.isEmpty { plainText += "\n\n" }
        descendInto(paragraph)
    }

    mutating func visitHeading(_ heading: Heading) {
        if !plainText.isEmpty { plainText += "\n\n" }
        descendInto(heading)
    }

    mutating func visitListItem(_ listItem: ListItem) {
//        if !plainText.isEmpty { plainText += "\n" }
        descendInto(listItem)
    }

    mutating func visitTable(_ table: Table) {
        if !plainText.isEmpty { plainText += "\n\n" }
        
        if let range = table.range {
            if let str = extractSource(from: range) {
                plainText += str
            }
        }
    }
    
    private func extractSource(from range: SourceRange) -> String? {
        // range.lowerBound.line is 1-based
        // range.lowerBound.column is 1-based
        
        let startLineIndex = range.lowerBound.line - 1
        let endLineIndex = range.upperBound.line - 1
        
        guard startLineIndex >= 0, startLineIndex < sourceLines.count,
              endLineIndex >= 0, endLineIndex < sourceLines.count else { return nil }
        
        // Calculate Lower Bound Index
        let startLineStart = lineOffsets[startLineIndex]
        // Safe column offset
        let startColOffset = range.lowerBound.column - 1
        let startIndex = source.index(startLineStart, offsetBy: startColOffset, limitedBy: sourceLines[startLineIndex].endIndex) ?? sourceLines[startLineIndex].endIndex
        
        // Calculate Upper Bound Index
        let endLineStart = lineOffsets[endLineIndex]
        let endColOffset = range.upperBound.column - 1
        let endIndex = source.index(endLineStart, offsetBy: endColOffset, limitedBy: sourceLines[endLineIndex].endIndex) ?? sourceLines[endLineIndex].endIndex
        
        if startIndex <= endIndex {
             return String(source[startIndex..<endIndex])
        }
        return nil
    }
}
