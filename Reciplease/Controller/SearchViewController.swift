import UIKit

class SearchViewController: UIViewController {
    

    // MARK: - Outlets
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    // MARK: - Properties
    private var ingredients: [String] = []
    private var currentPage = 1
    private var totalResults = 0
    private var hasMoreResults = true
    private var searchResults: [Recipe] = []
    
    private let recipeService = Configuration.recipeService
    private let coreDataManager = CoreDataManager.shared
    
    private lazy var loadingView: LoadingView = {
            let view = LoadingView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.isHidden = true
            return view
        }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        setupGestures()
        setupLoadingView()


    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Recipe Search"
        setupBackground()
        setupButtons()
        setupTextField()
    }
    

    private func setupLoadingView() {
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 250),
            loadingView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    func didAddFavorite(recipe: Recipe) {
           print("Attempting to save recipe as favorite: \(recipe.label)")
           coreDataManager.saveRecipe(recipe)
       }
       
       func didRemoveFavorite(recipe: Recipe) {
           print("Attempting to remove recipe from favorites: \(recipe.label)")
           coreDataManager.deleteRecipe(recipe)
       }
    
    private func setupTableView() {
        ingredientsTableView.dataSource = self
        ingredientsTableView.delegate = self
        ingredientsTableView.rowHeight = UITableView.automaticDimension
        ingredientsTableView.estimatedRowHeight = 40
        ingredientsTableView.sectionHeaderHeight = 1
        ingredientsTableView.register(ModernTableViewCell.self, forCellReuseIdentifier: "IngredientCell")
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
    
    @IBAction func searchRecipes(_ sender: UIButton) {
        dismissKeyboard()
        currentPage = 1
        searchResults.removeAll()
        showLoading(true)

        performSearch { [weak self] result in
            self?.handleSearchResult(result)
            self?.showLoading(false)

        }
    }
    
    private func showLoading(_ show: Bool) {
            loadingView.isHidden = !show
            if show {
                loadingView.startAnimating()
            } else {
                loadingView.stopAnimating()
            }
        }
    
    @IBAction func addIngredient(_ sender: Any) {
        guard let ingredient = ingredientTextField.text, !ingredient.isEmpty else {
            return
        }
        dismissKeyboard()
        ingredients.append(ingredient)
        ingredientsTableView.reloadData()
        ingredientTextField.text = ""
        ingredientTextField.resignFirstResponder() 

    }
    
    @IBAction func clearIngredients(_ sender: UIButton) {
        resetView()
    }
    
    func loadMoreResults(completion: @escaping (Result<[Recipe], Error>) -> Void) {
        guard hasMoreResults else {
            completion(.success([]))
            return
        }
        
        performSearch { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let paginatedRecipes):
                self.hasMoreResults = paginatedRecipes.nextPage != nil
                self.currentPage += 1
                completion(.success(paginatedRecipes.recipes))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func performSearch(completion: @escaping (Result<PaginatedRecipes, RecipeServiceError>) -> Void) {
        let sanitizedIngredients = ingredients.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        recipeService.searchRecipes(with: sanitizedIngredients, page: currentPage, completion: completion)
    }
    
    
    private func handleSearchResult(_ result: Result<PaginatedRecipes, RecipeServiceError>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch result {
            case .success(let paginatedRecipes):
                self.searchResults.append(contentsOf: paginatedRecipes.recipes)
                self.totalResults = paginatedRecipes.totalResults
                self.hasMoreResults = paginatedRecipes.nextPage != nil
                self.currentPage = paginatedRecipes.nextPage ?? self.currentPage + 1
                self.showSearchResults(self.searchResults)
            case .failure(let error):
                print("Failed to fetch recipes:", error)
                self.showErrorAlert(message: "Failed to fetch recipes: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func resetView() {
        ingredients.removeAll()
        searchResults.removeAll()
        currentPage = 1
        totalResults = 0
        hasMoreResults = true
        ingredientsTableView.reloadData()
    }
    
    private func setupTextField() {
        ingredientTextField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        ingredientTextField.textColor = UIColor(red: 0.4, green: 0.2, blue: 0.2, alpha: 1.0)
        ingredientTextField.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        ingredientTextField.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor 
        ingredientTextField.layer.borderWidth = 2
        ingredientTextField.layer.cornerRadius = 10
        ingredientTextField.layer.shadowColor = UIColor.black.cgColor
        ingredientTextField.layer.shadowOpacity = 0.2
        ingredientTextField.layer.shadowOffset = CGSize(width: 2, height: 2)
        ingredientTextField.layer.shadowRadius = 2
        ingredientTextField.autocorrectionType = .no
        ingredientTextField.spellCheckingType = .no
        ingredientTextField.smartInsertDeleteType = .no
        ingredientTextField.smartQuotesType = .no
            ingredientTextField.smartDashesType = .no
            ingredientTextField.autocapitalizationType = .none
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRecipeDetail",
           let destinationVC = segue.destination as? RecipeDetailViewController,
           let recipe = sender as? Recipe {
            destinationVC.recipe = recipe
        }
    }

    func showSearchResults(_ recipes: [Recipe]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let searchResultsVC = storyboard.instantiateViewController(withIdentifier: "FavoriteViewController") as? FavoriteViewController {
            searchResultsVC.loadViewIfNeeded()
            searchResultsVC.showSearchResults(recipes, searchViewController: self)
            searchResultsVC.title = "Search Results"
            navigationController?.pushViewController(searchResultsVC, animated: true)
        }
    }

    
    private func setupButtons() {
        [addButton, clearButton, searchButton].forEach { button in
            button?.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0) // Light gray background
            button?.setTitleColor(UIColor(red: 0.7, green: 0.6, blue: 0.8, alpha: 1.0), for: .normal) // Pale violet text color
            button?.layer.cornerRadius = 8
            button?.layer.borderWidth = 1.0
            button?.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor // Gray-ish border color
            button?.layer.shadowColor = UIColor.black.cgColor // Shadow color
            button?.layer.shadowOffset = CGSize(width: 0, height: 2) // Shadow offset for perspective
            button?.layer.shadowRadius = 2
            button?.layer.shadowOpacity = 0.2 // Shadow opacity
            button?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button?.addTarget(self, action: #selector(animateButton(_:)), for: .touchUpInside)
        }

        ingredientsTableView.backgroundColor = .clear
        ingredientsTableView.separatorStyle = .none

        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        clearButton.setImage(UIImage(systemName: "trash"), for: .normal)
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    }


    
    @objc private func animateButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform.identity
            }
        }
    }
    

    
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Chaque section contient une seule cellule
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as? ModernTableViewCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = ingredients[indexPath.section]
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    // Ajoutez ces nouvelles méthodes pour gérer la suppression par balayage
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Supprimez l'ingrédient du tableau
            ingredients.remove(at: indexPath.section)
            
            // Supprimez la section de la tableView
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
