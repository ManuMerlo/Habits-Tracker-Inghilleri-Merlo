import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    /// A list of tasks that the view model runs. Useful for cancellation.
    private(set) var tasks: [Task<Void, Never>] = []
    
    /// Represents the authenticated user.
    @Published var user: User?
    
    /// Stores an error message when an authentication operation fails.
    @Published var messageError: String? = nil
    
    /// Indicates if the user account has been linked.
    @Published var isAccountLinked: Bool = false
    
    // MARK: - Account Parameters
    
    /// Stores the username entered by the user.
    @Published var textFieldUsername: String = ""
    
    /// Stores the email entered by the user.
    @Published var textFieldEmail: String = ""
    
    /// Stores the password entered by the user.
    @Published var textFieldPassword: String = ""
    
    /// Stores the repeated password entered by the user.
    @Published var repeatPassword: String = ""
    
    /// Represents the linked accounts with the user's account.
    @Published var linkedAccounts: [LinkedAccounts] = []
    
    /// Indicates whether a feedback alert should be displayed.
    @Published var showAlert: Bool = false
    
    private let authenticationRepository: AuthenticationRepository
    
    /// Initializes the `AuthenticationViewModel` with an optional `AuthenticationRepository`.
    ///
    /// - Parameter authenticationRepository: An instance of `AuthenticationRepository`.
    init(authenticationRepository: AuthenticationRepository = AuthenticationRepository()) {
        self.authenticationRepository = authenticationRepository
        getAuthenticatedUser() // It is to check if a session already exists
    }
    
    /// Cancels all active tasks.
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    /// Validates if a given string is a valid email format.
    ///
    /// - Parameter email: The string to validate as email.
    /// - Returns: A boolean indicating if the email is valid.
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Clears the input fields used for user authentication.
    func clearAccountParameter() {
        self.textFieldUsername = ""
        self.textFieldEmail = ""
        self.textFieldPassword = ""
        self.repeatPassword = ""
        self.messageError = nil
    }
    
    /// Validates the entered fields for the sign-up operation.
    ///
    /// - Returns: `true` if all fields are valid, otherwise `false`.
    func validateFieldsSignUp() -> Bool {
        guard isValidEmail(email:textFieldEmail), !textFieldPassword.isEmpty, !repeatPassword.isEmpty else {
            messageError = "Not valid email or empty password"
            return false
        }
        guard textFieldPassword == repeatPassword else {
            messageError =  "Passwords do not match"
            return false
        }
        
        guard !textFieldUsername.isEmpty else {
            messageError =  "Username is empty"
            return false
        }
        return true
    }
    
    
    /// Fetches the authenticated user if a session exists.
    func getAuthenticatedUser() {
        self.user = try? authenticationRepository.getAuthenticatedUser()
    }
    
    /// Creates a new user with the provided email and password.
    ///
    /// - Throws: An error if any occurs during the user creation process.
    /// - Returns: The newly created `User`.
    func createNewUser() async throws -> User {
        guard !textFieldEmail.isEmpty, !textFieldPassword.isEmpty, !textFieldUsername.isEmpty, !repeatPassword.isEmpty else {
            throw ViewError.usernameEmailPasswordNotFound
        }
        let user = try await authenticationRepository.createNewUser(email: textFieldEmail, password: textFieldPassword)
        self.user = user
        return user
    }
    
    /// Initiates a password reset process for a given email.
    ///
    /// - Parameter email: The email for which to reset the password.
    /// - Throws: An error if any occurs during the password reset process.
    func resetPassword(email: String) async throws {
        try await authenticationRepository.resetPassword(email: email)
    }
    
    /// Updates the authenticated user's email.
    ///
    /// - Parameter email: The new email.
    /// - Throws: An error if any occurs during the email update process.
    func updateEmail(email: String) async throws {
        try await authenticationRepository.updateEmail(email: email)
    }
    
    /// Updates the authenticated user's password.
    ///
    /// - Parameter password: The new password.
    /// - Throws: An error if any occurs during the password update process.
    func updatePassword(password: String) async throws {
        try await authenticationRepository.updatePassword(password: password)
    }
    
    /// Attempts to log in the user with the provided email and password.
    /// If the input fields for email or password are empty, sets an error message.
    func login() {
        guard !textFieldEmail.isEmpty, !textFieldPassword.isEmpty else {
            self.messageError = "No username, email or password found."
            return
        }
        let task = Task {
            do {
                self.user = try await authenticationRepository.login(email: textFieldEmail, password: textFieldPassword)
            } catch {
                self.messageError = "Login error. Retry."
            }
        }
        tasks.append(task)
    }
    
    /// Attempts to log in the user using Facebook.
    ///
    /// - Throws: An error if any occurs during the login process.
    /// - Returns: The authenticated `User` instance.
    func loginFacebook() async throws -> User {
        let user = try await authenticationRepository.loginFacebook()
        self.user = user
        return user
    }
    
    /// Attempts to log in the user using Google.
    ///
    /// - Throws: An error if any occurs during the login process.
    /// - Returns: The authenticated `User` instance.
    func loginGoogle() async throws -> User {
        let user = try await authenticationRepository.loginGoogle()
        self.user = user
        return user
    }
    
    /// Logs out the currently authenticated user.
    func logout() {
        let task = Task {
            do {
                try authenticationRepository.logout()
                self.user = nil
            } catch {
                self.messageError = "Logout error. Retry."
            }
        }
        tasks.append(task)
    }
    
    /// Fetches the current authentication providers linked to the user.
    func getCurrentProvider() {
        linkedAccounts = authenticationRepository.getCurrentProvider()
    }
    
    /// Checks if the user's account is linked with email and password.
    ///
    /// - Returns: A boolean indicating the link status.
    func isEmailandPasswordLinked() -> Bool {
        linkedAccounts.contains(where: { $0.rawValue == "password"})
    }
    
    /// Checks if the user's account is linked with Facebook.
    ///
    /// - Returns: A boolean indicating the link status.
    func isFacebookLinked() -> Bool {
        linkedAccounts.contains(where: { $0.rawValue == "facebook.com"})
    }
    
    /// Checks if the user's account is linked with Google.
    ///
    /// - Returns: A boolean indicating the link status.
    func isGoogleLinked() -> Bool {
        linkedAccounts.contains(where: { $0.rawValue == "google.com"})
    }
    
    /// Attempts to link the user's account with Facebook.
    func linkFacebook() {
        let task = Task {
            do {
                try await authenticationRepository.linkFacebook()
                self.isAccountLinked = true
            } catch AuthenticationError.userNotLogged {
                self.isAccountLinked = false
                self.messageError = AuthenticationError.userNotLogged.description
            } catch {
                self.isAccountLinked = false
                self.messageError = "Facebook account not linked"
            }
            self.showAlert.toggle()
            self.getCurrentProvider()
        }
        tasks.append(task)
    }
    
    /// Attempts to link the user's account with Google.
    func linkGoogle() {
        let task = Task {
            do {
                try await authenticationRepository.linkGoogle()
                self.isAccountLinked = true
            } catch AuthenticationError.userNotLogged {
                self.isAccountLinked = false
                self.messageError = AuthenticationError.userNotLogged.description
            } catch {
                self.isAccountLinked = false
                self.messageError = "Google account not linked"
            }
            self.showAlert.toggle()
            self.getCurrentProvider()
        }
        tasks.append(task)
    }
    
    /// Attempts to link the user's account with email and password.
    func linkEmailAndPassword() {
        let task = Task {
            do {
                try await authenticationRepository.linkEmailAndPassword(email: textFieldEmail, password: textFieldPassword)
                self.isAccountLinked = true
            } catch AuthenticationError.missingCredential {
                self.isAccountLinked = false
                self.messageError = AuthenticationError.missingCredential.description
            } catch AuthenticationError.userNotLogged {
                self.isAccountLinked = false
                self.messageError = AuthenticationError.userNotLogged.description
            } catch {
                self.isAccountLinked = false
                self.messageError = "Email and Password account not linked"
            }
            self.showAlert.toggle()
            self.getCurrentProvider()
        }
        tasks.append(task)
    }
    
    /// Deletes the currently authenticated user.
    ///
    /// - Throws: An error if any occurs during the user deletion process.
    func deleteUser() async throws {
        try await authenticationRepository.deleteUser()
    }
    
}
