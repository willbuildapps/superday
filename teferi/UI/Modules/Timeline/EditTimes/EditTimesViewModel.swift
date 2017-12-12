import Foundation
import RxSwift

class EditTimesViewModel: RxViewModel
{
    var topSlotObservable: Observable<EditedSlot?> {
        return topSlot.asObservable()
            .map(toEditedSlot)
    }
    
    var bottomSlotObservable: Observable<EditedSlot?> {
        return bottomSlot.asObservable()
            .map(toEditedSlot)
    }
    
    var initialSlotRatio: CGFloat = 0
    var selectedSlotCategory: Category = .unknown
    
    private let timeService: TimeService
    private let timeSlotService: TimeSlotService
    
    private let topSlot: Variable<TimeSlot>
    private let bottomSlot: Variable<TimeSlot>
    
    private let initialTopSlot: TimeSlot
    private let initialBottomSlot: TimeSlot
    
    private let editingStartTime: Bool
    
    private let updateStartDateSubject: PublishSubject<Date>
    
    init(initialTopSlot: TimeSlot,
         initialBottomSlot: TimeSlot,
         editingStartTime: Bool,
         timeService: TimeService,
         timeSlotService: TimeSlotService,
         updateStartDateSubject: PublishSubject<Date>)
    {
        self.initialTopSlot = initialTopSlot
        self.initialBottomSlot = initialBottomSlot

        self.timeService = timeService
        self.timeSlotService = timeSlotService
        
        self.editingStartTime = editingStartTime
        self.updateStartDateSubject = updateStartDateSubject
        
        topSlot = Variable<TimeSlot>(initialTopSlot)
        bottomSlot = Variable<TimeSlot>(initialBottomSlot)
        
        super.init()
        
        let duration1 = slotDuration(initialTopSlot)
        let duration2 = slotDuration(initialBottomSlot)
        
        initialSlotRatio = CGFloat(duration1 / (duration1 + duration2))
        
        selectedSlotCategory = editingStartTime ? initialBottomSlot.category : initialTopSlot.category
    }
    
    func updateTimes(topPercentage: Double)
    {
        let totalDuration = slotDuration(topSlot.value) + slotDuration(bottomSlot.value)
        let topDuration = totalDuration * topPercentage
        let bottomDuration = totalDuration - topDuration
        
        topSlot.value = topSlot.value.withStartTime(topSlot.value.startTime,
                                                    endTime: topSlot.value.startTime.addingTimeInterval(topDuration))
        
        let secondSlotEnd = bottomSlot.value.endTime != nil ? topSlot.value.endTime?.addingTimeInterval(bottomDuration) : nil
        bottomSlot.value = bottomSlot.value.withStartTime(topSlot.value.endTime!,
                                                          endTime: secondSlotEnd)
    }
    
    func saveTimes()
    {
        if editingStartTime
        {
            updateStartDateSubject.on(.next(bottomSlot.value.startTime))
        }
        
        timeSlotService.updateTimes(firstSlot: initialTopSlot, secondSlot: initialBottomSlot, newBreakTime: bottomSlot.value.startTime)
    }
    
    private func toEditedSlot(slot: TimeSlot) -> EditedSlot
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return EditedSlot(
            category: slot.category,
            startTime: formatter.string(from: slot.startTime),
            duration: slotDuration(slot))
    }
    
    private func slotDuration(_ timeSlot: TimeSlot) -> TimeInterval
    {
        return timeSlot.duration ?? timeService.now.timeIntervalSince(timeSlot.startTime)
    }
}
