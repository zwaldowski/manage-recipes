import ArgumentParser
import Foundation

struct ApronRemoveDupes: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "apron-remove-dupes")

    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipesURL: URL

    @Option(
        name: .customLong("sku"))
    var dupeRecipeSKUs: [String]

    func run() async throws {
        let dupeRecipeSKUs = Set(dupeRecipeSKUs)
        let oldRecipes = try [BlueApron.Recipe](jsonContentsOf: newRecipesURL)
        let newRecipes = oldRecipes
            .filter { !dupeRecipeSKUs.contains($0.id) }

        print("Removed \(oldRecipes.count - newRecipes.count) recipes")

        try newRecipes.writeJSONContents(to: newRecipesURL)
    }

}
