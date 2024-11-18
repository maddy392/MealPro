// swiftlint:disable all
import Amplify
import Foundation

public struct Recipe: Model, Identifiable {
  public var id: Int { recipeId } // `id` property required by `Identifiable`
  public let recipeId: Int
  public var title: String
  public var image: String?
  public var imageType: String?
  public var vegetarian: Bool?
  public var vegan: Bool?
  public var glutenFree: Bool?
  public var dairyFree: Bool?
  public var veryHealthy: Bool?
  public var cheap: Bool?
  public var veryPopular: Bool?
  public var sustainable: Bool?
  public var lowFodmap: Bool?
  public var weightWatcherSmartPoints: Int?
  public var gaps: String?
  public var preparationMinutes: Int?
  public var cookingMinutes: Int?
  public var aggregateLikes: Int?
  public var healthScore: Int?
  public var creditsText: String?
  public var sourceName: String?
  public var pricePerServing: Double?
  public var readyInMinutes: Int?
  public var servings: Int?
  public var sourceUrl: String?
  public var summary: String?
  public var cuisines: [String?]?
  public var dishTypes: [String?]?
  public var diets: [String?]?
  public var occasions: [String?]?
  public var spoonacularSourceUrl: String?
  public var spoonacularScore: Double?
  public var nutrition: RecipeNutrition?
  public var analyzedInstructions: [AnalyzedInstruction?]?
  public var userFavorites: List<UserFavorite>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(recipeId: Int,
      title: String,
      image: String? = nil,
      imageType: String? = nil,
      vegetarian: Bool? = nil,
      vegan: Bool? = nil,
      glutenFree: Bool? = nil,
      dairyFree: Bool? = nil,
      veryHealthy: Bool? = nil,
      cheap: Bool? = nil,
      veryPopular: Bool? = nil,
      sustainable: Bool? = nil,
      lowFodmap: Bool? = nil,
      weightWatcherSmartPoints: Int? = nil,
      gaps: String? = nil,
      preparationMinutes: Int? = nil,
      cookingMinutes: Int? = nil,
      aggregateLikes: Int? = nil,
      healthScore: Int? = nil,
      creditsText: String? = nil,
      sourceName: String? = nil,
      pricePerServing: Double? = nil,
      readyInMinutes: Int? = nil,
      servings: Int? = nil,
      sourceUrl: String? = nil,
      summary: String? = nil,
      cuisines: [String?]? = nil,
      dishTypes: [String?]? = nil,
      diets: [String?]? = nil,
      occasions: [String?]? = nil,
      spoonacularSourceUrl: String? = nil,
      spoonacularScore: Double? = nil,
      nutrition: RecipeNutrition? = nil,
      analyzedInstructions: [AnalyzedInstruction?]? = nil,
      userFavorites: List<UserFavorite>? = []) {
    self.init(recipeId: recipeId,
      title: title,
      image: image,
      imageType: imageType,
      vegetarian: vegetarian,
      vegan: vegan,
      glutenFree: glutenFree,
      dairyFree: dairyFree,
      veryHealthy: veryHealthy,
      cheap: cheap,
      veryPopular: veryPopular,
      sustainable: sustainable,
      lowFodmap: lowFodmap,
      weightWatcherSmartPoints: weightWatcherSmartPoints,
      gaps: gaps,
      preparationMinutes: preparationMinutes,
      cookingMinutes: cookingMinutes,
      aggregateLikes: aggregateLikes,
      healthScore: healthScore,
      creditsText: creditsText,
      sourceName: sourceName,
      pricePerServing: pricePerServing,
      readyInMinutes: readyInMinutes,
      servings: servings,
      sourceUrl: sourceUrl,
      summary: summary,
      cuisines: cuisines,
      dishTypes: dishTypes,
      diets: diets,
      occasions: occasions,
      spoonacularSourceUrl: spoonacularSourceUrl,
      spoonacularScore: spoonacularScore,
      nutrition: nutrition,
      analyzedInstructions: analyzedInstructions,
      userFavorites: userFavorites,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(recipeId: Int,
      title: String,
      image: String? = nil,
      imageType: String? = nil,
      vegetarian: Bool? = nil,
      vegan: Bool? = nil,
      glutenFree: Bool? = nil,
      dairyFree: Bool? = nil,
      veryHealthy: Bool? = nil,
      cheap: Bool? = nil,
      veryPopular: Bool? = nil,
      sustainable: Bool? = nil,
      lowFodmap: Bool? = nil,
      weightWatcherSmartPoints: Int? = nil,
      gaps: String? = nil,
      preparationMinutes: Int? = nil,
      cookingMinutes: Int? = nil,
      aggregateLikes: Int? = nil,
      healthScore: Int? = nil,
      creditsText: String? = nil,
      sourceName: String? = nil,
      pricePerServing: Double? = nil,
      readyInMinutes: Int? = nil,
      servings: Int? = nil,
      sourceUrl: String? = nil,
      summary: String? = nil,
      cuisines: [String?]? = nil,
      dishTypes: [String?]? = nil,
      diets: [String?]? = nil,
      occasions: [String?]? = nil,
      spoonacularSourceUrl: String? = nil,
      spoonacularScore: Double? = nil,
      nutrition: RecipeNutrition? = nil,
      analyzedInstructions: [AnalyzedInstruction?]? = nil,
      userFavorites: List<UserFavorite>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.recipeId = recipeId
      self.title = title
      self.image = image
      self.imageType = imageType
      self.vegetarian = vegetarian
      self.vegan = vegan
      self.glutenFree = glutenFree
      self.dairyFree = dairyFree
      self.veryHealthy = veryHealthy
      self.cheap = cheap
      self.veryPopular = veryPopular
      self.sustainable = sustainable
      self.lowFodmap = lowFodmap
      self.weightWatcherSmartPoints = weightWatcherSmartPoints
      self.gaps = gaps
      self.preparationMinutes = preparationMinutes
      self.cookingMinutes = cookingMinutes
      self.aggregateLikes = aggregateLikes
      self.healthScore = healthScore
      self.creditsText = creditsText
      self.sourceName = sourceName
      self.pricePerServing = pricePerServing
      self.readyInMinutes = readyInMinutes
      self.servings = servings
      self.sourceUrl = sourceUrl
      self.summary = summary
      self.cuisines = cuisines
      self.dishTypes = dishTypes
      self.diets = diets
      self.occasions = occasions
      self.spoonacularSourceUrl = spoonacularSourceUrl
      self.spoonacularScore = spoonacularScore
      self.nutrition = nutrition
      self.analyzedInstructions = analyzedInstructions
      self.userFavorites = userFavorites
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
