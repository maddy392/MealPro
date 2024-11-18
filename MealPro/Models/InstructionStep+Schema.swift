// swiftlint:disable all
import Amplify
import Foundation

extension InstructionStep {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case number
    case step
    case ingredients
    case equipment
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let instructionStep = InstructionStep.keys
    
    model.listPluralName = "InstructionSteps"
    model.syncPluralName = "InstructionSteps"
    
    model.fields(
      .field(instructionStep.number, is: .required, ofType: .int),
      .field(instructionStep.step, is: .required, ofType: .string),
      .field(instructionStep.ingredients, is: .optional, ofType: .embeddedCollection(of: Ingredient.self)),
      .field(instructionStep.equipment, is: .optional, ofType: .embeddedCollection(of: Equipment.self))
    )
    }
}