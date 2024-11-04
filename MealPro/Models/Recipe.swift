// swiftlint:disable all
import Amplify
import Foundation

public struct Recipe: Model, Identifiable {
  public var id: Int { recipeId } // Conforming to Identifiable by mapping 'id' to 'recipeId'
  public let recipeId: Int
  public var title: String
  public var image: String?
  public var imageType: String?
  public var userFavorites: List<UserFavorite>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(recipeId: Int,
      title: String,
      image: String? = nil,
      imageType: String? = nil,
      userFavorites: List<UserFavorite>? = []) {
    self.init(recipeId: recipeId,
      title: title,
      image: image,
      imageType: imageType,
      userFavorites: userFavorites,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(recipeId: Int,
      title: String,
      image: String? = nil,
      imageType: String? = nil,
      userFavorites: List<UserFavorite>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.recipeId = recipeId
      self.title = title
      self.image = image
      self.imageType = imageType
      self.userFavorites = userFavorites
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
