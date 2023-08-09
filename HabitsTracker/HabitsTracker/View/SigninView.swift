import SwiftUI

struct SigninView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel // // Here authenticationViewModel is a @ObservedObject instead in HabitsTrackerApp is a @StateObject. For more details see (*1)
    @ObservedObject var firestoreViewModel : FirestoreViewModel
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(alignment: .center, spacing: 15) {
                Group {
                    LottieView(filename: "login")
                        .frame(width:300, height: 260)
                        .clipShape(Circle())
                        .shadow(color: .orange, radius: 1, x: 0, y: 0)
                        .padding(.top,10)
                    
                    Text("Sign in")
                        .font(.title)
                        .fontWeight(.semibold)
                        .offset(y: -12)
                    
                    CustomTextField(isSecure: false, hint: "Email", imageName: "envelope", text: $authenticationViewModel.textFieldEmailSignin)
                    
                    CustomTextField(isSecure:true, hint: "Password", imageName: "lock", text: $authenticationViewModel.textFieldPasswordSignin)
                    
                    NavigationLink {
                        //TODO recupera password
                    } label: {
                        Text("Forgot the password?")
                    }
                                        
                    Button {
                        guard authenticationViewModel.isValidEmail(email: authenticationViewModel.textFieldEmailSignin), !authenticationViewModel.textFieldPasswordSignin.isEmpty else {
                            print("Empty email or password")
                            return
                        }
                        
                        authenticationViewModel.login(email: authenticationViewModel.textFieldEmailSignin,
                                                      password: authenticationViewModel.textFieldPasswordSignin)
                        
                    } label: {
                        HStack() {
                            Text("Sign in")
                                .fontWeight(.semibold)
                                .contentTransition(.identity)
                            
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal,25)
                        .frame(height: 15)
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
                    
                    Button {
                        authenticationViewModel.loginGoogle(){ result in
                            switch result {
                            case .success(let userGoogle):
                                firestoreViewModel.fieldIsPresent(field: "id", value: userGoogle.id!){ result in
                                    switch result {
                                    case .success(let isPresent):
                                        if !isPresent  {
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
                        HStack {
                            Image("googlelogo")
                                .resizable()
                                .frame(width: 18, height: 18)
                            Text("Sign in with Google")
                            
                        }
                        .padding()
                        .background(.white)
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                        .frame(height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    
                    
                    Button {
                        authenticationViewModel.loginFacebook(){ result in
                            switch result {
                            case .success(let userFacebook):
                                firestoreViewModel.fieldIsPresent(field: "id", value: userFacebook.id!){ result in
                                    switch result {
                                    case .success(let isPresent):
                                        if !isPresent  {
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
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24,height: 24) // Dimensioni del cerchio bianco
                                
                                Image("facebook_logo")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                            }
                            
                            Text("Continue with Facebook")
                            
                        }
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .frame(height: 40)
                        .cornerRadius(8)
                        .frame(height: 40)
                    }
                    
                    
                    NavigationLink {
                        SignupView(authenticationViewModel: authenticationViewModel, firestoreViewModel: firestoreViewModel)
                    } label: {
                        Text("Don't have an account? Sign up")
                    }
                    .padding(.top, 5)
                }
                
            }
            .onAppear{
                authenticationViewModel.clearSignInParameter()
            }
            .padding(.horizontal, 50)
            .padding(.vertical,25)
            .offset(y:-30)
        }
    }
}

struct signinView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView(authenticationViewModel: AuthenticationViewModel(),firestoreViewModel: FirestoreViewModel())
    }
}
