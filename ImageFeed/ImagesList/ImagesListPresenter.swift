import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let service = ImagesListService.shared
    var photos: [Photo] = []
    
    func viewDidLoad() {
        loadPhotosPage()
        view?.imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                print(">>> [ImagesListViewController] Notification received, updating photos")
                updateTableViewAnimated()
            }
        updateTableViewAnimated()
    }
    
    func loadPhotosPage() {
        service.fetchPhotosNextPage { _ in }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = service.photos.count
        photos = service.photos
        if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            view?.updateTableViewAnimated(indexPaths: indexPaths)
        }
    }
    
    func getLargeImageUrl(for indexPath: IndexPath) -> URL? {
        guard let url = URL(string: photos[indexPath.row].largeImageURL) else { return nil }
        return url
    }
    
    func photosCount() -> Int {
        photos.count
    }
    
    func getThumbImageUrl(for indexPath: IndexPath) -> URL? {
        guard let url = URL(string: photos[indexPath.row].thumbImageURL) else { return nil }
        return url
    }
    
    func getSizeOfImage(for indexPath: IndexPath) -> CGSize {
        let imageWidth = photos[indexPath.row].size.width
        let imageHeight = photos[indexPath.row].size.height
        return CGSize(width: imageWidth, height: imageHeight)
    }
    
    func getPhotoCreationDate(for indexPath: IndexPath) -> String? {
        guard
            let creationDate = photos[indexPath.row].createdAt
        else { return nil }
        return creationDate
    }
    
    func isPhotoLiked(with indexPath: IndexPath) -> Bool {
            photos[indexPath.row].isLiked
        }
}
