// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension ApronQL.Objects {
  /// Representation of a recipe in Blue Apron's system. Recipes are ProductVariants, so they include all the available variant data. But they also have specialized attributes which are unique to recipes.
  static let Recipe = ApolloAPI.Object(
    typename: "Recipe",
    implementedInterfaces: [ApronQL.Interfaces.ProductVariant.self]
  )
}