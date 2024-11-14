// swiftlint:disable all
import Amplify
import Foundation

extension Ingredient {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case amount
    case unit
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let ingredient = Ingredient.keys
    
    model.listPluralName = "Ingredients"
    model.syncPluralName = "Ingredients"
    
    model.fields(
      .field(ingredient.id, is: .required, ofType: .int),
      .field(ingredient.name, is: .required, ofType: .string),
      .field(ingredient.amount, is: .optional, ofType: .double),
      .field(ingredient.unit, is: .optional, ofType: .string)
    )
    }
}