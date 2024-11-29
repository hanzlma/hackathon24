import Foundation

class CallAPI {
    
    var errorMessage: String?
    var isLoading: Bool = false
    var responseMessage: String?
    
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) {
        self.session = session
        self.jsonDecoder = decoder
        self.jsonEncoder = encoder
    }
    
    /// Fetch data from a URL
    func fetchData<T: Decodable>(
        from urlString: String,
        responseType: T.Type,
        retries: Int = 1,
        debugLogging: Bool = false,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            handleFailure("Invalid URL", completion: completion)
            return
        }
        
        if debugLogging { print("Fetching data from: \(url)") }
        isLoading = true
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                if retries > 0 {
                    self.fetchData(from: urlString, responseType: responseType, retries: retries - 1, debugLogging: debugLogging, completion: completion)
                } else {
                    self.handleFailure(error.localizedDescription, completion: completion)
                }
                return
            }
            
            guard let data = data else {
                self.handleFailure("No data received from server", completion: completion)
                return
            }
            
            do {
                let decodedData = try self.jsonDecoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(.success(decodedData))
                }
            } catch {
                self.handleFailure("Decoding error: \(error.localizedDescription)", completion: completion)
            }
        }
        
        task.resume()
    }
    
    /// Post data to a URL
    func postData<T: Codable>(
        to urlString: String,
        body: T,
        retries: Int = 1,
        debugLogging: Bool = false,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            handleFailure("Invalid URL", completion: completion)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try jsonEncoder.encode(body)
            request.httpBody = jsonData
            if debugLogging {
                print("Posting to: \(url)")
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Request body: \(jsonString)")
                }
            }
        } catch {
            handleFailure("Encoding error: \(error.localizedDescription)", completion: completion)
            return
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                if retries > 0 {
                    self.postData(to: urlString, body: body, retries: retries - 1, debugLogging: debugLogging, completion: completion)
                } else {
                    self.handleFailure(error.localizedDescription, completion: completion)
                }
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                self.handleFailure("Server responded with status code: \(response.statusCode)", completion: completion)
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
        
        task.resume()
    }
    
    /// Handles error and calls the completion handler
    private func handleFailure<T>(_ message: String, completion: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = message
            print("Error: \(message)")
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
            completion(.failure(error))
        }
    }
}
