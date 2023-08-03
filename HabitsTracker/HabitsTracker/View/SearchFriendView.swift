//
//  SearchFriendView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 01/08/23.
//

import SwiftUI

struct SearchFriendView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @State private var searchTerm = ""
    @State private var friends: [User] = UserList.usersGlobal
    
    var filteredFrieds : [User] {
        guard !searchTerm.isEmpty else {return friends}
        return friends.filter { $0.username!.localizedCaseInsensitiveContains(searchTerm)}
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
                UserProfileView(user: user)
                    
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(
                Color.green,
                for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            /*.task {
             friends = await getFriends()
             }*/
        }
    }
}

func getFriends () async -> [User] {
    return UserList.usersGlobal
}

struct ListItemView: View {
    var user : User
    
    var body: some View {
        
        GeometryReader {  geometry in
            HStack(){
                Image(user.image ?? "user")
                    .resizable()
                    .frame(width: geometry.size.width/7, height: geometry.size.width/7)
                    .mask(Circle())
                    .padding(.trailing,5)
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

