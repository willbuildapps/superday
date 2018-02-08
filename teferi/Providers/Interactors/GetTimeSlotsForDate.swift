import Foundation
import RxSwift

class GetTimeSlotsForDate: Interactor
{
    let persistency: CoreDataPersistency
    let timeService: TimeService
    let timeSlotService: TimeSlotService
    let appLifecycleService: AppLifecycleService
    
    let date: Date
    
    init(persistency: CoreDataPersistency, timeService: TimeService, timeSlotService: TimeSlotService, appLifecycleService: AppLifecycleService, date: Date)
    {
        self.persistency = persistency
        self.timeService = timeService
        self.timeSlotService = timeSlotService
        self.appLifecycleService = appLifecycleService
        
        self.date = date
    }
    
    func execute() -> Observable<[TimeSlot]>
    {
        let isCurrentDay = date.ignoreTimeComponents() == timeService.now.ignoreTimeComponents()
        
        let timer = isCurrentDay ? Observable<Int>.timer(0, period: 10, scheduler: MainScheduler.instance).mapTo(()) : Observable.just(())

        let refresh = Observable.merge([
                isCurrentDay ? timeSlotService.timeSlotCreatedObservable.filter(belongs(to: date)).mapTo(()) : Observable.never(),
                timeSlotService.timeSlotsUpdatedObservable.filter(allBelong(to: date)).mapTo(()),
                appLifecycleService.movedToForegroundObservable.mapTo(())
            ])
            .startWith(())
            .throttle(0.3, latest: false, scheduler: MainScheduler.instance)
        
        let timeSlots = refresh
            .flatMapLatest(fetchTimeSlots)
        
        // On time tick update timeSlot generation but don't fetch them again from DB
        return Observable.combineLatest(timeSlots, timer) { ts, _ in ts }
            .map(toTimeSlots >>> cropToDate >>> filterDurationZero)
    }
    
    private func fetchTimeSlots() -> Observable<[TimeSlotPM]>
    {
        // Takes timeslots from 1 day before and 1 after to also get the ones spaning midnight
        return persistency.fetch(TimeSlotPM.all(fromDate: date.add(days: -1), toDate: date.add(days: 1)))
    }
    
    private func toTimeSlots(timeSlotPMs: [TimeSlotPM]) -> [TimeSlot]
    {
        let isCurrentDay = date.ignoreTimeComponents() == timeService.now.ignoreTimeComponents()
        var previousTime: Date? = isCurrentDay ? timeService.now : self.date.add(days: 1).ignoreTimeComponents()

        // Adds end times as it maps to TimeSlots
        return timeSlotPMs
            .reversed()
            .map { pm in
                let newTimeSlot = TimeSlot(
                    startTime: pm.startTime,
                    endTime: previousTime,
                    category: pm.category
                )
                previousTime = pm.startTime
                return newTimeSlot
            }
            .reversed()
    }
    
    private func cropToDate(timeSlots: [TimeSlot]) -> [TimeSlot]
    {
        // We are not splitting at midnight in the DB anymore. So it does so here
        return timeSlots.flatMap { timeSlot in
            if timeSlot.startTime.ignoreTimeComponents() != date && timeSlot.endTime!.ignoreTimeComponents() != date {
                return nil
            }
            
            if timeSlot.startTime.ignoreTimeComponents() != date {
                return timeSlot.withStartTime(date.ignoreTimeComponents())
            }
            
            if timeSlot.endTime!.ignoreTimeComponents() != date {
                return timeSlot.withEndDate(date.ignoreTimeComponents())
            }
            
            return timeSlot
        }
    }
    
    // This is necessary in case there's one ending/starting exaclty at midnight
    private func filterDurationZero(timeSlots: [TimeSlot]) -> [TimeSlot]
    {
        return timeSlots.filter{ $0.duration! > 0}
    }
}


// Free functions (Might be moved to static functions on TimeSlot)

fileprivate func belongs(to date: Date) -> (TimeSlot) -> Bool
{
    return { timeSlot in
        return timeSlot.belongs(toDate: date)
    }
}

fileprivate func allBelong(to date: Date) -> ([TimeSlot]) -> Bool
{
    return { timeSlots in
        return timeSlots.filter(belongs(to: date)).count == timeSlots.count
    }
}


