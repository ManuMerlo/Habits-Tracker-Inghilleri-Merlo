import Foundation
import MapKit
import SwiftUI
import Combine

/// A view model responsible for managing the state and behavior related to points of interest.
@MainActor
final class PointsOfInterestViewModel: ObservableObject {
    
    /// The repository instance that provides data regarding points of interest.
    private let pointsOfInterestRepository: PointsOfInterestRepository
    
    /// The current location of the user.
    @Published var location: CLLocation? = nil
    
    /// The region on the map that the user is currently viewing.
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.4655, longitude: 9.1865), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    /// The list of landmarks based on user's location or search query.
    @Published var landmarks: [Landmark] = []
    
    /// Active tasks related to fetching landmarks. Used for task management and cancellations.
    private(set) var tasks: [Task<Void, Never>] = []
    
    /// A set of `AnyCancellable` objects to hold references to Combine subscriptions.
    private var cancellables: Set<AnyCancellable> = []
    
    /// Initializes the view model with a given repository or a default one.
    ///
    /// - Parameter pointsOfInterestRepository: The repository for accessing points of interest data. Defaults to `PointsOfInterestRepository`.
    init(pointsOfInterestRepository: PointsOfInterestRepository = PointsOfInterestRepository()) {
        self.pointsOfInterestRepository = pointsOfInterestRepository
        subscribeToUpdates()
    }
    
    /// Initializes the view model specifically for testing.
    ///
    /// - Parameter pointsOfInterestRepository: The mock repository for accessing points of interest data during testing.
    init(withRepository pointsOfInterestRepository: PointsOfInterestRepository) {
        self.pointsOfInterestRepository = pointsOfInterestRepository
        subscribeToUpdates()
    }
    
    /// Cancels all active tasks.
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    /// Fetches landmarks based on a given search query.
    ///
    /// - Parameter search: The search term to query.
    func getNearByLandmarks(search: String) {
        let task = Task {
            self.landmarks = await pointsOfInterestRepository.getNearByLandmarks(search: search)
        }
        tasks.append(task)
    }
    
    /// Fetches a predefined set of landmarks based on the current location.
    func getNearByDefaultLandmarks() {
        let task = Task {
            self.landmarks = await pointsOfInterestRepository.getNearByDefaultLandmarks()
        }
        tasks.append(task)
    }
    
    /// Subscribes to location updates from the repository.
    private func subscribeToUpdates() {
        pointsOfInterestRepository.getLocationPublisher()
            .receive(on: DispatchQueue.main) // Switch to the main thread
            .sink { [weak self] location in
                self?.location = location
                if let location = location {
                    self?.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                    self?.getNearByDefaultLandmarks()
                } else {
                    self?.landmarks = []
                }
            }
            .store(in: &cancellables)
    }
}




