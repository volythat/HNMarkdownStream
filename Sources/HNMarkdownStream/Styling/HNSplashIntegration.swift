import UIKit
import Splash

struct AttributedStringOutputFormat: OutputFormat {
    let theme: Theme

    func makeBuilder() -> Builder {
        return Builder(theme: theme)
    }
}

extension AttributedStringOutputFormat {
    class Builder: OutputBuilder {
        private let result = NSMutableAttributedString()
        private let theme: Theme

        init(theme: Theme) {
            self.theme = theme
        }

        func addToken(_ token: String, ofType type: TokenType) {
            let color = theme.tokenColors[type] ?? theme.plainTextColor
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: color,
                .font: theme.font
            ]
            result.append(NSAttributedString(string: token, attributes: attributes))
        }

        func addPlainText(_ text: String) {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: theme.plainTextColor,
                .font: theme.font
            ]
            result.append(NSAttributedString(string: text, attributes: attributes))
        }

        func addWhitespace(_ whitespace: String) {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: theme.plainTextColor,
                .font: theme.font
            ]
            result.append(NSAttributedString(string: whitespace, attributes: attributes))
        }

        func build() -> NSAttributedString {
            return result
        }
    }
}

extension AttributedStringOutputFormat {
    struct Theme {
        let font: UIFont
        let plainTextColor: UIColor
        let tokenColors: [TokenType: UIColor]
        
        static func defaultTheme(font: UIFont) -> Theme {
            return Theme(
                font: font,
                plainTextColor: .label,
                tokenColors: [
                    .keyword: .systemPink,
                    .string: .systemRed,
                    .type: .systemIndigo,
                    .call: .systemBlue,
                    .number: .systemOrange,
                    .comment: .systemGray,
                    .property: .systemPurple,
                    .dotAccess: .systemGray,
                    .preprocessing: .systemYellow
                ]
            )
        }
    }
}
