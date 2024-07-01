import Apollo
import Foundation
import os

extension ApolloClientProtocol {
    func fetch<Query>(query: Query, cachePolicy: CachePolicy = .default, contextIdentifier: UUID? = nil, context: RequestContext? = nil) async throws -> GraphQLResult<Query.Data> where Query: GraphQLQuery {
        let state = OSAllocatedUnfairLock(initialState: (nil as Cancellable?, false))
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let token = fetch(query: query, cachePolicy: cachePolicy, contextIdentifier: contextIdentifier, context: context, queue: .global(), resultHandler: continuation.resume)
                state.withLock { state in
                    if state.1 {
                        token.cancel()
                    } else {
                        state.0 = token
                    }
                }
            }
        } onCancel: {
            state.withLock {
                guard case (let token?, false) = $0 else { return }
                token.cancel()
            }
        }
    }
}
