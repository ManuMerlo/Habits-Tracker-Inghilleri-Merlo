//
//  CustomTextField.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 19/11/22.
//

import SwiftUI

struct CustomTextField: View {
    var hint: String
    @Binding var text: String
    //MARK: View Properties
    @FocusState var isEnabled: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if(hint == "Password") {
                SecureField(hint, text: $text)
                    .textContentType(.password)
                    .focused($isEnabled).autocorrectionDisabled(true).textInputAutocapitalization(.none)
            } else {
                TextField(hint, text: $text)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .focused($isEnabled).autocorrectionDisabled(true).textInputAutocapitalization(.none)
            }
            ZStack(alignment: .leading){
                Rectangle()
                    .fill(.black.opacity(0.2))
                
                Rectangle()
                    .fill(.black)
                    .frame(width: isEnabled ? nil : 0, alignment: .leading)
                    .animation(.easeInOut(duration: 0.3), value: isEnabled)
            }
            .frame(height: 2)
        }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
