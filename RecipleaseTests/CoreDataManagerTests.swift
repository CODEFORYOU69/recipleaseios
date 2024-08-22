//
//  CoreDataManagerTests.swift
//  RecipleaseTests
//
//  Created by younes ouasmi on 20/08/2024.
//

import XCTest
import CoreData
@testable import Reciplease

class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    var mockPersistentContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        
        // Set up an in-memory Core Data stack for testing
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        mockPersistentContainer = NSPersistentContainer(name: "TestContainer", managedObjectModel: managedObjectModel)
        mockPersistentContainer.persistentStoreDescriptions = [persistentStoreDescription]
        
        mockPersistentContainer.loadPersistentStores { (storeDescription, error) in
            XCTAssertNil(error)
        }
        
        coreDataManager = CoreDataManager.shared
        coreDataManager.persistentContainer = mockPersistentContainer
    }
    
    override func tearDown() {
        coreDataManager = nil
        mockPersistentContainer = nil
        super.tearDown()
    }
    
    func testSaveAndFetchRecipe() {
        let testRecipe = Recipe(uri: "test_uri", label: "Test Recipe", image: "test_image", ingredientLines: ["Ingredient 1", "Ingredient 2"], calories: 100.0, url: "https://example.com")
        
        coreDataManager.saveRecipe(testRecipe)
        
        let savedRecipes = coreDataManager.fetchSavedRecipes()
        XCTAssertEqual(savedRecipes.count, 1)
        XCTAssertEqual(savedRecipes.first, testRecipe)
        
        XCTAssertTrue(coreDataManager.isRecipeSaved(testRecipe))
    }
    
    func testDeleteRecipe() {
        let testRecipe = Recipe(uri: "test_uri", label: "Test Recipe", image: "test_image", ingredientLines: ["Ingredient 1", "Ingredient 2"], calories: 100.0, url: "https://example.com")
        
        coreDataManager.saveRecipe(testRecipe)
        XCTAssertTrue(coreDataManager.isRecipeSaved(testRecipe))
        
        coreDataManager.deleteRecipe(testRecipe)
        XCTAssertFalse(coreDataManager.isRecipeSaved(testRecipe))
        
        let savedRecipes = coreDataManager.fetchSavedRecipes()
        XCTAssertEqual(savedRecipes.count, 0)
    }
}

// MARK: - Mock CoreDataManagerDelegate
class MockCoreDataManagerDelegate: CoreDataManagerDelegate {
    var savedRecipe: Recipe?
    var deletedRecipe: Recipe?
    var fetchedRecipes: [Recipe]?
    var encounteredError: Error?
    var contextSaved = false
    
    func didSaveRecipe(_ recipe: Recipe) {
        savedRecipe = recipe
    }
    
    func didDeleteRecipe(_ recipe: Recipe) {
        deletedRecipe = recipe
    }
    
    func didFetchSavedRecipes(_ recipes: [Recipe]) {
        fetchedRecipes = recipes
    }
    
    func didEncounterError(_ error: Error) {
        encounteredError = error
    }
    
    func didSaveContext() {
        contextSaved = true
    }
}
