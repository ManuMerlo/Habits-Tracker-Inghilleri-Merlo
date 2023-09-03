import SwiftUI

struct CustomTextField: View {
    @State var isSecure: Bool
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
                        }).buttonStyle(PlainButtonStyle())
                        
                    }
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
        .background(.gray.opacity(0.2))
        .cornerRadius(8)
    }
}


struct customTextField_Previews: PreviewProvider {
    @State static var text: String = ""

    static var previews: some View {
        CustomTextField(isSecure: false, hint: "email", imageName: "envelope", text: $text)
    }
}

