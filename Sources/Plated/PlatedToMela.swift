import Foundation

extension Plated {
    static func convertToMela(_ recipes: some Sequence<Recipe>, baseURL: URL) throws {
        let imagesBaseURL = baseURL
            .appendingPathComponent("Images", isDirectory: true)
        let outputBaseURL = baseURL
            .appendingPathComponent("Mela", isDirectory: true)
        try FileManager.default.createDirectory(at: outputBaseURL, withIntermediateDirectories: true)

        for input in recipes {
            var output = Mela.Recipe()
            output.title = input.title
            output.text = String(html: input.recipeDescription, preservingWhitespace: true)
            output.categories = input.categories
            output.yield = "2"
            output.totalTime = "\(input.cookTime)"
            output.ingredients = (input.ingredientsFull.sorted { $0.displayOrder < $1.displayOrder } + input.pantryItemsFull.sorted { $0.displayOrder < $1.displayOrder }).map { "\($0)" }.joined(separator: "\n")
            output.instructions = try input.steps.map { step in
                """
                # \(step.title)
                \(try Mela.sanitizedMarkdownFromHTML(step.stepDescription, allowHeaders: false))
                """
            }
            .joined(separator: "\n")
            output.notes = try Mela.sanitizedMarkdownFromHTML(input.cookingTip, allowHeaders: true)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            output.nutrition = """
            **Calories**: \(input.calories)
            **Difficulty**: \(input.difficulty)
            """
            output.link = "Plated"

            let cardImageURL = imagesBaseURL
                .appendingPathComponent(input.pathComponent, isDirectory: true)
                .appendingPathComponent("card-resized", isDirectory: false)
                .appendingPathExtension("heic")
            if let cardImageData = try? Data(contentsOf: cardImageURL) {
                output.images.append(cardImageData)
            }

            let outputURL = outputBaseURL
                .appendingPathComponent(input.pathComponent, isDirectory: false)
                .appendingPathExtension("melarecipe")
            try output.writeJSONContents(to: outputURL)
        }
    }
}
