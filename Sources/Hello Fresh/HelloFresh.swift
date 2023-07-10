import Foundation
import HTMLAttributedString

enum HelloFresh {
    struct Recipe: Codable, Identifiable {
        // Previously: description, descriptionMarkdown
        let id: String
        let name: String
        let slug: String
        let headline: String
        let descriptionHTML: String
        let difficulty: Int
        let prepTime: PrepTime
        let totalTime: PrepTime?
        let createdAt: Date
        let updatedAt: Date
        let imagePath: URL
        let cardLink: URL?
        let nutrition: [Nutrition]
        let ingredients: [Ingredient]
        let yieldType: YieldType
        let yields: [Yield]
        let steps: [Step]
        let websiteURL: URL?

        enum CodingKeys: String, CodingKey {
            case id, name, slug, headline, descriptionHTML, difficulty, prepTime, totalTime, createdAt, updatedAt, imagePath, cardLink, nutrition, ingredients, yieldType, yields, steps
            case websiteURL = "websiteUrl"
        }
    }

    struct Ingredient: Codable, Identifiable {
        let id: String
        let name: String
        let slug: String
    }

    struct Nutrition: Codable {
        let name: String
        let amount: Int
        let unit: Unit
    }

    struct Step: Codable {
        // Previously: instructions, instructionsMarkdown
        let index: Int
        let instructionsHTML: String
        let images: [Image]
        let ingredients: [String]
    }

    struct Image: Codable {
        let path: String
        let caption: String
    }

    struct Yield: Codable {
        let yields: Int
        let ingredients: [YieldIngredient]
    }

    struct YieldIngredient: Codable, Identifiable {
        let id: String
        let amount: Double?
        let unit: Unit?
    }

    enum YieldType: String, Codable {
        case omitted = "0"
        case servings
    }

    enum Unit: String, Codable {
        case ounce
        case tablespoon
        case teaspoon
        case unit
        case cup
        case clove
        case gram = "g"
        case thumb
        case milliliter = "milliliters"
        case slice
        case milligram = "mg"
        case kilocalorie = "kcal"
    }

    struct PrepTime: RawRepresentable, Codable {
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }

        var dateComponents: DateComponents {
            var result = DateComponents()
            var work = rawValue[...]
            if work.starts(with: "PT") {
                work = work.dropFirst(2)
            }
            while case let numbers = work.prefix(while: \.isWholeNumber), let value = Int(numbers) {
                work = work[numbers.endIndex...]
                switch work.first {
                case "H":
                    result.hour = value
                case "M":
                    result.minute = value
                default:
                    break
                }
                work = work.dropFirst()
            }
            return result
        }
    }

    enum Requests {
        enum Subscriptions {
            static var url: URL {
                var components = URLComponents()
                components.scheme = "https"
                components.host = "www.hellofresh.com"
                components.path = "/gw/api/customers/me/subscriptions"
                components.queryItems = [
                    URLQueryItem(name: "country", value: "US")
                ]
                return components.url!
            }
        }

        struct PastDeliveries {
            var startingFromWeekID: String
            var subscriptionID: String

            init(startingFromWeekID: String, subscriptionID: String) {
                self.startingFromWeekID = startingFromWeekID
                self.subscriptionID = subscriptionID
            }

            var url: URL {
                var components = URLComponents()
                components.scheme = "https"
                components.host = "www.hellofresh.com"
                components.path = "/gw/my-deliveries/past-deliveries"
                components.queryItems = [
                    URLQueryItem(name: "subscription", value: subscriptionID),
                    URLQueryItem(name: "from", value: startingFromWeekID),
                    URLQueryItem(name: "locale", value: "en-US")
                ]
                return components.url!
            }
        }

        struct Recipe: Identifiable {
            var id: String

            init(id: String) {
                self.id = id
            }

            var url: URL {
                var components = URLComponents()
                components.scheme = "https"
                components.host = "www.hellofresh.com"
                components.path = "/gw/recipes/recipes/\(id)"
                components.queryItems = [
                    URLQueryItem(name: "recipeId", value: id),
                    URLQueryItem(name: "country", value: "us"),
                    URLQueryItem(name: "locale", value: "en-US")
                ]
                return components.url!
            }
        }
    }

    enum Responses {
        static let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }()

        struct Subscriptions: Codable {
            let items: [Item]

            struct Item: Codable, Identifiable {
                let id: String
                let nextDeliveryWeek: String
            }
        }

        struct PastDeliveries: Codable {
            let weeks: [Week]
            let nextWeek: String?

            struct Week: Codable {
                let week: String
                let meals: [Meal]
                let addons: [Addon]?
            }

            struct Meal: Codable, Identifiable {
                let id: String
                let name: String
                let image: URL
                let websiteURL: URL
            }

            struct Addon: Codable, Identifiable {
                let id: String
                let name: String
                let image: URL
                let websiteURL: URL
            }
        }
    }
}

