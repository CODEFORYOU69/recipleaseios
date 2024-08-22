//
//  RecipleaseTests.swift
//  RecipleaseTests
//
//  Created by younes ouasmi on 17/06/2024.
//

import XCTest
@testable import Reciplease

class RecipeTests: XCTestCase {
    
    func testRecipeInitialization() {
        let recipe = Recipe(uri: "test_uri", label: "Test Recipe", image: "test_image_url", ingredientLines: ["Ingredient 1", "Ingredient 2"], calories: 100.0, url: "https://example.com")
        
        XCTAssertEqual(recipe.uri, "test_uri")
        XCTAssertEqual(recipe.label, "Test Recipe")
        XCTAssertEqual(recipe.image, "test_image_url")
        XCTAssertEqual(recipe.ingredientLines, ["Ingredient 1", "Ingredient 2"])
        XCTAssertEqual(recipe.calories, 100.0)
        XCTAssertEqual(recipe.url, "https://example.com")
    }
    
    func testRecipeEquality() {
        let recipe1 = Recipe(uri: "test_uri", label: "Test Recipe", image: "test_image_url", ingredientLines: ["Ingredient 1", "Ingredient 2"], calories: 100.0, url: "https://example.com")
        let recipe2 = Recipe(uri: "test_uri", label: "Test Recipe", image: "test_image_url", ingredientLines: ["Ingredient 1", "Ingredient 2"], calories: 100.0, url: "https://example.com")
        let recipe3 = Recipe(uri: "different_uri", label: "Different Recipe", image: "different_image_url", ingredientLines: ["Ingredient 3"], calories: 200.0, url: "https://different.com")
        
        XCTAssertEqual(recipe1, recipe2)
        XCTAssertNotEqual(recipe1, recipe3)
    }
    
    func testRecipeCodable() {
        let recipe = Recipe(uri: "test_uri", label: "Test Recipe", image: "test_image_url", ingredientLines: ["Ingredient 1", "Ingredient 2"], calories: 100.0, url: "https://example.com")
        
        // Test encoding
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(recipe))
        
        guard let encodedData = try? encoder.encode(recipe) else {
            XCTFail("Failed to encode recipe")
            return
        }
        
        // Test decoding
        let decoder = JSONDecoder()
        XCTAssertNoThrow(try decoder.decode(Recipe.self, from: encodedData))
        
        guard let decodedRecipe = try? decoder.decode(Recipe.self, from: encodedData) else {
            XCTFail("Failed to decode recipe")
            return
        }
        
        XCTAssertEqual(recipe, decodedRecipe)
    }
    
    func testPaginatedRecipes() {
        let recipes = [
            Recipe(uri: "uri1", label: "Recipe 1", image: "image1", ingredientLines: ["Ingredient 1"], calories: 100.0, url: "https://example1.com"),
            Recipe(uri: "uri2", label: "Recipe 2", image: "image2", ingredientLines: ["Ingredient 2"], calories: 200.0, url: "https://example2.com")
        ]
        
        let paginatedRecipes = PaginatedRecipes(recipes: recipes, nextPage: 2, totalResults: 10)
        
        XCTAssertEqual(paginatedRecipes.recipes.count, 2)
        XCTAssertEqual(paginatedRecipes.nextPage, 2)
        XCTAssertEqual(paginatedRecipes.totalResults, 10)
    }
}
