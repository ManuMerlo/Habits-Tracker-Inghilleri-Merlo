//
//  HCard.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 21/11/22.
//

import SwiftUI

struct HCard: View {
    var activityType: String
    var quantity: String
    var image: String
    var body: some View {
        HStack(spacing: 20) {
            VStack (alignment: .leading, spacing: 8) {
                Text(activityType)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(quantity)
            }
            Text("+30pt")
                .font(.title)
                .fontWeight(.bold)
            Divider()
            Image(systemName: image)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: 110)
        .background(Color.green)
        .foregroundColor(.white)
        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
        
        
    }
}

struct HCard_Previews: PreviewProvider {
    static var previews: some View {
        HCard(activityType: "ActivityType", quantity: "Quantity", image: "figure.walk")
    }
}
