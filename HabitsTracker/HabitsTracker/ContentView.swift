//
//  ContentView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 19/11/22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    var body: some View {
        if logStatus {
            Home()
        } else {
            Signin()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
