import SwiftUI

struct SignupView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @State var isUsernamePresent: Bool = false
    
    var body: some View {
        ZStack{
            RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false){
                
                VStack(alignment: .center, spacing: 15) {
                    
                    ZStack{
                        LottieView(filename: "register")
                            .frame(width:330, height: 280)
                            .clipShape(Circle())
                            .shadow(color: .orange, radius: 1, x: 0, y: 0)
                    }
                    
                    Text("Create New Account")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .fontWeight(.semibold)
                        .lineSpacing(10)
                        .padding(.bottom, 10)
                        .offset(y: -4)
                    
                    CustomTextField(isSecure: false, hint: "username", imageName: "person", text: $authenticationViewModel.textFieldUsername)
                    
                    CustomTextField(isSecure: false, hint: "email", imageName:"envelope", text: $authenticationViewModel.textFieldEmail)
                    
                    CustomTextField(isSecure:true, hint: "password", imageName: "lock", text: $authenticationViewModel.textFieldPassword)
                    
                    CustomTextField(isSecure:true,hint: "repeat password", imageName: "lock",text: $authenticationViewModel.repeatPassword)
                    
                    Button {
                        // Maybe these checks are not necessary
                        guard authenticationViewModel.isValidEmail(email: authenticationViewModel.textFieldEmail), !authenticationViewModel.textFieldPassword.isEmpty, !authenticationViewModel.repeatPassword.isEmpty else {
                            authenticationViewModel.messageError = "Not valid email or empty password"
                            return
                        }
                        guard authenticationViewModel.textFieldPassword == authenticationViewModel.repeatPassword else {
                            authenticationViewModel.messageError =  "Passwords do not match"
                            return
                        }
                        
                        guard !authenticationViewModel.textFieldUsername.isEmpty else {
                            authenticationViewModel.messageError =  "Username is empty"
                            return
                        }
                        
                        firestoreViewModel.fieldIsPresent(field: "email", value: authenticationViewModel.textFieldEmail) { result in
                            switch result {
                            case .success(let isPresent):
                                if(isPresent) {
                                    authenticationViewModel.messageError = "The email is already present in the database"
                                    return
                                }
                            case .failure(_):
                                authenticationViewModel.messageError = "Error while checking existing email"
                            }
                        }
                        
                        firestoreViewModel.fieldIsPresent(field: "username", value: authenticationViewModel.textFieldUsername) { result in
                            switch result {
                            case .success(let isPresent):
                                if(!isPresent) {
                                    Task {
                                        do {
                                            var user = try await authenticationViewModel.createNewUser()
                                            print("Success, user created with email and password")
                                            user.setUsername(name: authenticationViewModel.textFieldUsername)
                                            firestoreViewModel.addNewUser(user: user)
                                            print("Success, user added to firestore")
                                        } catch{
                                            print("Error: \(error.localizedDescription)")
                                        }
                                    }
                                } else {
                                    authenticationViewModel.messageError = "The username is not available"
                                }
                            case .failure(let error):
                                print("\(error)")
                            }
                        }
                        
                    } label: {
                        Text("Sign up")
                            .font(.system(size:22))
                            .fontWeight(.semibold)
                            .frame(width: 120, height: 45)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .contentTransition(.identity)
                        
                    }.padding(.top,20)
                    
                    if let messageError = authenticationViewModel.messageError {
                        Text(messageError)
                            .font(.body)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                }.onAppear{
                    authenticationViewModel.clearSignUpParameter()
                }
                .padding(.horizontal, 50)
                .padding(.vertical,25)
            }
        }
        .foregroundColor(.white)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(
            Color("oxfordBlue"),
            for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
    }
}
