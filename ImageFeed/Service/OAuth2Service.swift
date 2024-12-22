import UIKit
import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() { }
    
    var authToken: String? {
            get {
                OAuth2TokenStorage().token
            }
            set {
                OAuth2TokenStorage().token = newValue
            }
        }

        private let urlSession = URLSession.shared
        private let decoder = JSONDecoder()
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
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
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Не удалось создать запрос"])))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    
                    let storage = OAuth2TokenStorage()
                    storage.token = tokenResponse.accessToken
                    
                    completion(.success(tokenResponse.accessToken))
                } catch {
                    print("Ошибка декодирования: (error.localizedDescription)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Ошибка сети: (error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
