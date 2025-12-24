import UIKit
import HNMarkdownStream

enum MessageRole {
    case user
    case ai
}

struct ChatMessage {
    let id = UUID()
    let role: MessageRole
    var content: String
    var isStreaming: Bool = false
}

class UserMessageCell: UITableViewCell {
    static let id = "UserMessageCell"
    
    private let bubbleView = UIView()
    private let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Light gray bubble (like standard LLM prompts)
        bubbleView.backgroundColor = .systemGray6
        bubbleView.layer.cornerRadius = 18
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        // Dark text
        label.textColor = .label
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(label)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60),
            
            label.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            label.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with message: ChatMessage) {
        label.text = message.content
    }
}

class AIMessageCell: UITableViewCell {
    static let id = "AIMessageCell"
    
    let markdownView = HNMarkdownView()
    var onLinkTapped: ((URL) -> Void)?
    var onImageTapped: ((UIImage?, String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // No bubble background, just raw markdown content
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(markdownView)
        
        // Forward link taps
        markdownView.onLinkTapped = { [weak self] url in
            self?.onLinkTapped?(url)
        }
        
        markdownView.onImageTapped = { [weak self] image, source in
            self?.onImageTapped?(image, source)
        }
        
        NSLayoutConstraint.activate([
            markdownView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            markdownView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            markdownView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            markdownView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with message: ChatMessage) {
        markdownView.update(with: message.content)
    }
}
