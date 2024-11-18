// swiftlint:disable all
import Amplify
import Foundation

extension AnalyzedInstruction {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case name
    case steps
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let analyzedInstruction = AnalyzedInstruction.keys
    
    model.listPluralName = "AnalyzedInstructions"
    model.syncPluralName = "AnalyzedInstructions"
    
    model.fields(
      .field(analyzedInstruction.name, is: .optional, ofType: .string),
      .field(analyzedInstruction.steps, is: .optional, ofType: .embeddedCollection(of: InstructionStep.self))
    )
    }
}