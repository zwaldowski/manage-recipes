import ArgumentParser
import Foundation

struct ApronDownloadRecipes: AsyncParsableCommand {
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var oldRecipeIdsURL: URL
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var oldRecipesURL: URL
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipeIdsURL: URL
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipesURL: URL
    
    @Option()
    var email: String
    
    @Option()
    var accessToken: String
    
    @Option()
    var datadome: String
    
    func run() async throws {
        let calendar = Calendar(identifier: .gregorian)
        let datadomeExpires = calendar.nextDate(after: .now, matching: DateComponents(timeZone: .gmt, month: 1, day: 1, hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime)!
        let oldRecipes = try [BlueApron.Recipe](jsonContentsOf: oldRecipesURL)
        let oldRecipeIDs = try Set<BlueApron.Recipe.ID>(jsonContentsOf: oldRecipeIdsURL)
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpShouldSetCookies = true
        sessionConfiguration.httpCookieAcceptPolicy = .always
        sessionConfiguration.httpAdditionalHeaders = [
            "Accept": "application/vnd.blueapron.com.v20150501+json",
            "Accept-Language": "en-US;q=1.0",
            "Authorization": "Basic Og==",
            "User-Agent": "BlueApron3.134.6 (iPhone; iOS 16.0.3; Scale/3.0)",
            "X-BlueApron-AppId": "iPhoneApp 3.134.6",
            "X-BlueApron-Email": email,
            "X-BlueApron-MobileApiVersion": "1",
            "X-BlueApron-Token": accessToken
        ]
        sessionConfiguration.httpCookieStorage!.setCookie(HTTPCookie(properties: [
            .name: "datadome",
            .value: datadome,
            .path: "/",
            .domain: ".blueapron.com",
            .expires: datadomeExpires
        ])!)

        let session = URLSession(configuration: sessionConfiguration)
        defer { session.finishTasksAndInvalidate() }
        
        let orders = try await loadActiveFoodSubscriptions(using: session)
            .async
            .flatMap { subscription in
                PastOrdersSequence(subscription: subscription, session: session)
            }
            .collect()
            .joined()

        let newRecipes = try await orders
            .flatMap(\.recipes)
            .filter { !oldRecipeIDs.contains($0.id) }
            .async
            .map {
                try await loadDetailsIfNeeded(for: $0, using: session)
            }
            .collect()
            .filter { !$0.isHeatAndEat }

        let recipes = oldRecipes + newRecipes
        let recipeIDs = (oldRecipeIDs + newRecipes.map(\.id)).sorted()

        try recipes.writeJSONContents(to: newRecipesURL)
        try recipeIDs.writeJSONContents(to: newRecipeIdsURL)
        
        print("Done!")
    }
    
    func loadActiveFoodSubscriptions(using session: URLSession) async throws -> [BlueApron.Subscription] {
        let data = try await retry {
            try await session.data(from: BlueApron.Requests.Users.url)
        }
        let response = try BlueApron.Responses.decoder.decode(BlueApron.Responses.Users.self, from: data)
        return response.user.subscriptions
            .filter { $0.isActive && $0.plan.kind == .food }
    }

    struct PastOrdersSequence: AsyncSequence {
        typealias Element = [BlueApron.Order]

        let subscription: BlueApron.Subscription
        let session: URLSession

        struct AsyncIterator: AsyncIteratorProtocol {
            let subscriptionID: BlueApron.Subscription.ID
            var page: Int? = 1
            let session: URLSession

            mutating func next() async throws -> [BlueApron.Order]? {
                guard let page else { return nil }
                let url = BlueApron.Requests.Orders(subscriptionID: subscriptionID, page: page).url
                let data = try await retry {
                    try await session.data(from: url)
                }
                let orders = try BlueApron.Responses.decoder.decode(BlueApron.Responses.Orders.self, from: data)
                self.page = orders.meta.pagination.nextPage
                return orders.orders
            }
        }

        func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(subscriptionID: subscription.id, session: session)
        }
    }

    func loadDetailsIfNeeded(for recipe: BlueApron.Recipe, using session: URLSession) async throws -> BlueApron.Recipe {
        guard recipe.calories == nil || recipe.steps == nil || recipe.pairings == nil || recipe.servings == nil else {
            return recipe
        }
        let url = BlueApron.Requests.RecipeDetails(recipeID: recipe.id).url
        let data = try await retry {
            try await session.data(from: url)
        }
        let response = try BlueApron.Responses.decoder.decode(BlueApron.Responses.RecipeDetails.self, from: data)
        return response.recipe
    }
    
}
