import Foundation
import RxSwift
@testable import teferi

class MockTimeSlotService : TimeSlotService
{
    //MARK: Fields
    private let timeService : TimeService
    private let locationService : LocationService
    
    private let timeSlotCreatedSubject = PublishSubject<TimeSlot>()
    private let timeSlotsUpdatedSubject = PublishSubject<[TimeSlot]>()
    
    //MARK: Properties
    var timeSlots = [TimeSlot]()
    private(set) var getLastTimeSlotWasCalled = false
    
    init(timeService: TimeService, locationService: LocationService)
    {
        self.timeService = timeService
        self.locationService = locationService
        
        _timeSlotCreatedObservable = timeSlotCreatedSubject.asObservable()
        timeSlotsUpdatedObservable = timeSlotsUpdatedSubject.asObservable()
    }
    
    // MARK: Properties
    private let _timeSlotCreatedObservable : Observable<TimeSlot>
    var timeSlotCreatedObservable : Observable<TimeSlot>
    {
        return _timeSlotCreatedObservable
            .do(onSubscribe: { [unowned self] in
                self.didSubscribe = true
            })
    }

    let timeSlotsUpdatedObservable : Observable<[TimeSlot]>
    var didSubscribe = false
    
    // MARK: PersistencyService implementation
    func calculateDuration(ofTimeSlot timeSlot: TimeSlot) -> TimeInterval
    {
        let endTime = getEndTime(ofTimeSlot: timeSlot)
        
        return endTime.timeIntervalSince(timeSlot.startTime)
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
    
    func getLast() -> TimeSlot?
    {
        getLastTimeSlotWasCalled = true
        return timeSlots.last
    }
    
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    {
        let startDate = day.ignoreTimeComponents()
        let endDate = day.tomorrow.ignoreTimeComponents()
        
        return timeSlots.filter { t in t.startTime > startDate && t.startTime < endDate }
    }
    
    func getTimeSlots(forDay day: Date, category: teferi.Category?) -> [TimeSlot]
    {
        let startDate = day.ignoreTimeComponents()
        let endDate = day.tomorrow.ignoreTimeComponents()
        
        return timeSlots.filter { t in t.startTime > startDate && t.startTime < endDate && t.category == category }
    }
    
    func getTimeSlots(sinceDaysAgo days: Int) -> [TimeSlot]
    {
        let today = timeService.now
        
        let startDate = today.add(days: -days).ignoreTimeComponents()
        let endDate = today.tomorrow.ignoreTimeComponents()
        
        return timeSlots.filter { t in t.startTime > startDate && t.startTime < endDate }
    }
    
    func getTimeSlots(betweenDate firstDate: Date, andDate secondDate: Date) -> [TimeSlot]
    {
        return timeSlots.filter { t in t.startTime >= firstDate && t.startTime <= secondDate }
    }
    
    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: teferi.Category, categoryWasSetByUser: Bool, tryUsingLatestLocation: Bool) -> TimeSlot?
    {
        let location : Location? = tryUsingLatestLocation ? locationService.getLastKnownLocation() : nil
        return addTimeSlot(withStartTime: startTime, category: category, categoryWasSetByUser: categoryWasSetByUser, location:  location)
    }
    
    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: teferi.Category, categoryWasSetByUser: Bool, location: Location?) -> TimeSlot?
    {
        let timeSlot = TimeSlot(startTime: startTime,
                                category: category,
                                categoryWasSetByUser: categoryWasSetByUser,
                                categoryWasSmartGuessed: false,
                                location: location)
        return tryAdd(timeSlot: timeSlot)
    }
    
    @discardableResult func addTimeSlot(fromTemporaryTimeslot temporaryTimeslot: TemporaryTimeSlot) -> TimeSlot?
    {
        let timeSlot = TimeSlot(startTime: temporaryTimeslot.start,
                                endTime: temporaryTimeslot.end,
                                category: temporaryTimeslot.category,
                                location: temporaryTimeslot.location,
                                categoryWasSetByUser: false,
                                categoryWasSmartGuessed: temporaryTimeslot.isSmartGuessed,
                                activity: temporaryTimeslot.activity)
        return tryAdd(timeSlot: timeSlot)
    }
    
    private func tryAdd(timeSlot: TimeSlot) -> TimeSlot
    {
        if let lastTimeSlot = timeSlots.last
        {
            timeSlots = timeSlots.dropLast() + [lastTimeSlot.withEndDate(timeSlot.startTime)]
        }
        
        timeSlots.append(timeSlot)
        timeSlotCreatedSubject.on(.next(timeSlot))
        
        return timeSlot
    }
    
    func update(timeSlots: [TimeSlot], withCategory category: teferi.Category)
    {
        var updatedTimeSlots = [TimeSlot]()
        timeSlots.forEach { (timeSlot) in
            let updatedTimeSlot = timeSlot.withCategory(category, setByUser: true)
            updatedTimeSlots.append(updatedTimeSlot)
            self.timeSlots = self.timeSlots.map
            {
                if $0.startTime == updatedTimeSlot.startTime
                {
                    return updatedTimeSlot
                }
                
                return $0
            }
        }
        
        timeSlotsUpdatedSubject.on(.next(updatedTimeSlots))
    }
    
    func updateTimes(firstSlot: TimeSlot, secondSlot: TimeSlot, newBreakTime: Date)
    {
        fatalError("Missing tests")
    }
}

class PagerMockTimeSlotService : MockTimeSlotService
{
    @discardableResult override func addTimeSlot(withStartTime startTime: Date, category: teferi.Category, categoryWasSetByUser: Bool, tryUsingLatestLocation: Bool) -> TimeSlot?
    {
        return nil
    }
    
    @discardableResult override func addTimeSlot(withStartTime startTime: Date, category: teferi.Category, categoryWasSetByUser: Bool, location: Location?) -> TimeSlot?
    {
        return nil
    }
}
