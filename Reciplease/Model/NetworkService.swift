//
//  NetworkService.swift
//  Reciplease
//
//  Created by younes ouasmi on 20/08/2024.
//

import Foundation
import Alamofire

protocol NetworkService {
    func request(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

class AlamofireNetworkService: NetworkService {
    func request(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
