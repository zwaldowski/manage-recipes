import ArgumentParser
import Foundation

struct FreshDownloadImages: AsyncParsableCommand {
    
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
        let oldIDs = try Set<String>(jsonContentsOf: oldRecipeIdsURL)
        var new = try [HelloFresh.Recipe](jsonContentsOf: newRecipesURL)
        new.removeAll { oldIDs.contains($0.id) }

        print("Today, the download is: \(new.count) recipes")
        
        let session = URLSession(configuration: .ephemeral)
        defer { session.finishTasksAndInvalidate() }
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for recipe in new {
                group.addTask {
                    try await downloadImage(for: recipe, using: session)
                }

                for step in recipe.steps {
                    group.addTask {
                        try await downloadImage(for: step, in: recipe, using: session)
                    }
                }
            }
            
            try await group.waitForAll()
        }

        print("Done!")
    }
    
    func downloadImage(for recipe: HelloFresh.Recipe, using session: URLSession) async throws {
        var remoteComponents = URLComponents()
        remoteComponents.scheme = "https"
        remoteComponents.host = "img.hellofresh.com"
        remoteComponents.path = "/f_auto,fl_lossy,h_1000,q_auto/hellofresh_s3\(recipe.imagePath)"

        guard let remoteURL = remoteComponents.url else { return }

        let imagesURL = output
            .appendingPathComponent(recipe.fileName)

        let localURL = imagesURL
            .appendingPathComponent("card")
            .appendingPathExtension(remoteURL.pathExtension)

        try await session.downloadIfNeeded(from: remoteURL, to: localURL)
    }

    func downloadImage(for step: HelloFresh.Step, in recipe: HelloFresh.Recipe, using session: URLSession) async throws {
        guard let image = step.images.first else { return }
        var remoteComponents = URLComponents()
        remoteComponents.scheme = "https"
        remoteComponents.host = "img.hellofresh.com"
        remoteComponents.path = "/f_auto,fl_lossy,h_704,q_auto/hellofresh_s3\(image.path)"
        guard let remoteURL = remoteComponents.url else { return }

        let imagesURL = output
            .appendingPathComponent(recipe.fileName)

        let localURL = imagesURL
            .appendingPathComponent("step-\(step.index)")
            .appendingPathExtension(remoteURL.pathExtension)

        try await session.downloadIfNeeded(from: remoteURL, to: localURL)
    }
    
}
