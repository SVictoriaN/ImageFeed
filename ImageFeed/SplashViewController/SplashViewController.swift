import UIKit
import Foundation
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    private let splashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token)
        } else {
            switchToAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(splashImageView)

        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            splashImageView.heightAnchor.constraint(equalTo: splashImageView.widthAnchor)
        ])
    }
    
    private func switchToAuthViewController() {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)

            guard let authViewController = storyboard.instantiateViewController(
                withIdentifier: "AuthViewController"
            ) as? AuthViewController else { return }
            
            authViewController.delegate = self

            let navigationController = UINavigationController(rootViewController: authViewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            
            print(">>> [ProfileService] Fetching profile...")
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                username = profile.username
                guard let username else { return }
                ProfileImageService.shared.fetchProfileImageURL(username: username) {  result in
                    switch result {
                    case .success:
                        print(">>> [ProfileImageService] Profile image URL: (url)")
                    case .failure:
                        print(">>> [ProfileImageService] Error fetching profile image: (error.localizedDescription)")
                    }
                }
                print(">>> [SplashViewController] Fetching profile completed")
                switchToTabBarController()
            case .failure:
                print(">>> [SplashViewController] Fetching profile failed")
                let alert = UIAlertController(title: "Что-то пошло не так(",
                                              message: "Не удалось войти в систему",
                                              preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ок", style: .default) { _ in
                    self.dismiss(animated: true)
                }
                alert.addAction(action)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let url):
                print(">>> [SplashViewController] OAuth token fetched successfully.")
                if let token = self.oauth2TokenStorage.token {
                    self.fetchProfile(token)
                } else {
                    print("No token found after fetching OAuth token.")
                }
            case .failure(let error):
                print("Error fetching OAuth token: (error.localizedDescription)")
            }
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = oauth2TokenStorage.token else {
            print("No token available after authentication.")
            return
        }
        
        fetchProfile(token)
    }
}
