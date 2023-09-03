import XCTest
import MapKit
import CoreLocation
import Combine
@testable import HabitsTracker

@MainActor
class PointsOfInterestViewModelTests: XCTestCase {
    var viewModel: PointsOfInterestViewModel?
    var mockDataSource: MockPointOfInterestDataSource?
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        mockDataSource = MockPointOfInterestDataSource()
        if let mockDataSource = mockDataSource{
            viewModel = PointsOfInterestViewModel(withRepository: PointsOfInterestRepository(withDataSource: mockDataSource))
        }
            
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockDataSource = nil
    }

    func testLocationUpdate() throws {
        guard let viewModel = viewModel, let mockDataSource = mockDataSource else {
            XCTFail()
            return
        }
        
        let expectation = XCTestExpectation(description: "Location update")
        let testLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        viewModel.$location
            .sink { location in
                if let location = location {
                    XCTAssertEqual(location.coordinate.latitude, testLocation.coordinate.latitude)
                    XCTAssertEqual(location.coordinate.longitude, testLocation.coordinate.longitude)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        mockDataSource.updateLocation(testLocation)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetNearByLandmarks() async throws {
        //Given
        let landamarks = getSampleLandmarks()
        let mockDataSource = MockPointOfInterestDataSource(fakeLandmarks: landamarks)
        let viewModel = PointsOfInterestViewModel(withRepository: PointsOfInterestRepository(withDataSource: mockDataSource))
        
        //When
        viewModel.getNearByLandmarks(search: "Colosseum")
        
        let task = viewModel.tasks.last
        let _ = await task?.result
        
        XCTAssertEqual(viewModel.landmarks, landamarks)
        
    }

    func testGetNearByDefaultLandmarks() async throws {
        let landamarks = getSampleLandmarks()
        let mockDataSource = MockPointOfInterestDataSource(fakeLandmarks: landamarks)
        let viewModel = PointsOfInterestViewModel(withRepository: PointsOfInterestRepository(withDataSource: mockDataSource))
        
        //When
        viewModel.getNearByDefaultLandmarks()
        
        let task = viewModel.tasks.last
        let _ = await task?.result
        
        XCTAssertEqual(viewModel.landmarks,landamarks)
    
    }
}

struct SamplePlacemark{
    let name: String
    let title: String
    let coordinate: CLLocationCoordinate2D
}

func getSampleLandmarks() -> [Landmark] {
    let italianPlacemarks: [SamplePlacemark] = [
        SamplePlacemark(name: "Colosseum", title: "Ancient Amphitheater", coordinate: CLLocationCoordinate2D(latitude: 41.890251, longitude: 12.492373)),
        SamplePlacemark(name: "Leaning Tower of Pisa", title: "Famous Bell Tower", coordinate: CLLocationCoordinate2D(latitude: 43.723032, longitude: 10.396604)),
        SamplePlacemark(name: "Venice", title: "City of Canals", coordinate: CLLocationCoordinate2D(latitude: 45.440847, longitude: 12.315515)),
    ]

    let parkPlacemarks: [SamplePlacemark] = [
        SamplePlacemark(name: "City Park", title: "Relax and Enjoy Nature", coordinate: CLLocationCoordinate2D(latitude: 41.900776, longitude: 12.483648)),
        SamplePlacemark(name: "Villa Borghese", title: "Beautiful Garden", coordinate: CLLocationCoordinate2D(latitude: 41.912857, longitude: 12.485935)),
    ]
    
    let gymPlacemarks: [SamplePlacemark] = [
        SamplePlacemark(name: "Fitness Center", title: "Stay Fit and Healthy", coordinate: CLLocationCoordinate2D(latitude: 41.902808, longitude: 12.455966)),
    ]
    
    let sportsArenaPlacemarks: [SamplePlacemark] = [
        SamplePlacemark(name: "Stadio Olimpico", title: "Sports Stadium", coordinate: CLLocationCoordinate2D(latitude: 41.933368, longitude: 12.454895)),
    ]
    
    let allPlacemarks = italianPlacemarks + parkPlacemarks + gymPlacemarks + sportsArenaPlacemarks
    
    var landmarks: [Landmark] = []
    
    for placemark in allPlacemarks {
        let placemark = MKPlacemark(coordinate: placemark.coordinate, addressDictionary: nil)
        let landmark = Landmark(placemark: placemark)
        landmarks.append(landmark)
    }
    return landmarks
    

}
