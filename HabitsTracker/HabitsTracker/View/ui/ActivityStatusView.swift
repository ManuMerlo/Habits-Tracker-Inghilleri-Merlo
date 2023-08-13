//
//  ActivityStatusView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 11/08/23.
//

import SwiftUI

struct ActivityStatusView: View {
    
    let color1 = Color(red: 1, green: 1, blue: 0)
    let color2 = Color(red: 0, green: 0.8, blue: 0)
    var activityType: String
    var quantity: Int
    var score: Int
    var image: String
    var measure: String
    
    var body: some View {
        
        VStack{
            
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color("delftBlue").opacity(0.9))
                .frame(height: 110, alignment: .center)
                .shadow(color: Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 25.0)
                        .stroke(Color("platinum").opacity(0.5), lineWidth: 2)
                )
                .opacity(0.8).overlay {
                    
                    VStack(){
                        Text("\(activityType): +\(score) points")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(y:15)
                            .padding(.leading,20)
                        
                        Text("\(quantity) \(measure)")
                            .font(.body)
                            .fontWeight(.thin)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .offset(y:15)
                            .padding(.trailing,20)
                        
                        HStack{
                            Image(systemName: "\(image)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30, alignment: .leading)
                                .foregroundColor(Color.white)
                                .opacity(0.8)
                                .padding(.leading,20)
                            
                            
                            Spacer()
                            
                            let quantity = Double(quantity)
                            let maximumQuantity = 270.0
                            let percentage = min(quantity, maximumQuantity)
                            
                            RoundedRectangle(cornerRadius: 25.0)
                                .frame(width: maximumQuantity, height: 10,
                                       alignment: .trailing)
                                .foregroundColor(Color("platinum"))
                                .opacity(0.3)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .fill(LinearGradient(
                                            gradient: .init(colors: [color1, color2]),
                                            startPoint: .init(x: 0, y: 0),
                                            endPoint: .init(x: 0.5, y: 0)
                                        ))
                                        .frame(width: percentage, height: 10, alignment: .trailing)
                                        .offset(x: -((maximumQuantity-percentage)/2))
                                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0.0, y: 0.0)
                                }
                                .padding(.trailing,20)
                            
                        }.padding(.horizontal,30)
                        
                    }
                }
        }
        .padding(.vertical,3)
        .padding(.horizontal,20)
    }
}

struct ActivityStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityStatusView(activityType: "Energy Burned", quantity: 40, score: 60, image: "flame", measure: "Kcal" )
    }
}
