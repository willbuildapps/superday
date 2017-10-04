import Foundation

class Persister
{
    private typealias SmartGuessUpdate = (smartGuess: SmartGuess, time: Date)
    
    private let timeSlotService : TimeSlotService
    private let smartGuessService : SmartGuessService
    private let timeService : TimeService
    private let metricsService:  MetricsService
    
    init(timeSlotService: TimeSlotService,
         smartGuessService: SmartGuessService,
         timeService: TimeService,
         metricsService: MetricsService)
    {
        self.timeSlotService = timeSlotService
        self.smartGuessService = smartGuessService
        self.timeService = timeService
        self.metricsService = metricsService
    }
    
    func persist(slots: [TemporaryTimeSlot])
    {
        if slots.isEmpty { return }
        
        var lastLocation : Location? = nil
        var smartGuessesToUpdate = [SmartGuessUpdate]()
        
        var firstSlotCreated : TimeSlot? = nil
        
        for temporaryTimeSlot in slots
        {
            let addedTimeSlot = timeSlotService.addTimeSlot(fromTemporaryTimeslot: temporaryTimeSlot)
            if let smartGuess = temporaryTimeSlot.smartGuess {
                smartGuessesToUpdate.append((smartGuess, temporaryTimeSlot.start))
            }
            if firstSlotCreated == nil { firstSlotCreated = addedTimeSlot }
            lastLocation = addedTimeSlot?.location ?? lastLocation
        }

        logTimeSlotsSince(date: firstSlotCreated?.startTime)
        smartGuessesToUpdate.forEach { self.smartGuessService.markAsUsed($0.smartGuess, atTime: $0.time) }
    }
    
    private func logTimeSlotsSince(date: Date?)
    {
        guard let startDate = date else { return }
        
        timeSlotService.getTimeSlots(betweenDate: startDate, andDate: timeService.now).forEach({ slot in
            metricsService.log(event: .timeSlotCreated(date: timeService.now, category: slot.category, duration: slot.duration))
            if let _ = slot.smartGuessId
            {
                metricsService.log(event: .timeSlotSmartGuessed(date: timeService.now, category: slot.category, duration: slot.duration))
            } else {
                metricsService.log(event: .timeSlotNotSmartGuessed(date: timeService.now, category: slot.category, duration: slot.duration))
            }
        })
    }
}

