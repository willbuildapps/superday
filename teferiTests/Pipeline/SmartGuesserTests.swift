import XCTest
import Nimble
@testable import teferi

class SmartGuesserTests: XCTestCase
{
    private var smartGuessService : MockSmartGuessService!
    private var smartGuesser : SmartGuesser!
    
    override func setUp()
    {
        smartGuessService = MockSmartGuessService()
        smartGuesser = SmartGuesser(smartGuessService: smartGuessService)
    }
    
    func testAlgorithmAsksForSmartGuessWithCorrectLocation()
    {
        let location = Location.baseLocation.offset(.north, meters: 200, seconds: 60*30)
        
        let timeline = [
            TemporaryTimeSlot(start: Date.noon, category: .unknown, location: location)
        ]
        
        let _ = smartGuesser.run(timeline: timeline)
        
        expect(self.smartGuessService.locationsAskedFor.count).to(equal(1))
        
        let askedForLocation = smartGuessService.locationsAskedFor[0]
        
        expect(askedForLocation.latitude).to(equal(location.latitude))
        expect(askedForLocation.longitude).to(equal(location.longitude))
        expect(askedForLocation.timestamp).to(equal(location.timestamp))
    }
    
    func testTimeSlotGetsUnknownCategoryIfNoSmartGuessExists()
    {
        smartGuessService.smartGuessToReturn = nil
        
        let location = Location.baseLocation.offset(.north, meters: 200, seconds: 60*30)
        
        let timeline = [
            TemporaryTimeSlot(start: Date.noon, category: .unknown, location: location)
        ]
        
        let timeSlots = smartGuesser.run(timeline: timeline)
        
        expect(timeSlots.count).to(equal(1))
        expect(timeSlots[0].category).to(equal(Category.unknown))
    }
    
    func testTimeSlotGetsCorrectCategoryIfSmartGuessExists()
    {
        smartGuessService.smartGuessToReturn = TimeSlot(startTime: Date(), category: .food, location: Location.baseLocation)
        
        let location = Location.baseLocation.offset(.north, meters: 200, seconds: 60*30)
        
        let timeline = [
            TemporaryTimeSlot(start: Date.noon, category: .unknown, location: location)
        ]
        
        let timeSlots = smartGuesser.run(timeline: timeline)
        
        expect(timeSlots.count).to(equal(1))
        expect(timeSlots[0].category).to(equal(Category.food))
    }
    
    func testPipeAsksForSmartGuessOnlyForUnknownSlots()
    {
        let location1 = Location.baseLocation.offset(.north, meters: 200, seconds: 60*30)
        let location2 = Location.baseLocation.offset(.north, meters: 400, seconds: 60*30*2)
        
        let timeline = [
            TemporaryTimeSlot(start: Date.noon, category: .food, location: Location.baseLocation),
            TemporaryTimeSlot(start: Date.noon, category: .unknown, location: location1),
            TemporaryTimeSlot(start: Date.noon, category: .commute, location: Location.baseLocation),
            TemporaryTimeSlot(start: Date.noon, category: .unknown, location: location2)
        ]
        
        let _ = smartGuesser.run(timeline: timeline)
        
        expect(self.smartGuessService.locationsAskedFor.count).to(equal(2))
        
        let askedForLocation1 = smartGuessService.locationsAskedFor[0]
        let askedForLocation2 = smartGuessService.locationsAskedFor[1]
        
        expect(askedForLocation1.latitude).to(equal(location1.latitude))
        expect(askedForLocation1.longitude).to(equal(location1.longitude))
        expect(askedForLocation1.timestamp).to(equal(location1.timestamp))
        
        expect(askedForLocation2.latitude).to(equal(location2.latitude))
        expect(askedForLocation2.longitude).to(equal(location2.longitude))
        expect(askedForLocation2.timestamp).to(equal(location2.timestamp))
    }
}
