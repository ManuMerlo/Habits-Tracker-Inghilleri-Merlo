//
//  SettingsView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 20/11/22.
//

import SwiftUI
import Firebase


struct SettingsView: View {
    private var userViewModel = UserViewModel()
    var body: some View {
        VStack {
            Image("Avatar 1")
                .resizable()
                .frame(width: 120, height: 120)
            .mask(Circle())
            
            Text("Username").font(.title)
            
            List {
                Button("Delete Account") {
                    userViewModel.logout(delete: true)
                }.foregroundColor(Color.red)
                
                Button("Logout") {
                    userViewModel.logout(delete: false)
                }
            }
        }.padding(.top, 15.0)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
