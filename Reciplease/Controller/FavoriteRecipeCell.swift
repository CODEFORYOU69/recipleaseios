//
//  FavoriteRecipeCell.swift
//  Reciplease
//
//  Created by younes ouasmi on 24/07/2024.
//

import UIKit

class FavoriteRecipeCell: UITableViewCell {
    
    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8 // Arrondir les coins de l'image
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemRed
        return imageView
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(recipeImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(favoriteImageView)

        NSLayoutConstraint.activate([
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recipeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            recipeImageView.widthAnchor.constraint(equalToConstant: 60),
            recipeImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteImageView.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            favoriteImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 24),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Amélioration de l'accessibilité
        isAccessibilityElement = true
        accessibilityHint = "Double tap to view recipe details"
    }
    
    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.label
        recipeImageView.image = placeholderImage // Set placeholder immediately
        
        recipeImageView.loadImage(from: recipe.image) { [weak self] success in
            if success {
                UIView.transition(with: self?.recipeImageView ?? UIImageView(),
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: { self?.recipeImageView.image = self?.recipeImageView.image },
                                  completion: nil)
            }
        }
        
        accessibilityLabel = recipe.label
        updateFavoriteStatus()
    }
    
    private func updateFavoriteStatus() {
        favoriteImageView.image = isFavorite ? UIImage(systemName: "heart.fill") : nil
        accessibilityLabel = (accessibilityLabel ?? "") + (isFavorite ? ", favorite recipe" : "")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        recipeImageView.image = placeholderImage
        titleLabel.text = nil
        accessibilityLabel = nil
        isFavorite = false
    }
}
