import XCTest

import Nimble

@testable import teferi

class LocationPumpTests: XCTestCase
{    
    private var trackEventService:MockTrackEventService!
    private var settingsService:MockSettingsService!
    private var timeSlotService:MockTimeSlotService!
    private var loggingService:MockLoggingService!
    
    private var locationService: MockLocationService!
    private var timeService: MockTimeService!
    
    private var locationPump : LocationPump!
    
    override func setUp()
    {        
        trackEventService = MockTrackEventService()
        settingsService = MockSettingsService()
        loggingService = MockLoggingService()
        
        locationService = MockLocationService()
        timeService = MockTimeService()
        timeSlotService = MockTimeSlotService(
            timeService:timeService,
            locationService:locationService
        )
        
        locationPump = LocationPump(
            trackEventService:trackEventService,
            settingsService:settingsService,
            timeSlotService:timeSlotService,
            loggingService: loggingService,
            timeService: timeService
        )
    }
    
    func testTheAlgorithmWillNotRunForTheFirstLocationEverReceived()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)
        settingsService.lastLocation = nil
        
        trackEventService.mockEvents = [
            TrackEvent.baseMockEvent
        ]
        
        let timeSlots = locationPump.run()

        expect(timeSlots.count).to(equal(0))
    }
    
    func testTheAlgorithmWillRunForTheSecondLocationEvenIfNotLastLocationExists()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)
        settingsService.lastLocation = nil
        
        trackEventService.mockEvents = [
            TrackEvent.baseMockEvent,
            TrackEvent.baseMockEvent.delay(hours:20).offset(meters: 300),
        ]
        
        let timeSlots = locationPump.run()
        
        expect(timeSlots.count).to(beGreaterThan(0))
    }
    
    func testTheAlgorithmWillNotRunIfTheNewLocationIsOlderThanTheLastLocationReceived()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)

        let oldLocation = Location.baseLocation.offset(.north, meters: 350, seconds:8*60)
        let newLocation = Location.baseLocation.offset(.north, meters: 650, seconds:-8*60)
        
        settingsService.lastLocation = oldLocation
        
        trackEventService.mockEvents = [
            Location.asTrackEvent(newLocation)
        ]
        
        let timeSlots = locationPump.run()

        expect(timeSlots.count).to(equal(0))
    }
    
    func testTheAlgorithmIgnoresInvalidLocationsAndKeepsValidOnes()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)
        settingsService.lastLocation = nil

        let locationA = Location.baseLocation.offset(.north, meters: 400).with(accuracy: 50)
        let eventA = Location.asTrackEvent(locationA)
        trackEventService.mockEvents = [
            eventA,
            eventA.delay(minutes: 30).offset(meters: 80), //Should ignore this but keep the 1st (more accurate) and last
            eventA.delay(minutes: 60).offset(meters: 160)
        ]
        
        let timeSlots = locationPump.run()
        
        // No lastLocation in settings, two updates -> Should create at least one TS.
        expect(timeSlots.count).to(beGreaterThan(0))
    }
    
    func testTheAlgorithmDetectsACommuteIfMultipleEntriesHappenInAShortPeriodOfTime()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)

        trackEventService.mockEvents = [
            TrackEvent.baseMockEvent.offset(meters: 200),
            TrackEvent.baseMockEvent.delay(minutes: 15).offset(meters: 400),
            TrackEvent.baseMockEvent.delay(hours:1).offset(meters: 600),
        ]
        
        let timeSlots = locationPump.run()
        
        let firstTimeSlot = timeSlots[0]
        expect(firstTimeSlot.category).to(equal(Category.commute))
    }
    
    func testTheAlgorithmDoesChangeTheTimeSlotToCommute()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)

        let firstEvent = TrackEvent.baseMockEvent.delay(hours: 1).offset(meters: 200)

        trackEventService.mockEvents = [
            firstEvent,
            firstEvent.delay(minutes: 15).offset(meters: 400)
        ]
        
        let timeSlots = locationPump.run()
        
        let firstTimeSlot = timeSlots[0]
        expect(firstTimeSlot.category).to(equal(Category.commute))
    }
    
    func testTheAlgorithmCreatesNewTimeSlotWhenANewUpdateComesAfterAWhile()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)

        let location = Location.baseLocation.offset(.north, meters: 350)
        let secondEvent = Location.asTrackEvent(location)
        
        trackEventService.mockEvents = [
            secondEvent
        ]
        
        let timeSlots = locationPump.run()
        
        expect(timeSlots.count).to(equal(1))
        expect(timeSlots.last!.start).to(equal(location.timestamp))
    }
    
    func testTheAlgorithmDoesNotCreateNewTimeSlotsUntilItDetectsTheUserBeingIdleForAWhile()
    {
        addStoredTimeSlot()

        let delays:[Double] = [45, 40, 50, 90, 110, 120]
        
        let dates = delays.map {
            return Date.noon.addingTimeInterval($0 * 60.0)
        }
        
        trackEventService.mockEvents = delays.map {
            TrackEvent.baseMockEvent.delay(minutes:$0).offset(meters:100*$0)
        }
        
        let timeSlots = locationPump.run()
        let commutesDetected = timeSlots.filter { $0.category == .commute }
        
        expect(timeSlots.count).to(equal(3))
        expect(commutesDetected.count).to(equal(2))
        expect(timeSlots[0].start).to(equal(dates[0]))
        expect(timeSlots[1].start).to(equal(dates[2]))
        expect(timeSlots[2].start).to(equal(dates[3]))
    }
    
    func testTheAlgorithmDoesNotCreateTimeSlotsFromLocationUpdatesInSimilarLocation()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)

        trackEventService.mockEvents = [
            TrackEvent.baseMockEvent.delay(hours: 1).offset(meters: 400),
            TrackEvent.baseMockEvent.delay(hours: 1).offset(meters: 20),
            TrackEvent.baseMockEvent.delay(hours: 1).offset(meters: 30)
        ]
        
        let timeSlots = locationPump.run()
        
        expect(timeSlots.count).to(equal(1))
    }
    
    func testTheAlgorithmDoesNotCreateTimeSlotsFromLocationUpdatesInSimilarLocationToTheStoredOne()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)
        
        trackEventService.mockEvents = [
            TrackEvent.baseMockEvent.delay(hours: 1).offset(meters: 10)
        ]
        
        let timeSlots = locationPump.run()
        
        expect(timeSlots.count).to(equal(0))
    }
    
    func testTheAlgorithmDoesNotDetectCommuteFromLocationUpdatesInSimilarLocation()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)
        
        let firstEvent = TrackEvent.baseMockEvent.delay(hours:1).offset(meters: 200)
        
        trackEventService.mockEvents = [
            firstEvent,
            firstEvent.delay(minutes: 15).offset(meters: 20)
        ]
        
        let timeSlots = locationPump.run()
        
        expect(timeSlots.count).to(equal(1))
        expect(timeSlots[0].category).to(equal(Category.unknown))
    }
    
    func testTheAlgorithmDoesNotTouchLastKnownLocationFromLocationUpdatesInSimilarLocation()
    {
        addStoredTimeSlot(minutesBeforeNoon: 30)
        settingsService.setLastLocation(Location.baseLocation)
        let firstEvent = TrackEvent.baseMockEvent.delay(minutes: 35).offset(meters: 10)
        
        trackEventService.mockEvents = [
            firstEvent
        ]
        
        let _ = locationPump.run()
        
        let lastLocation = settingsService.lastLocation!
        let baseLocation = Location.baseLocation
        
        expect(lastLocation.latitude).to(equal(baseLocation.latitude))
        expect(lastLocation.longitude).to(equal(baseLocation.longitude))
        expect(lastLocation.timestamp).to(equal(baseLocation.timestamp))
    }
    
    func testCanCreateUnkownSlotsBetweenCommuteSlots()
    {
        addStoredTimeSlot()

        trackEventService.mockEvents = [
            TrackEvent.baseMockEvent.delay(minutes:30).offset(meters: 200),
            TrackEvent.baseMockEvent.delay(minutes:45).offset(meters: 400),
            TrackEvent.baseMockEvent.delay(minutes:75).offset(meters: 800),
            TrackEvent.baseMockEvent.delay(minutes:90).offset(meters: 1000),
            TrackEvent.baseMockEvent.delay(minutes:120).offset(meters: 1200),
            TrackEvent.baseMockEvent.delay(minutes:135).offset(meters: 1400)
        ]
        
        let timeSlots = locationPump.run()
        
        expect(timeSlots.count).to(equal(5))
        expect(timeSlots[0].category).to(equal(Category.commute))
        expect(timeSlots[1].category).to(equal(Category.unknown))
        expect(timeSlots[2].category).to(equal(Category.commute))
        expect(timeSlots[3].category).to(equal(Category.unknown))
        expect(timeSlots[4].category).to(equal(Category.commute))
    }
    
    func testEndsLastTimeSlotIfCommuteAndLongerThanLimit()
    {
        addStoredTimeSlot(minutesBeforeNoon: 60)
        
        trackEventService.mockEvents = [
            TrackEvent.baseMockEvent.offset(meters: 200),
            TrackEvent.baseMockEvent.delay(seconds:15).offset(meters: 400)
        ]
        
        timeService.mockDate = Date.noon.addingTimeInterval(2*60*60)
        
        let timeSlots = locationPump.run()
        
        expect(timeSlots.count).to(equal(2))
        expect(timeSlots[1].category).to(equal(Category.unknown))
    }
    
    private func addStoredTimeSlot(minutesBeforeNoon:TimeInterval = 0)
    {
        let date = Date.noon.addingTimeInterval(-60 * minutesBeforeNoon)
        timeSlotService.addTimeSlot(withStartTime: date,
                                         category: .family,
                                         categoryWasSetByUser: false,
                                         tryUsingLatestLocation: false)
        
        let baseLocation = Location(timestamp: date,
                                    latitude: Location.baseLocation.latitude, longitude: Location.baseLocation.longitude,
                                    speed: 0, course: 0, altitude: Location.baseLocation.altitude,
                                    verticalAccuracy: Location.baseLocation.verticalAccuracy, horizontalAccuracy: Location.baseLocation.horizontalAccuracy)

        settingsService.setLastLocation(baseLocation)

    }
}

extension Date
{
    static var noon:Date {
        return Date.midnight.addingTimeInterval(12 * 60 * 60)
    }
    
    static var midnight:Date {
        return Date().ignoreTimeComponents()
    }
}
 
extension Location
{
    static var baseLocation:Location
    {
        return Location(timestamp: Date.noon,
                        latitude: 37.628060, longitude: -116.848463,
                        accuracy: 100)
    }
}

