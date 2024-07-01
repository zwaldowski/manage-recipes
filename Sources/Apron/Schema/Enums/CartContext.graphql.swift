// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension ApronQL {
  /// The context in which a cart was created.
  enum CartContext: String, EnumType {
    /// Cart used for gift cards only.
    case giftCard = "GIFT_CARD"
    /// Cart used for marketplace orders.
    case market = "MARKET"
    /// Cart belonging to a food subscription.
    case subscriptionFood = "SUBSCRIPTION_FOOD"
    /// Cart belonging to a wine subscription.
    case subscriptionWine = "SUBSCRIPTION_WINE"
  }

}