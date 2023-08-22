import SwiftUI

struct SigninView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel // // Here authenticationViewModel is a @ObservedObject instead in HabitsTrackerApp is a @StateObject. For more details see (*1)
    @ObservedObject var firestoreViewModel : FirestoreViewModel
    
    
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
                        content().padding(.vertical,20)
                    }.foregroundColor(.white)
                } else {
                    HStack{
                        LottieView(filename: "login")
                            .clipShape(Circle())
                            .shadow(color: .orange, radius: 1, x: 0, y: 0)
                            .padding(.top,10)
                            .frame(maxWidth: width/3)
                        
                        ScrollView(.vertical, showsIndicators: false){
                            content().padding(.vertical,50)
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
        
        VStack(alignment: .center, spacing: 17) {
            
            if !isLandscape{
                LottieView(filename: "login")
                    .frame(width:width, height: height/3)
                    .clipShape(Circle())
                    .shadow(color: .orange, radius: 1, x: 0, y: 0)
                    .padding(.top,10)
            }
            Group {
                
                Text("Sign in")
                    .font(.title)
                    .fontWeight(.semibold)
                    .offset(y: -12)
                
                CustomTextField(isSecure: false, hint: "Email", imageName: "envelope", text: $authenticationViewModel.textFieldEmailSignin)
                    .frame(width: getMaxWidth())
                
                CustomTextField(isSecure:true, hint: "Password", imageName: "lock", text: $authenticationViewModel.textFieldPasswordSignin)
                    .frame(width: getMaxWidth())
                
                
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
                }.frame(width: getMaxWidth())
                
                
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
                    .padding(10)
                    .background(.white)
                    .foregroundColor(.gray)
                    .cornerRadius(8)
                    .frame(height: 40)
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
