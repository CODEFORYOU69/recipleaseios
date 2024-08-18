import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    weak var delegate: CoreDataManagerDelegate?
    
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "Reciplease")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    func saveRecipe(_ recipe: Recipe) {
        let context = container.viewContext
        let savedRecipe = SavedRecipe(context: context)
        savedRecipe.label = recipe.label
        savedRecipe.image = recipe.image
        savedRecipe.ingredientLines = recipe.ingredientLines as NSObject
        savedRecipe.uri = recipe.uri
        
        saveContext()
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        let context = container.viewContext
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
    
    func fetchSavedRecipes() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<SavedRecipe> = SavedRecipe.fetchRequest()
        
        do {
            let savedRecipes = try context.fetch(fetchRequest)
            let recipes = savedRecipes.map { savedRecipe -> Recipe in
                return Recipe(
                    uri: savedRecipe.uri ?? "",
                    label: savedRecipe.label ?? "",
                    image: savedRecipe.image ?? "",
                    ingredientLines: savedRecipe.ingredientLines as? [String] ?? []
                )
            }
            delegate?.didFetchSavedRecipes(recipes)
        } catch {
            delegate?.didEncounterError(error)
        }
    }
    
    
    // MARK: - Core Data Saving support

    func saveContext() {
        let context = container.viewContext
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
    
    func isRecipeSaved(_ recipe: Recipe) -> Bool {
           let context = container.viewContext
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
}
