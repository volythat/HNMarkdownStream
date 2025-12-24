import Foundation

@MainActor
public class MockStream {
    public var onUpdate: ((String) -> Void)?
    public var onComplete: (() -> Void)?
    
    private var fullContent: String = ""
    private var currentContent: String = ""
    private var timer: Timer?
    private let speed: TimeInterval
    private let minChunkSize: Int
    private let maxChunkSize: Int
    
    /// - Parameters:
    ///   - speed: Interval between chunks in seconds (default 0.05 for fast stream).
    ///   - minChunkSize: Minimum characters per chunk.
    ///   - maxChunkSize: Maximum characters per chunk.
    public init(speed: TimeInterval = 0.05, minChunkSize: Int = 5, maxChunkSize: Int = 50) {
        self.speed = speed
        self.minChunkSize = minChunkSize
        self.maxChunkSize = maxChunkSize
    }
    
    public func start(content: String) {
        self.fullContent = content
        self.currentContent = ""
        stop()
        
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] _ in
            self?.processNextChunk()
        }
    }
    
    public func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func processNextChunk() {
        guard currentContent.count < fullContent.count else {
            stop()
            onComplete?()
            return
        }
        
        // Random chunk size
        let remaining = fullContent.count - currentContent.count
        let chunkSize = Int.random(in: minChunkSize...maxChunkSize)
        let actualSize = min(chunkSize, remaining)
        
        let startIndex = fullContent.index(fullContent.startIndex, offsetBy: currentContent.count)
        let endIndex = fullContent.index(startIndex, offsetBy: actualSize)
        
        let chunk = fullContent[startIndex..<endIndex]
        currentContent.append(contentsOf: chunk)
        
        onUpdate?(currentContent)
    }
}
