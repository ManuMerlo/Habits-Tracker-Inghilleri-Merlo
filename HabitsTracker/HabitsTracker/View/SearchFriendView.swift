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
    
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State var width = UIScreen.main.bounds.width
    
    @FirestoreQuery(
        collectionPath: "users"
    ) var friends: [User]
    
    var filteredFrieds : [User] {
        guard !searchTerm.isEmpty else {return friends}
        return friends.filter { $0.email.localizedCaseInsensitiveContains(searchTerm)}
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView{
                    VStack(spacing: 15){
                        ForEach(filteredFrieds, id: \.self) { friend in
                            NavigationLink(destination: UserProfileView(firestoreViewModel: firestoreViewModel, user: friend)) {
                                ListItemView(user: friend,
                                             width: isLandscape ? width/1.5 : width/1.1)
                            }
                        }
                    }
                    .padding(.top,15)
                }
            }
            .searchable(text: $searchTerm, prompt: "Search a friend")
            .navigationTitle("Friends")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(
                Color("oxfordBlue"),
                for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear(){
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        
    }
}

struct ListItemView: View {
    var user : User
    var width : CGFloat
    
    var body: some View {
        HStack{
            ProfileImageView(
                path: user.image,
                systemName: "person.crop.circle",
                size: 50,
                color: Color("platinum").opacity(0.7))
            .padding(.leading)
            
            Divider()
                .background(Color("platinum"))
                .frame(height: 50)
                .padding(.horizontal,5)
            
            Text(user.username ?? user.email)
                .font(.title2)
            
            Spacer()
            
        }
        .frame(width: width)
        .padding(.vertical,10)
        .foregroundColor(Color("platinum").opacity(0.7))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("platinum").opacity(0.5), lineWidth: 2)
        )
        .background(Color("oxfordBlue").opacity(0.9))
        .mask(RoundedRectangle(cornerRadius: 20, style:.continuous))
        .shadow(color: Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
        
    }
}


struct SearchFriendView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFriendView( firestoreViewModel: FirestoreViewModel())
            .environmentObject(OrientationInfo())
    }
}

