import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    var ingredients: [String] = []
    
    let recipeService = Configuration.recipeService
    let coreDataManager = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipe Search"
        
        ingredientsTableView.dataSource = self
        ingredientsTableView.delegate = self
        ingredientsTableView.rowHeight = UITableView.automaticDimension
        ingredientsTableView.estimatedRowHeight = 44

        
        setupUI()
        setupBackground()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    private func setupBackground() {
           let backgroundImageView = UIImageView(frame: view.bounds)
           backgroundImageView.image = UIColor.appBackground()
           backgroundImageView.contentMode = .scaleAspectFill
           backgroundImageView.clipsToBounds = true
           view.insertSubview(backgroundImageView, at: 0)

           // Ajout de contraintes pour s'assurer que l'image couvre toute la vue
           backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
               backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
           ])
       }
   
    
    func resetView() {
        ingredients.removeAll()
        ingredientsTableView.reloadData()
        // Réinitialisez d'autres éléments si nécessaire
    }
 

    
    private func setupUI() {
        
        ingredientTextField.backgroundColor = .white
        ingredientTextField.textColor = .appText
        ingredientTextField.layer.borderColor = UIColor.appAccent.cgColor
        ingredientTextField.layer.borderWidth = 1
        ingredientTextField.layer.cornerRadius = 8
        
        [addButton, clearButton, searchButton].forEach { button in
            button?.backgroundColor = .appAccent
            button?.setTitleColor(.white, for: .normal)
            button?.layer.cornerRadius = 8
        }
        
        ingredientsTableView.backgroundColor = .clear
        ingredientsTableView.separatorStyle = .none
        
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        clearButton.setImage(UIImage(systemName: "trash"), for: .normal)
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        
        [addButton, clearButton, searchButton].forEach { button in
            button?.addTarget(self, action: #selector(animateButton(_:)), for: .touchUpInside)
        }
        
        ingredientsTableView.register(ModernTableViewCell.self, forCellReuseIdentifier: "IngredientCell")
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
    
    @IBAction func addIngredient(_ sender: Any) {
        guard let ingredient = ingredientTextField.text, !ingredient.isEmpty else { return }
        ingredients.append(ingredient)
        ingredientsTableView.reloadData()
        ingredientTextField.text = ""
    }
    
    @IBAction func clearIngredients(_ sender: UIButton) {
        ingredients.removeAll()
        ingredientsTableView.reloadData()
    }
    
    @IBAction func searchRecipes(_ sender: UIButton) {
        let sanitizedIngredients = ingredients.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        recipeService.searchRecipes(with: sanitizedIngredients) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recipes):
                    self?.showSearchResults(recipes)
                case .failure(let error):
                    print("Failed to fetch recipes:", error)
                    self?.showErrorAlert(message: "Failed to fetch recipes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showSearchResults(_ recipes: [Recipe]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let favoriteVC = storyboard.instantiateViewController(withIdentifier: "FavoriteViewController") as? FavoriteViewController {
            favoriteVC.loadViewIfNeeded() // Force le chargement de la vue
            favoriteVC.showSearchResults(recipes)
            navigationController?.pushViewController(favoriteVC, animated: true)
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as? ModernTableViewCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = ingredients[indexPath.row]
        return cell
    }
    @objc func dismissKeyboard() {
           view.endEditing(true)
       }
}
