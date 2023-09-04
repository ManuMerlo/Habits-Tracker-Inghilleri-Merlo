import SwiftUI
import Foundation
import MapKit


struct PointsOfInterestView: View {
    @StateObject var pointsOfInterestViewModel = PointsOfInterestViewModel()
    
    @State private var search: String = ""
    @State private var selectedLandmark: Landmark?
    @State var width = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(spacing: 20){
            VStack(spacing: 0){
                Text("Points of Interests")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("HomeTitle")
                    .padding(.top,30)
                    .padding(.bottom,15)
                    .padding(.horizontal,15)
                    
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 1)
                    .foregroundColor(.white.opacity(0.5))
                    .shadow(color:.black,radius: 5)
                
            }
            .padding(.top,30)
            .background(Color("oxfordBlue"))
            
            ZStack(alignment: .top){

                // MapView
                MapView(landmarks: pointsOfInterestViewModel.landmarks, region: $pointsOfInterestViewModel.region, selectedLandmark: $selectedLandmark)
                    .frame(height: UIScreen.main.bounds.height/2)
                    .cornerRadius(15)
                    .background(
                        RoundedRectangle(cornerRadius: 15) //
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    ).padding(.horizontal,15)
                
                TextField("Search", text: $search, onEditingChanged: { _ in })
                {
                    if search != "" {
                        pointsOfInterestViewModel.getNearByLandmarks(search: search)
                    } else if search == "" {
                        pointsOfInterestViewModel.getNearByDefaultLandmarks()
                    }
                }
                .padding(20)
                .preferredColorScheme(.dark)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("oxfordBlue").opacity(0.95))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
                .padding(.vertical,15)
                .padding(.horizontal,30)
            }
            
            if pointsOfInterestViewModel.location == nil {
                VStack(){
                    Text("You have to allow User's location sharing in your phone settings.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(10)
                }
                .padding(15)
                .frame(width: width - 30)
                .background(.white.opacity(0.1))
                .cornerRadius(15)
                
            }
            
            // Conditionally show the VStack with landmark details at the bottom
            if let landmark = selectedLandmark {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 15) {
                        VStack(alignment: .center,spacing: 15) {
                            
                            Text(landmark.name)
                                .fontWeight(.bold)
                                .padding(.top,15)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 1)
                                .foregroundColor(.white.opacity(0.5))
                                .shadow(color:.black,radius: 5)
                            
                            Text(landmark.title)
                                .padding(.horizontal,15)
    
                            Button{
                                selectedLandmark = nil
                            }label: {
                                Text("Ok")
                                    .frame(width: 50)
                            }
                            .buttonStyle(.bordered)
                            .tint(.white)
                            .padding(.bottom,15)
                        }
 
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("oxfordBlue").opacity(0.95))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .frame(width: width/1.1)
                    .cornerRadius(8)
                    .shadow(radius: 10)
                    .padding(.bottom, 120)
                    
                }.cornerRadius(15)
                    
            }
            if !pointsOfInterestViewModel.landmarks.isEmpty && selectedLandmark == nil {
                PlaceListView(landmarks: pointsOfInterestViewModel.landmarks, selectedLandmark: $selectedLandmark)
                    .padding(.horizontal,15)
            } else {
                Spacer()
            }
            
        }.onDisappear {
            pointsOfInterestViewModel.cancelTasks()
        }
        .ignoresSafeArea()
        .background(RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
            .edgesIgnoringSafeArea(.all))
    }
 
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}


struct PointOfInterestView_Previews: PreviewProvider {
    static var previews: some View {
        PointsOfInterestView()
    }
}
