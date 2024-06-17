//
//  RecipeService.swift
//  Reciplease
//
//  Created by younes ouasmi on 27/06/2024.
//


import Foundation
import Alamofire



struct RecipeService {
    let apiKey = "f6225413"
    let apiId = "d414e37698fba8f4599bd1335e297d90    "
    let baseURL = "https://api.edamam.com/search"

    func searchRecipes(with ingredients: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        let ingredientsString = ingredients.joined(separator: ",")
        let urlString = "\(baseURL)?q=\(ingredientsString)&app_id=\(apiId)&app_key=\(apiKey)"
        
        AF.request(urlString).responseDecodable(of: RecipeResponse.self) { response in
            switch response.result {
            case .success(let recipeResponse):
                completion(.success(recipeResponse.hits.map { $0.recipe }))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct RecipeResponse: Decodable {
    let hits: [Hit]
}

struct Hit: Decodable {
    let recipe: Recipe
}

struct Recipe: Decodable {
    let label: String
    let ingredientLines: [String]
    let image: String
}
