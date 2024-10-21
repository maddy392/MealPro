// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "90f17567bb029867e553ff145aa0cc4a"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: UserFavorite.self)
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: Recipe.self)
  }
}