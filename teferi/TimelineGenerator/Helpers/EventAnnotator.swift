import Foundation
import RxSwift

enum EventAnnotatorError: Error
{
    case noLocations
}

class EventAnnotator
{
    private let settingsService: SettingsService
    private let timeSlotService: TimeSlotService
    private let timeService: TimeService
    private let trackEventService: TrackEventService
    private let motionService: MotionService
    
    init(settingsService: SettingsService, timeSlotService: TimeSlotService, timeService: TimeService, trackEventService: TrackEventService, motionService: MotionService)
    {
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.timeService = timeService
        self.trackEventService = trackEventService
        self.motionService = motionService
    }
    
    func annotatedEvents() -> Observable<[AnnotatedEvent]>
    {
        return Observable.combineLatest(motionEvents(), locations(), resultSelector: annotate)
    }
    
    private func motionEvents() -> Observable<[MotionEvent]>
    {
        let since = getSinceDate()
        return self.motionService.getActivities(since: since, until: self.timeService.now)
    }
    
    private func locations() -> Observable<[Location]>
    {
        return Observable.create { [unowned self] observer in
            
            var locations = self.trackEventService.getEventData(ofType: Location.self)
            if let storedLastLocation = self.settingsService.lastLocation {
                locations = [storedLastLocation] + locations
            }
            
            if locations.count > 1 {
                // filter out locations not valid (not different enough from previous one)
                let zipped = zip(locations, locations.dropFirst())
                    .flatMap { l1, l2 in
                        self.isValid(l2, previousLocation: l1) ? l2 : nil
                    }
                locations = [locations.first!] + zipped
            }
            
            observer.onNext(locations)
            observer.onCompleted()
            
            return Disposables.create { }
        }
    }
    
    private func annotate(motionEvents:[MotionEvent], locations: [Location]) throws -> [AnnotatedEvent]
    {
        guard let prevLocation = locations.first else {
            throw EventAnnotatorError.noLocations
        }
        
        var previousLocation = prevLocation
        
        return motionEvents.map { motionEvent in
            
            for location in locations {
                if location.timestamp > motionEvent.start {
                    break
                }
                previousLocation = location
            }
            
            return AnnotatedEvent(motionEvent: motionEvent, location: previousLocation)
        }
    }
    
    private func isValid(_ location: Location, previousLocation: Location) -> Bool
    {
        guard location.timestamp > previousLocation.timestamp,
            location.isSignificantlyDifferent(fromLocation: previousLocation) else {
                return false
        }
        
        return true
    }
    
    private func getSinceDate() -> Date
    {
        if let lastTimelineGenerationDate = settingsService.lastTimelineGenerationDate {
            return lastTimelineGenerationDate
        }
        
        if let lastTimeSlotEndDate = timeSlotService.getLast()?.endTime {
            return lastTimeSlotEndDate
        }
        
        return settingsService.installDate ?? timeService.now.add(days: -7)
    }
}
