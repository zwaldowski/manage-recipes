import Foundation
import HTMLAttributedString

enum BlueApron {

    struct Plan: Codable, Identifiable {

        enum Kind: String, Codable {
            case food
            case wine
        }

        enum CodingKeys: String, CodingKey {
            case id
            case kind = "type"
        }

        let id: UInt64
        let kind: Kind

        static let food = Plan(id: 1, kind: .food)

    }

    struct Subscription: Codable, Identifiable {

        enum CodingKeys: String, CodingKey {
            case id
            case isActive = "is_active"
            case plan
        }

        let id: UInt64
        let isActive: Bool
        let plan: Plan

        init(id: UInt64, isActive: Bool = true, plan: BlueApron.Plan) {
            self.id = id
            self.isActive = isActive
            self.plan = plan
        }


    }

    struct User: Codable {
        let subscriptions: [Subscription]
    }

    struct Order: Codable, Identifiable {

        enum CodingKeys: String, CodingKey {
            case id
            case arrival = "arrival_date"
            case recipes
        }

        let id: UInt64
        let arrival: Date
        let recipes: [Recipe]

    }

    struct CookTime: Codable {

        enum CodingKeys: String, CodingKey {
            case min
            case max
            case average = "avg"
        }

        let min: Int?
        let max: Int?
        let average: Int?

    }

    struct CookTimes: Codable {
        let prep: CookTime?
        let cook: CookTime?
        let overall: CookTime?
    }

    struct Ingredient: Codable, Identifiable {

        struct Name: Codable, Equatable {
            let quantity: String
            let unit: String
            let descriptor: String
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case sortOrder = "sort_order"
        }

        let id: UInt64
        let name: Name
        let sortOrder: Int

    }

    struct Step: Codable {

        let sortOrder: Int
        let title: String
        let textHTML: String
        let imageURL: URL?

        enum CodingKeys: String, CodingKey {
            case sortOrder = "step_number"
            case title = "step_title"
            case textHTML = "step_text"
            case imageURL = "recipe_step_image_url"
        }

    }

    struct Product: Codable {

        struct Producible: Codable {

            enum Kind: String, Codable {
                case wine
            }

            struct Wine: Codable, Identifiable {

                struct Varietal: Codable, Identifiable {
                    let id: UInt64
                    let name: String
                }

                let id: UInt64
                let varietals: [Varietal]

            }

            let kind: Kind
            let wine: Wine?

            enum CodingKeys: String, CodingKey {
                case kind = "type"
                case wine
            }

        }

        let id: UInt64
        let producible: Producible

    }

    struct Recipe: Identifiable, Codable, CustomReflectable {

        struct Image: Codable {

            enum Kind: String, Codable {
                case newsletter = "square_newsletter_image"
                case main = "main_dish_image"
            }

            enum Format: String, Codable {
                case square = "main_square"
                case squareRetina = "main_square_2x"
                case highResolution = "hi_res"
                case highResolutionFeature = "high_feature"
                case feature = "splash_feature"
                case featureRetina = "splash_feature_retina"
            }

            enum CodingKeys: String, CodingKey {
                case kind = "type"
                case format
                case url
            }

            let kind: Kind
            let format: Format
            let url: URL

        }

        struct Pairing: Codable {

            enum CodingKeys: String, CodingKey {
                case description
                case product = "paired_product"
            }

            let description: String
            let product: Product?

        }

        struct LastDelivery: Codable {

            enum CodingKeys: String, CodingKey {
                case deliveredAt = "delivered_at"
            }

            let deliveredAt: Date

        }

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case mainTitle = "main_title"
            case subTitle = "sub_title"
            case slug
            case calories = "calories_per_serving"
            case cookTimes = "times"
            case images = "images"
            case descriptionHTML = "description"
            case ingredients
            case steps = "recipe_steps"
            case pairings = "product_pairings"
            case servings
            case createdAt = "created_at"
            case lastDelivery = "last_delivery"
        }

        let id: UInt64
        let title: String
        let mainTitle: String
        let subTitle: String
        let slug: String
        let calories: String?
        let cookTimes: CookTimes
        let images: [Image]
        let descriptionHTML: String?
        let ingredients: [Ingredient]
        let steps: [Step]?
        let pairings: [Pairing]?
        let servings: String?
        let createdAt: Date?
        let lastDelivery: LastDelivery?

