import Foundation
import SwiftUI
import MapKit

import Foundation
import SwiftUI
import MapKit

class Coordinator: NSObject, MKMapViewDelegate {
    
    var control: MapView
    
    init(_ control: MapView) {
        self.control = control
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let annotationView = views.first {
            if let annotation = annotationView.annotation {
                if annotation is MKUserLocation {
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? LandmarkAnnotation {
            // Access the landmark from the annotation
            let selectedLandmark = annotation.landmark
            // Handle the tap event
            handleLandmarkTap(landmark: selectedLandmark)
        }
    }
        
    func handleLandmarkTap(landmark: Landmark) {
        control.selectedLandmark = landmark
    }
}

struct MapView: UIViewRepresentable {
    
    let landmarks: [Landmark]
    @Binding var region: MKCoordinateRegion
    @Binding var selectedLandmark: Landmark?
    
    func makeUIView(context: Context) -> MKMapView {
           let map = MKMapView()
           map.showsUserLocation = true
           map.delegate = context.coordinator
           map.setRegion(region, animated: false)
           return map
       }
     
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        updateAnnotations(from: uiView)
        
        if let landmark = selectedLandmark {
            let region = MKCoordinateRegion(center: landmark.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            uiView.setRegion(region, animated: true)
        } else {
            // The following line will set the region to the user's location when the location is updated
            uiView.setRegion(region, animated: true)
        }
    }

    private func updateAnnotations(from mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        let annotations = self.landmarks.map(LandmarkAnnotation.init)
        mapView.addAnnotations(annotations)
    }
}
