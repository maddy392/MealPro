// swiftlint:disable all
import Amplify
import Foundation

extension Nutrient {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case name
    case amount
    case unit
    case percentOfDailyNeeds
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let nutrient = Nutrient.keys
    
    model.listPluralName = "Nutrients"
    model.syncPluralName = "Nutrients"
    
    model.fields(
      .field(nutrient.name, is: .required, ofType: .string),
      .field(nutrient.amount, is: .optional, ofType: .double),
      .field(nutrient.unit, is: .optional, ofType: .string),
      .field(nutrient.percentOfDailyNeeds, is: .optional, ofType: .double)
    )
    }
}