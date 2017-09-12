import Foundation
import RxSwift
@testable import teferi

class MockLocationService : LocationService
{
    //MARK: Fields
    private var lastLocation: Location? = nil
    private var eventSubject = PublishSubject<Location>()
    
    //MARK: Properties
    private(set) var locationStarted = false
    var useNilOnLastKnownLocation = false
    
    //MARK: LocationService implementation
    var isInBackground : Bool = false
    
    func startLocationTracking()
    {
        locationStarted = true
    }
    
    func stopLocationTracking()
    {
        locationStarted = false
    }
    
    func getLastKnownLocation() -> Location?
    {
        return useNilOnLastKnownLocation ? nil : lastLocation
    }
    
    var eventObservable : Observable<TrackEvent>
    {
        return eventSubject
                .asObservable()
                .map(Location.asTrackEvent)
    }
    
    //MARK: Methods
    func sendNewTrackEvent(_ location: Location)
    {
        lastLocation = location
        eventSubject.onNext(location)
    }
}
