// swiftlint:disable all
import Amplify
import Foundation

public struct Nutrient: Embeddable {
  var name: String
  var amount: Double?
  var unit: String?
  var percentOfDailyNeeds: Double?
}