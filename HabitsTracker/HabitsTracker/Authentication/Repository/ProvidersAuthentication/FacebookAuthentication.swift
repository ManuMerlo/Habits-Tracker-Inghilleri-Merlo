import Foundation
import FacebookLogin

// MARK: - FacebookAuthentication Class

final class FacebookAuthentication {
    
    let loginManager = LoginManager()
    
    /// Logs in the user via Facebook.
    ///
    /// - Throws: Any errors encountered during login.
    ///
    /// - Returns: The token string of the authenticated user.
    func loginFacebook() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.loginManager.logIn(permissions: ["email"],
                                        from: nil) { loginManagerLoginResult, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let loginManagerLoginResult = loginManagerLoginResult, let token = loginManagerLoginResult.token {
                        continuation.resume(returning: token.tokenString)
                    }
                }
            }
        }
    }
    
    /// Retrieves the current Facebook access token string.
    ///
    /// - Returns: The token string of the authenticated Facebook user, or `nil` if not available.
    func getAccessToken() -> String? {
        AccessToken.current?.tokenString
    }
}
