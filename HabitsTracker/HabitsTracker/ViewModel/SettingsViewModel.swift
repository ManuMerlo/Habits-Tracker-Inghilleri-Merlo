import Foundation
import UserNotifications
import SwiftUI
import FirebaseAuth
import FirebaseStorage

protocol UserNotificationCenterProtocol {
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol { }

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var dailyNotification = false
    @Published var weeklyNotification = false
    @Published var dailyNotificationIdentifier: String?
    @Published var weeklyNotificationIdentifier:  String?
    @Published var notificationPermissionGranted: Bool = false
    @Published var settingsNotifications: Bool = false
    
    @Published var image: UIImage?
    
    func checkNotificationPermissionGanted() async {
        let settings = await checkNotificationSettings()
        if settings.authorizationStatus == .authorized {
            // Notifications are enabled
            self.settingsNotifications = true
            self.notificationPermissionGranted = UserDefaults.standard.bool(forKey: "NotificationPermissionGranted")
        } else {
            // Notifications are not enabled
            self.settingsNotifications = false
            self.notificationPermissionGranted = false
        }
        self.dailyNotification = notificationPermissionGranted && UserDefaults.standard.bool(forKey: "DailyNotification")
        self.weeklyNotification = notificationPermissionGranted && UserDefaults.standard.bool(forKey: "WeeklyNotification")
    }
    
    private func checkNotificationSettings() async -> UNNotificationSettings {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                //DispatchQueue.main.async {
                    continuation.resume(returning: settings)
                //}
            }
        }
        
    }
    
    func saveNotificationPermission(value: Bool) {
        UserDefaults.standard.set(value, forKey: "NotificationPermissionGranted")
        self.notificationPermissionGranted = value
    }
    
    func startDailyNotifications() {
          UserDefaults.standard.set(true, forKey: "DailyNotification")
          dailyNotificationIdentifier = scheduleNotifications(title: "Daily Notification", subtitle: "You are doing great!!", timeInterval: 86400, repeats: true)
      }
      
      func stopDailyNotifications() {
          UserDefaults.standard.set(false, forKey: "DailyNotification")
          dailyNotificationIdentifier = stopNotifications(identifier:dailyNotificationIdentifier)
      }
      
      func startWeeklyNotifications() {
          UserDefaults.standard.set(true, forKey: "WeeklyNotification")
          weeklyNotificationIdentifier = scheduleNotifications(title: "Weekly Notification", subtitle: "You are doing great!!", timeInterval: 86400*7, repeats: true)
      }
      
      func stopWeeklyNotifications() {
          UserDefaults.standard.set(false, forKey: "WeeklyNotification")
          weeklyNotificationIdentifier = stopNotifications(identifier:weeklyNotificationIdentifier)
      }
   
    
    private func scheduleNotifications(title: String, subtitle: String, timeInterval: TimeInterval, repeats: Bool, notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current()) -> String? {
        let identifier : String
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
    
    private func stopNotifications(identifier : String?) -> String? {
        if let id = identifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            return nil // Clear the stored identifier
        }
        return identifier
    }
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Imposta il formato della data, ad esempio "dd/MM/yyyy" per il formato giorno/mese/anno
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
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
}




