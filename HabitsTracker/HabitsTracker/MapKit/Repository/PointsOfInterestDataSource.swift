import Foundation
import MapKit
import CoreLocation
import Combine

protocol PointOfInterestDataSourceProtocol {
    func getLocationPublisher() -> AnyPublisher<CLLocation?, Never>
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    func getNearByLandmarks(search: String) async -> [Landmark]
    func getNearByDefaultLandmarks() async -> [Landmark]
}

final class PointsOfInterestDataSource: NSObject, CLLocationManagerDelegate, PointOfInterestDataSourceProtocol {
    
    var locationManager = CLLocationManager()
    
    private var location: CLLocation?
    
    var publisher: PassthroughSubject<CLLocation?, Never> = PassthroughSubject()
    
    override init() {
        super.init()
        self.setupLocationManager()
    }

    func getLocationPublisher() -> AnyPublisher<CLLocation?, Never> {
        return publisher.eraseToAnyPublisher()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    private func checkLocationAuthorization() {
        DispatchQueue.global().async {
            switch self.locationManager.authorizationStatus {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
            case .restricted:
                self.publisher.send(nil)
                print("You're location is restricted")
            case .denied:
                self.publisher.send(nil)
                self.location = nil
                print("You're location is denied")
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
            @unknown default:
                break
            }
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
        publisher.send(self.location!)
    }
    
    func getNearByLandmarks(search: String) async -> [Landmark] {
        var landmarks: [Landmark] = []
        if let location = self.location {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = search
            request.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            if let res = response {
                let mapItems = res.mapItems
                landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                }
            }
        }
        return landmarks
    }
    
    
    func getNearByDefaultLandmarks() async -> [Landmark] {
        let searchTerms = ["gyms", "parks", "sports arenas", "trails"]
        
        var landmarks: [Landmark] = []
        if let location = self.location {
            for term in searchTerms {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = term
                request.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                let search = MKLocalSearch(request: request)
                let response = try? await search.start()
                if let res = response {
                    let mapItems = res.mapItems
                    let newLandmarks = mapItems.map {
                        Landmark(placemark: $0.placemark)
                    }
                    landmarks.append(contentsOf: newLandmarks)
                }

            }
        }
        return landmarks
    }
}



