import Foundation

struct RetryTooManyAttempts: Error {}

func retry<Success>(attempts: Int = 2, operation: () async throws -> (Success, URLResponse)) async throws -> Success {
    for _ in 0 ... attempts {
        let (data, response) = try await operation()
        switch (response as? HTTPURLResponse)?.statusCode {
        case (200..<400)?:
            return data
        case (500..<600)?:
            continue
        default:
            throw URLError(.badServerResponse, userInfo: [
                NSURLErrorFailingURLErrorKey: response.url as Any,
                "response": response
            ])
        }
    }

    throw RetryTooManyAttempts()
}
