// swiftlint:disable all
import Amplify
import Foundation

public struct InstructionStep: Embeddable {
  var number: Int
  var step: String
  var ingredients: [Ingredient?]?
  var equipment: [Equipment?]?
}