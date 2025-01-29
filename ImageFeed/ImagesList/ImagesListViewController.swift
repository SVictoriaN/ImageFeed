import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let currentDate = Date()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListService.fetchPhotosNextPage { _ in }
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self = self else { return }
                print(">>> [ImagesListViewController] Notification received, updating photos")
                self.updateTableViewAnimated()
            }
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
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        photos = imagesListService.photos // Обновляем массив фотографий из сервиса
        let newCount = photos.count
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                if oldCount < newCount {
                    let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                    tableView.insertRows(at: indexPaths, with: .automatic)
                } else {
                    let indexPaths = (newCount..<oldCount).map { IndexPath(row: $0, section: 0) }
                    tableView.deleteRows(at: indexPaths, with: .automatic)
                }
            } completion: { _ in }
        }
        
        tableView.reloadData() // Перезагружаем данные таблицы
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
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row] // Получаем объект Photo из массива
        
        // Используем Kingfisher для загрузки изображения по URL
        // Преобразование строки в URL
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.2))])
        } else {
            // Если URL недействителен, устанавливаем изображение-заглушку
            cell.cellImage.image = UIImage(named: "placeholder")
        }
        
        // Настройка индикатора загрузки
        cell.cellImage.kf.indicatorType = .activity
        
        // Настройка даты
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath) {
        guard indexPath.row == photos.count - 1 else {return}
        imagesListService.fetchPhotosNextPage { _ in }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //guard let image = UIImage(named: photosName[indexPath.row]) else {
        //    return 0
       // }
        
        let image = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

