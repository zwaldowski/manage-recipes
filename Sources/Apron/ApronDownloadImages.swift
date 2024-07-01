import ArgumentParser
import Foundation

struct ApronDownloadImages: AsyncParsableCommand {
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var oldRecipeSkusURL: URL
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipeSkusURL: URL
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipesURL: URL
    
    @Option(
        completion: .directory,
        transform: directory)
    var output: URL

    func run() async throws {
        let oldSKUs = try Set<BlueApron.Recipe.ID>(jsonContentsOf: oldRecipeSkusURL)
        let new = try [BlueApron.Recipe](jsonContentsOf: newRecipesURL)
            .filter { !oldSKUs.contains($0.id) }

        print("Today, the download is: \(new.count) recipes")
        
        let session = URLSession(configuration: .ephemeral)
        defer { session.finishTasksAndInvalidate() }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for recipe in new {
                group.addTask {
                    try await downloadImage(for: recipe, using: session)
                }
            }
            
            try await group.waitForAll()
        }
        
        print("Done!")
    }

    func downloadImage(for recipe: BlueApron.Recipe, using session: URLSession) async throws {
        guard let remoteURL = recipe.primaryImage else { return }

        let imagesURL = output
            .appendingPathComponent(recipe.fileName)

        let localURL = imagesURL
            .appendingPathComponent("card")
            .appendingPathExtension(remoteURL.pathExtension)

        try await session.downloadIfNeeded(from: remoteURL, to: localURL)
    }

}
