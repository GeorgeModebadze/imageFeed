import Foundation
import WebKit
import SwiftKeychainWrapper

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    private let oauth = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    func logout() {
        cleanCookies()
        resetToken()
        resetProfileData()
        resetImagesData()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func resetToken() {
        KeychainWrapper.standard.removeObject(forKey: oauth.tokenKey)
        oauth.token = nil
    }
    
    private func resetProfileData() {
        profileService.cleanProfile()
        profileImageService.cleanAvatarURL()
    }
    
    private func resetImagesData() {
        imagesListService.cleanPhotos()
    }
}
