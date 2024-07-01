import ArgumentParser
import Foundation

struct ApronToMela: AsyncParsableCommand {
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var oldRecipeSkusURL: URL
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipeSkusURL: URL
    
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
        let oldSKUs = try Set<BlueApron.Recipe.ID>(jsonContentsOf: oldRecipeSkusURL)
        let recipes = try [BlueApron.Recipe](jsonContentsOf: newRecipesURL)
            .filter { !oldSKUs.contains($0.id) }

        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

        for input in recipes {
            var result = Mela.Recipe()
            result.title = input.fullName
            if let descriptionHTML = input.descriptionHTML {
                var description = String(html: descriptionHTML, preservingWhitespace: true)
                if let range = description.range(of: "\nCLICK FOR RECIPE CARD", options: [.anchored, .backwards]) {
                    description.removeSubrange(range)
                }
                result.text = description
            }
            result.yield = input.servings
            result.totalTime = "\(input.cookTimes)"
            result.ingredients = input.ingredients.sorted().map { "\($0)" }.joined(separator: "\n")
            result.instructions = try input.steps?.sorted().map { step in
                """
                # \(step.title)
                \(try Mela.sanitizedMarkdownFromHTML(step.textHTML, allowHeaders: false))
                """
            }
            .joined(separator: "\n")
            result.nutrition = """
            **Calories**: \(input.calories?.formatted() ?? "???") per serving
            """
            result.link = input.url.absoluteString
            result.date = input.lastDeliveredDate

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
