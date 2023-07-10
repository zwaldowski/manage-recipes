import ArgumentParser
import Foundation

struct ApronDownloadImages: AsyncParsableCommand {
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var oldRecipeIdsURL: URL
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipeIdsURL: URL
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipesURL: URL
    
    @Option(
        completion: .directory,
        transform: directory)
    var output: URL

    func run() async throws {
        let oldIDs = try Set<BlueApron.Recipe.ID>(jsonContentsOf: oldRecipeIdsURL)
        var new = try [BlueApron.Recipe](jsonContentsOf: newRecipesURL)
        new.removeAll { oldIDs.contains($0.id) }

        print("Today, the download is: \(new.count) recipes")
        
        let session = URLSession(configuration: .ephemeral)
        defer { session.finishTasksAndInvalidate() }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for recipe in new {
                group.addTask {
                    try await downloadImage(for: recipe, using: session)
                }
                
                for step in recipe.steps ?? [] {
                    group.addTask {
                        try await downloadImage(for: step, in: recipe, using: session)
                    }
                }
            }
            
            try await group.waitForAll()
        }
        
        print("Done!")
    }
    
    func bestImage(for recipe: BlueApron.Recipe) -> BlueApron.Recipe.Image? {
        recipe.images.lazy
            .filter { $0.kind == .main }
            .max { $0.format < $1.format }
    }

    func downloadImage(for recipe: BlueApron.Recipe, using session: URLSession) async throws {
        guard let image = bestImage(for: recipe) else { return }
        let remoteURL = image.url

        let imagesURL = output
            .appendingPathComponent(recipe.fileName)

        let localURL = imagesURL
            .appendingPathComponent("card")
            .appendingPathExtension(remoteURL.pathExtension)

        try await session.downloadIfNeeded(from: remoteURL, to: localURL)
    }
    
    func downloadImage(for step: BlueApron.Step, in recipe: BlueApron.Recipe, using session: URLSession) async throws {
        guard let remoteURL = step.imageURL else { return }

        let imagesURL = output
            .appendingPathComponent(recipe.fileName)

        let localURL = imagesURL
            .appendingPathComponent("step-\(step.sortOrder)")
            .appendingPathExtension(remoteURL.pathExtension)

        try await session.downloadIfNeeded(from: remoteURL, to: localURL)
    }

}
