// swiftlint:disable all
import Amplify
import Foundation

public struct UserFavorite: Model {
  public let id: String
  internal var _recipe: LazyReference<Recipe>
  public var recipe: Recipe?   {
      get async throws { 
        try await _recipe.get()
      } 
    }
  internal var _user: LazyReference<User>
  public var user: User?   {
      get async throws { 
        try await _user.get()
      } 
    }
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      recipe: Recipe? = nil,
      user: User? = nil) {
    self.init(id: id,
      recipe: recipe,
      user: user,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      recipe: Recipe? = nil,
      user: User? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self._recipe = LazyReference(recipe)
      self._user = LazyReference(user)
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
  public mutating func setRecipe(_ recipe: Recipe? = nil) {
    self._recipe = LazyReference(recipe)
  }
  public mutating func setUser(_ user: User? = nil) {
    self._user = LazyReference(user)
  }
  public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      id = try values.decode(String.self, forKey: .id)
      _recipe = try values.decodeIfPresent(LazyReference<Recipe>.self, forKey: .recipe) ?? LazyReference(identifiers: nil)
      _user = try values.decodeIfPresent(LazyReference<User>.self, forKey: .user) ?? LazyReference(identifiers: nil)
      createdAt = try? values.decode(Temporal.DateTime?.self, forKey: .createdAt)
      updatedAt = try? values.decode(Temporal.DateTime?.self, forKey: .updatedAt)
  }
  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(id, forKey: .id)
      try container.encode(_recipe, forKey: .recipe)
      try container.encode(_user, forKey: .user)
      try container.encode(createdAt, forKey: .createdAt)
      try container.encode(updatedAt, forKey: .updatedAt)
  }
}