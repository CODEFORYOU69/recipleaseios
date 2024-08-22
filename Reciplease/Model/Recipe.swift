import Foundation

struct Recipe: Codable, Equatable {
    let uri: String
    let label: String
    let image: String
    let ingredientLines: [String]
    let calories: Double
    let url: String  // URL pour les instructions complètes
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.uri == rhs.uri &&
               lhs.label == rhs.label &&
               lhs.image == rhs.image &&
               lhs.ingredientLines == rhs.ingredientLines &&
               lhs.calories == rhs.calories &&
               lhs.url == rhs.url
    }
}

struct PaginatedRecipes {
    let recipes: [Recipe]
    let nextPage: Int?
    let totalResults: Int
}

struct RecipeResponse: Decodable {
    let hits: [Hit]
    let count: Int
}

struct Hit: Decodable {
    let recipe: Recipe
}
