import UIKit
import HNMarkdownStream
import SafariServices

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private let messageInputView = UIView()
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    
    private var messages: [ChatMessage] = []
    private let typingController = HNTypingController(speed: 0.002)
    private let mockStream = MockStream(speed: 0.04, minChunkSize: 5, maxChunkSize: 50)
    
    // Sample AI response content
    private let sampleResponse = """
    Here is a breakdown of **Socket Programming** in Swift using `Foundation`:
    
    ### 1. Introduction
    Sockets provide an interface for programming networks at the transport layer. Network communication using Sockets is very similar to performing file I/O.
    
    ### 2. Client Side Example
    
    ```swift
    import Foundation
    
    func connect() {
        let task = URLSession.shared.streamTask(withHostName: "localhost", port: 8080)
        task.resume()
        // Handle read/write
    }
    ```
    
    ### 3. Math Representation
    
    The throughput $T$ can be approximated by:
    
    $$ T = \\frac{W}{RTT} $$
    
    Where:
    - $W$ is window size
    - $RTT$ is round trip time
    
    | Protocol | Type | Reliability |
    | :--- | :--- | :--- |
    | TCP | Stream | High |
    | UDP | Dgram | Low |
    
    """
    let readMeContents = """
----

Bạn có thể sử dụng **AlamofireSessionManager** để cấu hình SSL ~Pinning~. Để trust certificate self-signed, bạn cần tạo 1 custom *ServerTrustPolicy* và set cho `AlamofireSessionManager`.

Bạn có thể sử dụng [x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}] Để trust certificate self-signed.

----

# The largest heading
## The second largest heading
###### The smallest heading

**** Ví dụ như sau (kotlin):

```
let serverTrustPolicies: [String: ServerTrustPolicy] = [
"your.server.com": .pinCertificates(
    certificates: ServerTrustPolicy.certificates(),
    validateCertificateChain: true,
    validateHost: true
),
]

let sessionManager = Alamofire.SessionManager(
configuration: URLSessionConfiguration.default,
serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
)

sessionManager.request("https://your.server.com/api").responseJSON { response in
// handle response
}

```

Swift :
```
func animateImagePicker(to view: UIView) {
let picker = UIImagePickerController()
picker.sourceType = .photoLibrary
picker.delegate = self

// Present image picker
self.present(picker, animated: true) {
    // Image picker presented, animate the selected image
    guard let image = picker.selectedImage else { return }
    
    // Create UIImageView for the selected image
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    imageView.center = picker.view.center
    imageView.layer.cornerRadius = imageView.frame.width / 2
    imageView.clipsToBounds = true
    
    // Add the UIImageView to the destination view
    view.addSubview(imageView)
    
    // Animate the UIImageView using spring animation
    UIView.animate(withDuration: 0.8,
                   delay: 0,
                   usingSpringWithDamping: 0.5,
                   initialSpringVelocity: 0.5,
                   options: [],
                   animations: {
                       imageView.center = view.center
                   },
                   completion: { _ in
                       // Animation complete, remove the UIImageView
                       imageView.removeFromSuperview()
                   })
}
}

```

python

```swift
import socket

# create a socket object
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# define the server's IP address and port number
server_address = ('localhost', 12345)

# connect to the server
s.connect(server_address)

# send data to the server
data = 'Hello, server!'
s.sendall(data.encode())

# receive data from the server
received_data = s.recv(1024).decode()
print('Received from server:', received_data)

# close the connection
s.close()

```

> Outside of a dog, a book is man's best friend. Inside of a
> dog it's too dark to read.

> Outside of a dog, a book is man's best friend. Inside of a
> dog it's too dark to read.

> Outside of a dog, a book is man's best friend. Inside of a
> dog it's too dark to read.

\n
[pica](https://nodeca.github.io/pica/demo/),  [pica2](https://google.com.vn)

[x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}]


| First Header  | Second Header |
| ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |


$$
\\frac{1}{n}\\sum_{i=1}^{n}x_i \\geq \\sqrt[n]{\\prod_{i=1}^{n}x_i}
$$

- row 1 : Outside of a dog, a `book is man's` best friend
- row 2 : Outside of a *dog*, a book is man's best friend
- row 3 : Outside of a dog, a book is man's best friend

1. row 1 : Outside of a dog, a `book is man's` best friend
2. row 2 : Outside of a *dog*, a book is man's best friend
3. row 3 : **Outside** of a dog, a book ~~is man's best friend~~

* row 1
* row 2
* row 3

![A mushroom-head robot drinking bubble tea](https://raw.githubusercontent.com/Codecademy/docs/main/media/codey.jpg "Codey the Robot")


$
x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}
$

| STT | Tên người              | Tài sản ước tính (tỷ USD) | ACB.         |
|-----|------------------------|---------------------------|--------------|
| 1   | Jeff Bezos             | 115,3                     |              |
| 2   | Elon Musk              | 97,1                      |              |
| 3   | Bernard Arnault       | 76,1                      |              |
| 4   | Bill Gates             | 126,4                     |              |
| 5   | Mark Zuckerberg | 129,1                     |              |

Lưu ý:
- Một
- Hai
- Ba
    
![Image 2](https://itsfoss.com/content/images/wordpress/2021/04/retext_window_showing_syntax_and_preview-2.png)

Công thức nghiệm của phương trình bậc hai \\(ax^2 + bx + c = 0\\) là:

$ x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a} \\$

Trong đó:
- Nếu , phương trình có hai nghiệm phân biệt.
- Nếu , phương trình có nghiệm kép.
- Nếu , phương trình không có nghiệm thực.


Lưu ý:
- Một
- Hai
- Ba

Đây là mã C dùng để <f>giải</f> phương trình bậc 2 có dạng \\( ax^2 + bx + c = 0 \\). Mã này tính toán nghiệm của phương trình dựa trên các hệ số a, b và c.
"""
    
    let imageContent = """
    * row 1
    * row 2
    * row 3

    Image 1
    ![A mushroom-head robot drinking bubble tea](https://raw.githubusercontent.com/Codecademy/docs/main/media/codey.jpg "Codey the Robot")
    
    Image 2
    ![Image 2](https://itsfoss.com/content/images/wordpress/2021/04/retext_window_showing_syntax_and_preview-2.png)
    """
    
    private let latexExample = """
    Sure, here are some Math examples:
    
    Inline: $E = mc^2$ is famous.
    
    Review:
    
    $$
    \\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}
    $$
    
    And your requested equation:
    
    $$
    x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}
    $$
    """
    let contentb = """
Ngắn gọn: không bắt buộc và không nên tiến hành CPR nếu người bệnh bị đột quỵ nhưng vẫn còn tuần hoàn và thở. CPR chỉ thực hiện khi người bệnh đã ngừng tuần hoàn (không thở bình thường và/hoặc không có mạch).

Hướng dẫn cụ thể:

- Kiểm tra nhanh:
  - Đánh giá đáp ứng (gọi tên, lay vai).
  - Kiểm tra hô hấp: có thở bình thường không? (thở gasping không được coi là thở bình thường).
  - Nếu bạn biết cách và có thể, kiểm tra mạch trong 10 giây.

- Nếu người bệnh không có phản ứng và không thở bình thường (hoặc không bắt được mạch): gọi cấp cứu ngay và bắt đầu CPR, nếu có AED thì dùng theo hướng dẫn.

- Nếu người bệnh vẫn thở và còn mạch:
  - Không làm CPR.
  - Gọi cấp cứu ngay (ở VN gọi 115/115 hoặc dịch vụ cấp cứu tại địa phương), báo là nghi ngờ đột quỵ — thời gian rất quan trọng.
  - Đặt người bệnh ở tư thế an toàn (tư thế nằm nghiêng phục hồi) nếu ý thức giảm nhưng còn thở, để tránh sặc.
  - Theo dõi đường thở, hô hấp và mạch liên tục.
  - Kiểm tra và ghi thời điểm xuất hiện triệu chứng (rất quan trọng cho điều trị tái tưới máu).
  - Không cho uống thuốc, không tự ý dùng kháng đông hoặc hạ huyết áp tại nhà.
  - Nếu có oxy và người bệnh thiếu oxy (SpO2 <94%) cấp được oxy theo chỉ dẫn.

- Với nhân viên y tế: tiếp cận ABC, đảm bảo đường thở, cho oxy nếu SpO2< 94%, đo đường huyết, kích hoạt "stroke code", chụp CT/MRI khẩn cấp để xem có chỉ định tiêu sợi huyết hoặc can thiệp nội mạch hay không. Không trì hoãn chụp hình vì làm CPR (trừ khi có ngừng tuần hoàn).

Tóm lại: nếu còn tuần hoàn và thở thì không làm CPR — ưu tiên gọi cấp cứu, bảo vệ đường thở, theo dõi đến khi chuyên gia y tế đến. Nếu nghi ngờ là ngừng tim (không thở/mất mạch), thì cần bắt đầu CPR ngay.
"""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "AI Assistant"
        
        setupTableView()
        setupInputArea()
        
        // Setup Typing Controller (Legacy/Smooth)
        typingController.onUpdate = { [weak self] newText in
            self?.handleStreamUpdate(newText)
        }
        
        // Setup Mock Stream (Network Simulation)
        mockStream.onUpdate = { [weak self] newText in
            self?.handleStreamUpdate(newText)
        }
        
        // Initial welcome message
        messages.append(ChatMessage(role: .ai, content: "Hello! How can I help you with coding today?"))
        
        // Example of HNMarkdownParser.stripMarkdown
        let parser = HNMarkdownParser()
