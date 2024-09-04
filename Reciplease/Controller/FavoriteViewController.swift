import UIKit

class FavoriteViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let coreDataManager = CoreDataManager.shared

    private var savedRecipes: [Recipe] = []
    private var searchResults: [Recipe] = []
    private var isShowingSearchResults = false
    
    private var isLoading = false
        private var currentPage = 1
        private var hasMoreResults = true

        weak var searchViewController: SearchViewController?
        
        private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        coreDataManager.delegate = self
        setupBackground()
        setupTableView()
        setupLoadingIndicator()

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
    

    func showSearchResults(_ recipes: [Recipe], searchViewController: SearchViewController) {
        self.searchViewController = searchViewController
        searchResults = recipes
        isShowingSearchResults = true
        currentPage = 1
        hasMoreResults = true
        title = "Search Results"
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    private func loadMoreResults() {
           guard isShowingSearchResults, !isLoading, hasMoreResults else { return }
           isLoading = true
           loadingIndicator.startAnimating()
           
           searchViewController?.loadMoreResults { [weak self] result in
               guard let self = self else { return }
               
               switch result {
               case .success(let newRecipes):
                   if newRecipes.isEmpty {
                       self.hasMoreResults = false
                   } else {
                       self.searchResults.append(contentsOf: newRecipes)
                   }
               case .failure(let error):
                   print("Failed to load more recipes: \(error)")
               }
               
               DispatchQueue.main.async {
                   self.tableView.reloadData()
                   self.isLoading = false
                   self.loadingIndicator.stopAnimating()
               }
           }
       }
    
    private func setupBackground() {
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIColor.appBackground()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.insertSubview(backgroundImageView, at: 0)

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(FavoriteRecipeCell.self, forCellReuseIdentifier: "FavoriteRecipeCell")
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .gray
        tableView.tableFooterView = loadingIndicator
    }
    
    private func toggleFavorite(for recipe: Recipe, at indexPath: IndexPath) {
       
        if coreDataManager.isRecipeSaved(recipe) {
            coreDataManager.deleteRecipe(recipe)
            if !isShowingSearchResults {
                savedRecipes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        } else {
            coreDataManager.saveRecipe(recipe)
            if !isShowingSearchResults {
                savedRecipes.append(recipe)
                tableView.insertRows(at: [IndexPath(row: savedRecipes.count - 1, section: 0)], with: .automatic)
            } else {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    private func loadSavedRecipes() {
        print("Loading saved recipes")

        savedRecipes = coreDataManager.fetchSavedRecipes()
        tableView.reloadData()

        
    }
}

extension FavoriteViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isShowingSearchResults ? searchResults.count : savedRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteRecipeCell", for: indexPath) as? FavoriteRecipeCell else {
            print("Failed to dequeue FavoriteRecipeCell")
            return UITableViewCell()
        }
        
        let recipe = isShowingSearchResults ? searchResults[indexPath.row] : savedRecipes[indexPath.row]
        print("Configuring cell for recipe: \(recipe.label)")

        cell.configure(with: recipe)
        
        let isFavorite = coreDataManager.isRecipeSaved(recipe)
        cell.isFavorite = isFavorite
        print("Recipe \(recipe.label) is favorite: \(isFavorite)")
        
        cell.favoriteButtonTapped = { [weak self] in
            self?.toggleFavorite(for: recipe, at: indexPath)
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
        performSegue(withIdentifier: "ShowRecipeDetail", sender: recipe)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRecipeDetail",
           let destinationVC = segue.destination as? RecipeDetailViewController,
           let recipe = sender as? Recipe {
            destinationVC.recipe = recipe
            
            if isShowingSearchResults {
                // Si nous affichons les résultats de recherche, utilisez le délégué du SearchViewController
                destinationVC.delegate = searchViewController as? FavoriteUpdateDelegate
            } else {
                // Sinon, utilisez self comme délégué
                destinationVC.delegate = self
            }
            
            print("Preparing for segue to RecipeDetailViewController")
            print("Is showing search results: \(isShowingSearchResults)")
            print("Delegate set: \(destinationVC.delegate != nil)")
        }
    }
}

extension FavoriteViewController: CoreDataManagerDelegate {
    func didSaveRecipe(_ recipe: Recipe) {
        print("Attempting to save recipe: \(recipe.label)")
        if !savedRecipes.contains(where: { $0.uri == recipe.uri }) {
            savedRecipes.append(recipe)
            print("Recipe added to savedRecipes: \(recipe.label)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
                print("TableView reloaded after adding recipe")
            }
        } else {
            print("Recipe already exists in savedRecipes: \(recipe.label)")
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

extension FavoriteViewController: FavoriteUpdateDelegate {
    func didAddFavorite(recipe: Recipe) {
        if !savedRecipes.contains(where: { $0.uri == recipe.uri }) {
            savedRecipes.append(recipe)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func didRemoveFavorite(recipe: Recipe) {
        if let index = savedRecipes.firstIndex(where: { $0.uri == recipe.uri }) {
            savedRecipes.remove(at: index)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension FavoriteViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {  // 100 est un seuil arbitraire, ajustez selon vos besoins
            loadMoreResults()
        }
    }
}
