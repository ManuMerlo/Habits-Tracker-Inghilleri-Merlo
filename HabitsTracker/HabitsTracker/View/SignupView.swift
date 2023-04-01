//
//  SignupView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 25/11/22.
//

import SwiftUI

struct SignupView: View {
    // @StateObject private var signinViewModel = SigninViewModel()
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State var textfieldUsername: String = ""
    @State var textFieldEmail: String = ""
    @State var textFieldPassword: String = ""
    @State var repeatPassword: String = "" // Togliere State o mettere nel viewmodel?
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            
            VStack(alignment: .center, spacing: 15) {
                ZStack{
                    LottieView(filename: "register")
                        .frame(width:330, height: 280)
                        .clipShape(Circle())
                        .shadow(color: .orange, radius: 1, x: 0, y: 0)
                }
                
                Text("Create New Account")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .fontWeight(.semibold)
                    .lineSpacing(10)
                    .padding(.bottom, 10)
                    .offset(y: -4)
                
                HStack {
                    Image(systemName: "person")
                    CustomTextField(isSecure: false, hint: "username", text: $textfieldUsername)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius:10).stroke(lineWidth: 2))
                
                HStack {
                    Image(systemName: "envelope")
                    CustomTextField(isSecure: false,hint: "email", text: $textFieldEmail)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
                
                HStack {
                    Image(systemName: "lock")
                    CustomTextField(isSecure:true,hint: "password", text: $textFieldPassword)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
                HStack {
                    Image(systemName: "lock")
                    CustomTextField(isSecure:true,hint: "repeat password", text: $repeatPassword)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
                Button {
                    // Maybe these checks are not necessary
                    guard !textFieldEmail.isEmpty, !textFieldPassword.isEmpty else {
                        print("Empty email or password")
                        return
                    }
                    guard textFieldPassword == repeatPassword else {
                        print("Passwords do not match")
                        return
                    }
                    authenticationViewModel.createNewUser(email: textFieldEmail,
                                                          password: textFieldPassword)
                    // TODO: manage the username
                } label: {
                    HStack() {
                        Text("Sign up")
                            .fontWeight(.semibold)
                            .contentTransition(.identity)
                        
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal,25)
                    .padding(.vertical)
                    .background{
                        RoundedRectangle(cornerRadius: 10,style: .continuous).fill(.black.opacity(0.05))
                    }
                }
                .padding(.top,20)
                if let messageError = authenticationViewModel.messageError {
                    Text(messageError)
                        .font(.body)
                        .foregroundColor(.red)
                        .padding()
                }
                
            }
                   .padding(.horizontal, 50)
                   .padding(.vertical,25)
        }
        /*.alert(signinViewModel.errorMessage, isPresented: $signinViewModel.showError) {
        }*/
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(authenticationViewModel: AuthenticationViewModel())
    }
}
