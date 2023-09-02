import SwiftUI
import MapKit
import Contacts

struct PlaceListView: View {
    
    let landmarks: [Landmark]
    
    @Binding var selectedLandmark: Landmark?

    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            List {
                ForEach(self.landmarks, id: \.id) { landmark in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(landmark.name)
                            .fontWeight(.bold)
                        Text(landmark.title)
                    }.onTapGesture {
                        selectedLandmark = landmark
                    }
                }
                .listRowBackground(Color("oxfordBlue"))
                .listRowSeparatorTint(.white.opacity(0.8))
                .foregroundColor(.white.opacity(0.8))
                
            }
            .listStyle(PlainListStyle())
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .scrollContentBackground(.hidden)
        }
        .cornerRadius(15)
        .background(
            RoundedRectangle(cornerRadius: 15) //
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                .shadow(color: .black, radius: 5)
        )
    }
}
