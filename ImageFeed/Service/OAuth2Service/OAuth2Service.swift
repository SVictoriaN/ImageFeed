import UIKit
import Foundation

final class OAuth2Service {
    // MARK: - Singleton Instance
    static let shared = OAuth2Service()
    
    private init() { }
    
    // MARK: - Properties
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
    
    // MARK: - Private Methods
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
    
    // MARK: - Public Methods
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard task == nil || lastCode != code else {
            let error = AuthServiceError.duplicateRequest
            print("[fetchOAuthToken]: (error.localizedDescription) - Запрос с этим кодом уже выполняется")
            completion(.failure(error))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = AuthServiceError.invalidRequest
            print("[fetchOAuthToken]: (error.localizedDescription) - Неверный запрос")
            completion(.failure(error))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let tokenResponse):
                self?.authToken = tokenResponse.accessToken
                completion(.success(tokenResponse.accessToken))
            case .failure(let error):
                print("[fetchOAuthToken]: (error.localizedDescription) - Ошибка декодирования")
                completion(.failure(error))
            }
        }
        
        task?.resume()
    }
}

