import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    private(set) var tasks: [Task<Void, Never>] = []
    
    @Published var user: User?
    @Published var messageError: String?
    @Published var isAccountLinked: Bool = false
    
    // Account parameters
    @Published var textFieldUsername: String = ""
    @Published var textFieldEmail: String = ""
    @Published var textFieldPassword: String = ""
    @Published var repeatPassword: String = ""

    @Published var linkedAccounts: [LinkedAccounts] = []
    @Published var showAlert: Bool = false
    
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository = AuthenticationRepository()) {
        self.authenticationRepository = authenticationRepository
        getAuthenticatedUser() // It is to check if a session already exists
    }
    
    // function to cancel all tasks
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func clearAccountParameter() {
        self.textFieldUsername = ""
        self.textFieldEmail = ""
        self.textFieldPassword = ""
        self.repeatPassword = ""
        self.messageError = nil
    }
    
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
    
    
    // MARK: Not async because we want the result before the app loading.
    func getAuthenticatedUser() {
        self.user = try? authenticationRepository.getAuthenticatedUser()
    }
    
    func createNewUser() async throws -> User {
        guard !textFieldEmail.isEmpty, !textFieldPassword.isEmpty, !textFieldUsername.isEmpty, !repeatPassword.isEmpty else {
            throw ViewError.usernameEmailPasswordNotFound
        }
        let user = try await authenticationRepository.createNewUser(email: textFieldEmail, password: textFieldPassword)
        self.user = user
        print("Success, user created with email and password")
        return user
    }
    
    func resetPassword(email: String) async throws {
        try await authenticationRepository.resetPassword(email: email)
    }
    
    func updateEmail(email: String) async throws {
        try await authenticationRepository.updateEmail(email: email)
    }
    
    func updatePassword(password: String) async throws {
        try await authenticationRepository.updatePassword(password: password)
    }
    
    func login() {
        guard !textFieldEmail.isEmpty, !textFieldPassword.isEmpty else {
            self.messageError = "No username, email or password found."
            return
        }
        let task = Task {
            do {
                self.user = try await authenticationRepository.login(email: textFieldEmail, password: textFieldPassword)
                print("Success, user logged with email and password")
            } catch {
                self.messageError = "Login error. Retry."
            }
        }
        tasks.append(task)
    }
    
    func loginFacebook() async throws -> User {
        let user = try await authenticationRepository.loginFacebook()
        self.user = user
        return user
    }
    
    func loginGoogle() async throws -> User {
        let user = try await authenticationRepository.loginGoogle()
        self.user = user
        return user
    }
    
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
    
    func getCurrentProvider() {
        linkedAccounts = authenticationRepository.getCurrentProvider()
        //print("User Provider \(linkedAccounts)")
    }
    
    func isEmailandPasswordLinked() -> Bool {
        linkedAccounts.contains(where: { $0.rawValue == "password"})
    }
    
    func isFacebookLinked() -> Bool {
        linkedAccounts.contains(where: { $0.rawValue == "facebook.com"})
    }
    
    func isGoogleLinked() -> Bool {
        linkedAccounts.contains(where: { $0.rawValue == "google.com"})
    }
    
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
    
    func deleteUser() async throws {
        try await authenticationRepository.deleteUser()
    }
    
}
