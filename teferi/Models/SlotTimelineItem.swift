import Foundation

struct SlotTimelineItem
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

extension SlotTimelineItem
{
    func withLastTimeSlotFlag(isCurrentDay: Bool) -> SlotTimelineItem
    {
        return SlotTimelineItem(
            timeSlots: self.timeSlots,
            category: self.category,
            duration: self.duration,
            shouldDisplayCategoryName: self.shouldDisplayCategoryName,
            isLastInPastDay: !isCurrentDay,
            isRunning: isCurrentDay
        )
    }
    
    static func with(timeSlots: [TimeSlot],
                     timeSlotService: TimeSlotService,
                     shouldDisplayCategoryName: Bool = true,
                     isLastInPastDay: Bool = false,
                     isRunning: Bool = false) -> SlotTimelineItem
    {
        return SlotTimelineItem(timeSlots: timeSlots,
                            category: timeSlots.first!.category,
                            duration: timeSlots.map({ timeSlotService.calculateDuration(ofTimeSlot: $0) }).reduce(0, +),
                            shouldDisplayCategoryName: shouldDisplayCategoryName,
                            isLastInPastDay: isLastInPastDay,
                            isRunning: isRunning)
    }
}
