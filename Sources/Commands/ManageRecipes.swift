import ArgumentParser

@main
struct ManageRecipes: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [
            ApronDownloadRecipes.self,
            ApronDownloadImages.self,
            ApronDownloadPDFs.self,
            ApronRemoveDupes.self,
            ApronToMela.self,
            ApronToNotes.self,
            FreshDownloadRecipes.self,
            FreshDownloadImages.self,
            FreshDownloadPDFs.self,
            FreshToMela.self,
            FreshToNotes.self,
            CompressPDFs.self
        ])
}
