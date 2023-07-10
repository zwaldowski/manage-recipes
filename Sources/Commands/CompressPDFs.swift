import ArgumentParser
import Foundation
import PDFKit
import UniformTypeIdentifiers

struct CompressPDFs: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "compress-pdfs")

    @Option(
        completion: .directory,
        transform: directory)
    var input: URL
    
    @Option(
        completion: .directory,
        transform: directory)
    var output: URL
    
    func run() async throws {
        for pdfURL in try FileManager.default.contentsOfDirectory(at: input, includingPropertiesForKeys: [ .contentTypeKey ]) {
            guard try pdfURL.resourceValues(forKeys: [ .contentTypeKey ]).contentType?.conforms(to: .pdf) == true else { continue }

            let pdf = PDFDocument(url: pdfURL)!
            for i in 0 ..< pdf.pageCount {
                let page = pdf.page(at: i)!
                page.setBounds(page.bounds(for: .trimBox), for: .mediaBox)
            }

            let maybeCompressedURL = output.appendingPathComponent(pdfURL.deletingPathExtension().lastPathComponent, conformingTo: .pdf)
            pdf.write(to: maybeCompressedURL)
        }

        print("Done!")
    }

}
