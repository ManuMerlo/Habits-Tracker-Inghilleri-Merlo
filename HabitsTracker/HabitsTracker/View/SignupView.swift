import SwiftUI

struct SignupView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @State var isUsernamePresent: Bool = false
    
    //Responsiveness
    @EnvironmentObject var orientationInfo : OrientationInfo
    @State private var device : Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State private var isLandscape: Bool = false
    @State var height = UIScreen.main.bounds.height
    @State var width = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack{
            RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                .edgesIgnoringSafeArea(.all)
            
            if !isLandscape{
                ScrollView(.vertical, showsIndicators: false){
                    content()
                }.foregroundColor(.white)
            } else {
                HStack{
                    LottieView(filename: "register")
                        .clipShape(Circle())
                        .shadow(color: .orange, radius: 1, x: 0, y: 0)
                        .frame(maxWidth: width/3)
                    
                    ScrollView(.vertical, showsIndicators: false){
                        content()
                    }.foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: device == .iPad ? true : false)
                }
            }
        }
        .onAppear(){
            isLandscape = orientationInfo.orientation == .landscape
            height =  UIScreen.main.bounds.height
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            height =  UIScreen.main.bounds.height
            width = UIScreen.main.bounds.width
        }
        .foregroundColor(.white)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(
            Color("oxfordBlue"),
            for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    @ViewBuilder
    func content() -> some View {
        VStack(alignment: .center, spacing: 15) {

            if !isLandscape{
                LottieView(filename: "register")
                    .frame(width:width, height: height/3)
                    .clipShape(Circle())
                    .shadow(color: .orange, radius: 1, x: 0, y: 0)
            }
            
            Text("Create New Account")
                .font(.title)
                .multilineTextAlignment(.center)
                .fontWeight(.semibold)
                .lineSpacing(10)
            
            Group{
                
                CustomTextField(isSecure: false, hint: "Username", imageName: "person", text: $authenticationViewModel.textFieldUsername)
                
                CustomTextField(isSecure: false, hint: "Email", imageName:"envelope", text: $authenticationViewModel.textFieldEmail)
                
                CustomTextField(isSecure:true, hint: "Password", imageName: "lock", text: $authenticationViewModel.textFieldPassword)
                
                CustomTextField(isSecure:true,hint: "Repeat password", imageName: "lock",text: $authenticationViewModel.repeatPassword)
                
            }.frame(width: getMaxWidth())
            
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
                        
                        Task {
                            do {
                                let emailIsPresent = try await firestoreViewModel.fieldIsPresent(field: "email", value: authenticationViewModel.textFieldEmail)
                                if emailIsPresent {
                                    throw AuthenticationError.emailAlreadyExists
                                }
                                let usernameIsPresent = try await firestoreViewModel.fieldIsPresent(field: "username", value: authenticationViewModel.textFieldUsername)
                                if usernameIsPresent {
                                    throw AuthenticationError.usernameAlreadyExists
                                }
                                var user = try await authenticationViewModel.createNewUser()
                                print("Success, user created with email and password")
                                user.setUsername(name: authenticationViewModel.textFieldUsername)
                                firestoreViewModel.addNewUser(user: user)
                                print("Success, user added to firestore")
                            } catch ViewError.usernameEmailPasswordNotFound {
                                authenticationViewModel.messageError = ViewError.usernameEmailPasswordNotFound.description
                            } catch AuthenticationError.emailAlreadyExists {
                                authenticationViewModel.messageError = AuthenticationError.emailAlreadyExists.description
                            } catch AuthenticationError.usernameAlreadyExists {
                                authenticationViewModel.messageError = AuthenticationError.usernameAlreadyExists.description
                            } catch {
                                authenticationViewModel.messageError = "Failed to create the account. Retry."
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
                
            }
            
            if let messageError = authenticationViewModel.messageError {
                Text(messageError)
                    .font(.body)
                    .foregroundColor(.red)
                    .padding()
            }
            
        }.onAppear{
            authenticationViewModel.clearSignUpParameter()
        }.padding(.vertical, isLandscape ? 20 : 0)
    }
    
    func getMaxWidth() -> CGFloat{
        if device == .iPad {
            if isLandscape {
                return width / 2.5
            } else {
                return width / 1.8
            }
        } else if device == .iPhone {
            if isLandscape {
                return width/2.2
            } else {
                return width/1.2
            }
        }
        return width
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
            .environmentObject(OrientationInfo())
    }
}
