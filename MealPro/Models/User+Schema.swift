// swiftlint:disable all
import Amplify
import Foundation

extension User {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case userId
    case username
    case favorites
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let user = User.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Users"
    model.syncPluralName = "Users"
    
    model.attributes(
      .index(fields: ["userId"], name: nil),
      .primaryKey(fields: [user.userId])
    )
    
    model.fields(
      .field(user.userId, is: .required, ofType: .string),
      .field(user.username, is: .required, ofType: .string),
      .hasMany(user.favorites, is: .optional, ofType: UserFavorite.self, associatedFields: [UserFavorite.keys.user]),
      .field(user.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(user.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
    public class Path: ModelPath<User> { }
    
    public static var rootPath: PropertyContainerPath? { Path() }
}

extension User: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Custom
  public typealias IdentifierProtocol = ModelIdentifier<Self, ModelIdentifierFormat.Custom>
}

extension User.IdentifierProtocol {
  public static func identifier(userId: String) -> Self {
    .make(fields:[(name: "userId", value: userId)])
  }
}
extension ModelPath where ModelType == User {
  public var userId: FieldPath<String>   {
      string("userId") 
    }
  public var username: FieldPath<String>   {
      string("username") 
    }
  public var favorites: ModelPath<UserFavorite>   {
      UserFavorite.Path(name: "favorites", isCollection: true, parent: self) 
    }
  public var createdAt: FieldPath<Temporal.DateTime>   {
      datetime("createdAt") 
    }
  public var updatedAt: FieldPath<Temporal.DateTime>   {
      datetime("updatedAt") 
    }
}