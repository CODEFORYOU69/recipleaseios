//
//  RecipeServiceTests.swift
//  RecipleaseTests
//
//  Created by younes ouasmi on 20/08/2024.
//

import XCTest
@testable import Reciplease

class RecipeServiceTests: XCTestCase {
    
    var recipeService: RecipeService!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        recipeService = RecipeService(apiId: "test_id", apiKey: "test_key", networkService: mockNetworkService)
    }
    
    override func tearDown() {
        recipeService = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testSearchRecipesSuccess() {
        let expectation = self.expectation(description: "Search recipes")
        
        // Mock successful response
        let mockData = """
        {
            "hits": [
                {
                    "recipe": {
                        "uri": "test_uri",
                        "label": "Test Recipe",
                        "image": "test_image_url",
                        "ingredientLines": ["Ingredient 1", "Ingredient 2"],
                        "calories": 100.0,
                        "url": "https://example.com"
                    }
                }
            ],
            "count": 1
        }
        """.data(using: .utf8)!
        
        mockNetworkService.mockResult = .success(mockData)
        
        recipeService.searchRecipes(with: ["chicken"], page: 1) { result in
            switch result {
            case .success(let paginatedRecipes):
                XCTAssertEqual(paginatedRecipes.recipes.count, 1)
                XCTAssertEqual(paginatedRecipes.recipes[0].label, "Test Recipe")
                XCTAssertEqual(paginatedRecipes.totalResults, 1)
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSearchRecipesFailure() {
        let expectation = self.expectation(description: "Search recipes failure")
        
        // Mock failure response
        mockNetworkService.mockResult = .failure(NSError(domain: "TestError", code: 0, userInfo: nil))
        
        recipeService.searchRecipes(with: ["chicken"], page: 1) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    func testKeyNotFoundError() {
            let expectation = self.expectation(description: "Key not found error")
            
            let mockData = """
            {
                "hits": [
                    {
                        "recipe": {
                            "label": "Test Recipe",
                            "image": "test_image_url",
                            "ingredientLines": ["Ingredient 1", "Ingredient 2"],
                            "calories": 100.0,
                            "url": "https://example.com"
                        }
                    }
                ],
                "count": 1
            }
            """.data(using: .utf8)!
            
            mockNetworkService.mockResult = .success(mockData)
            
            recipeService.searchRecipes(with: ["chicken"], page: 1) { result in
                switch result {
                case .success:
                    XCTFail("Expected failure, but got success")
                case .failure(let error):
                    if case .decodingError(let decodingError) = error,
                       case .keyNotFound(let key, _) = decodingError as? DecodingError {
                        XCTAssertEqual(key.stringValue, "uri")
                    } else {
                        XCTFail("Expected keyNotFound error, but got \(error)")
                    }
                }
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 5, handler: nil)
        }

    func testValueNotFoundError() {
        let expectation = self.expectation(description: "Value not found error")
        
        let mockData = """
        {
            "hits": [
                {
                    "recipe": {
                        "uri": null,
                        "label": "Test Recipe",
                        "image": "test_image_url",
                        "ingredientLines": ["Ingredient 1", "Ingredient 2"],
                        "calories": 100.0,
                        "url": "https://example.com"
                    }
                }
            ],
            "count": 1
        }
        """.data(using: .utf8)!
        
        mockNetworkService.mockResult = .success(mockData)
        
        recipeService.searchRecipes(with: ["chicken"], page: 1) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                if case .decodingError(let decodingError) = error,
                   case .valueNotFound(let type, _) = decodingError as? DecodingError {
                    XCTAssertTrue(type is String.Type, "Expected String.Type for valueNotFound error")
                } else {
                    XCTFail("Expected valueNotFound error, but got \(error)")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testTypeMismatchError() {
        let expectation = self.expectation(description: "Type mismatch error")
        
        let mockData = """
        {
            "hits": [
                {
                    "recipe": {
                        "uri": "test_uri",
                        "label": "Test Recipe",
                        "image": "test_image_url",
                        "ingredientLines": ["Ingredient 1", "Ingredient 2"],
                        "calories": "Not a number",
                        "url": "https://example.com"
                    }
                }
            ],
            "count": 1
        }
        """.data(using: .utf8)!
        
        mockNetworkService.mockResult = .success(mockData)
        
        recipeService.searchRecipes(with: ["chicken"], page: 1) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                if case .decodingError(let decodingError) = error,
                   case .typeMismatch(let type, _) = decodingError as? DecodingError {
                    XCTAssertTrue(type is Double.Type, "Expected Double.Type for typeMismatch error")
                } else {
                    XCTFail("Expected typeMismatch error, but got \(error)")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
        func testDataCorruptedError() {
            let expectation = self.expectation(description: "Data corrupted error")
            
            let mockData = "This is not valid JSON".data(using: .utf8)!
            
            mockNetworkService.mockResult = .success(mockData)
            
            recipeService.searchRecipes(with: ["chicken"], page: 1) { result in
                switch result {
                case .success:
                    XCTFail("Expected failure, but got success")
                case .failure(let error):
                    if case .decodingError(let decodingError) = error,
                       case .dataCorrupted(_) = decodingError as? DecodingError {
                        // Test passes
                    } else {
                        XCTFail("Expected dataCorrupted error, but got \(error)")
                    }
                }
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 5, handler: nil)
        }

        func testNetworkError() {
            let expectation = self.expectation(description: "Network error")
            
            let mockError = NSError(domain: "NetworkErrorDomain", code: -1, userInfo: nil)
            mockNetworkService.mockResult = .failure(mockError)
            
            recipeService.searchRecipes(with: ["chicken"], page: 1) { result in
                switch result {
                case .success:
                    XCTFail("Expected failure, but got success")
                case .failure(let error):
                    if case .networkError(let networkError) = error {
                        XCTAssertEqual((networkError as NSError).domain, "NetworkErrorDomain")
                        XCTAssertEqual((networkError as NSError).code, -1)
                    } else {
                        XCTFail("Expected networkError, but got \(error)")
                    }
                }
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 5, handler: nil)
        }
}

// MARK: - Mock Network Service for testing
class MockNetworkService: NetworkService {
    var mockResult: Result<Data, Error>?
    
    func request(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        if let result = mockResult {
            completion(result)
        } else {
            completion(.failure(NSError(domain: "MockNetworkService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mock result set"])))
        }
    }
}
