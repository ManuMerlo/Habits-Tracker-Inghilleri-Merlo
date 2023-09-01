import SwiftUI

struct ActivityStatusView: View {
    
    let color1 = Color(red: 1, green: 1, blue: 0)
    let color2 = Color(red: 0, green: 0.8, blue: 0)
    var activityType: String
    var quantity: Int
    var score: Int
    var image: String
    var measure: String
    var width: CGFloat
    var record: Int
    
    var body: some View {
        
        VStack(){
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color("delftBlue").opacity(0.9))
                .frame(height: 110, alignment: .center)
                .shadow(color: Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 25.0)
                        .stroke(Color("platinum").opacity(0.5), lineWidth: 2)
                )
                .opacity(0.8)
                .overlay {
                    VStack(spacing: 0){
                        Text("\(activityType): +\(score) points")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading,20)
                            
                        Text("\(quantity) \(measure)")
                            .font(.body)
                            .fontWeight(.thin)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing,20)
                        
                        HStack() {
                            Image(systemName: "\(image)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: width*0.1, height: 30, alignment: .center)
                                .foregroundColor(Color.white)
                                .opacity(0.8)
                        
                            Spacer()
                            let maximumQuantity = Double(width) * 0.8
                            let ratio = Double(abs(quantity)) / Double(abs(record))
                            let actualQuantity = max(0, ratio) * Double(abs(maximumQuantity))
                            let percentage = min(actualQuantity, maximumQuantity)
                            
                            VStack{
                                RoundedRectangle(cornerRadius: 25.0)
                                    .frame(width: maximumQuantity, height: 10, alignment: .trailing)
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
                            }
                        }
                        .frame(width: width-40)
                        .padding(.horizontal,20)
                    
                    }
                }
        }
    }
}

struct ActivityStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityStatusView(activityType: "Energy Burned", quantity: 40, score: 60, image: "flame", measure: "Kcal", width: 700, record: 100)
    }
}
