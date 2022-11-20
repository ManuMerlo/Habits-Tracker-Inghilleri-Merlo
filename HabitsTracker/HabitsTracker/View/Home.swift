//
//  Home.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 19/11/22.
//

import SwiftUI
import Firebase
import GoogleSignIn


struct Home: View {
    @AppStorage("log_status") var logStatus: Bool = true
    var body: some View {
        NavigationStack {
            Text("Signed In")
                .navigationTitle("Habits Tracker")
                .toolbar {
                    ToolbarItem {
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
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
