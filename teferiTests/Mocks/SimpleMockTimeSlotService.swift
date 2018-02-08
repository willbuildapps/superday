import Foundation
import RxSwift
@testable import teferi

class SimpleMockTimeSlotService : TimeSlotService
{
    var newTimeSlotToReturn: TimeSlot? = nil
    var timeSlotsToReturn: [TimeSlot]? = nil
    var durationToReturn: TimeInterval = 0
    
    private(set) var dateAsked:Date? = nil
    
    private let timeSlotCreatedSubjet = PublishSubject<TimeSlot?>()
    var timeSlotCreatedObservable : Observable<TimeSlot> {
        return timeSlotCreatedSubjet.filterNil().asObservable()
    }
    
    private let timeSlotsUpdatedSubject = PublishSubject<[TimeSlot]?>()
    var timeSlotsUpdatedObservable : Observable<[TimeSlot]> {
        return timeSlotsUpdatedSubject.filterNil().asObservable()
    }
    
    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: teferi.Category, categoryWasSetByUser: Bool, tryUsingLatestLocation: Bool) -> TimeSlot?
    {
        timeSlotCreatedSubjet.onNext(newTimeSlotToReturn)
        return newTimeSlotToReturn
    }
    
    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: teferi.Category, categoryWasSetByUser: Bool, location: Location?) -> TimeSlot?
    {
        timeSlotCreatedSubjet.onNext(newTimeSlotToReturn)
        return newTimeSlotToReturn
    }
    
    @discardableResult func addTimeSlot(fromTemporaryTimeslot: TemporaryTimeSlot) -> TimeSlot?
    {
        timeSlotCreatedSubjet.onNext(newTimeSlotToReturn)
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
        let updatedTimeSlots = timeSlots.map { $0.withCategory(category) }
        timeSlotsUpdatedSubject.onNext(updatedTimeSlots)
    }
    
    func updateTimes(firstSlot: TimeSlot, secondSlot: TimeSlot, newBreakTime: Date)
    {
        fatalError("Not testing code")
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
