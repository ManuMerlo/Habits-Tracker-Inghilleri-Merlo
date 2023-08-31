@testable import HabitsTracker
import Foundation
import XCTest
import HealthKit

@MainActor
final class HealthViewModelTests: XCTestCase {
    private var viewModel: HealthViewModel?
   
    override func setUp() {
        super.setUp()
        let mockRepository = HealthRepository(withDataSource:MockHealthDataSource())
        viewModel = HealthViewModel(withRepository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func test_HealthViewModel_init_shouldSetValuesCorrectly() {
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let allMyTypes: [BaseActivity] = [
            BaseActivity(id: "activeEnergyBurned", quantity: 0),
            BaseActivity(id: "appleExerciseTime", quantity: 0),
            BaseActivity(id: "appleStandTime", quantity: 0),
            BaseActivity(id: "distanceWalkingRunning", quantity: 0),
            BaseActivity(id: "stepCount", quantity: 0),
            BaseActivity(id: "distanceCycling", quantity: 0),
        ]

        XCTAssertEqual(vm.dailyScore, 0)
        XCTAssertEqual(vm.singleScore, [:])
        XCTAssertEqual(vm.allMyTypes, allMyTypes)
    }
    
    func test_HealthViewModel_ComputeSingleScore_withSuccess() {
        //Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let activityBurned = Int.random(in: 0...300)
        let exerciseTime = Int.random(in: 0...100)
        let standTime = Int.random(in: 0...100)
        let distance = Int.random(in: 0...30)
        let stepCount = Int.random(in: 0...30000)
        let distanceCycling = Int.random(in: 0...30)
        let allMyTypes: [BaseActivity] = [
            BaseActivity(id: "activeEnergyBurned", quantity: activityBurned),
            BaseActivity(id: "appleExerciseTime", quantity: exerciseTime),
            BaseActivity(id: "appleStandTime", quantity: standTime),
            BaseActivity(id: "distanceWalkingRunning", quantity: distance),
            BaseActivity(id: "stepCount", quantity: stepCount),
            BaseActivity(id: "distanceCycling", quantity: distanceCycling),
        ]
        
        //When
        vm.allMyTypes = allMyTypes
        vm.computeSingleScore()
        
        //Then
        XCTAssertEqual(vm.singleScore["activeEnergyBurned"], Int(round(Double(activityBurned) * 0.2)))
        XCTAssertEqual(vm.singleScore["appleExerciseTime"], Int(round(Double(exerciseTime))))
        XCTAssertEqual(vm.singleScore["appleStandTime"], Int(round(Double(standTime) * 0.03)))
        XCTAssertEqual(vm.singleScore["distanceWalkingRunning"], Int(round(Double(distance) * 5)))
        XCTAssertEqual(vm.singleScore["stepCount"], Int(round(Double(stepCount) * 0.005)))
        XCTAssertEqual(vm.singleScore["distanceCycling"], Int(round(Double(distanceCycling) * 3)))
    }
    
    func test_HealthViewModel_ComputeTotalScore_withSuccess() {
        //Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let activityBurned = Int.random(in: 0...300)
        let exerciseTime = Int.random(in: 0...100)
        let standTime = Int.random(in: 0...100)
        let distance = Int.random(in: 0...30)
        let stepCount = Int.random(in: 0...30000)
        let distanceCycling = Int.random(in: 0...30)
        let dailyScore = activityBurned + exerciseTime + standTime + distance + stepCount + distanceCycling
        
        let singleScore: [String : Int] = [
            "activeEnergyBurned" : activityBurned,
            "appleExerciseTime" : exerciseTime,
            "appleStandTime" : standTime,
            "distanceWalkingRunning" : distance,
            "stepCount" : stepCount,
            "distanceCycling" : distanceCycling
        ]
        
        //When
        vm.singleScore = singleScore
        vm.computeTotalScore()
        
        //Then
        XCTAssertEqual(vm.dailyScore, dailyScore)
    }
    
    func test_HealthViewModel_updateRecords_shouldBeTrue() {
        //Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let activityBurned = Int.random(in: 0...300)
        let exerciseTime = Int.random(in: 0...100)
        let standTime = Int.random(in: 0...100)
        let distance = Int.random(in: 0...30)
        let stepCount = Int.random(in: 0...30000)
        let distanceCycling = Int.random(in: 0...30)

        let offset = Int.random(in: 0...200)
        
        var records: [BaseActivity] = [
           BaseActivity(id: "activeEnergyBurned", quantity: activityBurned),
           BaseActivity(id: "appleExerciseTime", quantity: exerciseTime),
           BaseActivity(id: "appleStandTime", quantity: standTime),
           BaseActivity(id: "distanceWalkingRunning", quantity: distance),
           BaseActivity(id: "stepCount", quantity: stepCount),
           BaseActivity(id: "distanceCycling", quantity: distanceCycling),
       ]
        
         let allMyTypes: [BaseActivity] = [
            BaseActivity(id: "activeEnergyBurned", quantity: activityBurned + offset),
            BaseActivity(id: "appleExerciseTime", quantity: exerciseTime),
            BaseActivity(id: "appleStandTime", quantity: standTime),
            BaseActivity(id: "distanceWalkingRunning", quantity: distance),
            BaseActivity(id: "stepCount", quantity: stepCount),
            BaseActivity(id: "distanceCycling", quantity: distanceCycling),
        ]
        
        //When
        vm.allMyTypes = allMyTypes
        let result = vm.updateRecords(records: &records)
        
        //Then
        XCTAssertTrue(result)
        XCTAssertEqual(records[0].quantity, activityBurned + offset)
        XCTAssertEqual(records[0].timestamp, Calendar.current.startOfDay(for: Date()).timeIntervalSince1970)
        
    }
    
    func test_HealthViewModel_updateRecords_shouldBeFalse() {
        //Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let activityBurned = Int.random(in: 0...300)
        let exerciseTime = Int.random(in: 0...100)
        let standTime = Int.random(in: 0...100)
        let distance = Int.random(in: 0...30)
        let stepCount = Int.random(in: 0...30000)
        let distanceCycling = Int.random(in: 0...30)
                
        var records: [BaseActivity] = [
           BaseActivity(id: "activeEnergyBurned", quantity: activityBurned),
           BaseActivity(id: "appleExerciseTime", quantity: exerciseTime),
           BaseActivity(id: "appleStandTime", quantity: standTime),
           BaseActivity(id: "distanceWalkingRunning", quantity: distance),
           BaseActivity(id: "stepCount", quantity: stepCount),
           BaseActivity(id: "distanceCycling", quantity: distanceCycling),
       ]
        
         let allMyTypes = records
        
        //When
        vm.allMyTypes = allMyTypes
        let result = vm.updateRecords(records: &records)
        
        //Then
        XCTAssertFalse(result)
    }
    
    func test_HealthViewModel_requestAccessToHealthData() {
        //Given
        let activityBurned = Int.random(in: 0...300)
        let exerciseTime = Int.random(in: 0...100)
        let standTime = Int.random(in: 0...100)
        let distance = Int.random(in: 0...30)
        let stepCount = Int.random(in: 0...30000)
        let distanceCycling = Int.random(in: 0...30)
        let activities : [BaseActivity] = [
           BaseActivity(id: "activeEnergyBurned", quantity: activityBurned),
           BaseActivity(id: "appleExerciseTime", quantity: exerciseTime),
           BaseActivity(id: "appleStandTime", quantity: standTime),
           BaseActivity(id: "distanceWalkingRunning", quantity: distance),
           BaseActivity(id: "stepCount", quantity: stepCount),
           BaseActivity(id: "distanceCycling", quantity: distanceCycling),
       ]
        
        let mockReposiroty = HealthRepository(withDataSource:MockHealthDataSource(mockAccessResult: .success(true), mockStats: activities))
        viewModel = HealthViewModel(withRepository: mockReposiroty)
        
        //When
        viewModel?.requestAccessToHealthData()
        
        //Then
        XCTAssertEqual(viewModel?.allMyTypes, activities)
    }
        
}
