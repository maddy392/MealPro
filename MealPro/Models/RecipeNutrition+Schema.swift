// swiftlint:disable all
import Amplify
import Foundation

extension RecipeNutrition {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case calorificBreakdown
    case nutrients
    case properties
    case ingredients
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let recipeNutrition = RecipeNutrition.keys
    
    model.listPluralName = "RecipeNutritions"
    model.syncPluralName = "RecipeNutritions"
    
    model.fields(
      .field(recipeNutrition.calorificBreakdown, is: .optional, ofType: .embedded(type: CalorificBreakdown.self)),
      .field(recipeNutrition.nutrients, is: .optional, ofType: .embeddedCollection(of: Nutrient.self)),
      .field(recipeNutrition.properties, is: .optional, ofType: .embeddedCollection(of: NutritionProperty.self)),
      .field(recipeNutrition.ingredients, is: .optional, ofType: .embeddedCollection(of: Ingredient.self))
    )
    }
}