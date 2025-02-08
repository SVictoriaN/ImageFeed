import Foundation

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    var profileImageServiceObserver: NSObjectProtocol? { get set }
    func updateUserDetails(name: String, loginName: String, bio: String)
    func updateAvatar(with url: URL)
}