        var customMirror: Mirror {
            Mirror(self, unlabeledChildren: [ title ])
        }

    }

    enum Requests {

        enum Users {

            static var url: URL {
                URL(string: "https://www.blueapron.com/api/users")!
            }

        }

        struct Orders {

            var subscriptionID: BlueApron.Subscription.ID
            var page: Int

            init(subscriptionID: BlueApron.Subscription.ID, page: Int) {
                self.subscriptionID = subscriptionID
                self.page = page
            }

            var url: URL {
                URL(string: "https://www.blueapron.com/api/subscriptions/\(subscriptionID)/orders/past?page=\(page)&per_page=50")!
            }

        }

        struct RecipeDetails {

            var recipeID: BlueApron.Recipe.ID

            init(recipeID: BlueApron.Recipe.ID) {
                self.recipeID = recipeID
            }

            var url: URL {
                URL(string: "https://www.blueapron.com/api/recipes/\(recipeID)")!
            }

        }

    }

    enum Responses {

        static let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }()

        struct Users: Codable {
            let user: User
        }

        struct Orders: Codable {
            let orders: [Order]
            let meta: Meta

            struct Meta: Codable {
                let pagination: Pagination

                struct Pagination: Codable {
                    let nextPage: Int?

                    enum CodingKeys: String, CodingKey {
                        case nextPage = "next_page"
                    }
                }
            }
        }

        struct RecipeDetails: Codable {
            let recipe: Recipe
        }

    }

}

extension BlueApron.CookTime: CustomStringConvertible {

    func localizedString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let components = [
            DateComponentsFormatter.localizedString(from: DateComponents(minute: min), unitsStyle: style),
            DateComponentsFormatter.localizedString(from: DateComponents(minute: max), unitsStyle: style)
        ].compactMap { $0 }.ifNotEmpty ?? [ "??? min" ]
        return components.joined(separator: " – ")
    }

    var description: String {
        return localizedString(style: .brief)
    }

}

extension BlueApron.CookTimes: CustomStringConvertible {

    var description: String {
        guard let cookTime = overall ?? cook ?? prep else { return "???" }
        return "\(cookTime)"
    }

}

extension BlueApron.Ingredient: Comparable {

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

}

extension BlueApron.Ingredient.Name: CustomStringConvertible {

    var description: String {
        [ quantity, unit, descriptor ].lazy
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

}

extension BlueApron.Step: Comparable {

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

}

extension BlueApron.Recipe.Image.Kind: CaseIterable, Comparable {

    static func < (lhs: Self, rhs: Self) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }

}

extension BlueApron.Recipe.Image.Format: CaseIterable, Comparable {

    static func < (lhs: Self, rhs: Self) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }

}

extension BlueApron.Recipe: CustomDebugStringConvertible {

    var url: URL {
        return URL(string: "https://www.blueapron.com/recipes/\(slug)")!
    }

    var pdfURL: URL? {
        guard let descriptionHTML = descriptionHTML else { return nil }
        let attributedString = AttributedString(html: descriptionHTML, options: .appKit)
        return attributedString.runs[\.link].last {
            $0.0 != nil && attributedString[$0.1].contains("RECIPE CARD")
        }?.0
    }

    var fileName: String {
        return [
            title,
            "(\(id))"
        ].compactMap { $0 }.joined(separator: " ")
    }

    var debugDescription: String {
        return [
            title,
            "",
            calories.map { " - Calories: \($0)" },
            cookTimes.overall.map { " - Cook Time: \($0)" },
            "",
            descriptionHTML,
            "",
            url.absoluteString
        ].lazy.compactMap { $0 }.joined(separator: "\n")
    }

    var isHeatAndEat: Bool {
        switch ingredients.count {
        case 0:
            guard let minOverallTime = cookTimes.overall?.min else { return false }
            return minOverallTime == 0
        case 1:
            guard let maxOverallTime = cookTimes.overall?.max else { return false }
            return maxOverallTime <= 15
        case _:
            return false
        }
    }
}

extension BlueApron.Recipe.Image: CustomDebugStringConvertible {

    var debugDescription: String {
        "\(kind.rawValue) - \(format.rawValue) (\(url.absoluteString))"
    }

}
