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
           
           // Mark the start of the loading state
           self.isLoading = true

           URLSession.shared.dataTask(with: url) { data, response, error in
               // Handle errors or invalid data
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
                   // Decode data into the provided type
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
    func postData(to urlString: String, payload: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
            // Ensure URL is valid
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            // Convert payload dictionary to JSON data
            guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Payload"])))
                return
            }

            // Configure the URLRequest for POST
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
        
            //API key
            request.setValue("xxx", forHTTPHeaderField: "X-API-KEY")

        
            // Set loading state
            self.isLoading = true

            // Perform the network request
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }

                // Handle error
                if let error = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion(.failure(error))
                    }
                    return
                }
                
                
                
                if let httpResponse = response as? HTTPURLResponse {
                   if httpResponse.statusCode == 429 {
                       DispatchQueue.main.async {
                           completion(.failure(NSError(domain: "", code: 429, userInfo: [NSLocalizedDescriptionKey: "Sorry, our servers are now busy. Please wait a few minutes and try again."])))
                       }
                       return
                   }
               }
                
                

                // Handle response
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.responseMessage = responseString
                        completion(.success(responseString))
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response received"])))
                    }
                }
            }
        task.resume()
    }
    
    
    //just pure string, no json no other just one thing that we get
    func fetchStringFromURL(urlString: String, completion: @escaping (String?) -> Void) {
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                completion(nil)
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                    print("No data or invalid response")
                    completion(nil)
                    return
                }

                // The response is a plain string
                completion(responseString)
            }

            task.resume()
        }
    
    }
