import Foundation
import MapKit
import CoreLocation
import Combine

protocol PointOfInterestDataSourceProtocol {
    
    /// Returns a publisher that emits location updates.
    func getLocationPublisher() -> AnyPublisher<CLLocation?, Never>
    
    /// Responds to changes in the location manager's authorization status.
    /// - Parameter manager: The location manager whose authorization status changed.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    
    /// Fetches nearby landmarks based on a search query.
    /// - Parameter search: The search term to find nearby landmarks.
    /// - Returns: An array of `Landmark` objects matching the search query.
    func getNearByLandmarks(search: String) async -> [Landmark]
    
    /// Fetches a predefined set of nearby landmarks.
    /// - Returns: An array of `Landmark` objects based on predefined criteria.
    func getNearByDefaultLandmarks() async -> [Landmark]
}

/// DataSource responsible for fetching points of interest using device location.
/// Implements the `CLLocationManagerDelegate` and `PointOfInterestDataSourceProtocol`.
final class PointsOfInterestDataSource: NSObject, CLLocationManagerDelegate, PointOfInterestDataSourceProtocol {
    
    var locationManager = CLLocationManager()
    
    private var location: CLLocation?
    
    var publisher: PassthroughSubject<CLLocation?, Never> = PassthroughSubject()
    
    /// Initializes and sets up the location manager.
    override init() {
        super.init()
        self.setupLocationManager()
    }
    
    /// Returns a publisher that emits location updates.
    func getLocationPublisher() -> AnyPublisher<CLLocation?, Never> {
        return publisher.eraseToAnyPublisher()
    }
    
    /// Responds to changes in the location manager's authorization status.
    /// - Parameter manager: The location manager whose authorization status changed.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    /// Responds to location manager updates.
    /// - Parameter manager: The location manager that updated the locations.
    /// - Parameter locations: An array of new location data.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        self.location = location
        publisher.send(self.location!)
    }
    
    /// Fetches nearby landmarks based on a given search query.
    /// - Parameter search: The search term.
    /// - Returns: An array of `Landmark` objects matching the search query.
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
    
    /// Fetches a predefined set of nearby landmarks.
    /// - Returns: An array of `Landmark` objects based on predefined criteria.
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
    
    /// Sets up the location manager.
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    /// Checks and handles the location authorization status.
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
}



