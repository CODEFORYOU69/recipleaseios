//
//  RecipeService.swift
//  Reciplease
//
//  Created by younes ouasmi on 27/06/2024.
//


import Foundation
import Alamofire

struct RecipeService {
    // MARK: - Properties
    private let apiId: String
    private let apiKey: String
    private let baseURL = "https://api.edamam.com/api/recipes/v2"
    private let type = "public"

    // MARK: - Initialization
    init(apiId: String, apiKey: String) {
        self.apiId = apiId
        self.apiKey = apiKey
    }

    // MARK: - Public Methods
    func searchRecipes(with ingredients: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(NSError(domain: "RecipeService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "q", value: ingredients.joined(separator: ",")),
            URLQueryItem(name: "app_id", value: apiId),
            URLQueryItem(name: "app_key", value: apiKey)
        ]

        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "RecipeService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL components"])))
            return
        }

        AF.request(url).responseDecodable(of: RecipeResponse.self) { response in
            switch response.result {
            case .success(let recipeResponse):
                completion(.success(recipeResponse.hits.map { $0.recipe }))
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Data Models
struct RecipeResponse: Decodable {
    let hits: [Hit]
}

struct Hit: Decodable {
    let recipe: Recipe
}

struct Recipe: Decodable {
    let uri: String
    let label: String
    let image: String
    let ingredientLines: [String]
}
