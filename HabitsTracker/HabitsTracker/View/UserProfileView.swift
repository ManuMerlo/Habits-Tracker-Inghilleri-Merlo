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
        GeometryReader{geometry in
            
            ZStack{
                
                BadgeBackground().frame(width: 600,height: 600)
                    .rotationEffect(Angle(degrees: -50))
                    .offset(x:20,y:-130)
                
                
                HStack{
                    if let image = user.image{
                        Image(image)
                            .resizable()
                            .clipped()
                            .clipShape(Circle())
                            .aspectRatio(contentMode: ContentMode.fill)
                            .frame(width: geometry.size.width/7,height: geometry.size.width/7)
                            .padding(.trailing,10)
                            .offset(y:-37)
                        
                        
                    }
                    
                    VStack(alignment: .leading){
                        HStack{
                            VStack(alignment: .leading){
                                if let username = user.username{
                                    Text(username)
                                        .font(.custom("Open Sans", size: 25))
                                        .foregroundColor(.white)
                                        .padding(.bottom,1)
                                    
                                }
                                
                                HStack{
                                    Image(systemName: "mappin.and.ellipse").foregroundColor(.white)
                                    Text("Country")
                                        .foregroundColor(.white)
                                        .font(.custom("Open Sans", size: 15))
                                }
                            }
                            Spacer()
                            
                            Button {
                                //TODO: add friend
                            } label: {
                                Text("Follow")
                                    .font(.custom("Open Sans", size: 18))
                            }.buttonStyle(.borderedProminent)
                                .foregroundColor(.purple)
                                .tint(.white)
                        }.padding(.bottom,20)
                        
                        HStack{
                            VerticalText(upperText: "1000", lowerText: "Daily")
                            
                            Spacer()
                            VerticalText(upperText: "1000", lowerText: "Weekly")
                            
                            Spacer()
                            
                            VerticalText(upperText: "1000", lowerText: "Friends")
                        }
                        
                    }
                }.frame(width:geometry.size.width/1.2,height: 30)
                
            }.offset(x:-100,y:-220)
        }
    }
}


struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(user:UserList.usersGlobal[1])
    }
}

struct BadgeBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                var width: CGFloat = min(geometry.size.width, geometry.size.height)
                let height = width
                let xScale: CGFloat = 0.832
                let xOffset = (width * (1.0 - xScale)) / 2.0
                width *= xScale
                path.move(
                    to: CGPoint(
                        x: width * 0.95 + xOffset,
                        y: height * (0.20 + HexagonParameters.adjustment)
                    )
                )
                
                
                HexagonParameters.segments.forEach { segment in
                    path.addLine(
                        to: CGPoint(
                            x: width * segment.line.x + xOffset,
                            y: height * segment.line.y
                        )
                    )
                    
                    
                    path.addQuadCurve(
                        to: CGPoint(
                            x: width * segment.curve.x + xOffset,
                            y: height * segment.curve.y
                        ),
                        control: CGPoint(
                            x: width * segment.control.x + xOffset,
                            y: height * segment.control.y
                        )
                    )
                }
            }
            .fill(.linearGradient(
                Gradient(colors: [Self.gradientEnd, .purple]),
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 0.6)
            ))
        }
        .aspectRatio(1, contentMode: .fit)
    }
    static let gradientStart = Color(red: 239.0 / 255, green: 120.0 / 255, blue: 221.0 / 255)
    static let gradientEnd = Color(red: 239.0 / 255, green: 172.0 / 255, blue: 120.0 / 255)
}

import CoreGraphics


struct HexagonParameters {
    struct Segment {
        let line: CGPoint
        let curve: CGPoint
        let control: CGPoint
    }
    
    
    static let adjustment: CGFloat = 0.085
    
    
    static let segments = [
        Segment(
            line:    CGPoint(x: 0.60, y: 0.05),
            curve:   CGPoint(x: 0.40, y: 0.05),
            control: CGPoint(x: 0.50, y: 0.00)
        ),
        Segment(
            line:    CGPoint(x: 0.05, y: 0.20 + adjustment),
            curve:   CGPoint(x: 0.00, y: 0.30 + adjustment),
            control: CGPoint(x: 0.00, y: 0.25 + adjustment)
        ),
        Segment(
            line:    CGPoint(x: 0.00, y: 0.70 - adjustment),
            curve:   CGPoint(x: 0.05, y: 0.80 - adjustment),
            control: CGPoint(x: 0.00, y: 0.75 - adjustment)
        ),
        Segment(
            line:    CGPoint(x: 0.40, y: 0.95),
            curve:   CGPoint(x: 0.60, y: 0.95),
            control: CGPoint(x: 0.50, y: 1.00)
        ),
        Segment(
            line:    CGPoint(x: 0.95, y: 0.80 - adjustment),
            curve:   CGPoint(x: 1.00, y: 0.70 - adjustment),
            control: CGPoint(x: 1.00, y: 0.75 - adjustment)
        ),
        Segment(
            line:    CGPoint(x: 1.00, y: 0.30 + adjustment),
            curve:   CGPoint(x: 0.95, y: 0.20 + adjustment),
            control: CGPoint(x: 1.00, y: 0.25 + adjustment)
        )
    ]
}

@ViewBuilder
func VerticalText(upperText: String, lowerText:String) -> some View {
    VStack(alignment: .center){
        
        Text(upperText).foregroundColor(.white)
            .font(.custom("Open Sans", size: 22))
            .padding(.bottom,1)
        Text(lowerText).foregroundColor(.white)
            .font(.custom("Open Sans", size: 15))
    }
}
