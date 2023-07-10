import ArgumentParser
import Foundation

struct ApronDownloadPDFs: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "apron-download-pdfs")
    
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
                    try await downloadRecipePDF(for: recipe, using: session)
                }
            }
            
            try await group.waitForAll()
        }

        print("Done!")
    }
    

    func downloadRecipePDF(for recipe: BlueApron.Recipe, using session: URLSession) async throws {
        guard let remoteURL = recipe.pdfURL else { return }

        let localURL = output
            .appendingPathComponent(recipe.fileName)
            .appendingPathExtension(for: .pdf)

        try await session.downloadIfNeeded(from: remoteURL, to: localURL)
    }
    
}
