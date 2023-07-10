extension Collection {
    
    var ifNotEmpty: Self? {
        isEmpty ? nil : self
    }
    
}
