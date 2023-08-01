//
//  SettingsView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 20/11/22.
//

import SwiftUI
import Firebase


struct SettingsView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State var expandVerificationWithEmailFrom : Bool = false
    @State var textFieldEmail: String = ""
    @State var textFieldPassword: String = ""
    // private var userViewModel = UserViewModel()
    
    var body: some View {
        VStack {
            Image("Avatar 1")
                .resizable()
                .frame(width: 120, height: 120)
                .mask(Circle())
            
            Text("Username").font(.title)
            
            List {
                Section(header: Text("Providers")){
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
                    }
                    
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
                    
                    Button{
                        authenticationViewModel.linkGoogle()
                    } label: {
                        Text("Connect with Google")
                    }.disabled(authenticationViewModel.isGoogleLinked())
                    
                }
                Button("Delete Account") {
                    //TODO: delete account
                    // userViewModel.logout(delete: true)
                }.foregroundColor(Color.red)
                
                Button("Logout") {
                    authenticationViewModel.logout()
                }
            }.padding(.top, 15.0)
                .task {
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
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(authenticationViewModel: AuthenticationViewModel())
    }
}
