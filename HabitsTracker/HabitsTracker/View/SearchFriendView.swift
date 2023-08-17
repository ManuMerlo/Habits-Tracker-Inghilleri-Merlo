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
        NavigationView {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView{
                    ForEach(filteredFrieds, id: \.self) { friend in
                        NavigationLink(destination: UserProfileView(firestoreViewModel: firestoreViewModel, user: friend)) {
                            ListItemView(user: friend)
                                .frame(height:UIScreen.main.bounds.height / 10 )
                                .padding(.top)
                        }
                    }.padding(.top,4)
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
        
    }
}

struct ListItemView: View {
    var user : User
    var body: some View {
        VStack(alignment:.leading){
            ZStack{
                
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(Color("oxfordBlue").opacity(0.9)) 
                    .frame(height: UIScreen.main.bounds.height / 10, alignment: .center)
                    .shadow(color: Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25.0)
                            .stroke(Color("platinum").opacity(0.5), lineWidth: 2)
                    )
                    .opacity(0.8)

                HStack{
                    ProfileImageView(
                        path: user.image,
                        systemName: "person.crop.circle",
                        size: UIScreen.main.bounds.height / 15,
                        color: Color("platinum").opacity(0.7))
                    .padding(.leading)
                
                    Divider()
                            .background(Color("platinum"))
                            .frame(height: UIScreen.main.bounds.height / 12)
                            .padding(.horizontal,5)
                    
                    Text(user.username ?? user.email)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
            }.padding(.vertical,3)
            .padding(.horizontal)
        }
    }
}


struct SearchFriendView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFriendView( firestoreViewModel: FirestoreViewModel())
    }
}

