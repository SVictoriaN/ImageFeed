import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let tokenKey = "oauth2_token"
    
    init() { }
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let newValue else {
                print(">>> [OAuth2TokenStorage] Saving auth token failed")
                return
            }
            KeychainWrapper.standard.set(newValue, forKey: tokenKey)
        }
    }
}
