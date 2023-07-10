import ArgumentParser
import Foundation
import NotesArchive

struct ApronToNotes: AsyncParsableCommand {
    
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
        let namespace = UUID(uuidString: "5C20042B-98ED-4B23-8A39-5E06A91BF440")!
        let hashtagID = UUID(uuidString: "5E89576C-D628-4BDB-9B82-63EED08D99AB")!

        let oldIDs = try Set<BlueApron.Recipe.ID>(jsonContentsOf: oldRecipeIDsURL)
        var recipes = try [BlueApron.Recipe](jsonContentsOf: newRecipesURL)
        recipes.removeAll { oldIDs.contains($0.id) }

        var folder = Folder(metadata: Folder.Metadata(title: "Blue Apron \(Date.now.formatted(.shortISODate))"))

        for recipe in recipes {
            let imagesURL = images.appendingPathComponent(recipe.fileName)

            let metadata = Note.Metadata(
                identifier: UUID(hashing: recipe.fileName, inNamespace: namespace),
                createdAt: recipe.lastDelivery?.deliveredAt ?? Date(),
                modifiedAt: recipe.lastDelivery?.deliveredAt ?? Date(),
                title: recipe.title,
                attachmentViewType: .thumbnail)
            var note = Note(metadata: metadata)

            note.metadata.content.append(recipe.mainTitle, paragraphStyle: Note.Content.ParagraphStyle(name: .title))

            note.metadata.content.newParagraph()
            note.metadata.content.append(recipe.subTitle, paragraphStyle: Note.Content.ParagraphStyle(name: .heading))

            if let descriptionHTML = recipe.descriptionHTML?.ifNotEmpty {
                note.metadata.content.newBlock()

                var description = AttributedString(html: descriptionHTML, options: .appKitParagraphs)
                if description.runs[\.link].contains(where: { $0.0?.host == "ww.com" }) {
                    print("!!!", String(descriptionHTML))
                    print()
                    print()
                    print("!!!", String(description.characters))
                    print()
                }
                description.trim()

                if let pdfURL = recipe.pdfURL {
                    if let (_, range) = description.runs[\.link].last(where: { $0.0 == pdfURL }) {
                        description.removeSubrange(range.lowerBound...)
                        description.trim()
                    }
                }

                note.metadata.content.append(description)
            }

            let cardImageURL = imagesURL
                .appendingPathComponent("card", isDirectory: false)
                .appendingPathExtension("jpg")

            if let attachment = try Attachment.image(url: cardImageURL, for: note) {
                note.metadata.content.newBlock()
                note.metadata.content.append(attachment)
                note.attachments.append(attachment)
            }

            note.metadata.content.newBlock()
            note.metadata.content.append("Prep time: ", font: .default.bold())
            note.metadata.content.append("\(recipe.cookTimes)\n")
            note.metadata.content.append("Yield: ", font: .default.bold())
            note.metadata.content.append("\(recipe.servings ?? "2") servings\n")
            note.metadata.content.append("Calories: ", font: .default.bold())
            note.metadata.content.append("\(recipe.calories ?? "???") per serving")
            if let wineVarietals = recipe.pairings?.flatMap({ $0.product?.producible.wine?.varietals ?? [] }).ifNotEmpty?.uniqued() {
                note.metadata.content.append("\n")
                note.metadata.content.append("Suggested wine pairings: ", font: .default.bold())
                note.metadata.content.append(wineVarietals.map(\.name).joined(separator: ", "))
            }

            if let ingredients = recipe.ingredients.ifNotEmpty?.sorted() {
                note.metadata.content.newBlock()
                note.metadata.content.append("Ingredients\n", paragraphStyle: Note.Content.ParagraphStyle(name: .heading))
                for ingredient in ingredients {
                    note.metadata.content.append("\(ingredient.name)\n", paragraphStyle: Note.Content.ParagraphStyle(name: .checklist, checklistItem: Note.Content.ChecklistItem()))
                }
            }

            if let steps = recipe.steps?.ifNotEmpty?.sorted() {
                note.metadata.content.newBlock()
                note.metadata.content.append("Directions\n", paragraphStyle: Note.Content.ParagraphStyle(name: .heading))

                for (index, step) in steps.enumerated() {
                    note.metadata.content.newParagraph()

                    let imageURL = imagesURL
                        .appendingPathComponent("step-\(index + 1)", isDirectory: false)
                        .appendingPathExtension("jpg")
                    if let attachment = try Attachment.image(url: imageURL, for: note) {
                        note.metadata.content.append(attachment)
                        note.attachments.append(attachment)
                    }

                    note.metadata.content.append("\(index + 1). \(step.title)\n", paragraphStyle: Note.Content.ParagraphStyle(name: .subheading))

                    var description = AttributedString(html: step.textHTML, options: .appKit)
                    description.trim()
                    note.metadata.content.append(description)
                }
            }

            note.metadata.content.newBlock()
            note.metadata.content.append("Source\n", paragraphStyle: Note.Content.ParagraphStyle(name: .heading))

            let source = Attachment.link(to: recipe.url, title: "\(recipe.title) | Blue Apron")
            note.metadata.content.append(source)
            note.attachments.append(source)

            note.metadata.content.newParagraph()
            note.metadata.content.append(Note.Content.InlineAttachment(identifier: hashtagID, contentIdentifier: "BLUE-APRON", altText: "#blue-apron", attachmentTypeIdentifier: Note.Content.InlineAttachment.TypeIdentifier.hashtag, createdAt: note.metadata.modifiedAt))

            folder.notes.append(note)
        }

        var archive = Archive()
        archive.folders.append(folder)
        try archive.write(to: output)

        print("Done!")
    }
    
}
