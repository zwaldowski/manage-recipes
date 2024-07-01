// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI
import Foundation

extension ApronQL {
    /// A valid URL, transported as a String
    typealias Url = Foundation.URL
    
}

extension Foundation.URL: @retroactive CustomScalarType {
    public init(_jsonValue value: ApolloAPI.JSONValue) throws {
        guard let string = value as? String, let url = URL(string: string) else {
            throw JSONDecodingError.couldNotConvert(value: value, to: Foundation.URL.self)
        }
        self = url
    }
    
    public var _jsonValue: ApolloAPI.JSONValue {
        absoluteString
    }
}
