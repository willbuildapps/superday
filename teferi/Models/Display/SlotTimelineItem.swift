import Foundation

struct SlotTimelineItem
{
    let timeSlots : [TimeSlot]
    let shouldDisplayCategoryName : Bool
    let isLastInPastDay : Bool
    let isRunning: Bool
    
    init(timeSlots: [TimeSlot], shouldDisplayCategoryName: Bool = true, isLastInPastDay: Bool = false, isRunning: Bool = false)
    {
        self.timeSlots = timeSlots
        self.shouldDisplayCategoryName = shouldDisplayCategoryName
        self.isLastInPastDay = isLastInPastDay
        self.isRunning = isRunning
    }
    
    var category: Category
    {
        return timeSlots.first!.category
    }
    
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
    
    var duration: TimeInterval
    {
        guard let startTime = timeSlots.first?.startTime, let endTime = timeSlots.last?.endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
}

extension SlotTimelineItem
{
    func withLastTimeSlotFlag(isCurrentDay: Bool) -> SlotTimelineItem
    {
        return SlotTimelineItem(
            timeSlots: self.timeSlots,
            shouldDisplayCategoryName: self.shouldDisplayCategoryName,
            isLastInPastDay: !isCurrentDay,
            isRunning: isCurrentDay
        )
    }
}
