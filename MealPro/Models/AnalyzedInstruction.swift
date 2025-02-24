// swiftlint:disable all
import Amplify
import Foundation

public struct AnalyzedInstruction: Embeddable {
  public var name: String?
  public var steps: [InstructionStep?]?
}
