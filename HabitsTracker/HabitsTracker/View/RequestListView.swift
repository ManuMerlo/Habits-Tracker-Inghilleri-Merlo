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
           
                ZStack{
                    RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView{
                        ForEach(firestoreViewModel.requests, id: \.self) { user in
                            RequestItemView(firestoreViewModel: firestoreViewModel, user: user)
                                .padding(.top)
                        }.padding(.top,20)
                    }
                    .padding()
                    .frame(width: nil)
                    .navigationTitle("Requests")
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(
                        Color("oxfordBlue"),
                        for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    
                    
                }
        }
    }
}

struct RequestItemView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var user: User
    
    var body: some View {
        GeometryReader {  geometry in
            VStack(alignment: .leading){
                ZStack{
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(Color("oxfordBlue").opacity(0.9))
                        .frame(alignment: .center)
                        .shadow(color: Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(Color("platinum").opacity(0.5), lineWidth: 2)
                        )
                        .opacity(0.8)
                        
                    HStack(){
                        ProfileImageView(
                            path: user.image,
                            systemName: "person.circle",
                            size: geometry.size.width/6,
                            color: .gray)
                        .padding(.leading,20)
                        
                     
                        Divider()
                            .background(Color.white)
                          
                        VStack(alignment: .leading){
                            
                            Text(user.username ?? user.email)
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                            HStack{
                                Button {
                                    firestoreViewModel.confirmFriend(uid: firestoreViewModel.firestoreUser!.id!, friendId: user.id!)
                                } label: {
                                    Text("Confirm")
                                }.buttonStyle(.borderedProminent)
                                    .foregroundColor(.white)
                                    .tint(.blue)
                                    .padding(.trailing,10)
                                
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
                        .padding()
                    }
                }
            }
            .frame(height: 40)
        }
    }
}


struct RequestListView_Previews: PreviewProvider {
    static var previews: some View {
        RequestListView( firestoreViewModel: FirestoreViewModel())
    }
}
