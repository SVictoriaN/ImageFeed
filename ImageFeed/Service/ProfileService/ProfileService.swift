import Foundation

// MARK: - Profile Service Errors
enum ProfileServiceError: Error {
    case extraRequest
    case invalidRequest
}

// MARK: - Profile Service
final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Create Request
    private func createRequest(token: String) -> URLRequest? {
        print("createRequest called")
        guard let url = URL(string: Constants.defaultURL + "me") else {
            print("ProfileService: func makeRequestToProfile(...)")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    // MARK: - Fetch Profile
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
            assert(Thread.isMainThread)

            if task != nil {
                completion(.failure(ProfileServiceError.extraRequest))
                return
            }

            guard let request = createRequest(token: token) else {
                completion(.failure(ProfileServiceError.invalidRequest))
                return
            }

            let urlSession = URLSession.shared
            let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
                
                switch result {
                case .success(let userInfo):
                    self.profile = Profile(
                        username: userInfo.username,
                        name: "\(userInfo.firstName ?? "") \(userInfo.lastName ?? "")",
                        loginName: "@\(userInfo.username)",
                        bio: userInfo.bio ?? ""
                    )
                    completion(.success(self.profile!))
                    
                case .failure(let error):
                    completion(.failure(error))
                }

                self.task = nil
            }

            self.task = task
            task.resume()
        }
}

// MARK: - URLSession Extension
extension URLSession {
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ProfileServiceError.invalidRequest))
                return
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                completion(.failure(ProfileServiceError.invalidRequest))
                return
            }
            
            guard let data = data else {
                completion(.failure(ProfileServiceError.invalidRequest))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
        return task
    }
}
