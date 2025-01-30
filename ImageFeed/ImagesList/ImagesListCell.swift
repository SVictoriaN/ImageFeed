import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    let fullsizeImageView = UIImageView()
    weak var delegate: ImagesListCellDelegate?
    
    private var isLiked: Bool = false

    override func prepareForReuse() {
        super.prepareForReuse()
        
        fullsizeImageView.kf.cancelDownloadTask()
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ liked: Bool) {
        isLiked = liked
        let likeImage = liked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
    }
}
