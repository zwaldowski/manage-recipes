import PDFKit

extension PDFDisplayBox {
    static let allCases = [ mediaBox, cropBox, bleedBox, trimBox, artBox ]

    var logDescription: String {
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
