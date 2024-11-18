// swiftlint:disable all
import Amplify
import Foundation

extension RecipeAnalyzedInstructions {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case name
    case steps
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let recipeAnalyzedInstructions = RecipeAnalyzedInstructions.keys
    
    model.listPluralName = "RecipeAnalyzedInstructions"
    model.syncPluralName = "RecipeAnalyzedInstructions"
    
    model.fields(
      .field(recipeAnalyzedInstructions.name, is: .optional, ofType: .string),
      .field(recipeAnalyzedInstructions.steps, is: .optional, ofType: .embeddedCollection(of: InstructionStep.self))
    )
    }
}