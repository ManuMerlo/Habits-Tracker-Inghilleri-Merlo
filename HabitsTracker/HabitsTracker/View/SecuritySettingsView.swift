import SwiftUI
import FirebaseAuth

struct SecuritySettingsView: View {
    
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State var width = UIScreen.main.bounds.width
    
    @State var expandEmail: Bool = false
    @State var expandPassword: Bool = false
    
    @State var showAlert: Bool = false
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    @State var messageError: String?
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Button(action: {
                        if expandEmail {
                            authenticationViewModel.textFieldEmail = ""
                            messageError = nil
                        }
                        withAnimation {
                            expandEmail.toggle()
                        }
                    }, label: {
                        HStack{
                            Text("Update Email")
                            Spacer()
                            Image(systemName: expandEmail ? "chevron.down": "chevron.up")
                        }
                    })
                }.listRowBackground(Color("oxfordBlue"))
                
                
                if expandEmail {
                    HStack{
                        VStack(spacing: 10){
                            CustomTextField(isSecure: false, hint: "Email", imageName: "envelope", text: $authenticationViewModel.textFieldEmail)
                            
                            Button("Submit") {
                                if !authenticationViewModel.textFieldEmail.isEmpty && authenticationViewModel.isValidEmail(email: authenticationViewModel.textFieldEmail) {
                                    Task {
                                        do {
                                            let emailIsPresent = try await firestoreViewModel.fieldIsPresent(field: "email", value: authenticationViewModel.textFieldEmail)
                                            if emailIsPresent {
                                                throw AuthenticationError.emailAlreadyExists
                                            }
                                            try await authenticationViewModel.updateEmail(email: authenticationViewModel.textFieldEmail)
                                            let uid = firestoreViewModel.firestoreUser?.id ?? ""
                                            firestoreViewModel.modifyUser(uid: uid, field: "email", value: authenticationViewModel.textFieldEmail)
                                            expandEmail.toggle()
                                            showAlert.toggle()
                                            alertTitle = "Success"
                                            alertMessage = "Email updated."
                                        } catch AuthenticationError.emailAlreadyExists {
                                            messageError = AuthenticationError.emailAlreadyExists.description
                                        } catch {
                                            showAlert.toggle()
                                            alertTitle = "Sensitive operation"
                                            alertMessage = "This operation is sensitive and requires recent authentication. Log in again before retrying this request."
                                        }
                                    }
                                    
                                } else {
                                    messageError = "Please insert a valid email."
                                }
                            }
                            .padding(10)
                            .background(.blue)
                            .cornerRadius(8)
                            
                            if let messageError = messageError {
                                Text(messageError)
                                    .font(.body)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }.listRowBackground(Color("delftBlue"))
                }
                
                HStack {
                    Button(action: {
                        if expandPassword {
                            authenticationViewModel.textFieldPassword = ""
                            messageError = nil
                        }
                        withAnimation{
                            expandPassword.toggle()
                        }
                    },label: {
                        HStack{
                            Text("Update Password")
                            Spacer()
                            Image(systemName: expandPassword ? "chevron.down": "chevron.up")
                        }
                    })
                }.listRowBackground(Color("oxfordBlue"))
                
                if expandPassword {
                    HStack {
                        VStack(spacing: 10) {
                            CustomTextField(isSecure: true, hint: "Password", imageName: "lock", text: $authenticationViewModel.textFieldPassword)
                            
                            Button("Submit") {
                                if !authenticationViewModel.textFieldPassword.isEmpty && !(authenticationViewModel.textFieldPassword.count < 6){
                                    Task {
                                        do {
                                            try await authenticationViewModel.updatePassword(password: authenticationViewModel.textFieldPassword)
                                            expandPassword.toggle()
                                            showAlert.toggle()
                                            alertTitle = "Success"
                                            alertMessage = "Password updated."
                                        } catch {
                                            showAlert.toggle()
                                            alertTitle = "Sensitive operation"
                                            alertMessage = "This operation is sensitive and requires recent authentication. Log in again before retrying this request."
                                        }
                                    }
                                }
                                else {
                                    messageError = "The password must be at least 6 characters long."
                                }
                            }
                            .padding(10)
                            .background(.blue)
                            .cornerRadius(8)
                            
                            if let messageError = messageError {
                                Text(messageError)
                                    .font(.body)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }.listRowBackground(Color("delftBlue"))
                }
            }.scrollContentBackground(.hidden)
            
        }.alert(alertTitle, isPresented: $showAlert) {} message: {
            Text(alertMessage)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.white.opacity(0.7))
        .background(RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500))
        .onAppear(){
            authenticationViewModel.clearAccountParameter()
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
        }
    }
    
}

struct SecuritySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SecuritySettingsView(authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
            .environmentObject(OrientationInfo())
    }
}

