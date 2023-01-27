import Cocoa

protocol AttributedStringConvertible {
    func attributedString(environment: Environment) -> NSAttributedString
}

struct Environment {
    var attributes: [NSAttributedString.Key: Any] = [:]
}

extension String: AttributedStringConvertible {
    func attributedString(environment: Environment) -> NSAttributedString {
        .init(string: self, attributes: environment.attributes)
    }
}

extension AttributedString: AttributedStringConvertible {
    func attributedString(environment: Environment) -> NSAttributedString {
        .init(self)
    }
}

struct Build: AttributedStringConvertible {
    var build: (Environment) -> NSAttributedString
    
    func attributedString(environment: Environment) -> NSAttributedString {
        build(environment)
    }
}

@resultBuilder
struct AttributedStringBuilder {
    static func buildBlock(_ components: AttributedStringConvertible...) -> some AttributedStringConvertible {
        Build { environment in
            var result = NSMutableAttributedString()
            for component in components {
                result.append(component.attributedString(environment: environment))
            }
            return result
        }
    }
    
    static func buildOptional<C: AttributedStringConvertible>(_ component: C?) -> some AttributedStringConvertible {
        Build { environment in
            component?.attributedString(environment: environment) ?? .init()
        }
    }
}

#if DEBUG
@AttributedStringBuilder
var example: AttributedStringConvertible {
    "Hello, World!"
    if 2 > 3 {
        "\n"
    }
    try! AttributedString(markdown: "Hello *world*")
}

import SwiftUI

let sampleAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont(name: "Monaco", size: 14)!
]

struct DebugPreview: PreviewProvider {
    static var previews: some View {
        let attStr = example.attributedString(environment: .init(attributes: sampleAttributes))
        Text(AttributedString(attStr))
    }
}
#endif
