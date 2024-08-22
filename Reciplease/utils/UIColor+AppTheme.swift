//
//  UIColor+AppTheme.swift
//  Reciplease
//
//  Created by younes ouasmi on 28/07/2024.
//

import UIKit

extension UIColor {
    /// The main accent color used throughout the app
    static let appAccent = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
    
    /// The primary text color
    static let appText = UIColor.white
    
    /// A secondary color for highlights or contrasts
    static let appSecondary = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
    
    /// Returns the background image for the app
    static func appBackground() -> UIImage? {
        return UIImage(named: "background1")
    }
}
