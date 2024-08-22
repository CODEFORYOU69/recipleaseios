import Foundation
import CoreData

protocol CoreDataManagerDelegate: AnyObject {
    func didSaveRecipe(_ recipe: Recipe)
    func didDeleteRecipe(_ recipe: Recipe)
    func didFetchSavedRecipes(_ recipes: [Recipe])
    func didEncounterError(_ error: Error)
    func didSaveContext()
}

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Reciplease")
            container.loadPersistentStores { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        container.viewContext.automaticallyMergesChangesFromParent = true
                container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return container
        }()
    weak var delegate: CoreDataManagerDelegate?
    
    private init() {}
       
    
    
    
    func saveRecipe(_ recipe: Recipe) {
           let context = persistentContainer.viewContext
           
           let savedRecipe = SavedRecipe(context: context)
           savedRecipe.uri = recipe.uri
           savedRecipe.label = recipe.label
           savedRecipe.image = recipe.image
           savedRecipe.ingredientLines = recipe.ingredientLines.joined(separator: "|")
           savedRecipe.calories = recipe.calories
           savedRecipe.url = recipe.url
           
           do {
               try context.save()
               print("Recipe saved successfully: \(recipe.label)")
           } catch {
               print("Failed to save recipe: \(error)")
           }
       }
    
    func fetchSavedRecipes() -> [Recipe] {
            let context = persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<SavedRecipe> = SavedRecipe.fetchRequest()
            
            do {
                let savedRecipes = try context.fetch(fetchRequest)
                return savedRecipes.map { savedRecipe in
                    Recipe(
                        uri: savedRecipe.uri ?? "",
                        label: savedRecipe.label ?? "",
                        image: savedRecipe.image ?? "",
                        ingredientLines: (savedRecipe.ingredientLines)?.components(separatedBy: "|") ?? [],
                        calories: savedRecipe.calories,
                        url: savedRecipe.url ?? ""
                    )
                }
            } catch {
                print("Failed to fetch recipes: \(error)")
                return []
            }
        }
    
    func deleteRecipe(_ recipe: Recipe) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SavedRecipe> = SavedRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uri == %@", recipe.uri)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let savedRecipe = results.first {
                context.delete(savedRecipe)
                try context.save()
                DispatchQueue.main.async {
                    self.delegate?.didDeleteRecipe(recipe)
                }
            }
        } catch {
            delegate?.didEncounterError(error)
        }
    }
    
    func isRecipeSaved(_ recipe: Recipe) -> Bool {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SavedRecipe> = SavedRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uri == %@", recipe.uri)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking if recipe is saved: \(error)")
            return false
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                delegate?.didSaveContext()
            } catch {
                let nserror = error as NSError
                delegate?.didEncounterError(nserror)
            }
        }
    }
}
