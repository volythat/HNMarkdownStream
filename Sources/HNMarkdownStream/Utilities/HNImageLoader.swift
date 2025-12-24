import UIKit

final class HNImageLoader: @unchecked Sendable {
    static let shared = HNImageLoader()
    
    private let cache = NSCache<NSString, UIImage>()
    private var activeRequests: [URL: [((UIImage?) -> Void)]] = [:]
    private let queue = DispatchQueue(label: "com.nativemarkdown.imageloader", attributes: .concurrent)
    
    private init() {
        cache.countLimit = 100
    }
    
    func image(from source: String) -> UIImage? {
        return cache.object(forKey: source as NSString)
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let key = url.absoluteString as NSString
        
        // Check cache
        if let cachedImage = cache.object(forKey: key) {
            completion(cachedImage)
            return
        }
        
        // Thread-safe access to active requests
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            if self.activeRequests[url] != nil {
                // Request already in progress, append completion
                self.activeRequests[url]?.append(completion)
                return
            }
            
            // Start new request
            self.activeRequests[url] = [completion]
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self, let data = data, let image = UIImage(data: data) else {
                    self?.handleCompletion(for: url, image: nil)
                    return
                }
                
                // Cache the image
                self.cache.setObject(image, forKey: key)
                
                self.handleCompletion(for: url, image: image)
            }.resume()
        }
    }
    
    private func handleCompletion(for url: URL, image: UIImage?) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let completions = self.activeRequests[url] ?? []
            self.activeRequests[url] = nil
            
            DispatchQueue.main.async {
                completions.forEach { $0(image) }
            }
        }
    }
}
