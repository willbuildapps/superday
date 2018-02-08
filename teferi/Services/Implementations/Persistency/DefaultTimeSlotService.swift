import CoreData
import RxSwift
import Foundation

class DefaultTimeSlotService : TimeSlotService
{
    // MARK: Public Properties
    let timeSlotCreatedObservable : Observable<TimeSlot>
    let timeSlotsUpdatedObservable : Observable<[TimeSlot]>
    
    // MARK: Private Properties
    private let timeService : TimeService
    private let loggingService : LoggingService
    private let locationService : LocationService
    private let persistencyService : BasePersistencyService<TimeSlot>
    
    private let timeSlotCreatedSubject = PublishSubject<TimeSlot>()
    private let timeSlotsUpdatedSubject = PublishSubject<[TimeSlot]>()
    
    // MARK: Initializer
    init(timeService: TimeService,
         loggingService: LoggingService,
         locationService: LocationService,
         persistencyService: BasePersistencyService<TimeSlot>)
    {
        self.timeService = timeService
        self.loggingService = loggingService
        self.locationService = locationService
        self.persistencyService = persistencyService

        timeSlotCreatedObservable = timeSlotCreatedSubject.asObservable()
        timeSlotsUpdatedObservable = timeSlotsUpdatedSubject.asObservable()
    }

