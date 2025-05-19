import Security
import Foundation

class TokenManager {
    static let shared = TokenManager()

    private let accessTokenKey = "authAccessToken"
    private let refreshTokenKey = "authRefreshToken"
    
    private init() {}

    // MARK: - Save Tokens
    func saveTokens(accessToken: String, refreshToken: String) {
        saveToken(accessToken, key: accessTokenKey)
        saveToken(refreshToken, key: refreshTokenKey)
    }

    private func saveToken(_ token: String, key: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Failed to save \(key) to Keychain: \(status)")
        }
    }

    // MARK: - Retrieve Tokens
    func getAccessToken() -> String? {
        return getToken(for: accessTokenKey)
    }

    func getRefreshToken() -> String? {
        return getToken(for: refreshTokenKey)
    }

    private func getToken(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        } else {
            print("Failed to retrieve \(key) from Keychain. Status: \(status)")
            return nil
        }
    }

    // MARK: - Delete Tokens
    func deleteTokens() {
        deleteToken(for: accessTokenKey)
        deleteToken(for: refreshTokenKey)
    }

    private func deleteToken(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            print("Failed to delete \(key) from Keychain. Status: \(status)")
        }
    }

    // MARK: - Refresh Token Logic
    func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = getRefreshToken() else {
            print("No refresh token available.")
            completion(false)
            return
        }

        let requestBody = ["refresh_token": refreshToken]

        CommunicationManager.shared.execute(
            endpoint: .refreshToken,
            body: requestBody,
            responseType: RefreshTokenResponse.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Refresh Token Successful. New Access Token Received.")
                    self.saveToken(response.access_token, key: self.accessTokenKey)
                    completion(true)
                case .failure(let error):
                    print("Refresh Token Failed: \(error.localizedDescription)")
                    self.deleteTokens()
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Verify Access Token
        func verifyAccessToken(completion: @escaping (Bool) -> Void) {
            guard let accessToken = getAccessToken() else {
                print("No access token available.")
                refreshToken(completion: completion)
                return
            }

            let requestBody = ["access_token": accessToken]

            CommunicationManager.shared.execute(
                endpoint: .verifyToken,
                body: requestBody,
                responseType: VerifyTokenResponse.self
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.valid {
                            print("Access Token is valid.")
                            completion(true)
                        } else {
                            print("Access Token is invalid. Attempting refresh...")
                            self.refreshToken(completion: completion)
                        }
                    case .failure(let error):
                        print("Verification Failed: \(error.localizedDescription). Attempting refresh...")
                        self.refreshToken(completion: completion)
                    }
                }
            }
        }
}
