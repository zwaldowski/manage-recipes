// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension ApronQL {
  /// Input for filtering a past orders query.
  struct PastOrdersFilterInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      cartContext: GraphQLEnum<CartContext>
    ) {
      __data = InputDict([
        "cartContext": cartContext
      ])
    }

    /// Context for the cart from which the orders were created.
    var cartContext: GraphQLEnum<CartContext> {
      get { __data["cartContext"] }
      set { __data["cartContext"] = newValue }
    }
  }

}