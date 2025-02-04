import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    // MARK: - Properties
    var fullImageURL: String?
    
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var shareButton: UIButton!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadImage()
        
        self.view.bringSubviewToFront(backButton)
        self.view.bringSubviewToFront(shareButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SingleImageViewController is visible")
    }
    // MARK: - Actions
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else {
            print("SingleImageViewController: func didTapShareButton(...)")
            return
        }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
        
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypBlack
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 2.0
        scrollView.maximumZoomScale = 5.0
        
        view.addSubview(scrollView)
        
        imageView.contentMode = .scaleAspectFill
        
        scrollView.addSubview(imageView)
        scrollView.backgroundColor = .ypBlack
    }
    
    private func loadImage() {
        guard let fullImageURLString = fullImageURL,
              let fullImageURL = URL(string: fullImageURLString) else {
            print("Full image URL is nil or invalid.")
            return
        }
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
           
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
         let minZoomScale = scrollView.minimumZoomScale
         let maxZoomScale = scrollView.maximumZoomScale
         view.layoutIfNeeded()
         let visibleRectSize = scrollView.bounds.size
         let imageSize = image.size
         let hScale = visibleRectSize.width / imageSize.width
         let vScale = visibleRectSize.height / imageSize.height
         let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
         scrollView.minimumZoomScale = scale
         scrollView.maximumZoomScale = 1.25
         scrollView.setZoomScale(scale, animated: false)
         scrollView.layoutIfNeeded()
         let newContentSize = scrollView.contentSize
         let x = (newContentSize.width - visibleRectSize.width) / 2
         let y = (newContentSize.height - visibleRectSize.height) / 2
         scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так. Попробовать ещё раз?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.loadImage()
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}


