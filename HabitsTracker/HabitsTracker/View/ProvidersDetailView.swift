//
//  ProvidersDetailView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 06/08/23.
//

import SwiftUI

struct ProvidersDetailView: View {
    
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    
    @State var expandVerificationWithEmailFrom : Bool = false
    @State var textFieldEmail: String = ""
    @State var textFieldPassword: String = ""
    
    
    var body: some View {
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
            
        }.task {
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

struct ProvidersDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProvidersDetailView(authenticationViewModel: AuthenticationViewModel())
    }
}
