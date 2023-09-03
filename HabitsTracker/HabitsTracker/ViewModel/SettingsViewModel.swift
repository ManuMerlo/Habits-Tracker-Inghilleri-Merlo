import Foundation
import UserNotifications
import SwiftUI
import FirebaseAuth
import FirebaseStorage

/// A protocol for managing user notifications.
protocol UserNotificationCenterProtocol {
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
}

/// An extension to enable the `UNUserNotificationCenter` to conform
/// to the `UserNotificationCenterProtocol`.
extension UNUserNotificationCenter: UserNotificationCenterProtocol { }

/// A view model to manage user settings.
@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var dailyNotification = false
    @Published var weeklyNotification = false
    @Published var dailyNotificationIdentifier: String?
    @Published var weeklyNotificationIdentifier:  String?
    @Published var notificationPermissionGranted: Bool = false
    @Published var settingsNotifications: Bool = false
    @Published var image: UIImage?
    @State var notificationCenter: UserNotificationCenterProtocol
    
    /// Initializes a new instance of `SettingsViewModel`.
    ///
    /// - Parameter notificationCenter: The notification center to use. Defaults to the system's current user notification center.
    init(notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current()) {
        self.notificationCenter = notificationCenter
        dailyNotificationIdentifier = UserDefaults.standard.string(forKey: "DailyNotificationIdentifier")
        weeklyNotificationIdentifier = UserDefaults.standard.string(forKey: "WeeklyNotificationIdentifier")
    }
    
    /// Initializes a new instance of `SettingsViewModel` for testing purposes.
    ///
    /// - Parameter notificationCenter: The optional notification center to use.
    init(notificationCenter: UserNotificationCenterProtocol? = nil) {
        if let providedNotificationCenter = notificationCenter {
            self.notificationCenter = providedNotificationCenter
        } else {
            self.notificationCenter = UNUserNotificationCenter.current()
        }
        dailyNotificationIdentifier = UserDefaults.standard.string(forKey: "DailyNotificationIdentifier")
        weeklyNotificationIdentifier = UserDefaults.standard.string(forKey: "WeeklyNotificationIdentifier")
        
    }
    
    /// Checks whether the user has granted permission for notifications.
    func checkNotificationPermissionGanted() async {
        let settings = await checkNotificationSettings()
        if settings.authorizationStatus == .authorized {
            // Notifications are enabled
            self.settingsNotifications = true
            self.notificationPermissionGranted = UserDefaults.standard.bool(forKey: "NotificationPermissionGranted")
        } else {
            // Notifications are not enabled
            notificationCenter.removeAllPendingNotificationRequests()
            self.settingsNotifications = false
            self.notificationPermissionGranted = false
        }
        self.dailyNotification = notificationPermissionGranted && UserDefaults.standard.bool(forKey: "DailyNotification")
        self.weeklyNotification = notificationPermissionGranted && UserDefaults.standard.bool(forKey: "WeeklyNotification")
    }
    
    /// Saves the notification permission status.
    ///
    /// - Parameter value: A boolean indicating whether the permission has been granted.
    func saveNotificationPermission(value: Bool) {
        UserDefaults.standard.set(value, forKey: "NotificationPermissionGranted")
        self.notificationPermissionGranted = value
    }
    
    /// Starts daily notifications.
    func startDailyNotifications() {
        UserDefaults.standard.set(true, forKey: "DailyNotification")
        dailyNotificationIdentifier = scheduleNotifications(title: "Daily Notification", subtitle: "You are doing great!!", timeInterval: 86400, repeats: true)
        UserDefaults.standard.set(dailyNotificationIdentifier, forKey: "DailyNotificationIdentifier")
    }
    
    /// Stops daily notifications.
    func stopDailyNotifications() {
        UserDefaults.standard.set(false, forKey: "DailyNotification")
        dailyNotificationIdentifier = stopNotifications(identifier:dailyNotificationIdentifier)
        UserDefaults.standard.set("", forKey: "DailyNotificationIdentifier")
    }
    
    /// Starts weekly notifications.
    func startWeeklyNotifications() {
        UserDefaults.standard.set(true, forKey: "WeeklyNotification")
        weeklyNotificationIdentifier = scheduleNotifications(title: "Weekly Notification", subtitle: "You are doing great!!", timeInterval: 86400*7, repeats: true)
        UserDefaults.standard.set(weeklyNotificationIdentifier, forKey: "WeeklyNotificationIdentifier")
    }
    
    /// Stops weekly notifications.
    func stopWeeklyNotifications() {
        UserDefaults.standard.set(false, forKey: "WeeklyNotification")
        weeklyNotificationIdentifier = stopNotifications(identifier: weeklyNotificationIdentifier)
        UserDefaults.standard.set("", forKey: "WeeklyNotificationIdentifier")
    }
    
    /// Schedules a new notification.
    ///
    /// - Parameters:
    ///   - title: The notification title.
    ///   - subtitle: The notification subtitle.
    ///   - timeInterval: The time interval between notifications.
    ///   - repeats: A boolean indicating whether the notification should repeat.
    ///
    /// - Returns: A string identifier for the scheduled notification.
    func scheduleNotifications(title: String, subtitle: String, timeInterval: TimeInterval, repeats: Bool) -> String? {
        let identifier: String
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = .default
        identifier = UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger (timeInterval: timeInterval, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request){ _ in
        }
        return identifier
    }
    
    /// Converts a `Date` instance to a string representation.
    ///
    /// - Parameter date: The date to convert.
    ///
    /// - Returns: The string representation of the given date.
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Imposta il formato della data, ad esempio "dd/MM/yyyy" per il formato giorno/mese/anno
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    /// Converts a string representation of a date to a `Date` instance.
    ///
    /// - Parameter dateString: The string representation of the date.
    ///
    /// - Returns: The `Date` instance or nil if conversion fails.
    func stringToDate(_ dateString: String?) -> Date? {
        guard let dateStr = dateString else {
            print("date conversion error settings view model: nil parameter")
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let date = dateFormatter.date(from: dateStr) {
            print("date conversion settings view model: \(date)")
            return date
        } else {
            print("date conversion error settings view model: nil conversion")
            return nil // Return nil if the string couldn't be converted to a date
        }
    }
    
    /// Persists the user's image to the Firebase storage.
    ///
    /// - Parameter completionBlock: A closure to handle the result of the image persistence operation.
    func persistimageToStorage (completionBlock: @escaping (Result<String,Error>) -> Void){
        guard let uid = Auth.auth().currentUser?.uid
        else { return }
        let ref = Storage.storage().reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality:
                                                    0.5) else { return }
        ref.putData (imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("error putData: \(error.localizedDescription)")
                completionBlock(.failure(error))
            }
            ref.downloadURL {url, error in
                if let error = error {
                    print("Error downloadURL: \(error.localizedDescription)")
                    completionBlock(.failure(error))
                }
                print("Successfully stored image with url: \(url?.absoluteString ?? "")")
                completionBlock(.success(url?.absoluteString ?? ""))
                
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Retrieves the current notification settings.
    ///
    /// - Returns: The current `UNNotificationSettings`.
    private func checkNotificationSettings() async -> UNNotificationSettings {
        return await withCheckedContinuation { continuation in
            notificationCenter.getNotificationSettings { settings in
                //DispatchQueue.main.async {
                continuation.resume(returning: settings)
                //}
            }
        }
    }
    
    /// Stops and removes pending notifications.
    ///
    /// - Parameter identifier: The identifier of the notification to stop.
    ///
    /// - Returns: A cleared identifier or the original identifier if the operation fails.
    private func stopNotifications(identifier: String?) -> String? {
        if let id = identifier {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
            return nil // Clear the stored identifier
        }
        return identifier
    }
    
}




