@testable import ImageFeed
import Foundation

final class ImagesListPresenterFake: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var photosCount: Int {
        photos.count
    }

    func viewDidLoad() {}

    func loadPhotosPage() {}

    private func updateTableViewAnimated() {}

    func getLargeImageUrl(for indexPath: IndexPath) -> URL? {
        URL(string: photos[indexPath.row].largeImageURL)
    }
    
    func getThumbImageUrl(for indexPath: IndexPath) -> URL? {
        URL(string: photos[indexPath.row].thumbImageURL)
    }

    func getSizeOfImage(for indexPath: IndexPath) -> CGSize {
        let imageWidth = photos[indexPath.row].size.width
        let imageHeight = photos[indexPath.row].size.height
        return CGSize(width: imageWidth, height: imageHeight)
    }

    func getPhotoCreationDate(for indexPath: IndexPath) -> String? {
        photos[indexPath.row].createdAt
    }

    func isPhotoLiked(with indexPath: IndexPath) -> Bool {
        photos[indexPath.row].isLiked
    }

    func changeLike(for indexPath: IndexPath, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let photo = photos[indexPath.row]
        let newPhoto = Photo(
            id: photo.id,
            size: photo.size,
            createdAt: photo.createdAt,
            welcomeDescription: photo.welcomeDescription,
            thumbImageURL: photo.thumbImageURL,
            largeImageURL: photo.largeImageURL,
            isLiked: !photo.isLiked
        )
        photos[indexPath.row] = newPhoto
        completion(.success(photos[indexPath.row].isLiked))
    }
}
