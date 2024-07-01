// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI
import Foundation

extension ApronQL {
    /// An ISO 8601-encoded date
    typealias Date = Foundation.Date
}

extension Foundation.Date: @retroactive CustomScalarType {
    public init(_jsonValue value: ApolloAPI.JSONValue) throws {
        guard let iso8601String = value as? String else {
            throw JSONDecodingError.couldNotConvert(value: value, to: Foundation.Date.self)
        }
        self = try Date(iso8601String, strategy: .iso8601.year().month().day())
    }
    
    public var _jsonValue: ApolloAPI.JSONValue {
        formatted(.iso8601.year().month().day())
    }
}
