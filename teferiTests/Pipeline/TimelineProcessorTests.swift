import XCTest
import Nimble
@testable import teferi

class TimelineProcessorTests: XCTestCase
{
    private typealias TestData = TempTimelineTestData
    
    private var midnight : Date!
    private var baseSlot : TemporaryTimeSlot!
    
    private var settingsService: MockSettingsService!
    private var timeSlotService: MockTimeSlotService!
    private var timeService : MockTimeService!
    
    
    private var timelineProcessor : TimelineProcessor!
    
    override func setUp()
    {
        super.setUp()
        
        settingsService = MockSettingsService()
        timeService = MockTimeService()
        timeSlotService = MockTimeSlotService(timeService: timeService, locationService: MockLocationService())
        
        midnight = Date().ignoreTimeComponents()
        let baseLocation = Location.baseLocation
        
        baseSlot = TemporaryTimeSlot(start: midnight, location: baseLocation, category: Category.commute)
        
        settingsService.setLastLocation(Location.baseLocation)
        timeService.mockDate = midnight.addingTimeInterval(1000)
        
        timelineProcessor = TimelineProcessor(settingsService: settingsService, timeSlotService: timeSlotService, timeService: timeService)
    }
    
    func testSlotsThatPassMidnightAreSplitAtMidnigtWhenEndTimeIsAvalable()
    {
        let initialData =
            [ TestData(startOffset: -1000, endOffset: -0180, teferi.Category.leisure),
              TestData(startOffset: -0180, endOffset: 0360, teferi.Category.work),
              TestData(startOffset: 0360, endOffset: 0540, teferi.Category.leisure) ].map(toTempTimeSlot)
        
        let expectedTimeline =
            [ TestData(startOffset: -1000, endOffset: -0180, teferi.Category.leisure),
              TestData(startOffset: -0180, endOffset: 0000, teferi.Category.work),
              TestData(startOffset: 0000, endOffset: 0360, teferi.Category.work),
              TestData(startOffset: 0360, endOffset: 0540, teferi.Category.leisure) ].map(toTempTimeSlot)
        
        timelineProcessor.process(slots: initialData)
            .enumerated()
            .forEach { i, actualTimeSlot in compare(timeSlot: actualTimeSlot, to: expectedTimeline[i]) }
    }
    
    func testSlotsThatPassMidnightAreSplitAtMidnigtWhenEndTimeIsNotAvalable()
    {
        let initialData =
            [ TestData(startOffset: -1000, endOffset: -0180, teferi.Category.leisure),
              TestData(startOffset: -0180, endOffset: 0360, teferi.Category.work)].map(toTempTimeSlot)
        
        let expectedTimeline =
            [ TestData(startOffset: -1000, endOffset: -0180, teferi.Category.leisure),
              TestData(startOffset: -0180, endOffset: 0000, teferi.Category.work),
              TestData(startOffset: 0000, endOffset: 0360, teferi.Category.work) ].map(toTempTimeSlot)
        
        timelineProcessor.process(slots: initialData)
            .enumerated()
            .forEach { i, actualTimeSlot in compare(timeSlot: actualTimeSlot, to: expectedTimeline[i]) }
    }
    
    func testThePipeCreatesInitialTimeSlotIfNoneExistYet()
    {
        let result = timelineProcessor.process(slots: [])
        
        expect(result.count).to(equal(1))
        expect(result.first!.start).to(equal(timeService.now))
    }
    
    func testThePipeCreatesATimeSlotIfThereIsNoTimeSlotPersistedTodayAndNoTimeSlotStartingTodayInThePipe()
    {
        timeSlotService.addTimeSlot(withStartTime: timeService.now.addingTimeInterval(-24*60*60), category: .unknown, categoryWasSetByUser: false, tryUsingLatestLocation: false)
        
        let result = timelineProcessor.process(slots: [TemporaryTimeSlot(start: timeService.now.yesterday, location: Location.baseLocation) ])
        
        expect(result.count).to(equal(2))
        expect(result.first!.start).to(equal(timeService.now.yesterday))
        expect(result.last!.start).to(equal(timeService.now))
    }
    
    func testThePipeCreatesATimeSlotIfTheresNoDataForTheCurrentDayBothPersistedAndInThePipe()
    {
        timeSlotService.addTimeSlot(withStartTime: timeService.now.addingTimeInterval(-24*60*60), category: .unknown, categoryWasSetByUser: false, tryUsingLatestLocation: false)
        
        let result = timelineProcessor.process(slots: [])
        
        expect(result.count).to(equal(1))
        expect(result.first!.start).to(equal(timeService.now))
    }
    
    func testThePipeDoesNotTouchDataIfThereAreSlotsInThePipe()
    {
        timeSlotService.addTimeSlot(withStartTime: timeService.now, category: .unknown, categoryWasSetByUser: false, tryUsingLatestLocation: false)
        
        let result = timelineProcessor.process(slots: [ TemporaryTimeSlot(start: timeService.now, location: Location.baseLocation) ])
        
        expect(result.count).to(equal(1))
    }
    
    func testThePipeDoesNotTouchDataIfThereArePersistedTimeSlotsForTheDay()
    {
        timeSlotService.addTimeSlot(withStartTime: timeService.now, category: .unknown, categoryWasSetByUser: false, tryUsingLatestLocation: false)
        
        let result = timelineProcessor.process(slots: [])
        
        expect(result.count).to(equal(0))
    }
    
    private func toTempTimeSlot(data: TestData) -> TemporaryTimeSlot
    {
        return TemporaryTimeSlot(
            start: date(data.startOffset),
            end: data.endOffset != nil ? date(data.endOffset!) : nil,
            category: data.category,
            location: baseSlot.location,
            activityTag: baseSlot.activityTag,
            smartGuess: nil)
    }
    
    private func date(_ timeInterval: TimeInterval) -> Date
    {
        return midnight.addingTimeInterval(timeInterval)
    }
    
    private func compare(timeSlot actualTimeSlot: TemporaryTimeSlot, to expectedTimeSlot: TemporaryTimeSlot)
    {
        expect(actualTimeSlot.start).to(equal(expectedTimeSlot.start))
        expect(actualTimeSlot.category).to(equal(expectedTimeSlot.category))
        
        compareOptional(actualTimeSlot.end, expectedTimeSlot.end)
        compareOptional(actualTimeSlot.location, expectedTimeSlot.location)
        compareOptional(actualTimeSlot.smartGuess, expectedTimeSlot.smartGuess)
    }
    
    private func compareOptional<T : Equatable>(_ actual: T?, _ expected: T?)
    {
        if expected == nil
        {
            expect(actual).to(beNil())
        }
        else
        {
            expect(actual).to(equal(expected))
        }
    }
}

extension SmartGuess : Equatable
{
    public static func ==(lhs: SmartGuess, rhs: SmartGuess) -> Bool
    {
        return lhs.id == rhs.id &&
            lhs.errorCount == rhs.errorCount &&
            lhs.category == rhs.category &&
            lhs.lastUsed == rhs.lastUsed
    }
}
