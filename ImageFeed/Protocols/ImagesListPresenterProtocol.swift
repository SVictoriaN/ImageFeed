import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func loadPhotosPage()
    func photosCount() -> Int
    func getThumbImageUrl(for indexPath: IndexPath) -> URL?
    func getLargeImageUrl(for indexPath: IndexPath) -> URL?
    func getSizeOfImage(for indexPath: IndexPath) -> CGSize
    func getPhotoCreationDate(for indexPath: IndexPath) -> String?
    func isPhotoLiked(with indexPath: IndexPath) -> Bool
}
