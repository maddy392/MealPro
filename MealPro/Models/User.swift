// swiftlint:disable all
import Amplify
import Foundation

public struct User: Model {
  public let userId: String
  public var username: String
  public var favorites: List<UserFavorite>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(userId: String,
      username: String,
      favorites: List<UserFavorite>? = []) {
    self.init(userId: userId,
      username: username,
      favorites: favorites,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(userId: String,
      username: String,
      favorites: List<UserFavorite>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.userId = userId
      self.username = username
      self.favorites = favorites
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}