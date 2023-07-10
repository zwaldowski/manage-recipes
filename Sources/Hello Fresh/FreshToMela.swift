import ArgumentParser
import Foundation

struct FreshToMela: AsyncParsableCommand {
    
    @Option(
        name: .customLong("old-recipe-ids-url"),
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var oldRecipeIDsURL: URL
    
    @Option(
        name: .customLong("new-recipe-ids-url"),
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipeIDsURL: URL
    
    @Option(
        name: .customLong("new-recipes-url"),
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipesURL: URL
    
    @Option(
        completion: .directory,
        transform: directory)
    var output: URL
    
    @Option(
        completion: .directory,
        transform: directory)
    var images: URL
    
    func run() async throws {
        let oldIDs = try Set<String>(jsonContentsOf: oldRecipeIDsURL)
        var recipes = try [HelloFresh.Recipe](jsonContentsOf: newRecipesURL)
        recipes.removeAll { oldIDs.contains($0.id) }

        for input in recipes {
            var result = Mela.Recipe()
            result.title = input.name
            result.text = String(html: input.descriptionHTML, preservingWhitespace: true)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let yield = input.yields.first {
                result.yield = input.formattedYield(yield.yields)
            }
            result.prepTime = "\(input.prepTime)"
            if let totalTime = input.totalTime {
                result.totalTime = "\(totalTime)"
            }
            if let yield = input.yields.first {
                result.ingredients = yield.ingredients.map { ingredient in
                    [
                        ingredient.formattedAmount(),
                        input.ingredients.first(where: { $0.id == ingredient.id })?.name
                    ]
                    .compactMap { $0 }
                    .joined(separator: " ")
                }
                .joined(separator: "\n")
            }
            result.instructions = try input.steps.map { (step) -> String in
                if let image = step.images.first {
                    return """
                    # \(image.caption)
                    \(try AttributedString(html: step.instructionsHTML, options: .appKit).bullets().map {
                        try Mela.sanitizedMarkdownFromStructured($0, allowHeaders: false)
                    }.joined(separator: "\n"))
                    """
                } else {
                    return try Mela.sanitizedMarkdownFromHTML(step.instructionsHTML, allowHeaders: false)
                }
            }
            .joined(separator: "\n")
            result.nutrition = input.nutrition.map {
                "**\($0.name)**: \($0.amount.formatted()) \($0.unit.rawValue)"
            }
            .joined(separator: "\n")
            result.link = input.websiteURL?.absoluteString
            result.date = input.updatedAt

            let cardImageURL = images
                .appendingPathComponent(input.fileName, isDirectory: true)
                .appendingPathComponent("card", isDirectory: false)
                .appendingPathExtension("jpg")
            if let cardImageData = try? Data(contentsOf: cardImageURL) {
                result.images.append(cardImageData)
            }

            let outputURL = output
                .appendingPathComponent(input.fileName, isDirectory: false)
                .appendingPathExtension("melarecipe")
            try result.writeJSONContents(to: outputURL)
        }

        print("Done!")
    }
    
}
