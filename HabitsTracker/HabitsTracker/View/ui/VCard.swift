//
//  VCard.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 21/11/22.
//

import SwiftUI

struct VCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Timeframe")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: 170, alignment: .leading)
                .layoutPriority(1)
            Text("Ranking")
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Points")
                .fontWeight(.bold)
            Spacer()
            HStack {
                ForEach(Array([2, 3, 4].shuffled().enumerated()), id: \.offset) { index, number in
                    Image("Avatar \(number)")
                        .resizable()
                        .frame(width: 44, height: 44)
                    .mask(Circle())
                    .offset(x: CGFloat(index * -20))
                }
            }
        }
        .foregroundColor(.white)
        .padding(30)
        .frame(width: 260, height: 310)
        .background(.linearGradient(colors: [Color.purple, Color.purple.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .mask(RoundedRectangle(cornerRadius: 30,style: .continuous))
        .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 12)
        .shadow(color: Color.purple.opacity(0.3), radius: 2, x: 0, y: 1)
        .overlay(
            Image("Topic 1")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(20)
        )
    }
}

struct VCard_Previews: PreviewProvider {
    static var previews: some View {
        VCard()
    }
}
