import Foundation
@testable import teferi

extension SlotTimelineItem
{
    init(withTimeSlots timeSlots: [TimeSlot],
         category: teferi.Category,
         duration: TimeInterval,
         shouldDisplayCategoryName: Bool = false,
         isLastInPastDay: Bool = false,
         isRunning: Bool = false)
    {
        self.timeSlots = timeSlots
        self.shouldDisplayCategoryName = shouldDisplayCategoryName
        self.isLastInPastDay = isLastInPastDay
        self.isRunning = isRunning
    }
    
    static func with(timeSlot: TimeSlot, timeSlotService: TimeSlotService) -> SlotTimelineItem
    {
        return SlotTimelineItem(withTimeSlots: [timeSlot],
                            category: timeSlot.category,
                            duration: timeSlotService.calculateDuration(ofTimeSlot: timeSlot),
                            shouldDisplayCategoryName: true)
    }
}
