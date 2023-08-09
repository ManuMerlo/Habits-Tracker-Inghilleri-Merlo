//
//  SearchFriendView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 01/08/23.
//

import SwiftUI
import FirebaseFirestoreSwift

struct SearchFriendView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @State private var searchTerm = ""
    
    @FirestoreQuery(
            collectionPath: "users"
        ) var friends: [User]
    
    var filteredFrieds : [User] {
        guard !searchTerm.isEmpty else {return friends}
        return friends.filter { $0.email.localizedCaseInsensitiveContains(searchTerm)}
    }
    
    var body: some View {
        NavigationStack {
            List(filteredFrieds, id: \.self) { friend in
                NavigationLink(value:friend){
                    ListItemView(user:friend).frame(height: 40)
                    
                }
                
            }
            .listStyle(PlainListStyle())
            .searchable(text:$searchTerm, prompt:"Search a friend")
            .navigationTitle("Friends")
            .navigationDestination(for: User.self) { user in
                UserProfileView(firestoreViewModel: firestoreViewModel,user: user)
                    
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(
                Color.green,
                for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct ListItemView: View {
    var user : User
    var body: some View {
        GeometryReader {  geometry in
            HStack(){

                ProfileImageView(
                    path: user.image,
                    size: geometry.size.width/7,
                    color: .gray)

                Text(user.username ?? user.email)
                    .font(.custom("Open Sans", size: 18))
                
            }
        }
    }
}


struct SearchFriendView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFriendView( firestoreViewModel: FirestoreViewModel())
    }
}

