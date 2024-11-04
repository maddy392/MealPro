// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "9df453d29f03e408ba80de444efe93d3"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: UserFavorite.self)
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: Recipe.self)
  }
}