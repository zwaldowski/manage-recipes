extension String {
    
    mutating func dropTrailingWhitespace() -> Substring {
        let lowerBound = reversed().drop(while: \.isWhitespace).startIndex.base
        let result = self[lowerBound...]
        self = Self(self[..<lowerBound])
        return result
    }
    
}
