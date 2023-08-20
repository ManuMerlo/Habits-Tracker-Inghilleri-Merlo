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
                    LazyVStack{
                        ForEach(firestoreViewModel.requests, id: \.self) { user in
                            RequestItemView(firestoreViewModel: firestoreViewModel, user: user)
                                .padding(.bottom, 95)
                        }
                    }
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
        }.refreshable {
            firestoreViewModel.getRequests()
        }
        .onAppear() {
            firestoreViewModel.getRequests()
        }.onChange(of: firestoreViewModel.friendsSubcollection) { newValue in
            firestoreViewModel.getRequests()
        }
    }
}

struct RequestItemView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var user: User
    
    var body: some View {
        GeometryReader {  geometry in
            VStack(alignment: .leading){
                
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(Color("oxfordBlue").opacity(0.9))
                    .frame(alignment: .center)
                    .shadow(color: Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25.0)
                            .stroke(Color("platinum").opacity(0.5), lineWidth: 2)
                    )
                    .opacity(0.8).overlay{
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
                                Spacer()
                                
                                Text(user.username ?? user.email)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                HStack{
                                    Button(action: {
                                        firestoreViewModel.confirmFriend(uid: firestoreViewModel.firestoreUser!.id, friendId: user.id)
                                    }) {
                                        Image(systemName: "person.fill.badge.plus")
                                        Text("Confirm")
                                            .font(.custom("Open Sans", size: 18))
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .foregroundColor(.white)
                                    .tint(.blue)
                                    
                                    
                                    Button {
                                        firestoreViewModel.removeFriend(uid: firestoreViewModel.firestoreUser!.id, friendId: user.id)
                                        
                                    } label: {
                                        Image(systemName: "person.fill.badge.minus")
                                        Text("Remove")
                                            .font(.custom("Open Sans", size: 18))
                                    }.buttonStyle(.borderedProminent)
                                        .foregroundColor(.black)
                                        .tint(.gray)
                                }
                                Spacer()
                            }
                        }
                    }.frame(height:90)
            }
            .frame(height: 90)
        }
    }
}


struct RequestItemView_Previews: PreviewProvider {
    static var previews: some View {
        RequestItemView( firestoreViewModel: FirestoreViewModel(),user: User(
            id: "12345",
            email: "lulu@gmail.com",
            username: "lulu",
            birthDate: "10/08/2001",
            sex: Sex.Female,
            height: 150,
            weight: 60,
            dailyScores: [20,50,40,60,60,90,70,200,40]))
    }
}

