// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "f3ab61d3350550c5a2b39a62039a289f"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: UserFavorite.self)
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: Recipe.self)
  }
}