extension Sequence {
    
    var async: AsyncLazySequence<Self> {
        AsyncLazySequence(self)
    }
    
}

struct AsyncLazySequence<Base>: AsyncSequence where Base: Sequence {
    
    typealias Element = Base.Element
    
    struct Iterator: AsyncIteratorProtocol {
        
        var base: Base.Iterator
        
        mutating func next() async throws -> Base.Element? {
            try Task.checkCancellation()
            return base.next()
        }
        
    }
    
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    func makeAsyncIterator() -> Iterator {
        Iterator(base: base.makeIterator())
    }
    
}
