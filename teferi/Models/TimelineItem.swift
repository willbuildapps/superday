import Foundation

struct TimelineItem
{
    let timeSlots : [TimeSlot]
    let category: Category
    let duration : TimeInterval
    let shouldDisplayCategoryName : Bool
    let isLastInPastDay : Bool
    let isRunning: Bool
    
    var startTime: Date
    {
        return timeSlots.first!.startTime
    }
    
    var endTime: Date?
    {
        return timeSlots.last!.endTime
    }
    
    var containsMultiple: Bool
    {
        return timeSlots.count > 1
    }
}

extension TimelineItem
{
    init(withTimeSlots timeSlots: [TimeSlot], category: Category, duration: TimeInterval, shouldDisplayCategoryName: Bool = false, isLastInPastDay: Bool = false, isRunning: Bool = false)
    {
        self.timeSlots = timeSlots
        self.category = category
        self.duration = duration
        self.shouldDisplayCategoryName = shouldDisplayCategoryName
        self.isLastInPastDay = isLastInPastDay
        self.isRunning = isRunning
    }
}

extension TimelineItem
{
    func withLastTimeSlotFlag(isCurrentDay: Bool) -> TimelineItem
    {
        return TimelineItem(
            timeSlots: self.timeSlots,
            category: self.category,
            duration: self.duration,
            shouldDisplayCategoryName: self.shouldDisplayCategoryName,
            isLastInPastDay: !isCurrentDay,
            isRunning: isCurrentDay)
    }
}
