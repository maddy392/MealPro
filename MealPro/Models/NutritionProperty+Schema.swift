// swiftlint:disable all
import Amplify
import Foundation

extension NutritionProperty {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case name
    case amount
    case unit
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let nutritionProperty = NutritionProperty.keys
    
    model.listPluralName = "NutritionProperties"
    model.syncPluralName = "NutritionProperties"
    
    model.fields(
      .field(nutritionProperty.name, is: .required, ofType: .string),
      .field(nutritionProperty.amount, is: .optional, ofType: .double),
      .field(nutritionProperty.unit, is: .optional, ofType: .string)
    )
    }
}