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
    @State var showLoginAgainAlert: Bool = false
    @State var showSuccessAlert: Bool = false
    
    @State var messageErrorEmail: String?
    @State var messageErrorPassword: String?
    
    var body: some View {
        VStack{
            List{
                HStack{
                    Button(action:{
                        if self.expandEmail{
                            authenticationViewModel.textFieldEmail = ""
                        }
                        withAnimation{
                            self.expandEmail.toggle()
                        }
                    },label: {
                        HStack{
                            Text("Update Email")
                            Spacer()
                            Image(systemName: self.expandEmail ? "chevron.down": "chevron.up")
                        }
                    })
                }.listRowBackground(Color("oxfordBlue"))
                
                
                if expandEmail{
                    HStack{
                        VStack(spacing: 10){
                            CustomTextField(isSecure: false, hint: "Email", imageName: "envelope", text: $authenticationViewModel.textFieldEmail)
                            
                            Button("Submit"){
                                if !authenticationViewModel.textFieldEmail.isEmpty {
                                    Task {
                                        do {
                                            try await authenticationViewModel.updateEmail(email: authenticationViewModel.textFieldEmail)
                                            let uid = firestoreViewModel.firestoreUser?.id ?? ""
                                            firestoreViewModel.modifyUser(uid: uid, field: "email", value: authenticationViewModel.textFieldEmail)
                                            expandEmail.toggle()
                                            showSuccessAlert.toggle()
                                        } catch {
                                            // TO DO: Make a custom error
                                            if let error = error as? URLError, error.code == .badServerResponse {
                                                showLoginAgainAlert = true
                                            }
                                            print("Error: \(error.localizedDescription)")
                                        }
                                    }
                                    
                                } else {
                                    messageErrorEmail = "Email can't be empty"
                                }
                            }
                            .padding(10)
                            .background(.blue)
                            .cornerRadius(8)
                            
                            if let messageError = messageErrorEmail {
                                Text(messageError)
                                    .font(.body)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }.listRowBackground(Color("delftBlue"))
                }
                
                HStack{
                    Button(action:{
                        if self.expandPassword{
                            authenticationViewModel.textFieldPassword = ""
                        }
                        withAnimation{
                            self.expandPassword.toggle()
                        }
                    },label: {
                        HStack{
                            Text("Update Password")
                            Spacer()
                            Image(systemName: self.expandEmail ? "chevron.down": "chevron.up")
                        }
                    })
                }.listRowBackground(Color("oxfordBlue"))
                
                if expandPassword{
                    HStack{
                        VStack(spacing: 10){
                            CustomTextField(isSecure: true, hint: "Password", imageName: "lock", text: $authenticationViewModel.textFieldPassword)
                            
                            Button("Submit"){
                                if !authenticationViewModel.textFieldPassword.isEmpty{
                                    Task {
                                        do {
                                            try await authenticationViewModel.updatePassword(password: authenticationViewModel.textFieldPassword)
                                            expandPassword.toggle()
                                            showSuccessAlert.toggle()
                                            
                                            
                                        } catch {
                                            if let error = error as? URLError, error.code == .badServerResponse {
                                                showLoginAgainAlert = true
                                            }
                                        }
                                    }
                                }
                                else {
                                    messageErrorPassword = "Password can't be empty"
                                }
                            }
                            
                            .padding(10)
                            .background(.blue)
                            .cornerRadius(8)
                            
                            if let messageError = messageErrorPassword {
                                Text(messageError)
                                    .font(.body)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }.listRowBackground(Color("delftBlue"))
                }
            }.scrollContentBackground(.hidden)
            
        }.alert("Sensitive operation", isPresented: $showLoginAgainAlert) {
            Button("Ok"){
                print("Dismiss alert")
                showLoginAgainAlert.toggle()  //TODO: forse si può togliere
            }
        } message: {
            Text("This operation is sensitive and requires recent authentication. Log in again before retrying this request.")
        }
        .alert("Successfull update", isPresented: $showSuccessAlert) {
            Button("Ok")
            {
                print("Dismiss alert")
            }
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

