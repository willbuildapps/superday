import XCTest
import Nimble
@testable import teferi

class CleanerTests: XCTestCase
{    
    typealias TestData = TempTimelineTestData
    private var baseSlot : TemporaryTimeSlot!

    private var cleaner : Cleaner!
    
    private var timeService : MockTimeService!
    private var settingsService : MockSettingsService!
    private var trackEventService : MockTrackEventService!
    
    private func getTestData() -> [TemporaryTimeSlot]
    {
        return
            [ TestData(startOffset: 0000, endOffset: 0100),
              TestData(startOffset: 0100, endOffset: 0400),
              TestData(startOffset: 0400, endOffset: 0700),
              TestData(startOffset: 0700, endOffset: 0900),
              TestData(startOffset: 0900, endOffset: 1200),
              TestData(startOffset: 1200, endOffset: 1300),
              TestData(startOffset: 1300, endOffset: nil ) ].map(toTempTimeSlot)
    }
    
    override func setUp()
    {
        let baseLocation = Location.baseLocation
        baseSlot = TemporaryTimeSlot(start: Date.noon, category: Category.unknown, location: baseLocation)

        let noon = Date.noon.ignoreTimeComponents().addingTimeInterval(12 * 60 * 60)
        timeService = MockTimeService()
        timeService.mockDate = noon.addingTimeInterval(1301)
        settingsService = MockSettingsService()
        trackEventService = MockTrackEventService()
        
        cleaner = Cleaner(settingsService: settingsService, trackEventService: trackEventService, timeService: timeService)
    }
    
    
    func testTheLastUsedLocationIsPersisted()
    {
        var data = getTestData()
        
        settingsService.lastLocation = nil
        
        let otherLocation = Location(timestamp: Date(),
                                     latitude: 38.628060, longitude: -117.848463)
        
        let expectedLocation = Location(timestamp: Date(),
                                        latitude: 37.628060, longitude: -116.848463)
        
        data[4] = data[4].with(location: otherLocation)
        data[5] = data[5].with(location: expectedLocation)
        
        cleaner.cleanUp(slots: data)

        expect(self.settingsService.lastLocation).toNot(beNil())
        expect(self.settingsService.lastLocation!.latitude).to(equal(expectedLocation.latitude))
        expect(self.settingsService.lastLocation!.longitude).to(equal(expectedLocation.longitude))
    }
    
    func testAllTempDataIsCleared()
    {
        trackEventService.mockEvents = [ TrackEvent.newLocation(location: Location.baseLocation) ]
        
        cleaner.cleanUp(slots: getTestData())
        
        expect(self.trackEventService.getEventData(ofType: Location.self).count).to(equal(0))
    }
    
    
    private func toTempTimeSlot(data: TestData) -> TemporaryTimeSlot
    {
        return baseSlot.with(start: Date.noon.addingTimeInterval(data.startOffset),
                             end: data.endOffset != nil ? Date.noon.addingTimeInterval(data.endOffset!) : nil)
    }
}
