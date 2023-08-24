import SwiftUI

struct ProvidersDetailView: View {
    
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    
    @State var expandVerificationWithEmailFrom : Bool = false
    @State var textFieldEmail: String = ""
    @State var textFieldPassword: String = ""
    
    
    var body: some View {
        VStack{
            List{
                HStack{
                    Button(action:{
                        withAnimation{
                            self.expandVerificationWithEmailFrom.toggle()
                        }
                    },label: {
                        HStack{
                            //Image(systemName: "envelope.fill")
                            Text("Connect with Email")
                            Spacer()
                            Image(systemName: self.expandVerificationWithEmailFrom ? "chevron.down": "chevron.up")
                        }
                    })
                    .disabled(authenticationViewModel.isEmailandPasswordLinked())
                }.listRowBackground(Color("oxfordBlue"))
                
                if expandVerificationWithEmailFrom {
                    Group{
                        TextField("Insert email", text:$textFieldEmail)
                        SecureField("Insert password", text:$textFieldPassword)
                        Button("Accept"){
                            authenticationViewModel.linkEmailAndPassword(email: textFieldEmail, password: textFieldPassword)
                        }
                        .padding(5)
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        
                        if let messageError = authenticationViewModel.messageError {
                            Text(messageError)
                                .font(.body)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
                
                Button{
                    authenticationViewModel.linkFacebook()
                } label: {
                    Text("Connect with Facebook")
                }.disabled(authenticationViewModel.isFacebookLinked())
                    .listRowBackground(Color("oxfordBlue"))
                    .listRowSeparatorTint(.white.opacity(0.7))
                
                Button{
                    authenticationViewModel.linkGoogle()
                } label: {
                    Text("Connect with Google")
                }.disabled(authenticationViewModel.isGoogleLinked())
                    .listRowBackground(Color("oxfordBlue"))
                    .listRowSeparatorTint(.white.opacity(0.7))
                
            }.onAppear {
                authenticationViewModel.getCurrentProvider()
            }
            .alert(authenticationViewModel.isAccountLinked ? "Link successful" : "Error", isPresented: $authenticationViewModel.showAlert) {
                Button("Accept"){
                    print("Dismiss alert")
                    if authenticationViewModel.isAccountLinked{
                        expandVerificationWithEmailFrom = false
                    }
                }
            } message: {
                Text(authenticationViewModel.isAccountLinked ? "Success" : "Error")
            }
            
            .scrollContentBackground(.hidden)
        }
        .foregroundColor(.white.opacity(0.7))
        .background(RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500).opacity(0.97))
    }
}

struct ProvidersDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProvidersDetailView(authenticationViewModel: AuthenticationViewModel())
    }
}
