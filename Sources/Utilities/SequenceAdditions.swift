extension Sequence {

    func uniqued<ID>(by id: (Element) -> ID) -> [Element] where ID: Hashable {
        var visited = Set<ID>()
        return filter { visited.insert(id($0)).inserted }
    }

}

extension Sequence where Element: Identifiable {

    func uniqued() -> [Element] {
        uniqued(by: \.id)
    }

}
