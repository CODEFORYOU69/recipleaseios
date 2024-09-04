import UIKit
import AlamofireImage

class FavoriteRecipeCell: UITableViewCell {
    var favoriteButtonTapped: (() -> Void)?
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Favorite"
        button.accessibilityHint = "tap to toggle favorite status"
        return button
    }()
    
    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.isAccessibilityElement = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isAccessibilityElement = false
        return label
    }()
    
    private let placeholderImage = UIImage(named: "placeholder_recipe")
    
    var isFavorite: Bool = false {
        didSet {
            updateFavoriteStatus()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupAccessibility()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupAccessibility()
    }
    
    private func setupViews() {
        contentView.addSubview(recipeImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(favoriteButton)
        
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        contentView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        contentView.layer.borderWidth = 2
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor // Shadow color
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2) // Shadow offset for perspective
        contentView.layer.shadowRadius = 2
        contentView.layer.shadowOpacity = 0.2 // Shadow opacity

        NSLayoutConstraint.activate([
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recipeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            recipeImageView.widthAnchor.constraint(equalToConstant: 60),
            recipeImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
        shouldGroupAccessibilityChildren = true
    }
    
    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.label

        if let imageUrl = URL(string: recipe.image) {
            recipeImageView.af.setImage(
                withURL: imageUrl,
                placeholderImage: placeholderImage,
                imageTransition: .crossDissolve(0.3)
            )
        } else {
            recipeImageView.image = placeholderImage
        }
        
        updateAccessibilityLabel()
    }
    
    private func updateFavoriteStatus() {
        favoriteButton.isSelected = isFavorite
        favoriteButton.accessibilityLabel = isFavorite ? "Remove from favorites" : "Add to favorites"
        updateAccessibilityLabel()
    }
    
    private func updateAccessibilityLabel() {
        DispatchQueue.main.async {
            let favoriteStatus = self.isFavorite ? "Favorite recipe" : "Not in favorites"
            self.accessibilityLabel = "\(self.titleLabel.text ?? "Recipe"), \(favoriteStatus)"
            self.accessibilityHint = "tap to view recipe details. Use the favorite button to change favorite status."
        }
    }
    
    @objc private func favoriteButtonPressed() {
        favoriteButtonTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        recipeImageView.image = placeholderImage
        titleLabel.text = nil
        isFavorite = false
        updateAccessibilityLabel()
    }
}
