import ArgumentParser
import Foundation

struct FreshDownloadRecipes: AsyncParsableCommand {
    
    @Option(
        name: .customLong("old-recipe-ids-url"),
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var oldRecipeIDsURL: URL
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var oldRecipesURL: URL
    
    @Option(
        name: .customLong("new-recipe-ids-url"),
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipeIDsURL: URL
    
    @Option(
        completion: .file(extensions: [ "json" ]),
        transform: file)
    var newRecipesURL: URL
    
    @Option()
    var authToken: String
    
    func run() async throws {
        let oldRecipes = try [HelloFresh.Recipe](jsonContentsOf: oldRecipesURL)
        let oldRecipeIDs = try Set<String>(jsonContentsOf: oldRecipeIDsURL)

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpShouldSetCookies = true
        sessionConfiguration.httpCookieAcceptPolicy = .always
        sessionConfiguration.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(authToken)",
            "Accept-Language": "en-US"
        ]

        let session = URLSession(configuration: sessionConfiguration)
        defer { session.finishTasksAndInvalidate() }

        let weeks = try await getSubscriptions(using: session)
            .async
            .flatMap {
                PastDeliveriesSequence(subscription: $0, session: session)
            }
            .collect()
            .joined()

        let newRecipeIDs = weeks.flatMap {
            $0.meals.map(\.id) + ($0.addons ?? []).map(\.id)
        }

        let newRecipes = try await newRecipeIDs
            .async
            .filter { id in
                !oldRecipeIDs.contains(id)
            }
            .compactMap { id in
                try await getRecipe(id: id, using: session)
            }
            .collect()

        let recipes = oldRecipes + newRecipes
        let recipeIDs = (oldRecipeIDs + newRecipes.map(\.id)).sorted()

        try recipes.writeJSONContents(to: newRecipesURL)
        try recipeIDs.writeJSONContents(to: newRecipeIDsURL)

        print("Done!")
    }
    
    func getSubscriptions(using session: URLSession) async throws -> [HelloFresh.Responses.Subscriptions.Item] {
        let url = HelloFresh.Requests.Subscriptions.url
        let data = try await retry {
            try await session.data(from: url)
        }
        let subscriptions = try HelloFresh.Responses.decoder.decode(HelloFresh.Responses.Subscriptions.self, from: data)
        return subscriptions.items
    }

    struct PastDeliveriesSequence: AsyncSequence {
        typealias Element = [HelloFresh.Responses.PastDeliveries.Week]

        let subscription: HelloFresh.Responses.Subscriptions.Item
        let session: URLSession

        struct AsyncIterator: AsyncIteratorProtocol {
            let subscriptionID: String
            var nextWeek: String?
            let session: URLSession

            mutating func next() async throws -> [HelloFresh.Responses.PastDeliveries.Week]? {
                guard let week = nextWeek else { return nil }
                let url = HelloFresh.Requests.PastDeliveries(startingFromWeekID: week, subscriptionID: subscriptionID).url
                let data = try await retry {
                    try await session.data(from: url)
                }
                let pastDeliveries = try HelloFresh.Responses.decoder.decode(HelloFresh.Responses.PastDeliveries.self, from: data)
                nextWeek = pastDeliveries.nextWeek
                return pastDeliveries.weeks
            }
        }

        func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(subscriptionID: subscription.id, nextWeek: subscription.nextDeliveryWeek ?? subscription.weekWithLatestMenu, session: session)
        }
    }

    func getRecipe(id: String, using session: URLSession) async throws -> HelloFresh.Recipe {
        var dataToDebug: Data?
        do {
            let url = HelloFresh.Requests.Recipe(id: id).url
            let data = try await retry {
                try await session.data(from: url)
            }
            dataToDebug = data
            return try HelloFresh.Responses.decoder.decode(HelloFresh.Recipe.self, from: data)
        } catch {
            print(String(decoding: dataToDebug ?? Data(), as: UTF8.self))
            throw error
        }
    }

}
