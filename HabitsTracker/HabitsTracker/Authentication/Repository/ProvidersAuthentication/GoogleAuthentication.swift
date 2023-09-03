import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

// MARK: - GoogleAuthentication Class

final class GoogleAuthentication {
    
    /// Logs in the user via Google.
    ///
    /// - Throws: `URLError.badURL` if the clientID for Firebase is not found.
    ///
    /// - Returns: An authenticated `GIDGoogleUser` object.
    func loginGoogle() async throws -> GIDGoogleUser {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw URLError(.badURL)
        }
        
        let rootController = await getRootController()
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.signIn(with: .init(clientID: clientID), presenting: rootController) { user, error in
                    if let user = user {
                        continuation.resume(returning: user)
                    } else if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: URLError(.badURL))
                    }
                }
            }
            
        }
    }
    
    /// Retrieves the root controller of the application.
    ///
    /// - Returns: The root `UIViewController` of the application.
    @MainActor
    func getRootController() -> UIViewController {
        return UIApplication.shared.rootController()
    }

    /// Retrieves the current Google user.
    ///
    /// - Returns: The current `GIDGoogleUser` if there is one; otherwise, `nil`.
    func getUser() -> GIDGoogleUser? {
        GIDSignIn.sharedInstance.currentUser
    }
}
