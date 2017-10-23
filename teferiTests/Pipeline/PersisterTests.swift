import Foundation
import XCTest
import Nimble
@testable import teferi

class PersisterTests : XCTestCase
{
    typealias TestData = TempTimelineTestData
    
    private var noon : Date!
    private var baseSlot : TemporaryTimeSlot!

    private var persister : Persister!
    
    private var timeService : MockTimeService!
    private var locationService : MockLocationService!
    private var settingsService : MockSettingsService!
    private var timeSlotService : MockTimeSlotService!
    private var trackEventService : MockTrackEventService!
    private var metricsService : MockMetricsService!
    
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
        noon = Date().ignoreTimeComponents().addingTimeInterval(12 * 60 * 60)
        let baseLocation = Location.baseLocation
        baseSlot = TemporaryTimeSlot(start: noon, category: Category.unknown, location: baseLocation)
        
        timeService = MockTimeService()
        timeService.mockDate = noon.addingTimeInterval(1301)
        
        locationService = MockLocationService()
        settingsService = MockSettingsService()
        timeSlotService = MockTimeSlotService(timeService: timeService, locationService: locationService)
        trackEventService = MockTrackEventService()
        metricsService = MockMetricsService()
        
        persister = Persister(timeSlotService: timeSlotService,
                              timeService: timeService,
                              metricsService: metricsService)
    }
    
    func testNewSlotCreationCallsTheMetricsService()
    {
        let data = getTestData()

        persister.persist(slots: data)

        data.forEach { tempTimeSlot in
            expect(self.metricsService.didLog(event: .timeSlotCreated(date: self.timeService.now, category: .unknown, duration: tempTimeSlot.duration))).to(beTrue())
            if tempTimeSlot.isSmartGuessed {
                expect(self.metricsService.didLog(event: .timeSlotSmartGuessed(date: self.timeService.now, category: .food, duration: tempTimeSlot.duration))).to(beTrue())
            } else {
                expect(self.metricsService.didLog(event: .timeSlotNotSmartGuessed(date: self.timeService.now, category: .unknown, duration: tempTimeSlot.duration))).to(beTrue())
            }
        }
    }
    
    private func toTempTimeSlot(data: TestData) -> TemporaryTimeSlot
    {
        return baseSlot.with(start: date(data.startOffset),
                                  end: data.endOffset != nil ? date(data.endOffset!) : nil)
    }
    
    private func date(_ timeInterval: TimeInterval) -> Date
    {
        return noon.addingTimeInterval(timeInterval)
    }
}

extension TemporaryTimeSlot
{
    func with(location: Location) -> TemporaryTimeSlot
    {
        return TemporaryTimeSlot(
            start: self.start,
            end: self.end,
            category: self.category,
            location: location,
            activity: self.activity
        )
    }
}

