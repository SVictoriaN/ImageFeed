import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount:  Int  {get} //-> Int
    func viewDidLoad()
    func loadPhotosPage()
    func getThumbImageUrl(for indexPath: IndexPath) -> URL?
    func getLargeImageUrl(for indexPath: IndexPath) -> URL?
    func getSizeOfImage(for indexPath: IndexPath) -> CGSize
    func getPhotoCreationDate(for indexPath: IndexPath) -> String?
    func isPhotoLiked(with indexPath: IndexPath) -> Bool
    func changeLike(for indexPath: IndexPath, _ completion: @escaping (Result<Bool, Error>) -> Void)
}
