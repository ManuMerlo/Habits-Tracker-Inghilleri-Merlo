//
//  AuthenticationViewModel.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 31/03/23.
//

import Foundation


final class AuthenticationViewModel: ObservableObject {
    @Published var user: User?
    @Published var messageError: String?
    @Published var isAccountLinked: Bool = false
    
    @Published var textfieldUsername: String = ""
    @Published var textFieldEmail: String = ""
    @Published var textFieldPassword: String = ""
    @Published var repeatPassword: String = ""
    
    @Published var linkedAccounts: [LinkedAccounts] = []
    @Published var showAlert : Bool = false
    
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository = AuthenticationRepository()) {
        self.authenticationRepository = authenticationRepository
        getCurrentUser() // It is to check if a session already exists
    }
    
    func getCurrentUser() {
        self.user = authenticationRepository.getCurrentUser()
    }
    
    func createNewUser(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void){
        authenticationRepository.createNewUser(email: email,
                                               password: password) { [weak self] result in // result would be the completionBlock of the repository that returns success or failure
            switch result {
            case .success(var user):
                user.setUsername(name: self?.textfieldUsername ?? "")
                self?.user? = user
                completionBlock(.success(user))
            case .failure(let error):
                self?.messageError = error.localizedDescription
                completionBlock(.failure(error))
            }
        }
    }
    
    func login(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void) {
        authenticationRepository.login(email: email,
                                       password: password) { [weak self] result in // result would be the completionBlock of the repository that returns success or failure
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
        do {
            try authenticationRepository.logout()
            self.user = nil
            self.textfieldUsername = ""
            self.textFieldEmail = ""
            self.textFieldPassword = ""
            self.repeatPassword = ""
        } catch {
            print("Error logout")
        }
    }
    
    func getCurrentProvider(){
        linkedAccounts = authenticationRepository.getCurrentProvider()
        print("User Provider \(linkedAccounts)")
    }
    
    func isEmailandPasswordLinked() -> Bool{
        linkedAccounts.contains(where: { $0.rawValue == "password"})
    }
    
    func isFacebookLinked() -> Bool{
        linkedAccounts.contains(where: { $0.rawValue == "facebook.com"})
    }
    
    func isGoogleLinked() -> Bool{
        linkedAccounts.contains(where: { $0.rawValue == "google.com"})
    }
    
    func linkFacebook () {
        authenticationRepository.linkFacebook { [weak self] isSuccess in
            print("Linked Facebook \(isSuccess.description)")
            self?.isAccountLinked = isSuccess
            self?.showAlert.toggle()
            self?.getCurrentProvider()
        }
    }
    
    func linkGoogle () {
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
    
    func deleteUser() {
        authenticationRepository.deleteUser() { [weak self] result in
            switch result {
            case .success(_):
                self?.user = nil
                self?.textfieldUsername = ""
                self?.textFieldEmail = ""
                self?.textFieldPassword = ""
                self?.repeatPassword = ""
                print("success in deleting the user")
            case .failure(let error):
                self?.messageError = error.localizedDescription
            }
        }
    }
    
}
