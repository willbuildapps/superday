@testable import teferi
import XCTest
import Foundation
import Nimble

class SmartGuessServiceTests : XCTestCase
{
    private typealias TestData = (distanceFromTarget: Double, category: teferi.Category, date: Date)
    private typealias LocationAndCategory = (location: Location, category: teferi.Category)
    
    private var timeService : MockTimeService!
    private var loggingService : MockLoggingService!
    private var settingsService : MockSettingsService!
    private var timeSlotService : MockTimeSlotService!
    private var date : Date { return timeService.now }
    
    private var smartGuessService : DefaultSmartGuessService!
    
    override func setUp()
    {
        timeService = MockTimeService()
        loggingService = MockLoggingService()
        settingsService = MockSettingsService()
        timeSlotService = MockTimeSlotService(timeService: timeService, locationService: MockLocationService())
        
        
        smartGuessService = DefaultSmartGuessService(timeService: timeService,
                                                     loggingService: loggingService,
                                                     settingsService: settingsService,
                                                     timeSlotService: timeSlotService)
    }
    
    func testMultipleFarAwayGuessesCanOutweighSingleCloseGuess()
    {
        let targetLocation = Location(timestamp: date,
                                      latitude: 41.9754219072948, longitude: -71.0230522245947)
        
        let testInput : [TestData] =
            [
                (distanceFromTarget: 08, category: .leisure, date: date.add(days: -1)),
                (distanceFromTarget: 50, category: .work, date: date.add(days: -1)),
                (distanceFromTarget: 54, category: .work, date: date.add(days: -1)),
                (distanceFromTarget: 59, category: .work, date: date.add(days: -1)),
                (distanceFromTarget: 66, category: .work, date: date.add(days: -1))
        ]
        
        timeSlotService.timeSlots = testInput
            .map(toLocation(offsetFrom: targetLocation))
            .map(toTimeSlot)
        
        let smartGuess = smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.work))
    }
    
    func testGuessesVeryCloseToTheLocationShouldOutweighMultipleGuessesSlightlyFurtherAway()
    {
        let targetLocation = Location(timestamp: date,
                                      latitude: 41.9754219072948, longitude: -71.0230522245947)
        
        let testInput : [TestData] =
        [
            (distanceFromTarget: 08, category: .leisure, date: date),
            (distanceFromTarget: 50, category: .work, date: date),
            (distanceFromTarget: 53, category: .leisure, date: date),
            (distanceFromTarget: 54, category: .work, date: date),
            (distanceFromTarget: 59, category: .work, date: date),
            (distanceFromTarget: 66, category: .work, date: date)
        ]
        
        timeSlotService.timeSlots =
            testInput
                .map(toLocation(offsetFrom: targetLocation))
                .map(toTimeSlot)
        
        let smartGuess = smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.leisure))
    }
    
    func testGuessesVeryCloseToTheLocationShouldOutweighMultipleGuessesSlightlyFurtherAwayEvenWithoutExtraGuessesHelpingTheWeight()
    {
        let targetLocation = Location(timestamp: date,
                                      latitude: 41.9754219072948, longitude: -71.0230522245947)
        
        let testInput : [TestData] =
        [
            (distanceFromTarget: 08, category: .leisure, date: date),
            (distanceFromTarget: 160, category: .work, date: date),
            (distanceFromTarget: 264, category: .work, date: date),
            (distanceFromTarget: 269, category: .work, date: date),
            (distanceFromTarget: 376, category: .work, date: date)
        ]
        
        timeSlotService.timeSlots =
            testInput
                .map(toLocation(offsetFrom: targetLocation))
                .map(toTimeSlot)
        
        let smartGuess = smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.leisure))
    }
    
    func testTheAmountOfGuessesInTheSameCategoryShouldMatterWhenComparingSimilarlyDistantGuessesEvenIfTheOutnumberedGuessIsCloser()
    {
        let targetLocation = Location(timestamp: date,
                                      latitude: 41.9754219072948, longitude: -71.0230522245947)
        
        let testInput : [TestData] =
        [
            (distanceFromTarget: 50, category: .work, date: date),
            (distanceFromTarget: 54, category: .work, date: date),
            (distanceFromTarget: 59, category: .work, date: date),
            (distanceFromTarget: 53, category: .leisure, date: date),
            (distanceFromTarget: 66, category: .work, date: date)
        ]
        
        timeSlotService.timeSlots =
            testInput
                .map(toLocation(offsetFrom: targetLocation))
                .map(toTimeSlot)
        
        let smartGuess = smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.work))
    }
    
    func testTheAmountOfGuessesInTheSameCategoryShouldMatterWhenComparingSimilarlyDistantGuesses()
    {
        let targetLocation = Location(timestamp: date,
                                      latitude: 41.9754219072948, longitude: -71.0230522245947)
        
        let testInput : [TestData] =
        [
            (distanceFromTarget: 41, category: .work, date: date),
            (distanceFromTarget: 45, category: .work, date: date),
            (distanceFromTarget: 46, category: .work, date: date),
            (distanceFromTarget: 47, category: .leisure, date: date),
            (distanceFromTarget: 53, category: .leisure, date: date),
            (distanceFromTarget: 56, category: .work, date: date)
        ]
        
        timeSlotService.timeSlots =
            testInput
                .map(toLocation(offsetFrom: targetLocation))
                .map(toTimeSlot)
        
        let smartGuess = smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.work))
    }
    
    private func toLocation(offsetFrom baseLocation: Location) -> (TestData) -> LocationAndCategory
    {
        return { (testData: TestData) in
            
            return (baseLocation.offset(.east, meters: testData.distanceFromTarget, timestamp: testData.date), testData.category)
        }
    }
    
    private func toTimeSlot(locationAndCategory: LocationAndCategory) -> TimeSlot
    {
        return TimeSlot(startTime: locationAndCategory.location.timestamp, category: locationAndCategory.category, location: locationAndCategory.location)
    }
}
