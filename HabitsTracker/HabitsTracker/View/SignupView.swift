import SwiftUI

struct SignupView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @State var isUsernamePresent: Bool = false
    
    var body: some View {
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
                            if(isPresent){
                                authenticationViewModel.messageError = "The email is already present in the database"
                                return
                            }
                        case .failure(_):
                            authenticationViewModel.messageError = "Error while checking existing email"
                            
                        }
                    }
                    
                    firestoreViewModel.fieldIsPresent(field : "username", value: authenticationViewModel.textFieldUsername) { result in
                        switch result {
                        case .success(let isPresent):
                            if(!isPresent){
                                authenticationViewModel.createNewUser(email: authenticationViewModel.textFieldEmail, password: authenticationViewModel.textFieldPassword) { result in
                                    switch result {
                                    case .success(var user):
                                        user.setUsername(name: authenticationViewModel.textFieldUsername)
                                        firestoreViewModel.addNewUser(user: user)
                                    case .failure(let error):
                                        print("Error creating new user: \(error)")
                                        return
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
                    HStack() {
                        Text("Sign up")
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
                .padding(.top,20)
                
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
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
    }
}
