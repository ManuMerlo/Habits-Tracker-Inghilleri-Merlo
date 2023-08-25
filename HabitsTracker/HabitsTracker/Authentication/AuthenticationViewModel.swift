import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    private var tasks: [Task<Void, Never>] = []
    
    @Published var user: User?
    @Published var messageError: String? // FIXME: async await
    @Published var isAccountLinked: Bool = false
    
    @Published var textFieldEmailSignin: String = ""
    @Published var textFieldPasswordSignin: String = ""
    
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
    
    func clearSignUpParameter() {
        self.textFieldUsername = ""
        self.textFieldEmail = ""
        self.textFieldPassword = ""
        self.repeatPassword = ""
        self.messageError = nil
    }
    
    func clearSignInParameter() {
        self.textFieldEmailSignin = ""
        self.textFieldPasswordSignin = ""
        self.messageError = nil
    }
    
    // MARK: Not async because we want the result before the app loading.
    func getAuthenticatedUser() {
        self.user = try? authenticationRepository.getAuthenticatedUser()
    }
    
    func createNewUser() async throws -> User {
        guard !textFieldEmail.isEmpty, !textFieldPassword.isEmpty, !textFieldUsername.isEmpty, !repeatPassword.isEmpty else {
            print("No username, email or password found.")
            throw URLError(.badServerResponse)
        }
        let user = try await authenticationRepository.createNewUser(email: textFieldEmail, password: textFieldPassword)
        self.user = user // FIXME: need for login after signup
        print("Success, user created with email and password")
        return user
    }
    
    // TODO: reset password, update email/password
    func login() {
        guard !textFieldEmailSignin.isEmpty, !textFieldPasswordSignin.isEmpty else {
            print("No username, email or password found.")
            return
        }
        let task = Task {
            do {
                self.user = try await authenticationRepository.login(email: textFieldEmailSignin, password: textFieldPasswordSignin)
                print("Success, user created with emal and password")
            } catch {
                print("Error: \(error.localizedDescription)")
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
                // FIXME: can it be avoided?
                self.user = nil
                clearSignInParameter()
                clearSignUpParameter()
            } catch {
                print("Error logout")
            }
        }
        tasks.append(task)
    }
    
    //FIXME: it can be
    func getCurrentProvider() {
        linkedAccounts = authenticationRepository.getCurrentProvider()
        print("User Provider \(linkedAccounts)")
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
            } catch {
                self.isAccountLinked = false
                print("Account not linked")
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
            } catch {
                self.isAccountLinked = false
                print("Account not linked")
            }
            self.showAlert.toggle()
            self.getCurrentProvider()
        }
        tasks.append(task)
    }
    
    func linkEmailAndPassword(email:String, password:String) {
        authenticationRepository.linkEmailAndPassword(email: email,
                                                      password: password) { [weak self] isSuccess in
            print("Linked Email and Password \(isSuccess.description)")
            self?.isAccountLinked = isSuccess
            self?.showAlert.toggle()
            self?.getCurrentProvider()
        }
    }
    
    func deleteUser() async throws {
        try await authenticationRepository.deleteUser()
    }
    
}
