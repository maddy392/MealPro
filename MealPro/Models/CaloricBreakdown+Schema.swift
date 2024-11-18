// swiftlint:disable all
import Amplify
import Foundation

extension CaloricBreakdown {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case percentProtein
    case percentFat
    case percentCarbs
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let caloricBreakdown = CaloricBreakdown.keys
    
    model.listPluralName = "CaloricBreakdowns"
    model.syncPluralName = "CaloricBreakdowns"
    
    model.fields(
      .field(caloricBreakdown.percentProtein, is: .optional, ofType: .double),
      .field(caloricBreakdown.percentFat, is: .optional, ofType: .double),
      .field(caloricBreakdown.percentCarbs, is: .optional, ofType: .double)
    )
    }
}