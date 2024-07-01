import Foundation
import HTMLAttributedString

enum BlueApron {

    struct CookTime: Codable {
        enum CodingKeys: String, CodingKey {
            case min
            case max
            case average = "avg"
        }

        var min: Int?
        var max: Int?
        var average: Int?
    }

    struct CookTimes: Codable {
        var prep: CookTime?
        var cook: CookTime?
        var overall: CookTime?
    }

    struct Ingredient: Codable {
        var unit: String?
        var amount: String
        var descriptor: String
        var displayPriority: Int
    }

    struct Step: Codable {
        var number: Int
        var title: String
        var textHTML: String
        var imageURL: URL?
    }

    struct Recipe: Identifiable, Codable, CustomReflectable {
        var sku: String
        var fullName: String
        var mainName: String
        var subName: String?
        var url: URL
        var calories: Int?
        var cookTimes: CookTimes
        var primaryImage: URL?
        var descriptionHTML: String?
        var ingredients: [Ingredient]
        var steps: [Step]?
        var servings: String?
        var createdDate: Date?
        var lastDeliveredDate: Date?

        var id: String {
            sku
        }

        var customMirror: Mirror {
            Mirror(self, unlabeledChildren: [ fullName ])
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

extension BlueApron.Ingredient: Comparable, CustomStringConvertible {

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.displayPriority < rhs.displayPriority
    }

    var description: String {
        [ amount, unit, descriptor ]
            .lazy
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

}

extension BlueApron.Step: Comparable {

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.number < rhs.number
    }

}


extension BlueApron.Recipe: CustomDebugStringConvertible {

    init?(from lineItem: ApronQL.PastOrdersQuery.Data.PastOrders.Node.LineItem, order: ApronQL.PastOrdersQuery.Data.PastOrders.Node) {
        guard let recipe = lineItem.variant.asRecipe else { return nil }
        self.init(
            sku: recipe.sku,
            fullName: recipe.name.full,
            mainName: recipe.name.main,
            subName: recipe.name.sub,
            url: recipe.url,
            calories: recipe.nutritionInfo.accurateServingCalories,
            cookTimes: BlueApron.CookTimes(
                overall: BlueApron.CookTime(
                    min: recipe.times.overall.min,
                    max: recipe.times.overall.max,
                    average: recipe.times.overall.average)),
            primaryImage: recipe.images?.primary?.url,
            descriptionHTML: recipe.description,
            ingredients: recipe.ingredients.map { ingredient in
                BlueApron.Ingredient(
                    unit: ingredient.unit,
                    amount: ingredient.amount,
                    descriptor: ingredient.description,
                    displayPriority: ingredient.displayPriority)
            },
            steps: recipe.steps.map { step in
                BlueApron.Step(
                    number: step.number,
                    title: step.title,
                    textHTML: step.text,
                    imageURL: step.image?.url)
            },
            servings: recipe.nutritionInfo.displayServingsCount,
            createdDate: order.createdDate,
            lastDeliveredDate: order.scheduledArrivalDate)
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
            fullName,
            "(\(id))"
        ].compactMap { $0 }.joined(separator: " ")
    }

    var debugDescription: String {
        return [
            fullName,
            "",
            calories.map { " - Calories: \($0)" },
            cookTimes.overall.map { " - Cook Time: \($0)" },
            "",
            descriptionHTML,
            "",
            url.absoluteString
        ].lazy.compactMap { $0 }.joined(separator: "\n")
    }

}
