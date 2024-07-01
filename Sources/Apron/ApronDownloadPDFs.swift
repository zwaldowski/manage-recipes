import ArgumentParser
import Foundation

struct ApronDownloadPDFs: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "apron-download-pdfs")
    
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
