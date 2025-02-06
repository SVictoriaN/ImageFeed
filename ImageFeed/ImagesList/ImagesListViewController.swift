import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: ImagesListPresenterProtocol?
    var imagesListServiceObserver: NSObjectProtocol?
    //private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    
    private let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    private let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            if let imageUrl = presenter?.getLargeImageUrl(for: indexPath) {
                viewController.fullImageURL = imageUrl.absoluteString // Преобразуем URL в String
            } else {
                viewController.fullImageURL = nil // Обрабатываем случай, если URL не удалось получить
            }
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated(indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    @objc private func didChangePhotos(notification: Notification) {
        guard let updatedPhotos = notification.userInfo?["updatedPhotos"] as? [Photo] else { return }
        
        tableView.performBatchUpdates {
            self.photos = updatedPhotos
            self.tableView.reloadData()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos
        
        if let url = presenter?.getLargeImageUrl(for: indexPath) {
            cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "Stub"), options: [.transition(.fade(0.2))])
        } else {
            cell.cellImage.image = UIImage(named: "Stub")
        }
        
        cell.cellImage.kf.indicatorType = .activity
        
        if let createdAt = presenter?.getPhotoCreationDate(for: indexPath) {
            cell.dateLabel.text = toFormattedDate(from: createdAt) ?? "Неверная дата"
        } else {
            cell.dateLabel.text = ""
        }
        
        if let isLiked = presenter?.isPhotoLiked(with: indexPath) {
            cell.setIsLiked(isLiked)
        } else {
            cell.setIsLiked(false)
        }
    }
    
    private func toFormattedDate(from dateString: String) -> String? {
        guard let date = iso8601DateFormatter.date(from: dateString) else { return nil }
        return outputDateFormatter.string(from: date)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath) {
        let testMode = ProcessInfo.processInfo.arguments.contains("testMode")
        if !testMode {
            guard indexPath.row + 1 == presenter?.photosCount() else { return }
            presenter?.loadPhotosPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = presenter?.getSizeOfImage(for: indexPath) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        //let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        presenter?.changeLike(for: indexPath) { [weak self] result in
            switch result {
            case .success(let isPhotoLiked):
                cell.setIsLiked(isPhotoLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                
                let alert = UIAlertController(title: "Что-то пошло не так(",
                                              message: "Не удалось выполнить действие.",
                                              preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ок", style: .default) { [weak self] _ in
                    self?.dismiss(animated: true)
                }
                alert.addAction(action)
                
                self?.present(alert, animated: true)
            }
        }
    }
}
