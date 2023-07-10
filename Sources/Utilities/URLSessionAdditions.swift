import Combine
import Foundation

extension URLResponse {

    func checkSuccessful() throws {
        guard case (200..<400)? = (self as? HTTPURLResponse)?.statusCode else {
            throw URLError(.badServerResponse, userInfo: [
                NSURLErrorFailingURLErrorKey: url as Any,
                "response": self
            ])
        }
    }

}

extension URLSession {

    func downloadIfNeeded(from remoteURL: URL, to localURL: URL) async throws {
        try FileManager.default.createDirectory(at: localURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        guard (try? localURL.checkResourceIsReachable()) != true else { return }
        let (tempURL, response) = try await download(from: remoteURL)
        try response.checkSuccessful()
        try FileManager.default.moveItem(at: tempURL, to: localURL)
    }

}
