import Foundation
import MapKit
import SwiftUI
import Combine

@MainActor
final class PointsOfInterestViewModel: ObservableObject {
    private let pointsOfInterestRepository: PointsOfInterestRepository
    @Published var location: CLLocation? = nil
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.4655, longitude: 9.1865), span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
    
    @Published var landmarks: [Landmark] = []

    private(set) var tasks: [Task<Void, Never>] = []
    
    private var cancellables: Set<AnyCancellable> = []
 
    //Production
    init(pointsOfInterestRepository: PointsOfInterestRepository = PointsOfInterestRepository()) {
        self.pointsOfInterestRepository = pointsOfInterestRepository
        subscribeToUpdates()
    }
    
    //Testing
    init(withRepository pointsOfInterestRepository: PointsOfInterestRepository) {
        self.pointsOfInterestRepository = pointsOfInterestRepository
        subscribeToUpdates()
    }
    
    // function to cancel all tasks
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }

    private func subscribeToUpdates() {
        pointsOfInterestRepository.getLocationPublisher()
            .receive(on: DispatchQueue.main) // Switch to the main thread
            .sink { [weak self] location in
                self?.location = location
                if let location = location {
                    self?.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
                    self?.getNearByDefaultLandmarks()
                } else {
                    self?.landmarks = []
                }
            }
            .store(in: &cancellables)
    }
    
    func getNearByLandmarks(search: String) {
        let task = Task {
            self.landmarks = await pointsOfInterestRepository.getNearByLandmarks(search: search)
        }
        tasks.append(task)
    }
    
    func getNearByDefaultLandmarks() {
        let task = Task {
            self.landmarks = await pointsOfInterestRepository.getNearByDefaultLandmarks()
        }
        tasks.append(task)
    }
    
}




