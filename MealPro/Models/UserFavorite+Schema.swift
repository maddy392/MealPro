// swiftlint:disable all
import Amplify
import Foundation

extension UserFavorite {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case recipe
    case user
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let userFavorite = UserFavorite.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "UserFavorites"
    model.syncPluralName = "UserFavorites"
    
    model.attributes(
      .primaryKey(fields: [userFavorite.id])
    )
    
    model.fields(
      .field(userFavorite.id, is: .required, ofType: .string),
      .belongsTo(userFavorite.recipe, is: .optional, ofType: Recipe.self, targetNames: ["recipeId"]),
      .belongsTo(userFavorite.user, is: .optional, ofType: User.self, targetNames: ["userId"]),
      .field(userFavorite.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(userFavorite.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
    public class Path: ModelPath<UserFavorite> { }
    
    public static var rootPath: PropertyContainerPath? { Path() }
}

extension UserFavorite: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}
extension ModelPath where ModelType == UserFavorite {
  public var id: FieldPath<String>   {
      string("id") 
    }
  public var recipe: ModelPath<Recipe>   {
      Recipe.Path(name: "recipe", parent: self) 
    }
  public var user: ModelPath<User>   {
      User.Path(name: "user", parent: self) 
    }
  public var createdAt: FieldPath<Temporal.DateTime>   {
      datetime("createdAt") 
    }
  public var updatedAt: FieldPath<Temporal.DateTime>   {
      datetime("updatedAt") 
    }
}