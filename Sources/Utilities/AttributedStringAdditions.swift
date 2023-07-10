import Foundation

extension AttributedStringProtocol {
    func trimmed() -> AttributedSubstring {
        let lowerBound = characters.firstIndex(where: { !$0.isWhitespace }) ?? startIndex
        let upperBound = characters[lowerBound...].reversed().drop(while: \.isWhitespace).startIndex.base
        return self[lowerBound..<upperBound]
    }
    
    func contains(_ source: some StringProtocol) -> Bool {
        range(of: source) != nil
    }
    
    func split(separator: String) -> [AttributedSubstring] {
        var result = [AttributedSubstring]()
        var subSequenceStart = startIndex
        
        func commit(upTo end: AttributedString.Index) {
            guard subSequenceStart != end else { return }
            result.append(self[subSequenceStart..<end])
        }
        
        while let range = self[subSequenceStart...].range(of: separator) {
            commit(upTo: range.lowerBound)
            subSequenceStart = range.upperBound
        }
        
        commit(upTo: endIndex)
        return result
    }
}

extension AttributedString {
    /// Removes characters at the start and end matching `Character.isWhitespace`.
    mutating func trim() {
        self = AttributedString(trimmed())
    }
}
