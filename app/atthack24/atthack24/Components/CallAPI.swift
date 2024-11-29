//
//  CallAPI.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import Foundation

class CallAPI {
    
    var errorMessage: String?
    var isLoading: Bool = false
    
    var responseMessage: String?
    
    init() {
        
    }
    
    func fetchData<T: Decodable>(from urlString: String, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        self.isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
}
