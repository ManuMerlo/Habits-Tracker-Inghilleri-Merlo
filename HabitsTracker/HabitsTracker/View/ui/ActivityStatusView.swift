//
//  ActivityStatusView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 11/08/23.
//

import SwiftUI

struct ActivityStatusView: View {
    
    var color1 : Color
    var color2 : Color
    var activityType: String
    var quantity: Int
    var image: String
    var measure: String
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Image(systemName: "\(image)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(Color.black)
                        .opacity(0.45)
                    
                    Spacer().frame(width: 100, alignment: .center)
                    
                    Text("\(quantity)")
                        .font(.system(size: 20))
                        .fontWeight(.thin)
                        .foregroundColor(Color.black)
                    
                    Spacer().frame(width: 60, alignment: .center)
                    
                    Text("\(measure)")
                        .font(.system(size:20))
                        .fontWeight(.thin)
                        .foregroundColor(Color.black)
                    
                }
                ZStack(){
                    RoundedRectangle(cornerRadius: 25.0)
                        .frame(width: 350, height: 10,
                               alignment: .center)
                        .foregroundColor(.gray)
                        .opacity(0.1)
                    
                    let quantity = 150.0
                    let maximumQuantity = 350.0
                    let percentage = ( quantity / maximumQuantity ) * maximumQuantity // min(quantity, maximumQuantity)
                    
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(LinearGradient(
                            gradient: .init(colors: [color1, color2]),
                            startPoint: .init(x: 0, y: 0),
                            endPoint: .init(x: 0.5, y: 0)
                        ))
                        .frame(width: percentage, height: 10, alignment: .center)
                        .offset(x: -((maximumQuantity-percentage)/2))
                    
                }
            }
            
            RoundedRectangle(cornerRadius: 25.0)
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 300, height: 90,
                       alignment: .center)
                .foregroundColor(.gray)
                .opacity(0.1)
                .shadow(color: .black, radius: 5, x: 0.0, y: 0.0)
        }
    }
}

struct ActivityStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityStatusView(color1: Color(red: 1, green: 1, blue: 0), color2: Color(red: 0, green: 0.8, blue: 0), activityType: "Active Energy Burned",quantity: 40, image: "flame", measure: "Kcal" )
    }
}
