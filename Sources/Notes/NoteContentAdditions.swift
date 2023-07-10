import Foundation
import NotesArchive
import Quartz

extension Note.Content {
    
    init(from source: some AttributedStringProtocol, paragraphStyle: ParagraphStyle = ParagraphStyle(name: .body)) {
        let start = NSRange(source.startIndex ..< source.startIndex, in: source)
        let offset = -start.upperBound
        let attributes = source.runs.map { run in
            Attribute(from: run, in: source, paragraphStyle: paragraphStyle)
                .offset(by: offset)
        }
        self.init(text: String(source.characters), attributes: attributes)
    }
    
    mutating func append(_ other: Note.Content) {
        let offset = text.utf16.count
        text.append(contentsOf: other.text)
        attributes.append(contentsOf: other.attributes.map { $0.offset(by: offset) })
    }
    
    mutating func append(_ source: some AttributedStringProtocol) {
        append(Self(from: source))
    }
    
    mutating func append(_ attachment: Attachment) {
        let newText = "\u{fffc}"
        let newAttribute = Attribute(range: Range(startsAt: text.utf16.count, length: newText.utf16.count), paragraphStyle: ParagraphStyle(), writingDirection: .leftToRight, attachmentIdentifier: attachment.metadata.identifier)
        text.append(newText)
        text.append("\n")
        attributes.append(newAttribute)
    }
    
    mutating func append(_ attachment: InlineAttachment) {
        let newText = "\u{fffc}"
        let newAttribute = Attribute(range: Range(startsAt: text.utf16.count, length: newText.utf16.count), paragraphStyle: ParagraphStyle(), writingDirection: .leftToRight, inlineAttachment: attachment)
        text.append(newText)
        attributes.append(newAttribute)
    }
    
    mutating func append(_ newText: String, font: Font? = nil, paragraphStyle: ParagraphStyle? = nil, link: URL? = nil, inlineAttachment: InlineAttachment? = nil) {
        let content = Self(text: newText, attributes: [
            Attribute(range: Range(startsAt: 0, length: newText.utf16.count), font: font, paragraphStyle: paragraphStyle, link: link, inlineAttachment: inlineAttachment)
        ])
        append(content)
    }
    
    mutating func newBlock() {
        guard !text.isEmpty, !text.hasSuffix("\n\n") else { return }
        text += text.hasSuffix("\n") ? "\n" : "\n\n"
    }
    
    mutating func newParagraph() {
        guard !text.isEmpty, !text.hasSuffix("\n") else { return }
        text += "\n"
    }
    
}

extension Attachment {
    
    static func image(url: URL, for note: Note) throws -> Self? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let identifier = CGImageSourceGetType(source),
              let attachmentTypeIdentifier = UTType(identifier as String),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let pixelWidth = properties[kCGImagePropertyPixelWidth] as? CGFloat,
              let pixelHeight = properties[kCGImagePropertyPixelHeight] as? CGFloat
        else { return nil }
        let metadata = Metadata(
            attachmentTypeIdentifier: attachmentTypeIdentifier,
            mediaFilename: url.lastPathComponent,
            createdAt: note.metadata.createdAt,
            modifiedAt: note.metadata.modifiedAt,
            bounds: CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
        var attachment = Attachment(metadata: metadata)
        try attachment.setContents(from: url)
        return attachment
    }
    
}

extension Note.Content.Range {
    
    init(from range: NSRange) {
        self.init(startsAt: range.location, length: range.length)
    }
    
    init(from region: some RangeExpression<AttributedString.Index>, in source: some AttributedStringProtocol) {
        self.init(from: NSRange(region, in: source))
    }
    
}

extension Note.Content.Font {
    
    init?(from attributes: AttributeContainer) {
        let font = attributes.appKit.font
        let isSystemFont = font?.fontName.starts(with: ".") != false
        let inlinePresentationIntent = attributes.inlinePresentationIntent
        let underlineStyle = attributes.appKit.underlineStyle
        let strikethroughStyle = attributes.appKit.strikethroughStyle
        let superscript = attributes.superscript
        let link = attributes.link
        guard font != nil || inlinePresentationIntent != nil || underlineStyle != nil || strikethroughStyle != nil || superscript != nil else { return nil }
        self.init()
        self.name = isSystemFont ? nil : font?.fontName
        self.pointSize = isSystemFont ? nil : font?.pointSize
        self.isBold = font?.fontDescriptor.symbolicTraits.contains(.bold) == true || inlinePresentationIntent?.contains(.stronglyEmphasized) == true
        self.isItalic = font?.fontDescriptor.symbolicTraits.contains(.italic) == true || inlinePresentationIntent?.contains(.emphasized) == true
        self.isUnderline = link == nil && underlineStyle != nil
        self.isStrikethrough = strikethroughStyle != nil
        self.superscript = superscript.map {
            if $0 < 0 {
                return .subscript
            } else if $0 > 0 {
                return .superscript
            } else {
                return .useDefault
            }
        }
    }
    
    static var `default`: Self { Note.Content.Font() }
    
    func bold() -> Self {
        var result = self
        result.isBold = true
        return result
    }
    
    func italic() -> Self {
        var result = self
        result.isItalic = true
        return result
    }
    
}

extension Note.Content.Attribute {
    
    init(from run: AttributedString.Runs.Run, in source: some AttributedStringProtocol, paragraphStyle: Note.Content.ParagraphStyle? = nil) {
        self.init(
            range: Note.Content.Range(from: run.range, in: source),
            font: Note.Content.Font(from: run.attributes),
            paragraphStyle: paragraphStyle,
            link: run.link)
    }
    
    func offset(by offset: Int) -> Self {
        var result = self
        result.range.startsAt += offset
        return result
    }
    
}
