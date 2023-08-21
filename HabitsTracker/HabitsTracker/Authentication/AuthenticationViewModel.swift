import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    private var tasks: [Task<Void, Never>] = []
    
    @Published var user: User?
    @Published var messageError: String?
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
        /*Task {
            do {
                self.user = try await authenticationRepository.createNewUser(email: textFieldEmail, password: textFieldPassword)
                print("Success, user created with emal and password")
            } catch{
                print("Error: \(error.localizedDescription)")
            }
        }*/
    }
    
    // TODO: reset password, update email/password
    func login() async throws {
        guard !textFieldEmailSignin.isEmpty, !textFieldPasswordSignin.isEmpty else {
            print("No username, email or password found.")
            return
        }
        self.user = try await authenticationRepository.login(email: textFieldEmailSignin, password: textFieldPasswordSignin)
        print("Success, user created with emal and password")
    }
    
    func loginFacebook(completionBlock: @escaping (Result<User, Error>) -> Void) {
        authenticationRepository.loginFacebook() { [weak self] result in // result would be the completionBlock of the repository that returns success or failure
            switch result {
            case .success(let user):
                self?.user = user
                completionBlock(.success(user))
            case .failure(let error):
                self?.messageError = error.localizedDescription
                completionBlock(.failure(error))
            }
        }
    }
    
    func loginGoogle(completionBlock:@escaping (Result<User, Error>) -> Void) {
        authenticationRepository.loginGoogle() { [weak self] result in // result would be the completionBlock of the repository that returns success or failure
            switch result {
            case .success(let user):
                self?.user = user
                completionBlock(.success(user))
            case .failure(let error):
                self?.messageError = error.localizedDescription
                completionBlock(.failure(error))
            }
        }
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
        authenticationRepository.linkFacebook { [weak self] isSuccess in
            print("Linked Facebook \(isSuccess.description)")
            self?.isAccountLinked = isSuccess
            self?.showAlert.toggle()
            self?.getCurrentProvider()
        }
    }
    
    func linkGoogle() {
        authenticationRepository.linkGoogle { [weak self] isSuccess in
            print("Linked Google \(isSuccess.description)")
            self?.isAccountLinked = isSuccess
            self?.showAlert.toggle()
            self?.getCurrentProvider()
        }
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
