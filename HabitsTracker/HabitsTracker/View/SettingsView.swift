//
//  SettingsView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 20/11/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct SettingsView: View {
    @AppStorage("log_status") var logStatus: Bool = true
    var body: some View {
        VStack (alignment: .center){
            Text("Info Account")
            
            Button("Logout") {
                try? Auth.auth().signOut()
                GIDSignIn.sharedInstance.signOut()
                withAnimation(.easeInOut) {
                    logStatus = false
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
