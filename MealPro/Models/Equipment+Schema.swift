// swiftlint:disable all
import Amplify
import Foundation

extension Equipment {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case localizedName
    case image
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let equipment = Equipment.keys
    
    model.listPluralName = "Equipment"
    model.syncPluralName = "Equipment"
    
    model.fields(
      .field(equipment.id, is: .required, ofType: .int),
      .field(equipment.name, is: .required, ofType: .string),
      .field(equipment.localizedName, is: .optional, ofType: .string),
      .field(equipment.image, is: .optional, ofType: .string)
    )
    }
}