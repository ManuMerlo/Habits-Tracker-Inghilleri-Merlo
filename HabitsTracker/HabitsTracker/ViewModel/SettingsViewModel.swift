//
//  SettingsViewModel.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 02/08/23.
//

import Foundation
import UserNotifications
import SwiftUI
import FirebaseAuth
import FirebaseStorage

final class SettingsViewModel: ObservableObject {
    @Published var agreedToTerms = true
    @Published var dailyNotification = false
    @Published var weeklyNotification = false
    @Published var dailyNotificationIdentifier: String?
    @Published var weeklyNotificationIdentifier:  String?
    @Published var image: UIImage?
    
    
    func scheduleNotifications( title: String, subtitle: String,timeInterval: TimeInterval, repeats: Bool)-> String?{
        let identifier : String
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = .default
        
        identifier = UUID().uuidString
        
        let trigger = UNTimeIntervalNotificationTrigger (timeInterval: timeInterval, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        return identifier
    }
    
    func stopNotifications(identifier : String?) -> String? {
        if let id = identifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            return nil // Clear the stored identifier
        }
        return identifier
    }
    
    
    func persistimageToStorage () {
        guard let uid = Auth.auth().currentUser?.uid
        else { return }
        let ref = Storage.storage().reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality:
                                                    0.5) else { return }
        ref.putData (imageData, metadata: nil) { metadata, err in
            if let err = err {
                print("error putData: \(err.localizedDescription)")
            }
            ref.downloadURL { url, err in
                if let err = err {
                    print("Error downloadURL: \(err.localizedDescription)")
                }
                //TODO: aggiorna imageURL utente
                print("Successfully stored image with url: \(url?.absoluteString ?? "")")
            }
        }
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Environment(\.presentationMode) private var presentationMode
        var sourceType: UIImagePickerController.SourceType = .photoLibrary
        @Binding var selectedImage: UIImage?
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
            
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = sourceType
            imagePicker.delegate = context.coordinator
            
            return imagePicker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
            
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            
            var parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    parent.selectedImage = image
                }
                
                parent.presentationMode.wrappedValue.dismiss()
            }
            
        }
    }
    
}




