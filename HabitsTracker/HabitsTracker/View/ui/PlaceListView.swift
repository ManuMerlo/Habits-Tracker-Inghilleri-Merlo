import SwiftUI
import MapKit
import Contacts

struct PlaceListView: View {
    
    let landmarks: [Landmark]
    var onTap: () -> ()
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            HStack {
                Text("Open Details")
                    .font(.title)
                    .foregroundColor(.white)
            }.frame(width: UIScreen.main.bounds.size.width, height: 60)
                .background(Color("oxfordBlue"))
                .gesture(TapGesture()
                    .onEnded(self.onTap)
            )
            List {
                ForEach(self.landmarks, id: \.id) { landmark in
                    
                    VStack(alignment: .leading) {
                        Text(landmark.name)
                            .fontWeight(.bold)
                        
                        Text(landmark.title)
                    }
                }
                
            }.scrollContentBackground(.hidden)
        }
        .background(Color("delftBlue"))
        .cornerRadius(10)
    }
}

struct PlaceListView_Previews: PreviewProvider {
    static var previews: some View {
            let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco's coordinates
            let mockPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: [CNPostalAddressStreetKey: "San Francisco"])
            return PlaceListView(landmarks: [Landmark(placemark: mockPlacemark)], onTap: {})
        }
}
