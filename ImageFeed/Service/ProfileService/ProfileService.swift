import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Private Methods
    private func makeProfileServiceRequest(token: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultURL + "me") else {
            print("ProfileService: func makeRequestToProfile(...)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            print("[fetchProfile]: (error.localizedDescription) - Запрос уже выполняется")
            completion(.failure(ProfileServiceError.extraRequest))
            return
        }
        
        guard let request = makeProfileServiceRequest(token: token) else {
            print("[fetchProfile]: (error.localizedDescription) - Неверный запрос")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) {[weak self] (result: Result<ProfileResult, Error>) in guard let self = self else {return}
            switch result {
            case .success(let userInfo):
                let profile = Profile(
                    username: userInfo.username,
                    name: "\(userInfo.firstName ?? "") \(userInfo.lastName ?? "")",
                    loginName: "@\(userInfo.username)",
                    bio: userInfo.bio ?? ""
                )
                self.profile = profile
                completion(.success(profile))
                
            case .failure(let error):
                print("[fetchProfile]: (error.localizedDescription) - Ошибка при получении профиля")
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
}

