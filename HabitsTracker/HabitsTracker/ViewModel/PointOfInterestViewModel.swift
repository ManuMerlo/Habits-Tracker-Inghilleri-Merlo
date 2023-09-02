import Foundation
import MapKit
import SwiftUI
import CoreLocation

final class PointOfInterestViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    var locationManager = CLLocationManager()
    
    @Published var location: CLLocation? = nil
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.4655, longitude: 9.1865), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @Published var landmarks: [Landmark] = []
    
    override init() {
           super.init()
           self.setupLocationManager()
           self.getNearByDefaultLandmarks()
       }

    private func setupLocationManager() {
           locationManager = CLLocationManager()
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.distanceFilter = kCLDistanceFilterNone
           checkIfLocationServiceIsEnabled()
    }
    
    func checkIfLocationServiceIsEnabled(){
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func checkLocationAuthorization(){
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            //TODO: show an alert
            print("You're location is restricted")
            
        case .denied:
            //TODO: show an alert
            print("You're location is denied")
            
        case .authorizedAlways, .authorizedWhenInUse:
           print("ok")
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        if landmarks.isEmpty {
            getNearByDefaultLandmarks()
        }
    }
    
    func getNearByLandmarks(search: String) {
        
        guard let userLocation = location else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        request.region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
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
    
    
    func getNearByDefaultLandmarks() {
        
        guard let userLocation = location else { return }
        
        let searchTerms = ["gyms", "parks", "lakes", "sports arenas", "trails"]
        
        self.landmarks = []
        
        for term in searchTerms {
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = term
            request.region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            
            let search = MKLocalSearch(request: request)
            
            search.start { (response, error) in
                if let response = response {
                    
                    let mapItems = response.mapItems
                    let newLandmarks = mapItems.map {
                        Landmark(placemark: $0.placemark)
                    }
                    self.landmarks.append(contentsOf: newLandmarks)
                }
                
            }
        }
    }
}




