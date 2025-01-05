import UIKit
import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() { }
    
    var authToken: String? {
        get {
            return OAuth2TokenStorage.shared.token
        }
        set {
            OAuth2TokenStorage.shared.token = newValue
        }
    }
    
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private var task: URLSessionTask?
    private var lastCode: String?
    private let queue = DispatchQueue(label: "OAuth2ServiceQueue")
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var components = URLComponents(url: baseURL.appendingPathComponent("/oauth/token"), resolvingAgainstBaseURL: false)
        
        let queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        queue.sync {
            if task != nil, lastCode == code {
                return
            } else {
                task?.cancel()
            }
            
            lastCode = code
            
            guard let request = makeOAuthTokenRequest(code: code) else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
            
            task = urlSession.dataTask(with: request) { [weak self] data, response, error in
                defer { self?.task = nil }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("Ошибка сети: (error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(AuthServiceError.noData))
                        return
                    }
                    
                    do {
                        let tokenResponse = try self?.decoder.decode(OAuthTokenResponseBody.self, from: data)
                        let token = tokenResponse?.accessToken ?? ""
                        self?.authToken = token
                        completion(.success(token))
                    } catch {
                        completion(.failure(AuthServiceError.decodingError(error)))
                    }
                }
            }
            task?.resume()
        }
    }
}

