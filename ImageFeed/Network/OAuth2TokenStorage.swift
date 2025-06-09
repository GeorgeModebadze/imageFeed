import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let keychain = KeychainWrapper.standard
    let tokenKey = "BearerToken"
    
    var token: String? {
            get {
                return keychain.string(forKey: tokenKey)
            }
            set {
                if let newValue = newValue {
                    keychain.set(newValue, forKey: tokenKey)
                } else {
                    keychain.removeObject(forKey: tokenKey)
                }
            }
        }
    
    private init() {}
}
