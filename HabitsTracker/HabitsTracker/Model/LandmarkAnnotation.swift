import Foundation
import MapKit

import Foundation
import MapKit

class LandmarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let landmark: Landmark

    init(landmark: Landmark) {
        self.title = landmark.name
        self.coordinate = landmark.coordinate
        self.landmark = landmark
    }
}
