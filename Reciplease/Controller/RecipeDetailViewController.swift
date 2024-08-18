import UIKit

class RecipeDetailViewController: UIViewController {
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var ingredientsTextView: UITextView!
    
    var recipes: [Recipe] = []
    var recipe: Recipe?
    var currentIndex: Int = 0
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let coreDataManager = CoreDataManager.shared
    private var isSaved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActivityIndicator()
        setupNavigationButtons()
        setupSwipeGestures()
        updateUI()
        checkIfRecipeIsSaved()
        coreDataManager.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))

    }
    
    @objc private func goBack() {
            navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfRecipeIsSaved()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)
        
        recipeImageView.layer.cornerRadius = 12
        recipeImageView.clipsToBounds = true
        recipeImageView.contentMode = .scaleAspectFill
        
        recipeTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        recipeTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        
        ingredientsTextView.backgroundColor = .white
        ingredientsTextView.layer.cornerRadius = 8
        ingredientsTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        ingredientsTextView.font = UIFont.systemFont(ofSize: 16)
        ingredientsTextView.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        
        activityIndicator.color = UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0)
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: recipeImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: recipeImageView.centerYAnchor)
        ])
    }
    
    private func setupNavigationButtons() {
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(toggleSaveRecipe))
        
        // Utilisez un UIBarButtonItem flexible pour créer de l'espace
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Configurez la barre de navigation
        navigationItem.leftBarButtonItems = [flexibleSpace] // Espace flexible à gauche
        navigationItem.rightBarButtonItems = [saveButton] // Bouton de sauvegarde à droite
        
        updateSaveButtonAppearance()
    }
    
    private func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            showNextRecipe()
        } else if gesture.direction == .right {
            showPreviousRecipe()
        }
    }
    
    @objc private func showPreviousRecipe() {
        guard recipe == nil else { return }
        if currentIndex > 0 {
            currentIndex -= 1
            animateTransition(direction: .right)
        }
    }
    
    @objc private func showNextRecipe() {
        guard recipe == nil else { return }
        if currentIndex < recipes.count - 1 {
            currentIndex += 1
            animateTransition(direction: .left)
        }
    }
    
    private func animateTransition(direction: UISwipeGestureRecognizer.Direction) {
        let transitionOptions: UIView.AnimationOptions = direction == .left ? .transitionFlipFromRight : .transitionFlipFromLeft
        UIView.transition(with: view, duration: 0.5, options: transitionOptions, animations: {
            self.updateUI()
        })
    }
    
    @objc private func toggleSaveRecipe() {
        let currentRecipe: Recipe
        if let singleRecipe = recipe {
            currentRecipe = singleRecipe
        } else if !recipes.isEmpty && currentIndex >= 0 && currentIndex < recipes.count {
            currentRecipe = recipes[currentIndex]
        } else {
            return
        }
        
        if isSaved {
            coreDataManager.deleteRecipe(currentRecipe)
        } else {
            coreDataManager.saveRecipe(currentRecipe)
        }
        isSaved.toggle()
        updateSaveButtonAppearance()
    }
    
    private func updateUI() {
        let currentRecipe: Recipe
        if let singleRecipe = recipe {
            currentRecipe = singleRecipe
        } else if !recipes.isEmpty && currentIndex >= 0 && currentIndex < recipes.count {
            currentRecipe = recipes[currentIndex]
        } else {
            return
        }

        title = currentRecipe.label
        recipeTitleLabel.text = currentRecipe.label
        ingredientsTextView.text = currentRecipe.ingredientLines.joined(separator: "\n")

        activityIndicator.startAnimating()
        recipeImageView.loadImage(from: currentRecipe.image) { [weak self] success in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
        }

        checkIfRecipeIsSaved()
    }
    
    private func checkIfRecipeIsSaved() {
        let currentRecipe: Recipe
        if let singleRecipe = recipe {
            currentRecipe = singleRecipe
        } else if !recipes.isEmpty && currentIndex >= 0 && currentIndex < recipes.count {
            currentRecipe = recipes[currentIndex]
        } else {
            return
        }
        isSaved = coreDataManager.isRecipeSaved(currentRecipe)
        updateSaveButtonAppearance()
    }
    
    private func updateSaveButtonAppearance() {
        let imageName = isSaved ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItems?.first?.image = UIImage(systemName: imageName)
    }
}

extension RecipeDetailViewController: CoreDataManagerDelegate {
    func didSaveRecipe(_ recipe: Recipe) {
        isSaved = true
        updateSaveButtonAppearance()
    }
    
    func didDeleteRecipe(_ recipe: Recipe) {
        isSaved = false
        updateSaveButtonAppearance()
    }
    
    func didFetchSavedRecipes(_ recipes: [Recipe]) {
        // Not needed in this view controller
    }
    
    func didEncounterError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
        // Implement error handling, e.g., show an alert to the user
    }
    
    func didSaveContext() {
        print("Core Data context saved successfully")
        // Vous pouvez ajouter ici toute logique supplémentaire nécessaire après une sauvegarde réussie
    }
}
