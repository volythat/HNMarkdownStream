import UIKit

public enum HNRenderNodeType {
    case text
    case codeBlock
    case quote
    case list
    case image
    case table
    case latex
    case thematicBreak
}

public class HNRenderNode {
    public let id = UUID()
    public let type: HNRenderNodeType
    public var frame: CGRect = .zero
    
    public init(type: HNRenderNodeType) {
        self.type = type
    }
}

public struct HNListItemContent {
    public let text: NSAttributedString
    public let level: Int
    
    public init(text: NSAttributedString, level: Int = 0) {
        self.text = text
        self.level = level
    }
}

public class HNListRenderNode: HNRenderNode {
    public let items: [HNListItemContent]
    public let isOrdered: Bool
    
    public init(items: [HNListItemContent], isOrdered: Bool) {
        self.items = items
        self.isOrdered = isOrdered
        super.init(type: .list)
    }
}

public class HNTableRenderNode: HNRenderNode {
    public let headers: [NSAttributedString]
    public let rows: [[NSAttributedString]]
    
    public init(headers: [NSAttributedString], rows: [[NSAttributedString]]) {
        self.headers = headers
        self.rows = rows
        super.init(type: .table)
    }
}

public class HNLatexRenderNode: HNRenderNode {
    public let latex: String
    
    public init(latex: String) {
        self.latex = latex
        super.init(type: .latex)
    }
}

public class HNTextRenderNode: HNRenderNode {
    public let text: NSAttributedString
    
    public init(text: NSAttributedString, type: HNRenderNodeType = .text) {
        self.text = text
        super.init(type: type)
    }
}

public class HNImageRenderNode: HNRenderNode {
    public let source: String?
    public let altText: String?
    
    public init(source: String?, altText: String?) {
        self.source = source
        self.altText = altText
        super.init(type: .image)
    }
}

public class HNCodeBlockRenderNode: HNRenderNode {
    public let code: String
    public let language: String?
    
    public init(code: String, language: String?) {
        self.code = code
        self.language = language
        super.init(type: .codeBlock)
    }
}
