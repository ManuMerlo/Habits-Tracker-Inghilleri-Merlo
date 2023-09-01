import SwiftUI

struct SigninView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var device : Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State private var isLandscape: Bool = false
    @State var height = UIScreen.main.bounds.height
    @State var width = UIScreen.main.bounds.width
    
    
    var body: some View {
        NavigationStack{
            ZStack{
                RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                    .edgesIgnoringSafeArea(.all)
                
                if !isLandscape{
                    ScrollView(.vertical, showsIndicators: false){
                        content()
                    }.foregroundColor(.white)
                } else {
                    HStack{
                        LottieView(filename: "login")
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
                LottieView(filename: "login")
                    .frame(width:width, height: height/3)
                    .clipShape(Circle())
                    .shadow(color: .orange, radius: 1, x: 0, y: 0)
            }
            Group {
                
                Text("Sign in")
                    .font(.title)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("SignInTitle")
                
                CustomTextField(isSecure: false, hint: "Email", imageName: "envelope", text: $authenticationViewModel.textFieldEmailSignin)
                    .frame(width: getMaxWidth())
                    .accessibilityIdentifier("SignInEmail")
                
                CustomTextField(isSecure:true, hint: "Password", imageName: "lock", text: $authenticationViewModel.textFieldPasswordSignin)
                    .frame(width: getMaxWidth())
                    .accessibilityIdentifier("SignInPassword")
                
                if let messageError = authenticationViewModel.messageError {
                    Text(messageError)
                        .font(.body)
                        .foregroundColor(.red)
                        .accessibilityIdentifier("MessageErrorSignIn")
                }
                
                NavigationLink {
                    //TODO recupera password
                } label: {
                    Text("Forgot the password?")
                }
                
                Button {
                    guard authenticationViewModel.isValidEmail(email: authenticationViewModel.textFieldEmailSignin), !authenticationViewModel.textFieldPasswordSignin.isEmpty else {
                        authenticationViewModel.messageError = "Empty email or password"
                        return
                    }
                    authenticationViewModel.login()
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
                }
            }
            
            Group {
                HStack(spacing: 20){
                    VStack{
                        Divider()
                            .background(Color.gray)
                    }
                    Text("or")
                        .foregroundColor(Color.white)
                    VStack {
                        Divider().background(Color.white)
                    }
                }.frame(width: getMaxWidth())
                
                
                Button {
                    Task {
                        do {
                            let userGoogle = try await authenticationViewModel.loginGoogle()
                            let isPresent = try await firestoreViewModel.fieldIsPresent(field: "id", value: userGoogle.id)
                            if (!isPresent) {
                                firestoreViewModel.addNewUser(user: userGoogle)
                            }
                        } catch {
                            authenticationViewModel.messageError = "Failed sign in with Google. Retry."
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
                    Task {
                        do {
                            let userFacebook = try await authenticationViewModel.loginFacebook()
                            let isPresent = try await firestoreViewModel.fieldIsPresent(field: "id", value: userFacebook.id)
                            if (!isPresent) {
                                firestoreViewModel.addNewUser(user: userFacebook)
                            }
                        } catch {
                            authenticationViewModel.messageError = "Failed sign in with Facebook. Retry."
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
                    .padding(10)
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
                }.accessibilityIdentifier("navigationLinkSignUp")
            }
            
        }
        .padding(.top, isLandscape ? 20 : 0)
        .onAppear{
            authenticationViewModel.clearSignInParameter()
        }
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

struct signinView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView(authenticationViewModel: AuthenticationViewModel(),firestoreViewModel: FirestoreViewModel())
            .environmentObject(OrientationInfo())
    }
}
