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
    
    private let topSlot: Variable<TimeSlot?>
    private let bottomSlot: Variable<TimeSlot?>
    
    init(slotAtDate: Date, editingStart: Bool, timeService: TimeService, timeSlotService: TimeSlotService)
    {
        self.timeService = timeService
        self.timeSlotService = timeSlotService
        
        let slots = timeSlotService.getTimeSlots(forDay: slotAtDate.ignoreTimeComponents())
        let slotIndex = slots.map{ $0.startTime }.index(of: slotAtDate) ?? 0
        
        var slot1: TimeSlot?
        var slot2: TimeSlot?
        if editingStart {
            slot1 = slots.safeGetElement(at: slotIndex - 1)
            slot2 = slots.safeGetElement(at: slotIndex)
        } else {
            slot1 = slots.safeGetElement(at: slotIndex)
            slot2 = slots.safeGetElement(at: slotIndex + 1)
        }
        
        topSlot = Variable<TimeSlot?>(slot1)
        bottomSlot = Variable<TimeSlot?>(slot2)
        
        super.init()
        
        if let duration1 = slot1?.duration, let duration2 = slot2?.duration {
            initialSlotRatio = CGFloat(duration1 / (duration1 + duration2))
        }
        
        selectedSlotCategory = slots[slotIndex].category
    }
    
    func updateTimes(topPercentage: Double)
    {
        guard let topSlotValue = topSlot.value, let bottomSlotValue = bottomSlot.value else { return }
        
        let totalDuration = (topSlotValue.duration ?? 0) + (bottomSlotValue.duration ?? 0)
        let topDuration = totalDuration * topPercentage
        let bottomDuration = totalDuration - topDuration
        
        topSlot.value = topSlotValue.withStartTime(topSlotValue.startTime,
                                                   endTime: topSlotValue.startTime.addingTimeInterval(topDuration))
        
        bottomSlot.value = bottomSlotValue.withStartTime(topSlotValue.endTime!,
                                                         endTime: topSlotValue.endTime!.addingTimeInterval(bottomDuration))
    }
    
    func saveTimes()
    {
        guard let topSlot = topSlot.value, let bottomSlot = bottomSlot.value else { return }
        timeSlotService.updateTimes(firstSlot: topSlot, secondSlot: bottomSlot)
    }
    
    private func toEditedSlot(slot: TimeSlot?) -> EditedSlot?
    {
        guard let slot = slot else { return nil }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return EditedSlot(
            category: slot.category,
            startTime: formatter.string(from: slot.startTime),
            duration: (slot.duration ?? 0))
    }
}
