// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol ApronQL_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == ApronQL.SchemaMetadata {}

protocol ApronQL_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == ApronQL.SchemaMetadata {}

protocol ApronQL_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == ApronQL.SchemaMetadata {}

protocol ApronQL_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == ApronQL.SchemaMetadata {}

extension ApronQL {
  typealias SelectionSet = ApronQL_SelectionSet

  typealias InlineFragment = ApronQL_InlineFragment

  typealias MutableSelectionSet = ApronQL_MutableSelectionSet

  typealias MutableInlineFragment = ApronQL_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "QueryRoot": return ApronQL.Objects.QueryRoot
      case "OrderConnection": return ApronQL.Objects.OrderConnection
      case "Order": return ApronQL.Objects.Order
      case "LineItem": return ApronQL.Objects.LineItem
      case "MarketItem": return ApronQL.Objects.MarketItem
      case "Recipe": return ApronQL.Objects.Recipe
      case "Wine": return ApronQL.Objects.Wine
      case "ProductName": return ApronQL.Objects.ProductName
      case "NutritionInfo": return ApronQL.Objects.NutritionInfo
      case "RecipeTimes": return ApronQL.Objects.RecipeTimes
      case "TimeRange": return ApronQL.Objects.TimeRange
      case "RecipeIngredient": return ApronQL.Objects.RecipeIngredient
      case "RecipeStep": return ApronQL.Objects.RecipeStep
      case "Image": return ApronQL.Objects.Image
      case "ProductImages": return ApronQL.Objects.ProductImages
      case "PageInfo": return ApronQL.Objects.PageInfo
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}