    // MARK: Public Methods
    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: Category, categoryWasSetByUser: Bool, tryUsingLatestLocation: Bool) -> TimeSlot?
    {
        let location : Location? = tryUsingLatestLocation ? locationService.getLastKnownLocation() : nil
        
        return addTimeSlot(withStartTime: startTime,
                                category: category,
                                categoryWasSetByUser: categoryWasSetByUser,
                                location: location)
    }
    
    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: Category, categoryWasSetByUser: Bool, location: Location?) -> TimeSlot?
    {
        let timeSlot = TimeSlot(startTime: startTime,
                                category: category, 
                                categoryWasSetByUser: categoryWasSetByUser,
                                categoryWasSmartGuessed: false,
                                location: location)
        
        return tryAdd(timeSlot: timeSlot)
    }
    
    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: Category, location: Location?) -> TimeSlot?
    {
        let timeSlot = TimeSlot(startTime: startTime,
                                category: category,
                                location: location)
        
        return tryAdd(timeSlot: timeSlot)
    }
    
    @discardableResult func addTimeSlot(fromTemporaryTimeslot temporaryTimeSlot: TemporaryTimeSlot) -> TimeSlot?
    {
        let timeSlot = TimeSlot(startTime: temporaryTimeSlot.start,
                                endTime: temporaryTimeSlot.end,
                                category: temporaryTimeSlot.category,
                                location: temporaryTimeSlot.location,
                                categoryWasSetByUser: false,
                                categoryWasSmartGuessed: temporaryTimeSlot.isSmartGuessed,
                                activity: temporaryTimeSlot.activity)
        
        return tryAdd(timeSlot: timeSlot)
    }
    
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    {
        return getTimeSlots(forDay: day, category: nil)
    }
    
    func getTimeSlots(forDay day: Date, category: Category?) -> [TimeSlot]
    {
        let startTime = day.ignoreTimeComponents() as NSDate
        let endTime = day.tomorrow.ignoreTimeComponents().addingTimeInterval(-1) as NSDate
        
        var timeSlots = [TimeSlot]()
        
        if let category = category
        {
            let predicates = [Predicate(parameter: "startTime", rangesFromDate: startTime, toDate: endTime),
                              Predicate(parameter: "category", equals: category.rawValue as AnyObject)]
            timeSlots = persistencyService.get(withANDPredicates: predicates)
        }
        else
        {
            let predicate = Predicate(parameter: "startTime", rangesFromDate: startTime, toDate: endTime)
            timeSlots = persistencyService.get(withPredicate: predicate)
        }
        
        return timeSlots
    }
    
    func getTimeSlots(sinceDaysAgo days: Int) -> [TimeSlot]
    {
        let today = timeService.now.ignoreTimeComponents()
        
        let startTime = today.add(days: -days).ignoreTimeComponents() as NSDate
        let endTime = today.tomorrow.ignoreTimeComponents() as NSDate
        let predicate = Predicate(parameter: "startTime", rangesFromDate: startTime, toDate: endTime)
        
        let timeSlots = persistencyService.get(withPredicate: predicate)
        return timeSlots
    }
    
    func getTimeSlots(betweenDate firstDate: Date, andDate secondDate: Date) -> [TimeSlot]
    {
        let date1 = firstDate.ignoreTimeComponents() as NSDate
        let date2 = secondDate.add(days: 1).ignoreTimeComponents() as NSDate
        let predicate = Predicate(parameter: "startTime", rangesFromDate: date1, toDate: date2)
        
        let timeSlots = persistencyService.get(withPredicate: predicate)
        return timeSlots
    }
    
    func update(timeSlots: [TimeSlot], withCategory category: Category)
    {
        let predicate = Predicate(parameter: "startTime", in: timeSlots.map({ $0.startTime }) as [AnyObject])
        let editFunction = { (timeSlot: TimeSlot) -> (TimeSlot) in
            return timeSlot.withCategory(category, setByUser: true)
        }
        
        if let updatedTimeSlots = persistencyService.batchUpdate(withPredicate: predicate, updateFunction: editFunction)
        {
            timeSlotsUpdatedSubject.on(.next(updatedTimeSlots))
        }
        else
        {
            timeSlots.forEach({ (timeSlot) in
                loggingService.log(withLogLevel: .warning, message: "Error updating category of TimeSlot created on \(timeSlot.startTime) from \(timeSlot.category) to \(category)")
            })
        }
    }
    
    func updateTimes(firstSlot: TimeSlot, secondSlot: TimeSlot, newBreakTime: Date)
    {
        let firstDuration = newBreakTime.timeIntervalSince(firstSlot.startTime)
        let secondDuration = secondSlot.endTime?.timeIntervalSince(newBreakTime) ?? timeService.now.timeIntervalSince(newBreakTime)
        
        var updated = [TimeSlot]()
        
        let firstPredicate = Predicate(parameter: "startTime", equals: firstSlot.startTime as AnyObject)
        let secondPredicate = Predicate(parameter: "startTime", equals: secondSlot.startTime as AnyObject)
        
        let firstFunction = { (timeSlot: TimeSlot) -> (TimeSlot) in
            return timeSlot.withEndDate(newBreakTime)
        }
        
        let secondFunction = { (timeSlot: TimeSlot) -> (TimeSlot) in
            return timeSlot.withStartTime(newBreakTime)
        }
        
        switch (firstDuration, secondDuration) {
        case (60..., 60...):
            
            if let firstUpdated = updateSlotTime(withPredicate: firstPredicate, updateFunction: firstFunction) {
                updated.append(firstUpdated)
            }
            if let secondUpdated = updateSlotTime(withPredicate: secondPredicate, updateFunction: secondFunction) {
                updated.append(secondUpdated)
            }
            
        case (..<60, 60...):
            
            persistencyService.delete(withPredicate: firstPredicate)

            if let updatedTimeslot = updateSlotTime(withPredicate: secondPredicate, updateFunction: secondFunction) {
                updated.append(updatedTimeslot)
            }
            
        case (60..., ..<60):
            
            persistencyService.delete(withPredicate: secondPredicate)
            
            if let updatedTimeslot = updateSlotTime(withPredicate: firstPredicate, updateFunction: firstFunction) {
                updated.append(updatedTimeslot)
            }
            
        default:
            break
        }

        timeSlotsUpdatedSubject.on(.next(updated))
    }
    
    private func updateSlotTime(withPredicate predicate: Predicate, updateFunction: @escaping (TimeSlot) -> (TimeSlot)) -> TimeSlot?
    {
        guard let updatedSlot = persistencyService.singleUpdate(withPredicate: predicate, updateFunction: updateFunction) else {
            loggingService.log(withLogLevel: .warning, message: "Error updating TimeSlot's time")
            return nil
        }
        
        return updatedSlot
    }
    
    func getLast() -> TimeSlot?
    {
        return persistencyService.getLast()
    }
    
    func calculateDuration(ofTimeSlot timeSlot: TimeSlot) -> TimeInterval
    {
        let endTime = getEndTime(ofTimeSlot: timeSlot)
        
        return endTime.timeIntervalSince(timeSlot.startTime)
    }
    
    // MARK: Private Methods
    private func tryAdd(timeSlot: TimeSlot) -> TimeSlot?
    {
        //The previous TimeSlot needs to be finished before a new one can start
        guard endPreviousTimeSlot(atDate: timeSlot.startTime) && persistencyService.create(timeSlot) else
        {
            loggingService.log(withLogLevel: .warning, message: "Failed to create new TimeSlot")
            return nil
        }
        
        loggingService.log(withLogLevel: .info, message: "New TimeSlot with category \"\(timeSlot.category)\" created")
        
        timeSlotCreatedSubject.on(.next(timeSlot))
        
        return timeSlot
    }
    
    private func getEndTime(ofTimeSlot timeSlot: TimeSlot) -> Date
    {
        if let endTime = timeSlot.endTime { return endTime}
        
        let date = timeService.now
        let timeEntryLimit = timeSlot.startTime.tomorrow.ignoreTimeComponents()
        let timeEntryLastedOverOneDay = date > timeEntryLimit
        
        //TimeSlots can't go past midnight
        let endTime = timeEntryLastedOverOneDay ? timeEntryLimit : date
        return endTime
    }
    
    private func endPreviousTimeSlot(atDate date: Date) -> Bool
    {
        guard let timeSlot = persistencyService.getLast() else { return true }
        
        let startDate = timeSlot.startTime
        var endDate = date
        
        guard endDate > startDate else
        {
            loggingService.log(withLogLevel: .warning, message: "Trying to create a negative duration TimeSlot")
            return false
        }
        
        //TimeSlot is going for over one day, we should end it at midnight
        if startDate.ignoreTimeComponents() != endDate.ignoreTimeComponents()
        {
            loggingService.log(withLogLevel: .info, message: "Early ending TimeSlot at midnight")
            endDate = startDate.tomorrow.ignoreTimeComponents()
        }
        
        let predicate = Predicate(parameter: "startTime", equals: timeSlot.startTime as AnyObject)
        let editFunction = { (timeSlot: TimeSlot) -> TimeSlot in
            
            return timeSlot.withEndDate(endDate)
        }
        
        guard let _ = persistencyService.singleUpdate(withPredicate: predicate, updateFunction: editFunction) else
        {
            loggingService.log(withLogLevel: .warning, message: "Failed to end TimeSlot started at \(timeSlot.startTime) with category \(timeSlot.category)")
            return false
        }
        
        return true
    }
}
