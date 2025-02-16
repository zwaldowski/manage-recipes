import Apollo
import ArgumentParser
import Foundation

struct ApronDownloadRecipes: AsyncParsableCommand {
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var oldRecipeSkusURL: URL

    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var oldRecipesURL: URL

    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipeSkusURL: URL

    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipesURL: URL

    @Option()
    var email: String

    @Option()
    var accessToken: String

    func run() async throws {
        let oldRecipes = try [BlueApron.Recipe](jsonContentsOf: oldRecipesURL)
        let oldRecipeSKUs = try Set<BlueApron.Recipe.ID>(jsonContentsOf: oldRecipeSkusURL)
        
        let store = ApolloStore()
        let provider = ApronInterceptorProvider(store: store, email: email, accessToken: accessToken)
        let networkTransport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: URL(string: "https://www.blueapron.com/graphql")!)
        let client = ApolloClient(networkTransport: networkTransport, store: store)

        let filter = ApronQL.PastOrdersFilterInput(cartContext: .case(.subscriptionFood))
        var hasNextPage = true
        var endCursor = GraphQLNullable<String>.null
        var allOrders = [ApronQL.PastOrdersQuery.Data.PastOrders.Node]()

        repeat {
            let query = ApronQL.PastOrdersQuery(filter: filter, first: 20, after: endCursor)
            let result = try await client.fetch(query: query)
            
            if let orders = result.data?.pastOrders.nodes {
                allOrders += orders.compactMap { $0 }
            }
            
            if let pageInfo = result.data?.pastOrders.pageInfo, pageInfo.hasNextPage, let cursor = pageInfo.endCursor {
                endCursor = .some(cursor)
            } else {
                hasNextPage = false
            }
        } while hasNextPage

        let newRecipes = allOrders
            .flatMap { order -> [BlueApron.Recipe] in
                order.lineItems.compactMap { lineItem -> BlueApron.Recipe? in
                    BlueApron.Recipe(from: lineItem, order: order)
                }
            }
            .filter { !oldRecipeSKUs.contains($0.sku) }
        let recipes = oldRecipes + newRecipes
        let recipeSKUs = Set((oldRecipeSKUs + recipes.map(\.sku))).sorted()
        
        try recipes.writeJSONContents(to: newRecipesURL)
        try recipeSKUs.writeJSONContents(to: newRecipeSkusURL)

        print("Done!")
    }
}
