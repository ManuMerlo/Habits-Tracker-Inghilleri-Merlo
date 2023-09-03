import SwiftUI
import FirebaseCore
import FacebookLogin

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// Configures third-party services (like Facebook and Firebase) during the app's launch.
    ///
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - launchOptions: A dictionary indicating the reason the app was launched (if any).
    /// - Returns: A Boolean value indicating whether the app launched successfully.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        return true
    }
}

// MARK: - HabitsTrackerApp

/// The main app entry point for HabitsTracker.
@main
struct HabitsTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authenticationViewModel = AuthenticationViewModel()
    @StateObject var healthViewModel = HealthViewModel()
    @StateObject var firestoreViewModel = FirestoreViewModel()
    
    /// Defines the main window of the app and its content.
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
