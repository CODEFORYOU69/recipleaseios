import UIKit

class ModernTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
        layer.masksToBounds = true
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        textLabel?.numberOfLines = 0
        
        // Ajouter une ombre
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
        
        // Customiser le texte
        textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel?.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
}
