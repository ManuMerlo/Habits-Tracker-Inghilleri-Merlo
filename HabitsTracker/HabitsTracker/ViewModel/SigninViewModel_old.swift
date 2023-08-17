//MARK: TO DELETE

import SwiftUI
import FirebaseAuth
//import GoogleSignIn
//import FBSDKLoginKit

final class SigninViewModel: ObservableObject {
    //MARK: View Properties
    //TODO: Non so se queste variabili email e password è meglio metterle qui o nel model
    @Published var username: String = ""
    @Published var emailAddress: String = ""
    @Published var password: String = ""
    
    //MARK: Error Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var register: Bool = false
    
    //MARK: App Log Status
    @AppStorage("log_status") var logStatus: Bool = false
    
    private var userViewModel = UserViewModel()
    
    /*
    func sign(emailAddress: String, password: String) {
        register ? signUp(emailAddress: emailAddress, password: password) : signIn(emailAddress: emailAddress, password: password)
    }*/
    
    func signIn(){
        //TODO: colseKeyboard() serve per chiudere la tastiera, ma non dovrebbe essere necessario perchè si chiude in automatico
        //UIApplication.shared.closeKeyboard()
        Auth.auth().signIn(withEmail: emailAddress, password: password) { result, err in
            if let error = err { //TODO: non so se bisogna controllare che result sia diverso da nil. Non so se è meglio cosi oppure con guard della sign up
                print(error.localizedDescription)
                return
            }
            //Success
            print("Signed In with email and password Success")
            withAnimation(.easeInOut){self.logStatus = true}
        }
    }
    
    
    func signUp(){
        //UIApplication.shared.closeKeyboard()
        /*Auth.auth().createUser(withEmail: emailAddress, password: password) { result, error in
            guard result != nil, error == nil else {
                return
            }*/
        Auth.auth().createUser(withEmail: emailAddress, password: password) { result, err in
            if let error = err {
                print(error.localizedDescription)
                return
            }
            // Success
            // Insert in Firestore
            if let result = result {
                // Add user to the database
                self.userViewModel.addUser(uid: result.user.uid, username: self.username, emailAddress: self.emailAddress)
                print("User added in Firestore")
            }
            //self.userViewModel.getUser(emailAddress: self.emailAddress)
            print("Signed Up with email and password Success")
            withAnimation(.easeInOut){self.logStatus = true}
        }
    }
    
    // MARK: Handling Error
    func handleError(error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
    // MARK: Logging Google User into Firebase
    /*func logGoogleUser(user: GIDGoogleUser) {
        Task {
            do {
                guard let idToken = user.authentication.idToken else {return}
                let accessToken = user.authentication.accessToken
                let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                try await Auth.auth().signIn(with: credentials)
                // Insert in firestore
                let currentUser = Auth.auth().currentUser
                if let currentUser = currentUser {
                    self.userViewModel.addUser(uid: currentUser.uid, username: String(currentUser.email?.split(separator:"@")[0] ?? ""), emailAddress: currentUser.email ?? "")
                }
                print("Success Google!")
                await MainActor.run(body: {
                    withAnimation(.easeInOut) {logStatus = true}
                })
            } catch {
                await handleError(error: error)
            }
        }
    }*/
}

extension UIApplication {
    /*func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }*/
    
    // Root Controller
    func rootController() -> UIViewController {
        guard let window = connectedScenes.first as? UIWindowScene else {return .init()}
        guard let viewController = window.windows.last?.rootViewController else {return .init()}
        return viewController
    }
}

