import ArgumentParser
import Foundation

struct ApronToMela: AsyncParsableCommand {
    
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
        let oldIDs = try Set<BlueApron.Recipe.ID>(jsonContentsOf: oldRecipeIDsURL)
        var recipes = try [BlueApron.Recipe](jsonContentsOf: newRecipesURL)
        recipes.removeAll { oldIDs.contains($0.id) }

        for input in recipes {
            var result = Mela.Recipe()
            result.title = input.mainTitle
            if let descriptionHTML = input.descriptionHTML {
                var description = String(html: descriptionHTML, preservingWhitespace: true)
                if let range = description.range(of: "\nCLICK FOR RECIPE CARD", options: [.anchored, .backwards]) {
                    description.removeSubrange(range)
                }
                result.text = description
            }
            result.yield = input.servings
            result.totalTime = "\(input.cookTimes)"
            result.ingredients = input.ingredients.sorted().map { "\($0.name)" }.joined(separator: "\n")
            result.instructions = try input.steps?.sorted().map { step in
                """
                # \(step.title)
                \(try Mela.sanitizedMarkdownFromHTML(step.textHTML, allowHeaders: false))
                """
            }
            .joined(separator: "\n")
            if let wineVarietals = input.pairings?.flatMap({ $0.product?.producible.wine?.varietals ?? [] }).ifNotEmpty?.uniqued() {
                result.notes = """
                **Suggested wine pairings:**: \(wineVarietals.map(\.name).joined(separator: ", "))
                """
            }
            result.nutrition = """
            **Calories**: \(input.calories ?? "???") per serving
            """
            result.link = input.url.absoluteString
            result.date = input.lastDelivery?.deliveredAt

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