extension HelloFresh.Responses.PastDeliveries.Meal: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Meal: \(name) (\(id))"
    }
}

extension HelloFresh.Responses.PastDeliveries.Addon: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Addon: \(name) (\(id))"
    }
}

extension HelloFresh.Recipe: CustomDebugStringConvertible {
    var fileName: String {
        "\(name) (\(id))"
    }

    var debugDescription: String {
        return [
            name,
            descriptionHTML,
            websiteURL?.absoluteString
        ].compactMap { $0 }.joined(separator: "\n\n")
    }
}

extension HelloFresh.Recipe: CustomReflectable {
    var customMirror: Mirror {
        Mirror(self, unlabeledChildren: [ name ])
    }
}

extension HelloFresh.PrepTime: CustomStringConvertible {
    func localizedString(style: DateComponentsFormatter.UnitsStyle) -> String {
        DateComponentsFormatter.localizedString(from: dateComponents, unitsStyle: style) ?? "??? min"
    }

    var description: String {
        return localizedString(style: .brief)
    }
}


extension HelloFresh.Recipe {
    func formattedYield(_ yields: Int) -> String {
        switch yieldType {
        case .omitted:
            return yields.formatted()
        case .servings:
            return "\(yields.formatted()) servings"
        }
    }
}

extension HelloFresh.YieldIngredient {
    func formattedAmount() -> String? {
        guard let amount = amount else { return nil }
        switch unit {
        case .ounce:
            return "\(amount.prettyFractionFormatted()) oz"
        case .tablespoon:
            return "\(amount.prettyFractionFormatted()) tbsp"
        case .teaspoon:
            return "\(amount.prettyFractionFormatted()) tsp"
        case .cup:
            return "\(amount.prettyFractionFormatted()) c"
        case .gram:
            let measurement = Measurement(value: amount, unit: UnitMass.grams)
            return measurement.formatted(.measurement(width: .wide, usage: .asProvided))
        case .milliliter:
            let measurement = Measurement(value: amount, unit: UnitVolume.milliliters)
            return measurement.formatted(.measurement(width: .wide, usage: .asProvided))
        case .milligram:
            let measurement = Measurement(value: amount, unit: UnitMass.milligrams)
            return measurement.formatted(.measurement(width: .wide, usage: .asProvided))
        case .kilocalorie:
            let measurement = Measurement(value: amount, unit: UnitEnergy.kilocalories)
            return measurement.formatted(.measurement(width: .wide, usage: .asProvided))
        case .unit, nil:
            return amount.formatted()
        case let other?:
            let unit = amount == 1 || other.rawValue.hasSuffix("s") ? other.rawValue : "\(other.rawValue)s"
            return "\(amount.formatted()) \(unit)"
        }
    }
}

extension HelloFresh.Yield {
    func formattedAmount(for ingredient: HelloFresh.YieldIngredient, in recipe: HelloFresh.Recipe) -> String? {
        guard let myIngredient = ingredients.first(where: { $0.id == ingredient.id }),
              myIngredient.amount != ingredient.amount,
              let amount = myIngredient.amount?.formatted() else { return nil }
        return "(\(amount) for \(recipe.formattedYield(yields)))"
    }
}

@available(macOS 12, *)
extension AttributedStringProtocol {
    func bullets() -> [AttributedSubstring] {
        runs[\.presentationIntent].flatMap { run in
            var result = self[run.1].split(separator: " • ")
            if !result.isEmpty, let range = result[0].range(of: "• ", options: .anchored) {
                result[0] = result[0][range.upperBound...]
            }
            return result
        }
    }
}
