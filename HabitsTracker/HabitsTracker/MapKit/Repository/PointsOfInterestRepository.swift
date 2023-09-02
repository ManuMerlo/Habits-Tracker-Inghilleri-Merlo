import Foundation
import Combine
import MapKit

final class PointsOfInterestRepository {
    private var cancellables: Set<AnyCancellable> = []
    
    var pointsOfInterestDataSource: PointOfInterestDataSourceProtocol
    
    init(pointsOfInterestDataSource: PointOfInterestDataSourceProtocol = PointsOfInterestDataSource()) {
        self.pointsOfInterestDataSource = pointsOfInterestDataSource
    }
       
    //Second initializer for test purposes
    init(withDataSource pointsOfInterestDataSource: PointOfInterestDataSourceProtocol) {
        self.pointsOfInterestDataSource = pointsOfInterestDataSource
    }
    
    func getLocationPublisher() -> AnyPublisher<CLLocation, Never> {
           return pointsOfInterestDataSource.getLocationPublisher()
    }
    
    func getNearByLandmarks(search: String) async -> [Landmark] {
        return await pointsOfInterestDataSource.getNearByLandmarks(search: search)
    }
    
    func getNearByDefaultLandmarks() async -> [Landmark] {
        return await pointsOfInterestDataSource.getNearByDefaultLandmarks()
    }
}


