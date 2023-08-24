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
    @StateObject var authenticationViewModel = AuthenticationViewModel()
    @StateObject var healthViewModel = HealthViewModel()
    @StateObject var firestoreViewModel = FirestoreViewModel()
    
    var body: some Scene {
        WindowGroup {
            if let _ = authenticationViewModel.user {
                GeneralView(healthViewModel: healthViewModel, authenticationViewModel: authenticationViewModel, firestoreViewModel: firestoreViewModel).environmentObject(OrientationInfo())
            } else {
                IntroView(healthViewModel: healthViewModel, authenticationViewModel:authenticationViewModel, firestoreViewModel: firestoreViewModel).environmentObject(OrientationInfo())
            }
        }
    }
}
