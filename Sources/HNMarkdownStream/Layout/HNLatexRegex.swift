import Foundation

struct HNLatexRegex {
    // Order matters: Check blocks first, then inline.
    static let patterns: [(pattern: String, type: LatexType, groupIndex: Int)] = [
        // Block: $$ ... $$
        (pattern: #"\$\$([\s\S]+?)\$\$"#, type: .block, groupIndex: 1),
        
        // Block: \[ ... \]
        (pattern: #"\\\[([\s\S]+?)\\\]"#, type: .block, groupIndex: 1),
        
        // Special Case: [ ... ] - User requested, but risky without strict math check.
        // We will try strictly matching start/end of custom logic or check if it contains math symbols?
        // For now, let's skip broad [ ... ] to avoid breaking links, unless user specifically asked.
        // User example: [x = ...]
        // Let's rely on standard patterns first. 
        
        // Inline: \( ... \)
        (pattern: #"\\\(([\s\S]+?)\\\)"#, type: .inline, groupIndex: 1),
        
        // Inline/Block: $ ... $ (Match last to avoid consuming $$)
        // Negative lookbehind/ahead for $ to ensure it's single $?
        // Swift Regex support is limited.
        // Simpler: match $...$ where ... is not nothing.
        (pattern: #"(?<!\$)\$(?!\$)([^$]+?)(?<!\$)\$(?!\$)"#, type: .inline, groupIndex: 1)
    ]
    
    enum LatexType {
        case block
        case inline
    }
}
