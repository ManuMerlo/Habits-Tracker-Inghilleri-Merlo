import SwiftUI
import FirebaseCore
import FacebookLogin
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // BACKGROUND TASK PROPERTIES:
       static let bgAppTaskId = "polimi.HabitsTrackerApp.background.task"
       var bgTask: BGAppRefreshTask?
       lazy var bgExpirationHandler = {{
           if let task = self.bgTask {
               task.setTaskCompleted(success: true)
           }
       }}()
    
        func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        registerBackgroundTask()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleFirebasePostTask(minutes: 10) // set intial request .
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
