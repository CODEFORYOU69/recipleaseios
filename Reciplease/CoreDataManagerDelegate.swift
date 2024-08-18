//
//  Reciplease
//
//  Created by younes ouasmi on 24/07/2024.
//

import Foundation

protocol CoreDataManagerDelegate: AnyObject {
    func didSaveRecipe(_ recipe: Recipe)
    func didDeleteRecipe(_ recipe: Recipe)
    func didFetchSavedRecipes(_ recipes: [Recipe])
    func didEncounterError(_ error: Error)
    func didSaveContext()
}
