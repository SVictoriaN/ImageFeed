import UIKit

final class ProfileViewController: UIViewController {
        
        private var avatarImageView: UIImageView!
        private var nameLabel: UILabel!
        private var loginNameLabel: UILabel!
        private var descriptionLabel: UILabel!
        private var logoutButton: UIButton!

        override func viewDidLoad() {
            super.viewDidLoad()
            setupAvatarImageView()
            setupNameLabel()
            setupLoginNameLabel()
            setupDescriptionLabel()
            setupLogoutButton()
        }
        
        private func setupAvatarImageView() {
            let profileImage = UIImage(named: "avatar")
            avatarImageView = UIImageView(image: profileImage)
            
            avatarImageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(avatarImageView)
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
            avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
            
            avatarImageView.layer.cornerRadius = 35
            avatarImageView.clipsToBounds = true
        }
        
        private func setupNameLabel() {
            nameLabel = UILabel()
            nameLabel.text = "Екатерина Новикова"
            nameLabel.textColor = .white
            nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
            
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(nameLabel)
            
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        }
        
        private func setupLoginNameLabel() {
            loginNameLabel = UILabel()
            loginNameLabel.textColor = .gray
            loginNameLabel.text = "@ekaterina_nov"
            loginNameLabel.font = UIFont.systemFont(ofSize: 13)
            
            loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(loginNameLabel)
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        }
        
        private func setupDescriptionLabel() {
            descriptionLabel = UILabel()
            descriptionLabel.textColor = .white
            descriptionLabel.text = "Hello, world!"
            descriptionLabel.font = UIFont.systemFont(ofSize: 13)
            
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(descriptionLabel)
            
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor).isActive = true
            descriptionLabel.trailingAnchor.constraint(equalTo: loginNameLabel.trailingAnchor).isActive = true
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        }
    
    private func setupLogoutButton() {
        logoutButton = UIButton.systemButton(
            with: UIImage(named: "logout_button")!,
            target:self,
            action:#selector(didTapLogoutButton))
        logoutButton.tintColor = .red
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
    }
    
    
    @objc
    private func didTapLogoutButton() {
        nameLabel?.removeFromSuperview()
        nameLabel = nil
        
        loginNameLabel?.removeFromSuperview()
        loginNameLabel = nil
        
        descriptionLabel?.removeFromSuperview()
        descriptionLabel = nil
    }
    
}
