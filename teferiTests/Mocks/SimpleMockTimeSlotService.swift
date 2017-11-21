import Foundation
import RxSwift
@testable import teferi

class SimpleMockTimeSlotService : TimeSlotService
{
    var newTimeSlotToReturn: TimeSlot? = nil
    var timeSlotsToReturn: [TimeSlot]? = nil
    var durationToReturn: TimeInterval = 0
    
    private(set) var dateAsked:Date? = nil
    
    var timeSlotCreatedObservable : Observable<TimeSlot> = Observable<TimeSlot>.empty()
    var timeSlotsUpdatedObservable : Observable<[TimeSlot]> = Observable<[TimeSlot]>.empty()
    
    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: teferi.Category, categoryWasSetByUser: Bool, tryUsingLatestLocation: Bool) -> TimeSlot?
    {
        return newTimeSlotToReturn
    }
    
    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: teferi.Category, categoryWasSetByUser: Bool, location: Location?) -> TimeSlot?
    {
        return newTimeSlotToReturn
    }
    
    @discardableResult func addTimeSlot(fromTemporaryTimeslot: TemporaryTimeSlot) -> TimeSlot?
    {
        return newTimeSlotToReturn
    }
    
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    {
        dateAsked = day
        return timeSlotsToReturn ?? []
    }
    
    func getTimeSlots(forDay day: Date, category: teferi.Category?) -> [TimeSlot]
    {
        dateAsked = day
        return timeSlotsToReturn ?? []
    }
    
    func getTimeSlots(sinceDaysAgo days: Int) -> [TimeSlot]
    {
        return timeSlotsToReturn ?? []
    }
    
    func getTimeSlots(betweenDate firstDate: Date, andDate secondDate: Date) -> [TimeSlot]
    {
        return timeSlotsToReturn ?? []
    }

    func update(timeSlots: [TimeSlot], withCategory category: teferi.Category)
    {
        
    }
    
    func updateTimes(firstSlot: TimeSlot, secondSlot: TimeSlot)
    {
        
    }
    
    func getLast() -> TimeSlot?
    {
        return timeSlotsToReturn?.last
    }
    
    func calculateDuration(ofTimeSlot timeSlot: TimeSlot) -> TimeInterval
    {
        return durationToReturn
    }
}
