import Foundation

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    var imagesListServiceObserver: NSObjectProtocol? { get set }
    func updateTableViewAnimated(indexPaths: [IndexPath])
}
