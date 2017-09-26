import Foundation
@testable import teferi

extension TrackEvent
{
    static var baseMockEvent:TrackEvent {
        return Location.asTrackEvent(Location.baseLocation)
    }
    
    func delay(hours:Double = 0, minutes:Double = 0, seconds:Double = 0) -> TrackEvent
    {
        switch self {
        case .newLocation(let location):
            return TrackEvent.newLocation(
                location: Location(
                    timestamp: location.timestamp.addingTimeInterval(hours*60*60 + minutes*60 + seconds),
                    latitude: location.latitude,
                    longitude: location.longitude,
                    speed: location.speed,
                    course: location.course,
                    altitude: location.altitude,
                    verticalAccuracy: location.verticalAccuracy,
                    horizontalAccuracy: location.horizontalAccuracy
                )
            )
        }
    }
    
    func offset(meters:Double) -> TrackEvent
    {
        switch self {
        case .newLocation(let oldLocation):
            
            let location = oldLocation.offset(.north, meters:meters)

            return TrackEvent.newLocation(
                location: Location(
                    timestamp: location.timestamp,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    speed: location.speed,
                    course: location.course,
                    altitude: location.altitude,
                    verticalAccuracy: location.verticalAccuracy,
                    horizontalAccuracy: location.horizontalAccuracy
                )
            )
        }
    }
}
