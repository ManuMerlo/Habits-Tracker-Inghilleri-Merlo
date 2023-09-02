import Foundation
import SwiftUI
import FirebaseFirestoreSwift

struct RequestListView: View {
    
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State private var device: Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State var width = UIScreen.main.bounds.width
 
    var body: some View {
        
       NavigationStack {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                    .edgesIgnoringSafeArea(.all)
                ScrollView{
                    VStack(spacing: 15){
                        ForEach(firestoreViewModel.requests, id: \.self) { user in
                            RequestItemView(firestoreViewModel: firestoreViewModel, user: user)
                                .frame(width: isLandscape ? width/1.5 : width/1.1)
                        }
                    }
                    .padding(.top, getMaxWidth())
                }
                .accessibilityIdentifier("RequestListScrollView")
                .edgesIgnoringSafeArea(.top)
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
        .onAppear(){
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
        }
    }

    func getMaxWidth() -> CGFloat{
        if device == .iPad {
            return 90
        }
        else {
            return isLandscape ? 45 : 105
        }
    }
}

struct RequestItemView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var user: User
    
    var body: some View {
        
        HStack(spacing: 10){
            ProfileImageView(
                path: user.image,
                systemName: "person.circle",
                size: 60,
                color: .gray)
            
            Divider()
                .background(Color("platinum"))
                .frame(height: 70)
            
            VStack(alignment: .leading,spacing: 10){
                Text(user.username ?? user.email)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 10){
                    Button(action: {
                        firestoreViewModel.confirmFriend(uid: firestoreViewModel.firestoreUser!.id, friendId: user.id)
                    }) {
                        Image(systemName: "person.fill.badge.plus")
                        Text("Confirm")
                            .font(.custom("Open Sans", size: 15))
                            .lineLimit(1)
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(.white)
                    .tint(.blue)
                    
                    Button {
                        firestoreViewModel.removeFriend(uid: firestoreViewModel.firestoreUser!.id, friendId: user.id)
                        
                    } label: {
                        Image(systemName: "person.fill.badge.minus")
                        Text("Remove")
                            .font(.custom("Open Sans", size: 15))
                            .lineLimit(1)
                    }.buttonStyle(.borderedProminent)
                        .foregroundColor(.black)
                        .tint(.gray)
                }
                
            }
            .padding(.vertical,10)
            
        }
        .padding(.horizontal,10)
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


struct RequestItemView_Previews: PreviewProvider {
    static var previews: some View {
    /*RequestListView(firestoreViewModel: FirestoreViewModel())
            .environmentObject(OrientationInfo())*/
        RequestItemView(firestoreViewModel: FirestoreViewModel(),user: User(
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

