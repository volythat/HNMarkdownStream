import Foundation

@MainActor
public class HNTypingController {
    public var onUpdate: ((String) -> Void)?
    public var onComplete: (() -> Void)?
    private var fullText: String = ""
    private var currentText: String = ""
    private var timer: Timer?
    private let speed: TimeInterval
    
    public var isTyping: Bool {
        return timer != nil
    }
    
    public init(speed: TimeInterval = 0.01) {
        self.speed = speed
    }
    
    public func start(markdown: String) {
        fullText = markdown
        currentText = ""
        timer?.invalidate()
        
        startTimer()
    }
    
    public func update(markdown: String) {
        // If new text is shorter than what we've already displayed (e.g. reset), reset
        if markdown.count < currentText.count {
            start(markdown: markdown)
            return
        }
        
        fullText = markdown
        
        // Ensure timer is running if it was stopped
        if timer == nil && currentText.count < fullText.count {
            startTimer()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] _ in
            self?.step()
        }
    }
    
    private func step() {
        guard currentText.count < fullText.count else {
            timer?.invalidate()
            timer = nil
            DispatchQueue.main.async {
                self.onComplete?()
            }
            return
        }
        
        let remaining = fullText.count - currentText.count
        
        // Adaptive speed:
        // If remaining is large, take more characters at once to catch up.
        // Base chunk is 3.
        // If > 50 chars pending, take 5.
        // If > 100 chars pending, take 10.
        let chunkSize: Int
        if remaining > 100 {
            chunkSize = 15
        } else if remaining > 50 {
            chunkSize = 8
        } else if remaining > 20 {
            chunkSize = 4
        } else {
            chunkSize = 2
        }
        
        // Don't exceed remaining
        let take = min(remaining, chunkSize)
        
        let startIndex = fullText.index(fullText.startIndex, offsetBy: currentText.count)
        let endIndex = fullText.index(startIndex, offsetBy: take)
        let chunk = fullText[startIndex..<endIndex]
        
        currentText.append(contentsOf: chunk)
        
        DispatchQueue.main.async {
            self.onUpdate?(self.currentText)
        }
    }
    
    public func stop() {
        timer?.invalidate()
        timer = nil
        // Optional: immediately show full text?
        // currentText = fullText
        // onUpdate?(currentText)
    }
    
    public func skipAnimation() {
        timer?.invalidate()
        timer = nil
        currentText = fullText
        onUpdate?(currentText)
    }
}
