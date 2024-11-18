// swiftlint:disable all
import Amplify
import Foundation

public struct RecipeAnalyzedInstructions: Embeddable {
  var name: String?
  var steps: [InstructionStep?]?
}