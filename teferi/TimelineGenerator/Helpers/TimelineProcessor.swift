import Foundation

class TimelineProcessor
{
    private let settingsService: SettingsService
    private let timeSlotService: TimeSlotService
    private let timeService: TimeService
    
    init(settingsService: SettingsService, timeSlotService: TimeSlotService, timeService: TimeService)
    {
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.timeService = timeService
    }
    
    func process(slots: [TemporaryTimeSlot]) -> [TemporaryTimeSlot]
    {
        var auxSlots = capMidnight(slots: slots)
        auxSlots = addFirstOfDay(slots: auxSlots)
        return auxSlots
    }
    
    private func capMidnight(slots: [TemporaryTimeSlot]) -> [TemporaryTimeSlot]
    {
        return slots.reduce([TemporaryTimeSlot]()) { acc, slot in
            guard let end = slot.end else { return acc + [slot] }
            
            if slot.start.day != end.day {
                return acc + [
                    slot.with(end: end.ignoreTimeComponents()),
                    slot.with(start: end.ignoreTimeComponents(), end: end)
                ]
            } else {
                return acc + [slot]
            }
        }
    }
    
    private func addFirstOfDay(slots: [TemporaryTimeSlot]) -> [TemporaryTimeSlot]
    {
        let now = timeService.now
        let slotLocation = slots.last?.location ?? settingsService.lastLocation!
        
        guard !hasTimeSlotsForToday(slots) && timeSlotService.getTimeSlots(forDay: now).isEmpty else { return slots }
        
        return slots + [ TemporaryTimeSlot(start: now, location: slotLocation, category: .leisure)]
    }
    
    private func hasTimeSlotsForToday(_ timeline: [TemporaryTimeSlot]) -> Bool
    {
        return !timeline.isEmpty && timeline.contains(where: timeSlotStartsToday)
    }
    
    private func timeSlotStartsToday(timeSlot: TemporaryTimeSlot) -> Bool
    {
        return timeSlot.start.ignoreTimeComponents() == timeService.now.ignoreTimeComponents()
    }
}
