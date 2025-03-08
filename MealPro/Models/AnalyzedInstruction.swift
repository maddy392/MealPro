// swiftlint:disable all
import Amplify
import Foundation

public struct AnalyzedInstruction: Embeddable {
  var name: String?
  var steps: [InstructionStep?]?
}