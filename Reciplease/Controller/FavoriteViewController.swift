import UIKit

class FavoriteViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let coreDataManager = CoreDataManager.shared
    private var savedRecipes: [Recipe] = []
    private var searchResults: [Recipe] = []
    private var isShowingSearchResults = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataManager.delegate = self
        setupTableView()
        
        if isShowingSearchResults {
            tableView?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isShowingSearchResults {
            loadSavedRecipes()
        }
    }
    
    func showSearchResults(_ recipes: [Recipe]) {
        searchResults = recipes
        isShowingSearchResults = true
        title = "Search Results"
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoriteRecipeCell.self, forCellReuseIdentifier: "FavoriteRecipeCell")
    }
    
    private func loadSavedRecipes() {
        coreDataManager.fetchSavedRecipes()
    }
}

extension FavoriteViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isShowingSearchResults ? searchResults.count : savedRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteRecipeCell", for: indexPath) as? FavoriteRecipeCell else {
            return UITableViewCell()
        }
        
        let recipe = isShowingSearchResults ? searchResults[indexPath.row] : savedRecipes[indexPath.row]
        cell.configure(with: recipe)
        
        // Ajouter un cœur si la recette est dans les favoris
        if isShowingSearchResults {
            cell.isFavorite = coreDataManager.isRecipeSaved(recipe)
        } else {
            cell.isFavorite = true
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // ou la hauteur que vous préférez
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && !isShowingSearchResults {
            let recipeToDelete = savedRecipes[indexPath.row]
            coreDataManager.deleteRecipe(recipeToDelete)
            savedRecipes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isShowingSearchResults
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = isShowingSearchResults ? searchResults[indexPath.row] : savedRecipes[indexPath.row]
        // Naviguer vers RecipeDetailViewController
        performSegue(withIdentifier: "ShowRecipeDetail", sender: recipe)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRecipeDetail",
           let destinationVC = segue.destination as? RecipeDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.recipes = isShowingSearchResults ? searchResults : savedRecipes
            destinationVC.currentIndex = indexPath.row
        }
    }
}


extension FavoriteViewController: CoreDataManagerDelegate {
    func didSaveRecipe(_ recipe: Recipe) {
        if !savedRecipes.contains(where: { $0.uri == recipe.uri }) {
            savedRecipes.append(recipe)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func didDeleteRecipe(_ recipe: Recipe) {
        DispatchQueue.main.async { [weak self] in
            self?.loadSavedRecipes()
        }
    }
    
    func didFetchSavedRecipes(_ recipes: [Recipe]) {
        print("Fetched \(recipes.count) saved recipes")
        savedRecipes = recipes
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didEncounterError(_ error: Error) {
        print("Core Data error: \(error.localizedDescription)")
        // Vous pouvez ajouter ici une alerte pour l'utilisateur si nécessaire
    }
    
    func didSaveContext() {
        print("Core Data context saved successfully")
        // Vous pouvez ajouter ici toute logique supplémentaire nécessaire après une sauvegarde réussie
    }
}
