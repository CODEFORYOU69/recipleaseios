import UIKit
import SafariServices


protocol FavoriteUpdateDelegate: AnyObject {
    func didAddFavorite(recipe: Recipe)
    func didRemoveFavorite(recipe: Recipe)
}

class RecipeDetailViewController: UIViewController {
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var caloriesLabel: UILabel!

    @IBOutlet weak var instructionsButton: UIButton!

    
    var recipes: [Recipe] = []
    var recipe: Recipe?
    var currentIndex: Int = 0
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    weak var delegate: FavoriteUpdateDelegate?
    
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
        setupButtons()
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
        instructionsButton.setTitle("View Instructions", for: .normal)
              instructionsButton.addTarget(self, action: #selector(openInstructions), for: .touchUpInside)
    }
    private func setupButtons() {
            instructionsButton.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0) // Light gray background
            instructionsButton.setTitleColor(UIColor(red: 0.7, green: 0.6, blue: 0.8, alpha: 1.0), for: .normal) // Pale violet text color
        instructionsButton.layer.cornerRadius = 8
        instructionsButton.layer.borderWidth = 1.0

        instructionsButton.layer.shadowColor = UIColor.black.cgColor // Shadow color
        instructionsButton.layer.shadowOffset = CGSize(width: 0, height: 2) // Shadow offset for perspective
        instructionsButton.layer.shadowRadius = 2
        instructionsButton.layer.shadowOpacity = 0.2 // Shadow opacity
        instructionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionsButton.addTarget(self, action: #selector(animateButton(_:)), for: .touchUpInside)
        

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
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        navigationItem.leftBarButtonItems = [flexibleSpace]
        navigationItem.rightBarButtonItems = [saveButton]
        
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
        guard let currentRecipe = getCurrentRecipe() else { return }
        
        if isSaved {
            coreDataManager.deleteRecipe(currentRecipe)
            delegate?.didRemoveFavorite(recipe: currentRecipe)
            print("Recipe removed from favorites: \(currentRecipe.label)")
        } else {
            coreDataManager.saveRecipe(currentRecipe)
            delegate?.didAddFavorite(recipe: currentRecipe)
            print("Recipe added to favorites: \(currentRecipe.label)")
        }
        isSaved.toggle()
        updateSaveButtonAppearance()
    }

    private func getCurrentRecipe() -> Recipe? {
        return recipe ?? (recipes.isEmpty ? nil : recipes[currentIndex])
    }
    
    private func updateUI() {
        guard let currentRecipe = getCurrentRecipe() else { return }

        title = currentRecipe.label
        recipeTitleLabel.text = currentRecipe.label
        ingredientsTextView.text = currentRecipe.ingredientLines.joined(separator: "\n")
        caloriesLabel.text = String(format: "Calories: %.1f", currentRecipe.calories)

        activityIndicator.startAnimating()
        recipeImageView.loadImage(from: currentRecipe.image) { [weak self] success in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
        }

        // Mettre à jour le bouton d'instructions
        instructionsButton.isEnabled = !currentRecipe.url.isEmpty
        instructionsButton.setTitle(currentRecipe.url.isEmpty ? "No Instructions Available" : "View Instructions", for: .normal)

        checkIfRecipeIsSaved()
    }

    
    private func checkIfRecipeIsSaved() {
        guard let currentRecipe = getCurrentRecipe() else { return }
        isSaved = coreDataManager.isRecipeSaved(currentRecipe)
        updateSaveButtonAppearance()
    }
    
    private func updateSaveButtonAppearance() {
        let imageName = isSaved ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItems?.first?.image = UIImage(systemName: imageName)
    }
    
    @objc private func openInstructions() {
        print("openInstructions called")
        
        guard let currentRecipe = getCurrentRecipe() else {
            print("No current recipe found")
            return
        }
        
        print("Recipe URL: \(currentRecipe.url)")
        
        guard let url = URL(string: currentRecipe.url) else {
            print("Invalid URL: \(currentRecipe.url)")
            return
        }
        
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true) {
            print("Safari View Controller presented")
        }
    }



}

extension RecipeDetailViewController: CoreDataManagerDelegate {
    func didSaveRecipe(_ recipe: Recipe) {
        isSaved = true
        updateSaveButtonAppearance()
        delegate?.didAddFavorite(recipe: recipe)
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
