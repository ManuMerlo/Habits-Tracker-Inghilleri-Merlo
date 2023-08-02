//
//  UserProfile.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 01/08/23.
//

import SwiftUI

struct UserProfileView: View {
    var user: User
    var body: some View {
        VStack{
            if let background = user.background {
                Image(background)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(height: 200, alignment: .center)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius:10))
                    .padding([.leading,.trailing])
            }
            VStack{
                if let image = user.image{
                    Image(image)
                        .resizable()
                        .clipped()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: ContentMode.fill)
                        .frame(width: 120,height: 120)
                }
                if let username = user.username{
                    Text(username)
                        .font(.title3)
                        .bold()
                }
            }.offset(y:-60)
            Spacer()
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(user:UserList.usersGlobal[1])
    }
}
