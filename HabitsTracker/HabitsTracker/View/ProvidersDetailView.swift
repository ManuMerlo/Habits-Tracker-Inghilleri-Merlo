import SwiftUI

struct ProvidersDetailView: View {
    
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State var expandVerificationWithEmailForm: Bool = false

    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State var width = UIScreen.main.bounds.width
    
    var body: some View {
        VStack{
            List{
                HStack{
                    Button(action:{
                        withAnimation{
                            self.expandVerificationWithEmailForm.toggle()
                        }
                    },label: {
                        HStack{
                            //Image(systemName: "envelope.fill")
                            Text("Connect with Email")
                            Spacer()
                            Image(systemName: self.expandVerificationWithEmailForm ? "chevron.down": "chevron.up")
                        }
                    })
                    .disabled(authenticationViewModel.isEmailandPasswordLinked())
                }.listRowBackground(Color("oxfordBlue"))
                
                if expandVerificationWithEmailForm {
                    HStack{
                        VStack(spacing: 5){
                            CustomTextField(isSecure: false, hint: "Email", imageName: "envelope", text: $authenticationViewModel.textFieldEmailProviders)
                            CustomTextField(isSecure:true, hint: "Password", imageName: "lock", text: $authenticationViewModel.textFieldPasswordProviders)
                            
                            Button("Accept"){
                                authenticationViewModel.linkEmailAndPassword()
                            }
                            .padding(10)
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            
                            if let messageError = authenticationViewModel.messageError {
                                Text(messageError)
                                    .font(.body)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }.listRowBackground(Color("delftBlue"))
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
                
            }
            .frame(width: isLandscape ? width/1.3 : width)
            .onAppear {
                authenticationViewModel.getCurrentProvider()
            }
            .alert(authenticationViewModel.isAccountLinked ? "Link successful" : "Error", isPresented: $authenticationViewModel.showAlert) {
                Button("Accept"){
                    print("Dismiss alert")
                    if authenticationViewModel.isAccountLinked{
                        expandVerificationWithEmailForm = false
                    }
                }
            } message: {
                Text(authenticationViewModel.isAccountLinked ? "Success" : "Error")
            }
            
            .scrollContentBackground(.hidden)
        }
        .accessibilityIdentifier("ProvidersVStack")
        .frame(maxWidth: .infinity)
        .foregroundColor(.white.opacity(0.7))
        .background(RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500))
        .onAppear(){
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
        }
    }
}

struct ProvidersDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProvidersDetailView(authenticationViewModel: AuthenticationViewModel())
            .environmentObject(OrientationInfo())
    }
}
