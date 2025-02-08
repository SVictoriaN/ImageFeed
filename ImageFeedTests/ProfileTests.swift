@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsUpdating() {
        let viewController = ProfileViewControllerSpy()
        let someProfile = Profile(username: "TimCook", name: "Tim Cook", loginName: "@TimCook", bio: "")
        let someAvatarURL = "https://www.placebear.com/200/300"
        ProfileService.shared.profile = someProfile
        ProfileImageService.shared.avatarURL = someAvatarURL
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController

        presenter.viewDidLoad()

        XCTAssertTrue(viewController.updateUserDetailsCalled)
        XCTAssertTrue(viewController.updateAvatarCalled)
    }

    func testUpdatingImageByNotification() {
        let viewController = ProfileViewControllerSpy()
        let someProfile = Profile(username: "TimCook", name: "Tim Cook", loginName: "@TimCook", bio: "")
        let someAvatarURL = "https://www.placebear.com/200/300"
        ProfileService.shared.profile = someProfile
        ProfileImageService.shared.avatarURL = someAvatarURL
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController

        presenter.viewDidLoad() 
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: nil
        )

        XCTAssertEqual(viewController.updateAvatarCounter, 2)
    }
}
