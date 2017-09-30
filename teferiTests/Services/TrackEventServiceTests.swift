import XCTest
import UserNotifications
import Nimble
@testable import teferi

class TrackEventServiceTests : XCTestCase
{
    private var trackEventService : DefaultTrackEventService!
    
    private var loggingService : MockLoggingService!
    private var locationService : MockLocationService!
    private var persistencyService : BasePersistencyService<TrackEvent>!
    
    override func setUp()
    {
        loggingService = MockLoggingService()
        locationService = MockLocationService()
        persistencyService = TrackEventPersistencyService(loggingService: loggingService,
                                                               locationPersistencyService: MockPersistencyService<Location>())
        
        trackEventService = DefaultTrackEventService(loggingService: loggingService,
                                                          persistencyService: persistencyService,
                                                          withEventSources: locationService)
    }
    
    func testNewEventsGetPersistedByTheTrackEventService()
    {
        locationService.sendNewTrackEvent(Location.baseLocation)
        locationService.sendNewTrackEvent(Location.baseLocation)
        locationService.sendNewTrackEvent(Location.baseLocation)
        
        let persistedEvents = trackEventService.getEventData(ofType: Location.self)
        expect(persistedEvents.count).to(equal(3))
    }
}
