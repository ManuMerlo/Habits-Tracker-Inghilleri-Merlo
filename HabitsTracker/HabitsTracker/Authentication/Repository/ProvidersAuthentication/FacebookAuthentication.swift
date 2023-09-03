import Foundation
import FacebookLogin

final class FacebookAuthentication {
    let loginManager = LoginManager()
    
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
    
    func getAccessToken() -> String? {
        AccessToken.current?.tokenString
    }
}
