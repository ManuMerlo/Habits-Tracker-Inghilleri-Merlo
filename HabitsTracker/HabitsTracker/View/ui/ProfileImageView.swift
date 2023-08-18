//
//  profileImageView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 06/08/23.
//

import SwiftUI

struct ProfileImageView: View {
    var path: String?
    var systemName : String?
    var size: CGFloat
    var color: Color
    
    var body: some View {
        VStack(alignment: .center){
            if let path = path {
                AsyncImage(url: URL(string: path)){ phase in
                    switch phase {
                    case .failure:
                        Image(systemName: systemName ?? "person.fill")
                            .resizable()
                            .frame(width: size, height: size)
                            .mask(Circle())
                            .foregroundColor(.white)

                    case .success(let image):
                        image .resizable()
                        default: ProgressView() }
                    
                } .frame(width: size, height: size)
                    .mask(Circle())
                
            } else {
                    Image(systemName:systemName ?? "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .mask(Circle())
                        .foregroundColor(color)
            }
        }
        
    }
}

struct ProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageView( size: 60, color: .black)
    }
}
