import Foundation

extension Decodable {

    init(jsonContentsOf url: URL) throws {
        self = try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
    }

}

extension Encodable {

    func writeJSONContents(to url: URL) throws {
        try JSONEncoder().encode(self).write(to: url)
    }

}
