//
//  UIColor+AppTheme.swift
//  Reciplease
//
//  Created by younes ouasmi on 28/07/2024.
//

import UIKit

extension UIColor {
    static let appAccent = UIColor(red: 0.2, green: 0.6, blue: 0.86, alpha: 1.0)
    static let appText = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    static let appSecondary = UIColor(red: 0.96, green: 0.76, blue: 0.36, alpha: 1.0)
    static func appBackground() -> UIImage? {
           return UIImage(named: "background")
    }
}
