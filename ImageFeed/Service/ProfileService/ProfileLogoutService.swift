import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        clearUserData()
        switchToSplashViewController()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func clearUserData() {
        ProfileService.shared.clearProfileData()
        ProfileImageService.shared.clearProfileImage()
        ImagesListService.shared.clearImagesList()
        OAuth2TokenStorage.shared.cleanToken()
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        let splashViewController = SplashViewController()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = splashViewController
        }, completion: nil)
    }
}
