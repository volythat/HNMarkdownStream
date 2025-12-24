import UIKit
import SwiftMath

final class HNLatexImageGenerator: Sendable {
    static let shared = HNLatexImageGenerator()
    
    private init() {}
    
    func image(from latex: String, fontSize: CGFloat, textColor: UIColor) -> UIImage? {
        if Thread.isMainThread {
            return generate(latex: latex, fontSize: fontSize, textColor: textColor)
        } else {
            return DispatchQueue.main.sync {
                return generate(latex: latex, fontSize: fontSize, textColor: textColor)
            }
        }
    }
    
    private func generate(latex: String, fontSize: CGFloat, textColor: UIColor) -> UIImage? {
        let label = MTMathUILabel()
        let trimmed = latex.trimmingCharacters(in: .whitespacesAndNewlines)
        label.latex = trimmed
        label.textColor = textColor
        label.labelMode = .display
        
        // Explicitly set font to ensure resources are loaded
        // Note: checking if MTFontManager is available or standard font setup
        // If SwiftMath follows iosMath structure:
        // label.font = MTFontManager().font(withName: .latinModernMath, size: fontSize) 
        // But since we can't easily check API, let's rely on label.fontSize first, 
        // but maybe the alignment is the issue.
        
        // Let's try to set a default frame *before* sizeToFit, sometimes helps.
        label.frame = CGRect(x: 0, y: 0, width: 320, height: 100)
        
        // Try creating a math list directly to verify syntax? 
        // No, stay high level.
        
        // Revert to assigning fontSize property if MTFontManager check fails compilation
        label.fontSize = fontSize
        
        // Important: check if label actually parsed the latex
        // Some versions of iosMath expose 'mathList' or 'error'
        
        // Size to fit
        var size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        
        // print("DEBUG: Generator - Calculated Size: \(size)")
        
        // Safety check for zero size
        if size.width <= 0 || size.height <= 0 {
             print("DEBUG: Generator - Zero size calculated for latex: \(trimmed)")
             // Try forcing a relayout?
             return nil
        }
        
        // Ensure non-fractional sizes for sharper rendering
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        
        label.frame = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Flip context vertically
        // MTMathUILabel draws assuming a bottom-left coordinate system (Core Text default),
        // but UIKit context is top-left.
        context.saveGState()
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        label.layer.render(in: context)
        
        context.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
