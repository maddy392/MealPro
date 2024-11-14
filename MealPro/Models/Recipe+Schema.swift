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
    case vegetarian
    case vegan
    case glutenFree
    case dairyFree
    case veryHealthy
    case cheap
    case veryPopular
    case sustainable
    case lowFodmap
    case weightWatcherSmartPoints
    case gaps
    case preparationMinutes
    case cookingMinutes
    case aggregateLikes
    case healthScore
    case creditsText
    case sourceName
    case pricePerServing
    case readyInMinutes
    case servings
    case sourceUrl
    case summary
    case cuisines
    case dishTypes
    case diets
    case occasions
    case spoonacularSourceUrl
    case spoonacularScore
    case nutrition
    case userFavorites
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let recipe = Recipe.keys
    
    model.authRules = [
      rule(allow: .private, operations: [.create, .update, .delete, .read])
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
      .field(recipe.vegetarian, is: .optional, ofType: .bool),
      .field(recipe.vegan, is: .optional, ofType: .bool),
      .field(recipe.glutenFree, is: .optional, ofType: .bool),
      .field(recipe.dairyFree, is: .optional, ofType: .bool),
      .field(recipe.veryHealthy, is: .optional, ofType: .bool),
      .field(recipe.cheap, is: .optional, ofType: .bool),
      .field(recipe.veryPopular, is: .optional, ofType: .bool),
      .field(recipe.sustainable, is: .optional, ofType: .bool),
      .field(recipe.lowFodmap, is: .optional, ofType: .bool),
      .field(recipe.weightWatcherSmartPoints, is: .optional, ofType: .int),
      .field(recipe.gaps, is: .optional, ofType: .string),
      .field(recipe.preparationMinutes, is: .optional, ofType: .int),
      .field(recipe.cookingMinutes, is: .optional, ofType: .int),
      .field(recipe.aggregateLikes, is: .optional, ofType: .int),
      .field(recipe.healthScore, is: .optional, ofType: .int),
      .field(recipe.creditsText, is: .optional, ofType: .string),
      .field(recipe.sourceName, is: .optional, ofType: .string),
      .field(recipe.pricePerServing, is: .optional, ofType: .double),
      .field(recipe.readyInMinutes, is: .optional, ofType: .int),
      .field(recipe.servings, is: .optional, ofType: .int),
      .field(recipe.sourceUrl, is: .optional, ofType: .string),
      .field(recipe.summary, is: .optional, ofType: .string),
      .field(recipe.cuisines, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(recipe.dishTypes, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(recipe.diets, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(recipe.occasions, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(recipe.spoonacularSourceUrl, is: .optional, ofType: .string),
      .field(recipe.spoonacularScore, is: .optional, ofType: .int),
      .field(recipe.nutrition, is: .optional, ofType: .embedded(type: RecipeNutrition.self)),
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
  public var vegetarian: FieldPath<Bool>   {
      bool("vegetarian") 
    }
  public var vegan: FieldPath<Bool>   {
      bool("vegan") 
    }
  public var glutenFree: FieldPath<Bool>   {
      bool("glutenFree") 
    }
  public var dairyFree: FieldPath<Bool>   {
      bool("dairyFree") 
    }
  public var veryHealthy: FieldPath<Bool>   {
      bool("veryHealthy") 
    }
  public var cheap: FieldPath<Bool>   {
      bool("cheap") 
    }
  public var veryPopular: FieldPath<Bool>   {
      bool("veryPopular") 
    }
  public var sustainable: FieldPath<Bool>   {
      bool("sustainable") 
    }
  public var lowFodmap: FieldPath<Bool>   {
      bool("lowFodmap") 
    }
  public var weightWatcherSmartPoints: FieldPath<Int>   {
      int("weightWatcherSmartPoints") 
    }
  public var gaps: FieldPath<String>   {
      string("gaps") 
    }
  public var preparationMinutes: FieldPath<Int>   {
      int("preparationMinutes") 
    }
  public var cookingMinutes: FieldPath<Int>   {
      int("cookingMinutes") 
    }
  public var aggregateLikes: FieldPath<Int>   {
      int("aggregateLikes") 
    }
  public var healthScore: FieldPath<Int>   {
      int("healthScore") 
    }
  public var creditsText: FieldPath<String>   {
      string("creditsText") 
    }
  public var sourceName: FieldPath<String>   {
      string("sourceName") 
    }
  public var pricePerServing: FieldPath<Double>   {
      double("pricePerServing") 
    }
  public var readyInMinutes: FieldPath<Int>   {
      int("readyInMinutes") 
    }
  public var servings: FieldPath<Int>   {
      int("servings") 
    }
  public var sourceUrl: FieldPath<String>   {
      string("sourceUrl") 
    }
  public var summary: FieldPath<String>   {
      string("summary") 
    }
  public var cuisines: FieldPath<String>   {
      string("cuisines") 
    }
  public var dishTypes: FieldPath<String>   {
      string("dishTypes") 
    }
  public var diets: FieldPath<String>   {
      string("diets") 
    }
  public var occasions: FieldPath<String>   {
      string("occasions") 
    }
  public var spoonacularSourceUrl: FieldPath<String>   {
      string("spoonacularSourceUrl") 
    }
  public var spoonacularScore: FieldPath<Int>   {
      int("spoonacularScore") 
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