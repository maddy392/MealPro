// swiftlint:disable all
import Amplify
import Foundation

extension Recipe {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case recipeId
    case title
    case image
    case imageType
    case userFavorites
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let recipe = Recipe.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Recipes"
    model.syncPluralName = "Recipes"
    
    model.attributes(
      .index(fields: ["recipeId"], name: nil),
      .primaryKey(fields: [recipe.recipeId])
    )
    
    model.fields(
      .field(recipe.recipeId, is: .required, ofType: .int),
      .field(recipe.title, is: .required, ofType: .string),
      .field(recipe.image, is: .optional, ofType: .string),
      .field(recipe.imageType, is: .optional, ofType: .string),
      .hasMany(recipe.userFavorites, is: .optional, ofType: UserFavorite.self, associatedFields: [UserFavorite.keys.recipe]),
      .field(recipe.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(recipe.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
    public class Path: ModelPath<Recipe> { }
    
    public static var rootPath: PropertyContainerPath? { Path() }
}

extension Recipe: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Custom
  public typealias IdentifierProtocol = ModelIdentifier<Self, ModelIdentifierFormat.Custom>
}

extension Recipe.IdentifierProtocol {
  public static func identifier(recipeId: Int) -> Self {
    .make(fields:[(name: "recipeId", value: recipeId)])
  }
}
extension ModelPath where ModelType == Recipe {
  public var recipeId: FieldPath<Int>   {
      int("recipeId") 
    }
  public var title: FieldPath<String>   {
      string("title") 
    }
  public var image: FieldPath<String>   {
      string("image") 
    }
  public var imageType: FieldPath<String>   {
      string("imageType") 
    }
  public var userFavorites: ModelPath<UserFavorite>   {
      UserFavorite.Path(name: "userFavorites", isCollection: true, parent: self) 
    }
  public var createdAt: FieldPath<Temporal.DateTime>   {
      datetime("createdAt") 
    }
  public var updatedAt: FieldPath<Temporal.DateTime>   {
      datetime("updatedAt") 
    }
}