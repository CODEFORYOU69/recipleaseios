//
//  UIImageView+LoadImage.swift
//  Reciplease
//
//  Created by younes ouasmi on 24/07/2024.
//

import Foundation
import UIKit


extension UIImageView {
    func loadImage(from urlString: String, completion: @escaping (Bool) -> Void = { _ in }) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                self?.image = image
                completion(true)
            }
        }.resume()
    }
}
