import Foundation
import Alamofire

enum RecipeServiceError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
}

struct RecipeService {
    private let apiId: String
    private let apiKey: String
    private let baseURL = "https://api.edamam.com/api/recipes/v2"
    private let type = "public"
    private let itemsPerPage = 20
    
    private let cache = NSCache<NSString, AnyObject>()

    
    var networkService: NetworkService

    init(apiId: String, apiKey: String, networkService: NetworkService = AlamofireNetworkService()) {
        self.apiId = apiId
        self.apiKey = apiKey
        self.networkService = networkService
    }

    func searchRecipes(with ingredients: [String], page: Int, completion: @escaping (Result<PaginatedRecipes, RecipeServiceError>) -> Void) {
        
        let cacheKey = (ingredients.joined() + "\(page)") as NSString
        if let cachedResult = cache.object(forKey: cacheKey) as? PaginatedRecipes {
            completion(.success(cachedResult))
            return
        }

        
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }

        let from = (page - 1) * itemsPerPage
        let to = page * itemsPerPage

        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "q", value: ingredients.joined(separator: ",")),
            URLQueryItem(name: "app_id", value: apiId),
            URLQueryItem(name: "app_key", value: apiKey),
            URLQueryItem(name: "from", value: String(from)),
            URLQueryItem(name: "to", value: String(to))
        ]

        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }

        print("Request URL: \(url.absoluteString)")

        networkService.request(url) { result in
            switch result {
            case .success(let data):
                do {
                    let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
                    let recipes = recipeResponse.hits.map { $0.recipe }
                    let totalResults = recipeResponse.count
                    let nextPage = (from + recipes.count < totalResults) ? page + 1 : nil
                    let paginatedRecipes = PaginatedRecipes(recipes: recipes, nextPage: nextPage, totalResults: totalResults)
                    self.cache.setObject(paginatedRecipes as AnyObject, forKey: cacheKey)
                    completion(.success(paginatedRecipes))
                } catch {
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                            print("codingPath: \(context.codingPath)")
                        case .valueNotFound(let type, let context):
                            print("Value of type '\(type)' not found: \(context.debugDescription)")
                            print("codingPath: \(context.codingPath)")
                        case .typeMismatch(let type, let context):
                            print("Type '\(type)' mismatch: \(context.debugDescription)")
                            print("codingPath: \(context.codingPath)")
                        case .dataCorrupted(let context):
                            print("Data corrupted: \(context.debugDescription)")
                            print("codingPath: \(context.codingPath)")
                        @unknown default:
                            print("Unknown decoding error")
                        }
                    }
                    completion(.failure(.decodingError(error)))
                }
            case .failure(let error):
                print("Network error: \(error)")
                completion(.failure(.networkError(error)))
            }
        }
    }
}
