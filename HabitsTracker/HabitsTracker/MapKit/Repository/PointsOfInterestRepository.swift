import Foundation
import Combine
import MapKit

final class PointsOfInterestRepository {
    private var cancellables: Set<AnyCancellable> = []
    
    var pointsOfInterestDataSource: PointOfInterestDataSourceProtocol
    
    /// Initializes a new instance of the repository with a given data source or a default one.
    ///
    /// - Parameter pointsOfInterestDataSource: The data source for accessing points of interest data.
    ///   Defaults to `PointsOfInterestDataSource`.
    init(pointsOfInterestDataSource: PointOfInterestDataSourceProtocol = PointsOfInterestDataSource()) {
        self.pointsOfInterestDataSource = pointsOfInterestDataSource
    }
    
    /// Initializes a new instance of the repository specifically for testing.
    ///
    /// - Parameter pointsOfInterestDataSource: The mock data source for accessing points of interest data during testing.
    init(withDataSource pointsOfInterestDataSource: PointOfInterestDataSourceProtocol) {
        self.pointsOfInterestDataSource = pointsOfInterestDataSource
    }
    
    /// Provides a publisher for location updates.
    ///
    /// - Returns: A publisher emitting `CLLocation` updates.
    func getLocationPublisher() -> AnyPublisher<CLLocation?, Never> {
        return pointsOfInterestDataSource.getLocationPublisher()
    }
    
    /// Fetches nearby landmarks based on a given search query.
    ///
    /// - Parameter search: The search term.
    /// - Returns: An array of `Landmark` objects matching the search query.
    func getNearByLandmarks(search: String) async -> [Landmark] {
        return await pointsOfInterestDataSource.getNearByLandmarks(search: search)
    }
    
    /// Fetches a predefined set of nearby landmarks.
    ///
    /// - Returns: An array of `Landmark` objects based on predefined criteria.
    func getNearByDefaultLandmarks() async -> [Landmark] {
        return await pointsOfInterestDataSource.getNearByDefaultLandmarks()
    }
}


