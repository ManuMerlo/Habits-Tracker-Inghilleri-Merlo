//
//  Signin.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 19/11/22.
//

import SwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift

struct SigninView: View {
    @StateObject private var signinViewModel = SigninViewModel()
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false){
            
            VStack(alignment: .center,
                   spacing: 17.0) {
                
                Image(systemName: "figure.run.square.stack.fill")
                    .font(.system(size:50))
                
                (Text("Welcome") +
                 Text(signinViewModel.register ? "\nSign up to start" :"\nSign in to continue")
                ).font(.title)
                    .multilineTextAlignment(.center)
                    .fontWeight(.semibold)
                    .lineSpacing(10)
                    .padding(.top,20)
                
                // MARK: Custom TextField
                CustomTextField(hint: "Email", text: $signinViewModel.emailAddress)
                    .padding(.top,50)
                CustomTextField(hint: "Password", text: $signinViewModel.password)
                    .padding(.top,20)
                
                Button{
                    guard !signinViewModel.emailAddress.isEmpty, !signinViewModel.password.isEmpty else {
                        print("Empty email or password")
                        return
                    }
                    signinViewModel.sign(emailAddress: signinViewModel.emailAddress, password: signinViewModel.password)
                } label: {
                    HStack(spacing: 15) {
                        Text(signinViewModel.register ? "Sign up": "Sign in")
                            .fontWeight(.semibold)
                            .contentTransition(.identity)
                        Image(systemName: "line.diagonal.arrow")
                            .font(.title3)
                            .rotationEffect(.init(degrees: 45))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal,25)
                    .padding(.vertical)
                    .background{
                        RoundedRectangle(cornerRadius: 10,style: .continuous).fill(.black.opacity(0.05))
                    }
                }
                .padding(.top,40)
                
                Text("(OR)").foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top,30)
                    .padding(.bottom,25)
                
            //MARK: Custom Google Sign in Button
                if !signinViewModel.register {
                    CustomButton()
                        .overlay {
                            if let clientID = FirebaseApp.app()?.options.clientID {
                                GoogleSignInButton {
                                    GIDSignIn.sharedInstance.signIn(with: .init(clientID: clientID), presenting: UIApplication.shared.rootController()) {user, err in
                                        if let error = err {
                                            print(error.localizedDescription)
                                            return
                                        }
                                        //MARK: Logging Google User into Firebase
                                        if let user {
                                            signinViewModel.logGoogleUser(user: user)
                                        }
                                    }
                                }
                                .blendMode(.overlay)
                            }
                        }
                        .clipped()
                }
                
                //TODO: Non so se è meglio usare qualcos'altro invece di un button (tipo navigationlink)
                Button(signinViewModel.register ? "Return to signin page" : "Not already have an account? Sign up Now!") {
                    withAnimation(.easeInOut){
                        signinViewModel.register.toggle()
                    }
                }.font(.subheadline).padding(.horizontal)
                
            }
                   .padding(.horizontal, 50)
                   .padding(.vertical,25)
        }
        .alert(signinViewModel.errorMessage, isPresented: $signinViewModel.showError) {
        }
    }
    
    @ViewBuilder
    func CustomButton() -> some View {
        HStack{
            Image("googlelogo").resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .frame(height: 45)
            Text("Continue with Google")
                .font(.callout)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal,15)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}

struct signinView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
