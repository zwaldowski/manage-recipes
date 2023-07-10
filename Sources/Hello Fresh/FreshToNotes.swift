import ArgumentParser
import Foundation
import NotesArchive

struct FreshToNotes: AsyncParsableCommand {
    
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
        let namespace = UUID(uuidString: "04B0B150-6D58-46C9-A040-12B619826D54")!
        let hashtagID = UUID(uuidString: "5E89576C-D628-4BDB-9B82-63EED08D99AB")!

        let oldIDs = try Set<String>(jsonContentsOf: oldRecipeIDsURL)
        var recipes = try [HelloFresh.Recipe](jsonContentsOf: newRecipesURL)
        recipes.removeAll { oldIDs.contains($0.id) }

        var folder = Folder(metadata: Folder.Metadata(title: "Hello Fresh \(Date.now.formatted(.shortISODate))"))

        for recipe in recipes {
            let imagesURL = images
                .appendingPathComponent(recipe.fileName, isDirectory: true)

            let metadata = Note.Metadata(
                identifier: UUID(hashing: recipe.fileName, inNamespace: namespace),
                createdAt: recipe.createdAt,
                modifiedAt: recipe.updatedAt,
                title: recipe.name,
                attachmentViewType: .thumbnail)
            var note = Note(metadata: metadata)

            note.metadata.content.append(recipe.name, paragraphStyle: Note.Content.ParagraphStyle(name: .title))

            note.metadata.content.newParagraph()
            note.metadata.content.append(recipe.headline, paragraphStyle: Note.Content.ParagraphStyle(name: .heading))

            if let descriptionHTML = recipe.descriptionHTML.ifNotEmpty {
                note.metadata.content.newBlock()

                var description = AttributedString(html: descriptionHTML, options: .appKit)
                description.trim()
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
            note.metadata.content.append("\(recipe.prepTime)\n")
            if let totalTime = recipe.totalTime {
                note.metadata.content.append("Total time: ", font: .default.bold())
                note.metadata.content.append("\(totalTime)\n")
            }
            if let yield = recipe.yields.first {
                note.metadata.content.append("Yield: ", font: .default.bold())
                note.metadata.content.append("\(recipe.formattedYield(yield.yields))\n")
            }
            if let calories = recipe.nutrition.first(where: { $0.unit == .kilocalorie }) {
                note.metadata.content.append("\(calories.name): ", font: .default.bold())
                note.metadata.content.append("\(calories.amount.formatted()) per serving")
            }

            if let yield = recipe.yields.first {
                let otherYield = recipe.yields.dropFirst().first
                note.metadata.content.newBlock()
                note.metadata.content.append("Ingredients\n", paragraphStyle: Note.Content.ParagraphStyle(name: .heading))
                for ingredient in yield.ingredients {
                    let description = [
                        ingredient.formattedAmount(),
                        recipe.ingredients.first(where: { $0.id == ingredient.id })?.name,
                        otherYield?.formattedAmount(for: ingredient, in: recipe)
                    ]
                    .compactMap { $0 }
                    .joined(separator: " ")
                    note.metadata.content.append("\(description)\n", paragraphStyle: Note.Content.ParagraphStyle(name: .checklist, checklistItem: Note.Content.ChecklistItem()))
                }
            }

            if let steps = recipe.steps.ifNotEmpty?.sorted(by: { $0.index < $1.index }) {
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

                    if let image = step.images.first {
                        note.metadata.content.append("\(index + 1). \(image.caption)\n", paragraphStyle: Note.Content.ParagraphStyle(name: .subheading))

                        let instructions = AttributedString(html: step.instructionsHTML, options: .appKit)
                        let bullets = instructions.bullets()
                        let paragraphStyle = Note.Content.ParagraphStyle(name: bullets.count > 1 ? .bulletList : .body)
                        for bullet in bullets {
                            let item = Note.Content(from: bullet, paragraphStyle: paragraphStyle)
                            note.metadata.content.newParagraph()
                            note.metadata.content.append(item)
                        }
                    } else {
                        let instructions = AttributedString(html: step.instructionsHTML, options: .appKit)
                        let content = Note.Content(from: instructions, paragraphStyle: Note.Content.ParagraphStyle(name: .numberedList, indent: 0))
                        note.metadata.content.append(content)
                    }
                }
            }

            note.metadata.content.newBlock()
            note.metadata.content.append("Source\n", paragraphStyle: Note.Content.ParagraphStyle(name: .heading))

            let source = Attachment.link(to: recipe.websiteURL, title: "\(recipe.name) | Hello Fresh")
            note.metadata.content.append(source)
            note.attachments.append(source)

            note.metadata.content.newParagraph()
            note.metadata.content.append(Note.Content.InlineAttachment(identifier: hashtagID, contentIdentifier: "HELLO-FRESH", altText: "#hello-fresh", attachmentTypeIdentifier: Note.Content.InlineAttachment.TypeIdentifier.hashtag, createdAt: note.metadata.modifiedAt))

            folder.notes.append(note)
        }

        var archive = Archive()
        archive.folders.append(folder)
        try archive.write(to: output)

        print("Done!")
    }
    
}
