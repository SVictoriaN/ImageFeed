import UIKit
import ProgressHUD


protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    // MARK: - Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ок", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert.addAction(action)
        
        present(alert, animated: true)
        
    }
    
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        fetchOAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                self.delegate?.authViewController(self, didAuthenticateWithCode: token)
                self.dismiss(animated: true)
                
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code: code) { result in
            completion(result)
        }
    }
}

