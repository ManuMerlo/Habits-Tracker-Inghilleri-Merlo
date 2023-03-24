//
//  UserViewModel.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 19/03/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn

final class UserViewModel: ObservableObject {
    
    // @Published var users = [User]()
    //var found: Bool = false
    let db = Firestore.firestore()
    
    @AppStorage("log_status") var logStatus: Bool = true
    
    func addUser(uid: String, username: String, emailAddress: String) {
        // Check that the user doesn't exist (Testare meglio)
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                    // print("exist not added")
                    return
                } else {
                    self.db.collection("users").document(uid).setData([
                        "username": username,
                        "emailAddress": emailAddress
                        ])
                    print("added in firestore")
                }
        }
    }
    
    func logout(delete: Bool){
        /*if delete { // TODO: Must be atomic the deletion in firestore and in authenticator
            let user = Auth.auth().currentUser
            if let user = user {
                db.collection("users").document(user.uid).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                        return
                    } else {
                        print("Document successfully removed!")
                    }
                }
                db.collection("users").document(user.uid).getDocument { document, error in
                    if let document = document, document.exists {
                            // print("exist not added")
                            return
                        } else {
                            user.delete { error in
                              if let error = error {
                                  print(error.localizedDescription)
                                  return
                              } else {
                                  print("Account deleted")
                              }
                            }
                        }
                }
                
            }
        }*/
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        withAnimation(.easeInOut) {
            logStatus = false
        }
    }
    
    
    
    /*func getAllUsers() {
        // Read the documents of the database
        db.collection("users").getDocuments { snapshot, err in
            // Check for errors
            if let error = err {
                print(error.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                // Update the list property in the main thread
                DispatchQueue.main.async {
                    // Get all the users
                    self.users = snapshot.documents.map { d in // transforms documents in users
                        return User(id: d.documentID, username: d["username"] as! String, emailAddress: d["emailAddress"] as! String, age: d["age"] as? Int ?? nil, sex: d["sex"] as? Sex ?? nil, weight: d["weight"] as? Float ?? nil)
                    }
                }
            }
        }
    }*/
    
    /*func getUser(emailAddress: String) -> User {
        //Check if it is a valid email
        /*db.collection("users").getDocuments { snapshot, err in
            // Check for errors
            if let error = err {
                print(error.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for d in snapshot.documents {
                    if(String(d["emailAddress"]) == emailAddress){
                        //self.found = true
                    }
                }
            }
        }*/
        var currentUser: User
        db.collection("users").whereField("emailAddress", isEqualTo: emailAddress)
            .getDocuments() { (querySnapshot, err) in
                if let error = err {
                    print("Error getting user by email: \(error)")
                } else {
                    if let querySnapshot = querySnapshot {
                        for document in querySnapshot.documents {
                            currentUser = User(id: document.documentID, username: document["username"], emailAddress: document["emailAddress"])
                        }
                    }
                }
        }
        return currentUser
    }*/
    
    /*func deleteUser(userToDelete: User) {
        db.collection("users").document(userToDelete.id).delete { err in
            if let error = err {
                print(error.localizedDescription)
                return
            }
            /*DispatchQueue.main.async{
                self.users.removeAll { user in
                    return user.id == userToDelete.id
                }
            }*/
            let user = Auth.auth().currentUser
            
            user?.delete { err in
                if let error = err {
                    print(error.localizedDescription)
                    return
                } else {
                    // Logout
                }
            }
        }
    }*/
    
}

