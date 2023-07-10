import Foundation

enum Plated {}

extension Plated {
    struct Recipe: Codable, Identifiable {
        var mealCourse: MealCourse
        var recipeDescription: String
        var subtitle: String?
        var calories: String
        var cookTime: CookTime
        var pantryItemsFull: [Ingredient]
        var title: String
        var equipment: [String]
        var id: Int
        var slug: String
        var ingredientsFull: [Ingredient]
        var difficulty: Difficulty
        var cookingTip: String
        var nativeImages: [NativeImage]
        var steps: [Step]

        enum CodingKeys: String, CodingKey {
            case mealCourse
            case recipeDescription = "description"
            case subtitle, calories, cookTime
            case pantryItemsFull = "pantry_items_full"
            case title, equipment
            case id = "recipeId"
            case slug
            case ingredientsFull = "ingredients_full"
            case difficulty
            case cookingTip = "cooking_tip"
            case nativeImages, steps
        }
    }

    struct CookTime: Codable {
        var min, max: Components

        struct Components: Codable {
            var days, hours, minutes: Int
        }
    }

    enum Difficulty: String, Codable {
        case challenging = "challenging"
        case easy = "easy"
        case medium = "medium"
    }

    enum MeasurementUnit: String, Codable {
        case bulb = "bulb"
        case bunch = "bunch"
        case can = "can"
        case clove = "clove"
        case container = "container"
        case cup = "cup"
        case each = "each"
        case empty = ""
        case fillet = "fillet"
        case head = "head"
        case ounce = "ounce"
        case package = "package"
        case packet = "packet"
        case pint = "pint"
        case pound = "pound"
        case round = "round"
        case slice = "slice"
        case tablespoon = "tablespoon"
        case teaspoon = "teaspoon"
    }

    enum MealCourse: String, Codable {
        case brunch = "brunch"
        case dessert = "dessert"
        case main = "main"
    }

    struct Ingredient: Codable {
        var quantity: String?
        var measurementUnit: MeasurementUnit?
        var displayOrder: Int
        var imageURL: URL
        var name: String

        enum CodingKeys: String, CodingKey {
            case quantity, measurementUnit, displayOrder
            case imageURL = "imageUrl"
            case name
        }
    }

    struct NativeImage: Codable {
        var image: Image
    }

    struct Image: Codable {
        var url: URL
        var size: Size
        var type: TypeEnum

        enum Size: String, Codable {
            case full = "full"
            case hero = "hero"
            case largeCropped = "large_cropped"
            case largeRectangle = "large-rectangle"
            case mediumRectangle = "medium-rectangle"
            case mediumSquare = "medium-square"
            case smallSquare = "small-square"
        }

        enum TypeEnum: String, Codable {
            case card = "card"
            case main = "main"
            case mainCropped = "main_cropped"
            case portrait = "portrait"
        }
    }

    struct Step: Codable {
        var title, stepDescription: String
        var imageURL: URL

        enum CodingKeys: String, CodingKey {
            case title
            case stepDescription = "description"
            case imageURL = "imageUrl"
        }
    }
}

extension Plated.Recipe: CustomDebugStringConvertible, CustomReflectable {
    var debugDescription: String {
        title
    }

    var customMirror: Mirror {
        Mirror(self, unlabeledChildren: [ title ])
    }

    var pathComponent: String {
        [
            title,
            subtitle,
            "(\(id))"
        ]
        .compactMap { $0?.ifNotEmpty }
        .joined(separator: " ")
    }
}

extension Plated.Recipe {
    var categories: [String] {
        switch mealCourse {
        case .brunch:
            return [ "Brunch" ]
        case .dessert:
            return [ "Dessert" ]
        case .main:
            return [ "Dinner" ]
        }
    }
}

extension Plated.CookTime.Components: CustomStringConvertible {
    var dateComponents: DateComponents {
        DateComponents(
            day: days > 0 ? days : nil,
            hour: hours > 0 ? hours : nil,
            minute: minutes > 0 ? minutes : nil)
    }

    var description: String {
        DateComponentsFormatter.localizedString(from: dateComponents, unitsStyle: .brief) ?? "??? min"
    }
}

extension Plated.Difficulty: CustomStringConvertible {
    var description: String {
        switch self {
        case .challenging:
            return "Challenging"
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        }
    }
}

extension Plated.CookTime: CustomStringConvertible {
    var description: String {
        if min.days == 0, min.hours == 0, min.minutes != 0, max.days == 0, max.hours == 0, max.minutes != 0 {
            return "\(min.minutes)-\(max.minutes) min"
        } else {
            return "\(max)"
        }
    }
}

extension Plated.Ingredient: CustomStringConvertible {
    var description: String {
        [ prettyQuantity, prettyUnit, name ]
            .compactMap { $0?.ifNotEmpty }
            .joined(separator: " ")
    }
}

extension Plated.Ingredient {
    var prettyQuantity: String? {
        switch quantity.flatMap(Double.init) {
        case 0.125:
            return "⅛"
        case 0.25:
            return "¼"
        case 0.33:
            return "⅓"
        case 0.5:
            return "½"
        case 0.66:
            return "⅔"
        case 0.75:
            return "¾"
        case 1.25:
            return "1¼"
        case 1.5:
            return "1½"
        case 2.25:
            return "2¼"
        case 2.5:
            return "2½"
        case 3.5:
            return "3½"
        case 4.5:
            return "4½"
        case let other?:
            return other.formatted()
        case nil:
            return quantity
        }
    }

    var prettyUnit: String? {
        switch measurementUnit {
        case .cup:
            return "c"
        case .ounce:
            return "oz"
        case .package:
            return "pkg"
        case .pint:
            return "pt"
        case .pound:
            return "lb"
        case .tablespoon:
            return "tbsp"
        case .teaspoon:
            return "tsp"
        case .empty, .each, nil:
            return nil
        case let other?:
            return other.rawValue
        }
    }
}

