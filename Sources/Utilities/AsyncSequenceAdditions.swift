extension AsyncSequence {

    func collect() async throws -> [Element] {
        var result = [Element]()
        for try await item in self {
            result.append(item)
        }
        return result
    }

}
