import Apollo
import Foundation

class ApronInterceptorProvider: DefaultInterceptorProvider {
    let email: String
    let accessToken: String

    init(client: URLSessionClient = URLSessionClient(), store: ApolloStore = ApolloStore(), email: String, accessToken: String) {
        self.email = email
        self.accessToken = accessToken
        super.init(client: client, shouldInvalidateClientOnDeinit: true, store: store)
    }
    
    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(ApronInterceptor(email: email, accessToken: accessToken), at: 0)
        return interceptors
    }
}

private struct ApronInterceptor: ApolloInterceptor {
    var id = UUID().uuidString
    var email: String
    var accessToken: String

    func interceptAsync<Operation>(chain: any Apollo.RequestChain, request: Apollo.HTTPRequest<Operation>, response: Apollo.HTTPResponse<Operation>?, completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, any Error>) -> Void) where Operation: GraphQLOperation {
        request.addHeader(name: "Authorization", value: "Basic Og==")
        request.addHeader(name: "Accept-Language", value: "en-US")
        request.addHeader(name: "X-BlueApron-Email", value: email)
        request.addHeader(name: "X-BlueApron-Token", value: accessToken)
        request.addHeader(name: "User-Agent", value: "BlueApron3.218.24 (iPhone; iOS 18.0; Scale/3.0)")
        chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
    }
}
