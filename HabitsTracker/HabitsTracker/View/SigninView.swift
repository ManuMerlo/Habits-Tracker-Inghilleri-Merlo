//
//  Signin.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 19/11/22.
//

import SwiftUI

struct SigninView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel // // Here authenticationViewModel is a @ObservedObject instead in HabitsTrackerApp is a @StateObject. For more details see (*1)
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            
            VStack(alignment: .center, spacing: 15) {
                Group {
                    ZStack{
                        LottieView(filename: "login")
                            .frame(width:330, height: 280)
                            .clipShape(Circle())
                            .shadow(color: .orange, radius: 1, x: 0, y: 0)
                    }
                    
                    Text("Sign in").font(.title)
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)
                        .offset(y: -8)
                    
                    CustomTextField(isSecure: false, hint: "Email", imageName: "envelope", text: $authenticationViewModel.textFieldEmail)
                    
                    CustomTextField(isSecure:true, hint: "Password", imageName: "lock", text: $authenticationViewModel.textFieldPassword)
                    
                    NavigationLink {
                        //TODO recupera password
                    } label: {
                        Text("Forgot the password?")
                    }
                    .padding(.vertical, 6)
                    Button {
                        guard !authenticationViewModel.textFieldEmail.isEmpty, !authenticationViewModel.textFieldPassword.isEmpty else {
                            print("Empty email or password")
                            return
                        }
                        authenticationViewModel.login(email: authenticationViewModel.textFieldEmail,
                                                      password: authenticationViewModel.textFieldPassword){ result in
                            switch result {
                            case .success(let userPasw):
                                firestoreViewModel.getUser(uid: userPasw.id!) { result in
                                    switch result {
                                    case .success(let userFirestore):
                                        if let user = userFirestore  {
                                            authenticationViewModel.user = user
                                        }
                                    case .failure(let error):
                                        print("Error finding document user: \(error)")
                                        return
                                    }
                                }
                            case .failure(let error):
                                print("Error logging the user: \(error)")
                                return
                            }
                        }
                    } label: {
                        HStack() {
                            Text("Sign in")
                                .fontWeight(.semibold)
                                .contentTransition(.identity)
                            
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal,25)
                        .padding(.vertical)
                        .background{
                            RoundedRectangle(cornerRadius: 10,style: .continuous).fill(.black.opacity(0.05))
                        }
                    }
                    // TODO: it must disappear.
                    if let messageError = authenticationViewModel.messageError {
                        Text(messageError)
                            .font(.body)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                
                Group {
                    HStack{
                        VStack { Divider().background(Color.gray) }.padding(.horizontal, 20)
                        Text("or").foregroundColor(Color.gray)
                        VStack { Divider().background(Color.gray) }.padding(.horizontal, 20)
                    }
                    
                    //MARK: Custom Google Sign in Button
                    /*CustomButton(logo: "googlelogo")
                     .overlay {
                     if let clientID = FirebaseApp.app()?.options.clientID {
                     GoogleSignInButton {
                     GIDSignIn.sharedInstance.signIn(with: .init(clientID: clientID), presenting: UIApplication.shared.rootController()) {user, err in
                     if let error = err {
                     print(error.localizedDescription)
                     return
                     }
                     //MARK: Logging Google User into Firebase
                     if let user {
                     //signinViewModel.logGoogleUser(user: user)
                     }
                     }
                     }
                     .blendMode(.overlay)
                     }
                     }
                     .clipped()*/
                    
                    Button {
                        authenticationViewModel.loginGoogle(){ result in
                            switch result {
                            case .success(let userGoogle):
                                firestoreViewModel.getUser(uid: userGoogle.id!) { result in
                                    switch result {
                                    case .success(let userFirestore):
                                        if let user = userFirestore  {
                                            authenticationViewModel.user = user
                                        }
                                        else {
                                            firestoreViewModel.addNewUser(user: userGoogle)
                                        }
                                    case .failure(let error):
                                        print("Error finding document user: \(error)")
                                        return
                                    }
                                }
                            case .failure(let error):
                                print("Error logging the user: \(error)")
                                return
                            }
                        }
                        
                    } label: {
                        Text("Continue with Google")
                    }
                    
                    Button {
                        authenticationViewModel.loginFacebook(){ result in
                            switch result {
                            case .success(let userFacebook):
                                firestoreViewModel.getUser(uid: userFacebook.id!) { result in
                                    switch result {
                                    case .success(let userFirestore):
                                        if let user = userFirestore {
                                            authenticationViewModel.user = user
                                        }
                                        else {
                                            firestoreViewModel.addNewUser(user: userFacebook)
                                        }
                                    case .failure(let error):
                                        print("Error finding document user: \(error)")
                                        return
                                    }
                                }
                            case .failure(let error):
                                print("Error logging the user: \(error)")
                                return
                            }
                        }
                    } label: {
                        Text("Continue with Facebook")
                    }
                    
                    NavigationLink {
                        SignupView(authenticationViewModel: authenticationViewModel,firestoreViewModel: firestoreViewModel)
                    } label: {
                        Text("Don't have an account? Sign up")
                    }
                    .padding(.top, 5)
                }
                
            }
            .padding(.horizontal, 50)
            .padding(.vertical,25)
            .offset(y:-30)
        }
        /*.alert(signinViewModel.errorMessage, isPresented: $signinViewModel.showError) {
         }*/
    }
    
    /*@ViewBuilder
     func CustomButton(logo: String) -> some View {
     HStack{
     Image(logo).resizable()
     .aspectRatio(contentMode: .fit)
     .frame(width: 25, height: 25)
     .frame(height: 45)
     Text("Continue with Google")
     .font(.callout)
     .lineLimit(1)
     .foregroundColor(.white)
     }
     .padding(.horizontal,15)
     .background {
     RoundedRectangle(cornerRadius: 10, style: .continuous)
     .fill(.black)
     }
     }*/
}

struct signinView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView(authenticationViewModel: AuthenticationViewModel(),firestoreViewModel: FirestoreViewModel())
    }
}
