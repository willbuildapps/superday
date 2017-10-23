import Foundation

class Persister
{
    private let timeSlotService : TimeSlotService
    private let timeService : TimeService
    private let metricsService:  MetricsService
    
    init(timeSlotService: TimeSlotService,
         timeService: TimeService,
         metricsService: MetricsService)
    {
        self.timeSlotService = timeSlotService
        self.timeService = timeService
        self.metricsService = metricsService
    }
    
    func persist(slots: [TemporaryTimeSlot])
    {
        if slots.isEmpty { return }
        
        var lastLocation : Location? = nil
        var firstSlotCreated : TimeSlot? = nil
        
        for temporaryTimeSlot in slots
        {
            let addedTimeSlot = timeSlotService.addTimeSlot(fromTemporaryTimeslot: temporaryTimeSlot)
            if firstSlotCreated == nil { firstSlotCreated = addedTimeSlot }
            lastLocation = addedTimeSlot?.location ?? lastLocation
        }

        logTimeSlotsSince(date: firstSlotCreated?.startTime)
    }
    
    private func logTimeSlotsSince(date: Date?)
    {
        guard let startDate = date else { return }
        
        timeSlotService.getTimeSlots(betweenDate: startDate, andDate: timeService.now).forEach({ slot in
            metricsService.log(event: .timeSlotCreated(date: timeService.now, category: slot.category, duration: slot.duration))
            if slot.categoryWasSmartGuessed
            {
                metricsService.log(event: .timeSlotSmartGuessed(date: timeService.now, category: slot.category, duration: slot.duration))
            }
            else
            {
                metricsService.log(event: .timeSlotNotSmartGuessed(date: timeService.now, category: slot.category, duration: slot.duration))
            }
        })
    }
}

