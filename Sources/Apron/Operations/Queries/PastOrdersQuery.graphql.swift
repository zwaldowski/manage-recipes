// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ApronQL {
  class PastOrdersQuery: GraphQLQuery {
    static let operationName: String = "PastOrders"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PastOrders($filter: PastOrdersFilterInput!, $first: Int, $after: String) { pastOrders(filter: $filter, first: $first, after: $after) { __typename nodes { __typename scheduledArrivalDate lineItems { __typename variant { __typename ... on Recipe { sku url name { __typename main full sub } description nutritionInfo { __typename displayServingsCount accurateServingCalories } times { __typename overall { __typename min max average } } ingredients { __typename unit amount description displayPriority } steps { __typename number title text image { __typename url } } images { __typename primary { __typename url } } } } } createdDate } pageInfo { __typename hasNextPage endCursor } } }"#
      ))

    public var filter: PastOrdersFilterInput
    public var first: GraphQLNullable<Int>
    public var after: GraphQLNullable<String>

    public init(
      filter: PastOrdersFilterInput,
      first: GraphQLNullable<Int>,
      after: GraphQLNullable<String>
    ) {
      self.filter = filter
      self.first = first
      self.after = after
    }

    public var __variables: Variables? { [
      "filter": filter,
      "first": first,
      "after": after
    ] }

    struct Data: ApronQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.QueryRoot }
      static var __selections: [ApolloAPI.Selection] { [
        .field("pastOrders", PastOrders.self, arguments: [
          "filter": .variable("filter"),
          "first": .variable("first"),
          "after": .variable("after")
        ]),
      ] }

      /// A paginated connection of "past" (ie, already delivered) orders in descending order by delivery date. So `first: 2` would return a connection with the two most recently delivered orders as nodes within containing edges.
      var pastOrders: PastOrders { __data["pastOrders"] }

      /// PastOrders
      ///
      /// Parent Type: `OrderConnection`
      struct PastOrders: ApronQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.OrderConnection }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
          .field("pageInfo", PageInfo.self),
        ] }

        /// A list of nodes.
        var nodes: [Node?]? { __data["nodes"] }
        /// Information to aid in pagination.
        var pageInfo: PageInfo { __data["pageInfo"] }

        /// PastOrders.Node
        ///
        /// Parent Type: `Order`
        struct Node: ApronQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.Order }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("scheduledArrivalDate", ApronQL.Date?.self),
            .field("lineItems", [LineItem].self),
            .field("createdDate", ApronQL.Date?.self),
          ] }

          /// The date this order is scheduled to arrive. Note that this is a rough approximation, since orders may contain shipments from multiple sources which may not arrive on the same day.
          var scheduledArrivalDate: ApronQL.Date? { __data["scheduledArrivalDate"] }
          /// The line items contained in this order. May be empty if no line items are currently associated with this order. This is intended for cases where clients wish to present a view that does not care about shipment details.
          var lineItems: [LineItem] { __data["lineItems"] }
          /// The date at which this order was created from a finalized cart.
          var createdDate: ApronQL.Date? { __data["createdDate"] }

          /// PastOrders.Node.LineItem
          ///
          /// Parent Type: `LineItem`
          struct LineItem: ApronQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.LineItem }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("variant", Variant.self),
            ] }

            /// The desired Variant for this line item.
            var variant: Variant { __data["variant"] }

            /// PastOrders.Node.LineItem.Variant
            ///
            /// Parent Type: `ProductVariant`
            struct Variant: ApronQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: ApolloAPI.ParentType { ApronQL.Interfaces.ProductVariant }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .inlineFragment(AsRecipe.self),
              ] }

              var asRecipe: AsRecipe? { _asInlineFragment() }

              /// PastOrders.Node.LineItem.Variant.AsRecipe
              ///
              /// Parent Type: `Recipe`
              struct AsRecipe: ApronQL.InlineFragment {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                typealias RootEntityType = PastOrdersQuery.Data.PastOrders.Node.LineItem.Variant
                static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.Recipe }
                static var __selections: [ApolloAPI.Selection] { [
                  .field("sku", ApronQL.ID.self),
                  .field("url", ApronQL.Url.self),
                  .field("name", Name.self),
                  .field("description", String.self),
                  .field("nutritionInfo", NutritionInfo.self),
                  .field("times", Times.self),
                  .field("ingredients", [Ingredient].self),
                  .field("steps", [Step].self),
                  .field("images", Images?.self),
                ] }

                /// The globally unique SKU of the variant. The exact format here should never be relied on, and the value should be treated as opaque to clients.
                var sku: ApronQL.ID { __data["sku"] }
                /// The URL for the details page of this variant.
                var url: ApronQL.Url { __data["url"] }
                /// Naming information for this variant.
                var name: Name { __data["name"] }
                /// Description of the variant.
                var description: String { __data["description"] }
                /// Nutritional information for this recipe.
                var nutritionInfo: NutritionInfo { __data["nutritionInfo"] }
                /// Timing information for this recipe.
                var times: Times { __data["times"] }
                /// Ingredients for this recipe, if any. This array may be empty if the recipe has no visible ingredients.
                var ingredients: [Ingredient] { __data["ingredients"] }
                /// Steps for this recipe, if any. This array may be empty if the recipe has no visible steps.
                var steps: [Step] { __data["steps"] }
                /// Collection of images for this variant. May not be present if the variant hasn't been assigned any images yet.
                var images: Images? { __data["images"] }

                /// PastOrders.Node.LineItem.Variant.AsRecipe.Name
                ///
                /// Parent Type: `ProductName`
                struct Name: ApronQL.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.ProductName }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("main", String.self),
                    .field("full", String.self),
                    .field("sub", String?.self),
                  ] }

                  /// The main title of the product.
                  var main: String { __data["main"] }
                  /// The full name of the product.
                  var full: String { __data["full"] }
                  /// The subtitle, if any, of the product.
                  var sub: String? { __data["sub"] }
                }

                /// PastOrders.Node.LineItem.Variant.AsRecipe.NutritionInfo
                ///
                /// Parent Type: `NutritionInfo`
                struct NutritionInfo: ApronQL.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.NutritionInfo }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("displayServingsCount", String?.self),
                    .field("accurateServingCalories", Int?.self),
                  ] }

                  /// The value to display for nutritional servings count. This represents the number of servings from a nutritional perspective. Note that this value may not be strictly numeric - there exist some recipes with fractional servings which are rendered as 2½, etc, so clients should not attempt to parse this value. The intention is for this value to logically represent a quantity. Clients may use this to construct strings as appropriate.
                  var displayServingsCount: String? { __data["displayServingsCount"] }
                  /// Accurate per-facility calories per serving, if available. This value is not guaranteed to be available for all variants. This information is expensive to query, and should generally only be fetched for a small number of variants at a time. If the client has this value cached locally, it is generally preferred to display this instead of the estimated value.
                  var accurateServingCalories: Int? { __data["accurateServingCalories"] }
                }

                /// PastOrders.Node.LineItem.Variant.AsRecipe.Times
                ///
                /// Parent Type: `RecipeTimes`
                struct Times: ApronQL.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.RecipeTimes }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("overall", Overall.self),
                  ] }

                  /// Overall time range information for the recipe. Includes the time needed to prepare and actually cook.
                  var overall: Overall { __data["overall"] }

                  /// PastOrders.Node.LineItem.Variant.AsRecipe.Times.Overall
                  ///
                  /// Parent Type: `TimeRange`
                  struct Overall: ApronQL.SelectionSet {
                    let __data: DataDict
                    init(_dataDict: DataDict) { __data = _dataDict }

                    static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.TimeRange }
                    static var __selections: [ApolloAPI.Selection] { [
                      .field("__typename", String.self),
                      .field("min", Int?.self),
                      .field("max", Int?.self),
                      .field("average", Int?.self),
                    ] }

                    /// Minimum amount of time in minutes. This may be null if the range is not constrained at the lower end.
                    var min: Int? { __data["min"] }
                    /// Maximum amount of time in minutes. This may be null if the range is not constrained at the upper end.
                    var max: Int? { __data["max"] }
                    /// Average amount of time in minutes. This may be null if average is not applicable to the use case. This is often true for older recipes, for example.
                    var average: Int? { __data["average"] }
                  }
                }

                /// PastOrders.Node.LineItem.Variant.AsRecipe.Ingredient
                ///
                /// Parent Type: `RecipeIngredient`
                struct Ingredient: ApronQL.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.RecipeIngredient }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("unit", String?.self),
                    .field("amount", String.self),
                    .field("description", String.self),
                    .field("displayPriority", Int.self),
                  ] }

                  /// The units of measurement for this ingredient, e.g., "tbsps", if any. Some ingredients do not have a relevant unit as part of their display, in which case this value is null.
                  var unit: String? { __data["unit"] }
                  /// The number of ingredient units used in this recipe, e.g. 1/4. Clients should not assume this value is purely numeric.
                  var amount: String { __data["amount"] }
                  /// The name of this recipe ingredient, e.g., "honey".
                  var description: String { __data["description"] }
                  /// The priority with which to display this ingredient. Ingredients should be displayed in ascending order - lower numbers here should display first.
                  var displayPriority: Int { __data["displayPriority"] }
                }

                /// PastOrders.Node.LineItem.Variant.AsRecipe.Step
                ///
                /// Parent Type: `RecipeStep`
                struct Step: ApronQL.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.RecipeStep }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("number", Int.self),
                    .field("title", String.self),
                    .field("text", String.self),
                    .field("image", Image?.self),
                  ] }

                  /// This step's position in the overall sequence of steps.
                  var number: Int { __data["number"] }
                  /// The one-line title of the step.
                  var title: String { __data["title"] }
                  /// The actual detailed text of the step describing what to do.
                  var text: String { __data["text"] }
                  /// The image associated with this step, if any.
                  var image: Image? { __data["image"] }

                  /// PastOrders.Node.LineItem.Variant.AsRecipe.Step.Image
                  ///
                  /// Parent Type: `Image`
                  struct Image: ApronQL.SelectionSet {
                    let __data: DataDict
                    init(_dataDict: DataDict) { __data = _dataDict }

                    static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.Image }
                    static var __selections: [ApolloAPI.Selection] { [
                      .field("__typename", String.self),
                      .field("url", ApronQL.Url.self),
                    ] }

                    /// The URL to use to retrieve the image.
                    var url: ApronQL.Url { __data["url"] }
                  }
                }

                /// PastOrders.Node.LineItem.Variant.AsRecipe.Images
                ///
                /// Parent Type: `ProductImages`
                struct Images: ApronQL.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.ProductImages }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("primary", Primary?.self),
                  ] }

                  /// Primary image for this product. This will always be present if the product has images - but not all products do.
                  var primary: Primary? { __data["primary"] }

                  /// PastOrders.Node.LineItem.Variant.AsRecipe.Images.Primary
                  ///
                  /// Parent Type: `Image`
                  struct Primary: ApronQL.SelectionSet {
                    let __data: DataDict
                    init(_dataDict: DataDict) { __data = _dataDict }

                    static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.Image }
                    static var __selections: [ApolloAPI.Selection] { [
                      .field("__typename", String.self),
                      .field("url", ApronQL.Url.self),
                    ] }

                    /// The URL to use to retrieve the image.
                    var url: ApronQL.Url { __data["url"] }
                  }
                }
              }
            }
          }
        }

        /// PastOrders.PageInfo
        ///
        /// Parent Type: `PageInfo`
        struct PageInfo: ApronQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: ApolloAPI.ParentType { ApronQL.Objects.PageInfo }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool.self),
            .field("endCursor", String?.self),
          ] }

          /// When paginating forwards, are there more items?
          var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          var endCursor: String? { __data["endCursor"] }
        }
      }
    }
  }

}