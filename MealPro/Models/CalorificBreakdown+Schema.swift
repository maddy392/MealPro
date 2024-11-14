// swiftlint:disable all
import Amplify
import Foundation

extension CalorificBreakdown {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case percentProtein
    case percentFat
    case percentCarbs
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let calorificBreakdown = CalorificBreakdown.keys
    
    model.listPluralName = "CalorificBreakdowns"
    model.syncPluralName = "CalorificBreakdowns"
    
    model.fields(
      .field(calorificBreakdown.percentProtein, is: .optional, ofType: .double),
      .field(calorificBreakdown.percentFat, is: .optional, ofType: .double),
      .field(calorificBreakdown.percentCarbs, is: .optional, ofType: .double)
    )
    }
}