//
//  RecordView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 13/08/23.
//

import SwiftUI

struct RecordDetailView: View {
    
    var activityType: String
    var quantity: Int
    var image: String
    var measure: String
    var color : Int
    var up: Bool
    var width: CGFloat
    @State var showAlert = false
    
    var body: some View {
        
        VStack{
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color("delftBlue").opacity(0.9))
                .frame(width: width, height: 70, alignment: .leading)
                .shadow(color: Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 25.0)
                        .stroke(Color("platinum").opacity(0.5), lineWidth: 2)
                )
                .opacity(0.8)
                .overlay {
                    HStack{
                        Circle()
                            .frame(width: 35, height: 35)
                            .foregroundColor(Color("platinum").opacity(0.1))
                            .overlay(
                                Image(systemName: up ? "chevron.up" : "chevron.down")
                                    .font(.system(size:27))
                                    .fontWeight(.bold)
                                    .foregroundColor(ItemColor(number: color))
                                    .shadow(color: ItemColor(number: color).opacity(0.8), radius: 3, x: 0, y: 0)
                            ).padding(.leading,10)
                        
                        
                        VStack(){
                            
                            Text("\(activityType)")
                                .font(.system(size:10))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.trailing,10)
                            
                            
                            Text("\(quantity) \(measure)/day")
                                .font(.system(size:16))
                                .fontWeight(.bold)
                                .foregroundColor(ItemColor(number: color))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing,10)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
                .overlay {
                    if (up){
                        Button {
                            showAlert = true
                        } label: {
                            Image(systemName: "star.fill")
                                .font(.system(size:25))
                                .foregroundColor(.yellow)
                                .overlay {
                                    Image(systemName: "star")
                                        .font(.system(size:26))
                                        .foregroundColor(.white)
                                }
                            
                        }.offset(x: width/2-10, y:-32)
                    }
                }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Congratulations!"),
                message: Text("You have exceeded your Record"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func ItemColor(number : Int ) -> Color {
        let colors: [Color] = [Color("skyBlue"), Color("magenta"), Color("phlox"), Color("imperialRed"), Color("darkPastelGreen")]
        return colors[number % 5]
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailView(activityType: "Energy Burned", quantity: 40, image: "flame", measure: "Kcal", color: 4, up: true, width: 180 )
    }
}
