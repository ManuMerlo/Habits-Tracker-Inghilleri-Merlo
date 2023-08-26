import BackgroundTasks

extension AppDelegate {

    // MARK - DEBUGGING BG TASK IN XCODE DEBUGGER:

    //////////////////////////////////////////////////////////////////
    // Simulate a background task:
    // Run the app, and after the app loads, use the XCode pause button
    // to pause the running of the app.
    // Copy the following into the XCode debugger:
    // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"polimi.HabitsTrackerApp.background.task"]
    // Unpause app (you should now see the print statements from your background task being executed.

    // Simulate termination of a background task:
    // Make sure you have done the steps above.
    // Pause app
    // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"polimi.HabitsTrackerApp.background.task"]
    // Unpause app
    //////////////////////////////////////////////////////////////////

    // MARK: - REGISTER OUR BG TASK:
    // When the App launches, register the task with Apple's task scheduler.
    // This must be done before 'applicationDidFinishLaunching(_:)'

    /// Register the  BG task for getting data from Firebase.
    /// - IMPORTANT: Needs to be called in 'didFinishLaunchingWithOptions' App delegate function.
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.bgAppTaskId, using: nil) { task in
            guard let firebaseTask = task as? BGAppRefreshTask else { return }
            self.bgTask = firebaseTask
            self.handleFirebasePostTask(firebaseTask)
        }
    }

    // MARK: - SCHEDULE BG TASK:
    // When the App goes into the background, we need schedule when we want our task to be executed.
    // We must not overabuse 'how often' we run our BG task as Apple could throttle it based on
    // how often our user actually uses our app.

    /// Schedule the app to try our background task for getting Firebase posts.
    /// - Parameter minutes: (Int) How many minutes from now do you want this to run?
    /// - IMPORTANT: Needs to be called in 'applicationDidEnterBackground' App delegate function.
    func scheduleFirebasePostTask(minutes: Int) {
        do {
            let seconds = TimeInterval(minutes * 60)
            print("BG Task: Scheduling to run again in \(minutes) minutes.")
            let task = BGAppRefreshTaskRequest(identifier: Self.bgAppTaskId)
            task.earliestBeginDate = seconds == 0 ? nil : Date(timeIntervalSinceNow: seconds)
            try BGTaskScheduler.shared.submit(task)
        } catch {
            print("BG Task: Failed to submit to the BG Task Scheduler: \(error.localizedDescription)")
        }
    }

    // MARK: - HANDLE TASK:

    /// What the task will execute when it does get called.
    /// First we reschedule our app to run again in 'X' minutes.
    /// We must set an expiration handler. (safety net)
    /// The handler gets called if our task is taking too long (for multiple reasons).
    /// Then we ask Firebase to give us fresh posts.
    /// - Parameter task: (BGAppRefreshTask) The task associated with getting firebase posts.
    private func handleFirebasePostTask(_ task: BGAppRefreshTask) {
        scheduleFirebasePostTask(minutes: 60) // This is how often we want our BG Task to run.
        task.expirationHandler = bgExpirationHandler
        getFirebasePosts(task)
    }

    // MARK: - GET FIREBASE POSTS:

    /// Will ask Firebase for new posts for our users.
    /// Whether the data is fetched successfully or not, we must set our task as completed once we get a response.
    /// If the network call for some reason hangs (poor network connection) the expiration handler on the task will be called.
    /// - Parameter task: (BGAppRefreshTask) The task associated with getting firebase posts.
    func getFirebasePosts(_ task: BGAppRefreshTask) {
        print("BG Task: Attempting to get Firebase Data.")

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        
        print("fetch data here ..")
        
        dispatchGroup.notify(queue: .main) {
            print("BG Task: Finished getting Firebase Posts.")
            task.setTaskCompleted(success: true)
        }
    }
}
