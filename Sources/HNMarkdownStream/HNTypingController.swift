import Foundation

@MainActor
public class HNTypingController {
    public var onUpdate: ((String) -> Void)?
    private var fullText: String = ""
    private var currentText: String = ""
    private var timer: Timer?
    private let speed: TimeInterval
    
    public init(speed: TimeInterval = 0.01) {
        self.speed = speed
    }
    
    public func start(markdown: String) {
        fullText = markdown
        currentText = ""
        timer?.invalidate()
        
        // Use a timer to append characters
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] _ in
            self?.step()
        }
    }
    
    private func step() {
        guard currentText.count < fullText.count else {
            timer?.invalidate()
            return
        }
        
        let index = fullText.index(fullText.startIndex, offsetBy: currentText.count)
        currentText.append(fullText[index])
        
        // Optimization: Maybe append chunk of characters if text is very long
        // But for "typing effect", char by char is smoother
        
        DispatchQueue.main.async {
            self.onUpdate?(self.currentText)
        }
    }
    
    public func stop() {
        timer?.invalidate()
    }
}
