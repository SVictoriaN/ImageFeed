import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage = 0
    private var task: URLSessionTask?
    
    private func makeImagesListRequest(_ token: String) -> URLRequest? {
        let nextPage = lastLoadedPage + 1
        
        guard var urlComponents = URLComponents(string: Constants.defaultURL + "photos") else {
            print("ImagesListService: func makeImagesListRequest(...)")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)")
        ]
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeImagesListLikeRequest(_ token: String, _ photoId: String, _ isLike: Bool) -> URLRequest? {
        guard let urlComponents = URLComponents(string: Constants.defaultURL + "photos/\(photoId)/like")
        else {
            print("ImagesListService: func makeImagesListLikeRequest(...)")
            return nil
        }
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? "POST" : "DELETE"
        return request
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard
            let token = OAuth2TokenStorage.shared.token
        else { return }
        
        if task != nil {
            print("[fetchPhotosNextPage]: (error.localizedDescription) - Запрос уже выполняется")
            completion(.failure(ServiceError.extraRequest))
            return
        }
        
        guard
            let request = makeImagesListRequest(token)
        else {
            print("[fetchProfile]: (error.localizedDescription) - Неверный запрос")
            completion(.failure(ServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photos):
                var receivedPhotos: [Photo] = []
                for photo in photos {
                    let photo = Photo(
                        id: photo.id,
                        size: CGSize(width: photo.width, height: photo.height),
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.description,
                        thumbImageURL: photo.urls.regular,
                        largeImageURL: photo.urls.full,
                        isLiked: photo.likedByUser
                    )
                    receivedPhotos.append(photo)
                }
                let uniquePhotos = receivedPhotos.filter { newPhoto in
                    !(self.photos.contains(where: { $0.id == newPhoto.id }))
                }
                self.photos.append(contentsOf: uniquePhotos)
                
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["updatedPhotos": self.photos]
                    )
                self.lastLoadedPage += 1
                completion(.success(receivedPhotos))
            case .failure(let error):
                print(">>> [ImagesListService] Failed to load photos: \(error.localizedDescription) - Не удалось загрузить фотографии")
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void){
        guard
            let token = OAuth2TokenStorage.shared.token
        else { return }
        
        guard let request = makeImagesListLikeRequest(token, photoId, isLike) else {
            print(">>> [ImagesListService] Failed to create the request")
            completion(.failure(ServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoWrapper, Error>) in
            guard let self else { return }
            switch result {
            case .success(_):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
            case .failure(let error):
                print(">>> [ImagesListService] Failed to get data with like")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func clearImagesList() {
        photos = []
        lastLoadedPage = 0
    }
}

