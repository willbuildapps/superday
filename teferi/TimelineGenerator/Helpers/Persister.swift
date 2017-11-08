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
        guard let firstSlot = slots.first else { return }
        
        var lastLocation : Location? = nil
        var firstSlotCreated : TimeSlot? = nil
        
        var auxSlots = slots
        if let lastSlot = timeSlotService.getLast(), shouldContinue(lastSlot: lastSlot, withSlot: firstSlot) {
            auxSlots = Array(auxSlots.dropFirst())
        }
        
        for temporaryTimeSlot in auxSlots
        {
            let addedTimeSlot = timeSlotService.addTimeSlot(fromTemporaryTimeslot: temporaryTimeSlot)
            if firstSlotCreated == nil { firstSlotCreated = addedTimeSlot }
            lastLocation = addedTimeSlot?.location ?? lastLocation
        }

        logTimeSlotsSince(date: firstSlotCreated?.startTime)
    }
    
    private func shouldContinue(lastSlot: TimeSlot, withSlot nextSlot: TemporaryTimeSlot) -> Bool
    {
        guard lastSlot.startTime.ignoreTimeComponents() == nextSlot.start.ignoreTimeComponents() else { return false }
        
        let activityMatches = activitiesMatch(slot: lastSlot, temporaryTimeSlot: nextSlot)
        if lastSlot.categoryWasSetByUser {
            // If the last stored slot category was set by user and the activity matches the first TTS, we just continue the last stored one
            return activityMatches
        }
        
        // If the last stored slot category was NOT set by user we also check the category matches with the smartguessed one
        return activityMatches && (lastSlot.category == nextSlot.category || nextSlot.category == .unknown)
    }
    
    private func activitiesMatch(slot: TimeSlot, temporaryTimeSlot: TemporaryTimeSlot) -> Bool
    {
        switch (slot.activity, temporaryTimeSlot.activity) {
        case (nil, .still):
            return true
        case (nil, _):
            return false
        case (let a, let b):
            return a == b
        }
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

