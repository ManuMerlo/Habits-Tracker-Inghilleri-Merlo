//
//  RequestListView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 07/08/23.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift

struct RequestListView: View {
    
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    //@FirestoreQuery(
        //collectionPath: "users"
    //) var globalUsers: [User] //FIXME: se non usiamo tutto lo user, basta prendere solo un id
    
    //var requests: [User] {
        //if let friends = firestoreViewModel.firestoreUser?.friends, !friends.isEmpty{
            // Filter friends with status "Request" and get their IDs
            //let requestFriendIds = friends.filter { $0.status == "Request" }.map{ $0.id }
            //return globalUsers.filter { requestFriendIds.contains($0.id!)}
            //return globalUsers.filter { firestoreViewModel.requestsIds.contains($0.id!)}
        //} else {
        //    return []
        //}
    //}
    
    var body: some View {
    
        NavigationStack {
            List(firestoreViewModel.requests, id: \.self) { user in
                RequestItemView(firestoreViewModel: firestoreViewModel, user: user).frame(height: 40)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Requests")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(
                Color.green,
                for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct RequestItemView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var user: User
    
    var body: some View {
        GeometryReader {  geometry in
            HStack(){
                ProfileImageView(
                    path: user.image,
                    size: geometry.size.width/8,
                    color: .gray)
                
                Text(user.username ?? user.email)
                    .font(.custom("Open Sans", size: 18))
                
                Spacer()
                
                Button {
                    firestoreViewModel.confirmFriend(uid: firestoreViewModel.firestoreUser!.id!, friendId: user.id!)
                } label: {
                    Text("Confirm")
                }.buttonStyle(.borderedProminent)
                    .foregroundColor(.white)
                    .tint(.blue)
                
                Button {
                    firestoreViewModel.removeFriend(uid: firestoreViewModel.firestoreUser!.id!, friend: user.id!)
                    
                    firestoreViewModel.removeFriend(uid:user.id!, friend: firestoreViewModel.firestoreUser!.id!)
                } label: {
                    Text("Remove")
                }.buttonStyle(.borderedProminent)
                    .foregroundColor(.black)
                    .tint(.gray)
            }
        }
    }
}


struct RequestListView_Previews: PreviewProvider {
    static var previews: some View {
        RequestListView( firestoreViewModel: FirestoreViewModel())
    }
}
