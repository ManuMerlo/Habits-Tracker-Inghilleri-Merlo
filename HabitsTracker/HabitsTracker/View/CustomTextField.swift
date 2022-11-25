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
    @Binding var text: String
    @FocusState var isEnabled: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if hint.lowercased().contains("password") {
                HStack{
                    if isSecure {
                        SecureField(hint, text: $text)
                            .textContentType(.password)
                            .focused($isEnabled)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.none)
                    }
                    else {
                        TextField(hint, text: $text)
                            .textContentType(.password)
                            .focused($isEnabled)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.none)
                    }
                    Button(action: {
                        isSecure.toggle()
                    }, label: {
                        Image(systemName: !isSecure ? "eye.slash" : "eye" ).foregroundColor(.black)
                        
                    })}
            } else {
                TextField(hint, text: $text)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .focused($isEnabled)
                    .autocorrectionDisabled(true).textInputAutocapitalization(.none)
            }
        }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
