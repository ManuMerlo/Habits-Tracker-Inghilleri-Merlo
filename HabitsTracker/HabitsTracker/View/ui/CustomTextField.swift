//
//  CustomTextField.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 19/11/22.
//

import SwiftUI

struct CustomTextField: View {
    @State var isSecure : Bool
    var hint: String
    var imageName: String
    @Binding var text: String
    @FocusState var isEnabled: Bool
    var body: some View {
        HStack {
            Image(systemName: imageName)
            VStack(alignment: .leading, spacing: 15) {
                if hint.lowercased().contains("password") {
                    HStack{
                        if isSecure {
                            SecureField(hint, text: $text)
                                .foregroundColor(.white)
                                .textContentType(.oneTimeCode)
                                .focused($isEnabled)
                                .autocorrectionDisabled(true)
                                .autocapitalization(.none)
                        }
                        else {
                            TextField(hint, text: $text)
                                .foregroundColor(.white)
                                .textContentType(.oneTimeCode)
                                .focused($isEnabled)
                                .autocorrectionDisabled(true)
                                .autocapitalization(.none)
                        }
                        Button(action: {
                            isSecure.toggle()
                        }, label: {
                            Image(systemName: !isSecure ? "eye.slash" : "eye" )
                            
                        })}
                } else {
                    TextField(hint, text: $text)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .focused($isEnabled)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)

                }
            }
        }
        .preferredColorScheme(.dark)
        .padding()
        .frame(height: 45)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1.25))
    }
}


struct customTextField_Previews: PreviewProvider {
    @State static var text: String = ""

    static var previews: some View {
        CustomTextField(isSecure: false, hint: "email", imageName: "envelope", text: $text)
    }
}

