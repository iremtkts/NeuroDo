import Foundation

final class TokenManager {
    
    static let shared = TokenManager()
    private init() {}
    
    private let accessTokenKey = "accessToken"
    private let tokenTypeKey = "tokenType"
    
    func saveToken(token: String, tokenType: String) {
        UserDefaults.standard.set(token, forKey: accessTokenKey)
        UserDefaults.standard.set(tokenType, forKey: tokenTypeKey)
    }
    
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    func getAuthorizationHeader() -> String? {
        if let token = getAccessToken(),
           let type = UserDefaults.standard.string(forKey: tokenTypeKey) {
            return "\(type) \(token)"
        }
        return nil
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: tokenTypeKey)
    }
}
