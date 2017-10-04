import Foundation

struct TemporaryTimeSlot
{
    let start : Date
    let end : Date?
    let category : Category
    let location : Location
    let activity: MotionEventType
    let smartGuess : SmartGuess?
}

extension TemporaryTimeSlot
{
    init(withEvent event: AnnotatedEvent)
    {
        self.start = event.startTime
        self.end = event.endTime
        self.category = TemporaryTimeSlot.getCategory(from: event.type)
        self.location = event.location
        self.activity = event.type
        self.smartGuess = nil
    }
    
    init(start: Date, location: Location, end: Date? = nil, category: Category = .unknown, activity: MotionEventType = .still, smartGuess: SmartGuess? = nil)
    {
        self.start = start
        self.end = end
        self.category = category
        self.location = location
        self.activity = activity
        self.smartGuess = nil
    }
    
    func with(start: Date? = nil, end: Date? = nil) -> TemporaryTimeSlot
    {
        return TemporaryTimeSlot(
            start: start ?? self.start,
            end: end ?? self.end,
            category: self.category,
            location: self.location,
            activity: self.activity,
            smartGuess: self.smartGuess
        )
    }
    
    private static func getCategory(from type: MotionEventType) -> Category
    {
        switch type {
        case .cycling, .run:
            return .fitness
        case .other, .still:
            return .unknown
        case .walk, .auto:
            return .commute
        }
    }
    
    var duration : TimeInterval?
    {
        guard let end = self.end else { return nil }

        return end.timeIntervalSince(start)
    }
}
