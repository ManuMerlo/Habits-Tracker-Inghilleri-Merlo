//
//  IntroView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 25/11/22.
//

import SwiftUI

struct IntroView: View {
    @State private var selectedPage = 0
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    var body: some View {
        NavigationView {
            VStack{
                ZStack{
                    let circle = Circle().frame(width: 500, height: 500)
                        .offset(x: 0, y: -190)
                    
                    let white_circle = Circle()
                        .frame(width: 600, height: 600)
                        .foregroundColor(.white)
                        .offset(x: 0, y: -290)
                    
                    TabView(selection: $selectedPage)
                    {
                        ForEach(0..<3) {
                            index in Card(card: data[index]).tag(index).offset(y:25)
                        }
                        
                    }
                    .onAppear() {
                        UIPageControl.appearance().currentPageIndicatorTintColor = .black
                        UIPageControl.appearance().pageIndicatorTintColor = .gray
                    }
                    .offset(y:-10)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode:.automatic))
                    .onReceive(timer){ time in
                        selectedPage = (selectedPage + 1) % 3
                    }
                    
                    //Selected Pages
                    if selectedPage == 0 {
                        circle.foregroundColor(.blue)
                        white_circle
                        ZStack{
                            LottieView(filename: "notes")
                                .frame(width:450, height: 450)
                                .clipShape(Circle())
                                .shadow(color: .orange, radius: 1, x: 0, y: 0)
                                .offset(x: 0, y: -180)
                        }
                    }
                    
                    if selectedPage == 1 {
                        circle.foregroundColor(.purple)
                        white_circle
                        ZStack{
                            LottieView(filename: "share")
                                .frame(width: 450, height: 450)
                                .shadow(color: .orange, radius: 1, x: 0, y: 0)
                                .clipShape(Circle())
                                .offset(x: 10, y: -180)
                        }
                        
                    }
                    
                    if selectedPage == 2 {
                        circle.foregroundColor(.pink)
                        white_circle
                        ZStack {
                            LottieView(filename: "plan_activities")
                                .frame(width: 450, height: 450)
                                .shadow(color: .orange, radius: 1, x: 0, y: 0)
                                .clipShape(Circle())
                                .offset(x: 0, y: -180)
                        }
                    }
                    
                }
                
                NavigationLink {
                    SigninView(authenticationViewModel: authenticationViewModel)
                } label: {
                    Text("Skip")
                        .fontWeight(.semibold)
                        .frame(width: 180, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
        }
    }
    
    @ViewBuilder
    func Card(card : Card) -> some View {
        VStack(alignment: .center, spacing: 17.0) {
            Text(card.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(card.description)
                .font(.system(size: 24))
                .fontWeight(.light)
                .multilineTextAlignment(.center)
                .frame(width: 300)
            
        }.padding(.horizontal, 40)
            .offset(y: 160)
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView(authenticationViewModel: AuthenticationViewModel())
    }
}
