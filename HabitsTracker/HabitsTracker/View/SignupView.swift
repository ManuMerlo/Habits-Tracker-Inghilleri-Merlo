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
                    content().padding(.vertical,20)
                }.foregroundColor(.white)
            } else {
                HStack{
                    LottieView(filename: "register")
                        .clipShape(Circle())
                        .shadow(color: .orange, radius: 1, x: 0, y: 0)
                        .padding(.top,10)
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
                    .padding(.top,10)
            }
            
            Text("Create New Account")
                .font(.title)
                .multilineTextAlignment(.center)
                .fontWeight(.semibold)
                .lineSpacing(10)
                .padding(.bottom, 10)
                .offset(y: -4)
            
            Group{
                
                CustomTextField(isSecure: false, hint: "username", imageName: "person", text: $authenticationViewModel.textFieldUsername)
                
                CustomTextField(isSecure: false, hint: "email", imageName:"envelope", text: $authenticationViewModel.textFieldEmail)
                
                CustomTextField(isSecure:true, hint: "password", imageName: "lock", text: $authenticationViewModel.textFieldPassword)
                
                CustomTextField(isSecure:true,hint: "repeat password", imageName: "lock",text: $authenticationViewModel.repeatPassword)
                
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
                    Text("Sign up")
                        .font(.system(size:22))
                        .fontWeight(.semibold)
                        .frame(width: 120, height: 45)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .contentTransition(.identity)
                
            }.padding(.top,10)
            
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
