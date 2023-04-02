//
//  HabitsTrackerApp.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 19/11/22.
//

import SwiftUI
import FirebaseCore
import FacebookLogin

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        return true
    }
}

@main
struct HabitsTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authenticationViewModel = AuthenticationViewModel() // Here authenticationViewModel is a @StateObject instead in the others view is only an @ObservedObject. For more details see (*1)
    @StateObject var healthViewModel = HealthViewModel()
    var body: some Scene {
        WindowGroup {
            if let _ = authenticationViewModel.user {
                GeneralView(healthViewModel: healthViewModel, authenticationViewModel: authenticationViewModel)
            } else {
                IntroView(healthViewModel: healthViewModel, authenticationViewModel: authenticationViewModel)
            }
        }
    }
}
