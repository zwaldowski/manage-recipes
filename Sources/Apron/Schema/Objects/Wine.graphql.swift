// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension ApronQL.Objects {
  /// Representation of a wine in Blue Apron's system. Wines are ProductVariants, so they include all the available variant data. But they also have specialized attributes which are unique to wines.
  static let Wine = ApolloAPI.Object(
    typename: "Wine",
    implementedInterfaces: [ApronQL.Interfaces.ProductVariant.self]
  )
}