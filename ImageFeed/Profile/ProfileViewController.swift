import UIKit
import Foundation

final class ProfileViewController: UIViewController {
    
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "avatar")
        view.image = image
        view.layer.cornerRadius = 35
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        //label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 23)
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        //label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        //label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "logout_button")!,
            target: self,
            action: #selector(didTapLogoutButton))
        button.tintColor = UIColor(red: 0xF5/255.0, green: 0x6B/255.0, blue: 0x6C/255.0, alpha: 1.0)
        return button
    }()
    
    private let profile = ProfileService.shared.profile
    private let profileService = ProfileService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupСonstraints()
        
        loadProfile()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupViews() {
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupСonstraints(){
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: loginNameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func loadProfile() {
            // Здесь нужно передать токен для загрузки профиля
        guard let token = OAuth2TokenStorage.shared.token else {
                    print("Token is missing.")
                    return
                }

            profileService.fetchProfile(token) { [weak self] result in
                switch result {
                case .success(let profile):
                    DispatchQueue.main.async {
                        self?.updateProfileDetails(with: profile)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("Ошибка при загрузке профиля: (error)")
                        self?.loginNameLabel.text = "Неизвестный пользователь"
                        self?.descriptionLabel.text = "Нет информации"
                    }
                }
            }
        }
        
        @objc private func profileUpdated() {
            // Обновляем данные при получении уведомления
            if let updatedProfile = profileService.profile {
                updateProfileDetails(with: updatedProfile)
            }
        }
        
        func updateProfileDetails(with profile: Profile?) {
            
            guard let profile = profile else {
                loginNameLabel.text = "Неизвестный пользователь"
                descriptionLabel.text = "Нет информации"
                return
            }
            
            nameLabel.text = profile.name
            loginNameLabel.text = profile.loginName
            descriptionLabel.text = profile.bio
        }
    
    @objc
    private func didTapLogoutButton() {
        // TODO: - Добавить логику нажатия на кнопку Logout
    }
}
