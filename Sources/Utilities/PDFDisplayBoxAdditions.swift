import PDFKit

extension PDFDisplayBox: CaseIterable, CustomDebugStringConvertible {
    public static let allCases = [ PDFDisplayBox.mediaBox, .cropBox, .bleedBox, .trimBox, .artBox ]

    public var debugDescription: String {
        switch self {
        case .mediaBox: return "media"
        case .cropBox: return "crop"
        case .bleedBox: return "bleed"
        case .trimBox: return "trim"
        case .artBox: return "art"
        @unknown default: return "und"
        }
    }
}
