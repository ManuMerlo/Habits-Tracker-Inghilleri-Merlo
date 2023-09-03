@testable import HabitsTracker
import MapKit
import CoreLocation

import Foundation
import Combine

class MockPointOfInterestDataSource: PointOfInterestDataSourceProtocol {
    var locationSubject = CurrentValueSubject<CLLocation?, Never>(nil)
    var nearbyLandmarks: [Landmark] = []
    init(initialLocation: CLLocation? = nil, fakeLandmarks: [Landmark] = []) {
           locationSubject.send(initialLocation)
           self.nearbyLandmarks = fakeLandmarks
       }

    func getLocationPublisher() -> AnyPublisher<CLLocation?, Never> {
        return locationSubject.eraseToAnyPublisher()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }

    func getNearByLandmarks(search: String) async -> [Landmark] {
        try? await Task.sleep(nanoseconds: 1) // Simulate async delay
        return nearbyLandmarks
    }

    func getNearByDefaultLandmarks() async -> [Landmark] {
        try? await Task.sleep(nanoseconds: 1) // Simulate async delay
        return nearbyLandmarks
    }

    // Helper method to update location subject
    func updateLocation(_ location: CLLocation?) {
        locationSubject.send(location)
    }

}


