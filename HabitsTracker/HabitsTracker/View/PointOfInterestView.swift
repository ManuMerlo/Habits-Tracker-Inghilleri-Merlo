import SwiftUI
import Foundation
import MapKit

struct PointOfInterestView: View {
    @ObservedObject var locationManager = LocationManager()
    
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var search: String = ""
    @State private var tapped: Bool = false
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State private var device : Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State var width = UIScreen.main.bounds.width
    @State var height = UIScreen.main.bounds.height
    
    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(landmarks: landmarks)
            TextField("Search", text: $search, onEditingChanged: { _ in })
            {
                if !search.isEmpty{
                    self.getNearByLandmarks()
                } else {
                    self.getNearByDefaultLandmarks()
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .offset(y: 44)
            
            PlaceListView(landmarks: self.landmarks) {
                            // on tap
                            self.tapped.toggle()
                        }.animation(.spring(), value: tapped)
                        .offset(y: calculateOffset())
                        
        }.ignoresSafeArea()
        .onAppear(){
                getNearByDefaultLandmarks()
        }
    }
    
    private func getNearByLandmarks() {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let response = response {
                
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                }
                
            }
            
        }
    }
    
    private func getNearByDefaultLandmarks() {
        
        let searchTerms = ["gyms", "parks", "lakes", "sports arenas", "trails"]
        
        for term in searchTerms {
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = term
            
            let search = MKLocalSearch(request: request)
            
            search.start { (response, error) in
                if let response = response {
                    
                    let newLandmarks = response.mapItems.map {
                        Landmark(placemark: $0.placemark)
                    }
                    
                    self.landmarks.append(contentsOf: newLandmarks)
                    
                }
            }
        }
    }

    
    func calculateOffset() -> CGFloat {
        if self.landmarks.count > 0 && !self.tapped {
            return height - height / 10
        }
        else if self.tapped {
            return 100
        } else {
            return height
        }
    }
    
}


struct PointOfInterestView_Previews: PreviewProvider {
    static var previews: some View {
        PointOfInterestView()
    }
}