//        let strippedText = parser.stripMarkdown(readMeContents)
        let first = parser.getFirstParagraph(latexExample)
//        print("----- Original Markdown -----")
//        print(sampleResponse)
        print("----- first Text -----")
        print(first)
        print("-------------------------")
    }
    
    private func handleStreamUpdate(_ newText: String) {
        print("====================")
        print("NewText = \(newText)")
        if var last = messages.last, last.role == .ai { // Changed from .assistant to .ai based on ChatMessage role
            messages[messages.count - 1].content = newText
            
            // Efficient update: Get cell directly
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? AIMessageCell { // Changed from MessageCell to AIMessageCell
                cell.configure(with: messages.last!)
                
                // Keep scrolled to bottom
                // Only scroll if already at bottom? For now force it.
                // tableView.scrollToRow(at: indexPath, at: .bottom, animated: false) 
                // Scrolling might be jerky during stream.
            }
            
            // Auto scroll logic from original typingController.onUpdate
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            
            let containerHeight = self.tableView.frame.height - self.tableView.contentInset.top - self.tableView.contentInset.bottom
            let contentHeight = self.tableView.contentSize.height
            if contentHeight > containerHeight {
                let offset = CGPoint(x: 0, y: contentHeight - containerHeight)
                self.tableView.setContentOffset(offset, animated: false)
            }
        }
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: UserMessageCell.id)
        tableView.register(AIMessageCell.self, forCellReuseIdentifier: AIMessageCell.id)
        tableView.keyboardDismissMode = .onDrag
        
        view.addSubview(tableView)
    }
    
    private func setupInputArea() {
        messageInputView.backgroundColor = .systemBackground
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        
        // Top border
        let border = UIView()
        border.backgroundColor = .separator
        border.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.addSubview(border)
        
        textView.font = .systemFont(ofSize: 16)
        textView.layer.cornerRadius = 18
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        messageInputView.addSubview(textView)
        messageInputView.addSubview(sendButton)
        view.addSubview(messageInputView)
        
        NSLayoutConstraint.activate([
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            border.topAnchor.constraint(equalTo: messageInputView.topAnchor),
            border.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 0.5),
            
            textView.topAnchor.constraint(equalTo: messageInputView.topAnchor, constant: 10),
            textView.bottomAnchor.constraint(equalTo: messageInputView.bottomAnchor, constant: -10),
            textView.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor, constant: 16),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: 120),
            
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor, constant: -16),
            sendButton.bottomAnchor.constraint(equalTo: messageInputView.bottomAnchor, constant: -10),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor)
        ])
    }
    
    @objc private func sendMessage() {
        guard let text = textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        textView.text = ""
        
        // 1. Add User Message
        messages.append(ChatMessage(role: .user, content: text))
        let userIndexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [userIndexPath], with: .bottom)
        
        // 2. Prepare AI Response (placeholder)
        messages.append(ChatMessage(role: .ai, content: "", isStreaming: true))
        let aiIndexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [aiIndexPath], with: .bottom)
        tableView.scrollToRow(at: aiIndexPath, at: .bottom, animated: true)
        
        // 3. Start Streaming (Mock)
        // Note: onUpdate is handled by viewDidLoad setup calling handleStreamUpdate
        
        // Pick a response based on keywords or random?
        var content = readMeContents
        if text.lowercased().contains("latex") {
            content = latexExample
        }
        if text.lowercased().contains("image") {
            content = imageContent
        }
        if text.lowercased().contains("b") {
            content = contentb
        }
        
        typingController.stop()
        mockStream.start(content: content)
    }
    
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.role == .user {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserMessageCell.id, for: indexPath) as! UserMessageCell
            cell.configure(with: message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AIMessageCell.id, for: indexPath) as! AIMessageCell
            cell.configure(with: message)
            cell.onLinkTapped = { [weak self] url in
                let safari = SFSafariViewController(url: url)
                self?.present(safari, animated: true)
            }
            cell.onImageTapped = { image, source in
                print("Image tapped: \(source)")
            }
            return cell
        }
    }
}
