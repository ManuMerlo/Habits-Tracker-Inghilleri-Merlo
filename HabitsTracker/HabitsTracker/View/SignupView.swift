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
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    
    
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
                
                
                CustomTextField(isSecure: false, hint: "username", imageName: "person", text: $authenticationViewModel.textfieldUsername)
                
                CustomTextField(isSecure: false, hint: "email", imageName:"envelope", text: $authenticationViewModel.textFieldEmail)
                
                CustomTextField(isSecure:true, hint: "password", imageName: "lock", text: $authenticationViewModel.textFieldPassword)
                
                CustomTextField(isSecure:true,hint: "repeat password", imageName: "lock",text: $authenticationViewModel.repeatPassword)
                
                Button {
                    // Maybe these checks are not necessary
                    guard !authenticationViewModel.textFieldEmail.isEmpty, !authenticationViewModel.textFieldPassword.isEmpty else {
                        print("Empty email or password")
                        return
                    }
                    guard authenticationViewModel.textFieldPassword == authenticationViewModel.repeatPassword else {
                        print("Passwords do not match")
                        return
                    }
                    authenticationViewModel.createNewUser(email: authenticationViewModel.textFieldEmail, password: authenticationViewModel.textFieldPassword) { result in
                        
                        switch result {
                        case .success(let user):
                            firestoreViewModel.addNewUser(user: user)
                        case .failure(let error):
                            print("Error creating new user: \(error)")
                            return
                        }
                    }
                    
                    
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
        SignupView(authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
    }
}
