import Foundation

struct AnnotatedEvent
{
    let startTime: Date
    let endTime: Date
    let type: MotionEventType
    let location: Location
    let subEvents: [MotionEvent]
    
    var duration: TimeInterval
    {
        return endTime.timeIntervalSince(startTime)
    }
}

let MAX_MERGING_GAP: TimeInterval = 60 * 15
let MAX_MERGING_DISTANCE: Double = 0.5

extension AnnotatedEvent
{
    init (motionEvent: MotionEvent, location: Location)
    {
        self.startTime = motionEvent.start
        self.endTime = motionEvent.end
        self.type = motionEvent.type
        self.location = location
        self.subEvents = [motionEvent]
    }
    
    func merging(_ newEvent: AnnotatedEvent) -> AnnotatedEvent
    {
        return AnnotatedEvent(
            startTime: self.startTime,
            endTime: newEvent.endTime,
            type: self.type,
            location: self.location,
            subEvents: self.subEvents + newEvent.subEvents
        )
    }
    
    func with(endTime: Date) -> AnnotatedEvent
    {
        return AnnotatedEvent(
            startTime: self.startTime,
            endTime: endTime,
            type: self.type,
            location: self.location,
            subEvents: self.subEvents
        )
    }
    
    func canBeMergedWith(event: AnnotatedEvent) -> Bool
    {
        return (event.startTime.timeIntervalSince(self.endTime) < MAX_MERGING_GAP ||
            self.startTime.timeIntervalSince(event.endTime) < MAX_MERGING_GAP) &&
            event.type == self.type
        // We should consider the possibility of taking the distance into account for most categories (not for movement)
    }
}



extension AnnotatedEvent: CustomStringConvertible
{
    var description: String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let timeInterval = endTime.timeIntervalSince(startTime)
        let minutes = floor(timeInterval / 60)
        let seconds = timeInterval - minutes * 60
        
        return "\(dateFormatter.string(from: startTime)) - \(dateFormatter.string(from: endTime)) : \(type) \(Int(minutes))m \(Int(seconds))s"
    }
}

