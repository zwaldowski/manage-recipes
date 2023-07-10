import Foundation
import HTMLAttributedString

enum Mela {}

extension Mela {
    struct Recipe: Codable {
        var id: UUID
        var title: String?
        var text: String?
        var images: [Data]
        var categories: [String]
        var yield: String?
        var prepTime: String?
        var cookTime: String?
        var totalTime: String?
        var ingredients: String?
        var instructions: String?
        var notes: String?
        var nutrition: String?
        var link: String?
        var favorite: Bool
        var wantToCook: Bool
        var date: Date?
        init(id: UUID = UUID(), title: String? = nil, text: String? = nil, images: [Data] = [], categories: [String] = [], yield: String? = nil, prepTime: String? = nil, cookTime: String? = nil, totalTime: String? = nil, ingredients: String? = nil, instructions: String? = nil, notes: String? = nil, nutrition: String? = nil, link: String? = nil, favorite: Bool = false, wantToCook: Bool = false, date: Date? = nil) {
            self.id = id
            self.title = title
            self.text = text
            self.images = images
            self.categories = categories
            self.yield = yield
            self.prepTime = prepTime
            self.cookTime = cookTime
            self.totalTime = totalTime
            self.ingredients = ingredients
            self.instructions = instructions
            self.notes = notes
            self.nutrition = nutrition
            self.link = link
            self.favorite = favorite
            self.wantToCook = wantToCook
            self.date = date
        }
    }

    static var encoder: JSONEncoder { JSONEncoder() }
    static var decoder: JSONDecoder { JSONDecoder() }
}

extension Mela {
    static func isHeader(_ type: PresentationIntent.IntentType) -> Bool {
        if case .header = type.kind { return true } else { return false }
    }

    static func sanitizedMarkdownFromStructured(_ input: some AttributedStringProtocol, allowHeaders: Bool) throws -> String {
        var output = ""
        for (intent, range) in input.runs[\.presentationIntent] {
            if intent == nil, input[range].characters.allSatisfy(\.isWhitespace) {
                continue
            }

            var assumeBold = false

            if intent?.components.contains(where: isHeader) == true {
                if allowHeaders, intent?.components.contains(where: isHeader) == true {
                    output += "# "
                } else {
                    assumeBold = true
                }
            }

            var isBold = false
            var isItalic = false

            for (intent, range) in input[range].runs[\.inlinePresentationIntent] {
                let wantsBold = assumeBold || intent?.contains(.stronglyEmphasized) == true
                let wantsItalic = intent?.contains(.emphasized) == true

                if isBold, !wantsBold {
                    output += "**\(output.dropTrailingWhitespace())"
                    isBold = false
                } else if !isBold, wantsBold {
                    output += "**"
                    isBold = true
                }

                if isItalic, !wantsItalic {
                    output += "_\(output.dropTrailingWhitespace())"
                    isItalic = false

                } else if !isItalic, wantsItalic {
                    output += "_"
                    isItalic = true
                }

                output += String(input[range].characters)
                    .replacingOccurrences(of: "**", with: #"\*\*"#)
                    .replacingOccurrences(of: "_", with: #"\_"#)
            }

            if isBold {
                output += "**\(output.dropTrailingWhitespace())"
            }

            if isItalic {
                output += "_\(output.dropTrailingWhitespace())"
            }

            output += "\n"
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func sanitizedMarkdownFromHTML(_ input: String, allowHeaders: Bool) throws -> String {
        try sanitizedMarkdownFromStructured(AttributedString(html: input, options: .appKit.set(\.interpretedSyntax, .full)), allowHeaders: allowHeaders)
    }
}
