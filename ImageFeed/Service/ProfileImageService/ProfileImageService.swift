import Foundation

final class ProfileImageService {
    // MARK: - Notifications
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChangeNotification")
    
    // MARK: - Singleton Instance
    static let shared = ProfileImageService()
    private init() {}
    
    // MARK: - Properties
    private var task: URLSessionTask?
    var avatarURL: String?
    
    // MARK: - Private Methods
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage.shared.token
        else { return nil }
        
        guard let url = URL(
            string: "/users/\(username)"
            + "?client_id=\(Constants.accessKey)",
            relativeTo: Constants.defaultBaseURL
        ) else {
            assertionFailure(">>> [ProfileImageService] Failed to create URL for username: \(username)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            print("[fetchProfile]: (error.localizedDescription) - Запрос уже выполняется")
            completion(.failure(ServiceError.extraRequest))
            return
        }
        
        guard
            let request = makeProfileImageRequest(username: username)
        else {
            print("[fetchProfile]: (error.localizedDescription) - Неверный запрос")
            completion(.failure(ServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userImage):
                let profileImageURL = userImage.profileImage?.small
                
                self.avatarURL = profileImageURL
                
                if let url = profileImageURL {
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": url]
                    )
                    completion(.success(url))
                } else {
                    completion(.failure(NSError(domain: "ProfileService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Изображение не найдено"])))
                }
            case .failure(let error):
                print("[fetchProfile]: (error.localizedDescription) - Ошибка при получении данных")
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func clearProfileImage() {
        avatarURL = nil
    }
}


