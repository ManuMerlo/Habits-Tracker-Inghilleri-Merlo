import SwiftUI

struct SigninView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var body: some View {
        ZStack{
            RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false) {

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
                            //TODO: recupera password
                        } label: {
                            Text("Forgot the password?")
                        }
                        
                        Button {
                            guard authenticationViewModel.isValidEmail(email: authenticationViewModel.textFieldEmailSignin), !authenticationViewModel.textFieldPasswordSignin.isEmpty else {
                                print("Empty email or password")
                                return
                            }
                            Task {
                                do {
                                    try await authenticationViewModel.login()
                                } catch {
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                            
                        } label: {
                            HStack() {
                                Text("Sign in")
                                    .font(.system(size:18))
                                    .fontWeight(.semibold)
                                    .frame(width: 120, height: 45)
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .contentTransition(.identity)
                                
                            }
                            .padding(.vertical,10)

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
                            Text("or").foregroundColor(Color.white)
                            VStack { Divider().background(Color.white) }.padding(.horizontal, 20)
                        }
                        
                        Button {
                            authenticationViewModel.loginGoogle() { result in
                                switch result {
                                case .success(let userGoogle):
                                    Task {
                                        do {
                                            let isPresent = try await firestoreViewModel.fieldIsPresent(field: "id", value: userGoogle.id)
                                            if (!isPresent) {
                                                firestoreViewModel.addNewUser(user: userGoogle)
                                            }
                                            // authenticationViewModel.user = userGoogle
                                        } catch {
                                            print(error.localizedDescription)
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
                            .padding(10)
                            .background(.white)
                            .foregroundColor(.gray)
                            .cornerRadius(8)
                            .frame(height: 40)
                        }
                        
                        Button {
                            authenticationViewModel.loginFacebook() { result in
                                switch result {
                                case .success(let userFacebook):
                                    Task {
                                        do {
                                            let isPresent = try await firestoreViewModel.fieldIsPresent(field: "id", value: userFacebook.id)
                                            if (!isPresent) {
                                                firestoreViewModel.addNewUser(user: userFacebook)
                                            }
                                            authenticationViewModel.user = userFacebook
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                    
                                    /*firestoreViewModel.fieldIsPresent(field: "id", value: userFacebook.id) { result in
                                        switch result {
                                        case .success(let isPresent):
                                            if !isPresent  {
                                                firestoreViewModel.addNewUser(user: userFacebook)
                                            }
                                        case .failure(let error):
                                            print("Error finding document user: \(error)")
                                            return
                                        }
                                    }*/
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
                                .foregroundColor(.blue)
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
            }.foregroundColor(.white)
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(
                Color("oxfordBlue"),
                for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct signinView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView(authenticationViewModel: AuthenticationViewModel(),firestoreViewModel: FirestoreViewModel())
    }
}
