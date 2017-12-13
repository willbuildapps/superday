import Foundation
import RxSwift

class TimeslotDetailViewModel
{
    var timelineItemObservable: Observable<TimelineItem?>
    {
        return timelineItemVariable.asObservable()
    }

    let categoryProvider : CategoryProvider
    let timeService: TimeService
    var isShowingSubSlot : Bool
    let updateStartDateSubject : PublishSubject<Date>
    
    private let timeSlotService: TimeSlotService
    private let metricsService: MetricsService
    private let smartGuessService: SmartGuessService
    private var startDate: Date
    
    private let timelineItemVariable = Variable<TimelineItem?>(nil)
    private let disposeBag = DisposeBag()
    
    private var isCurrentDay : Bool
    {
        return timeService.now.ignoreTimeComponents() == startDate.ignoreTimeComponents()
    }
    
    // MARK: - Init
    init(startDate: Date,
         isShowingSubSlot: Bool = false,
         updateStartDateSubject: PublishSubject<Date>,
         timeSlotService: TimeSlotService,
         metricsService: MetricsService,
         smartGuessService: SmartGuessService,
         timeService: TimeService,
         appLifecycleService: AppLifecycleService)
    {
        self.startDate = startDate
        self.isShowingSubSlot = isShowingSubSlot
        self.updateStartDateSubject = updateStartDateSubject
        self.timeSlotService = timeSlotService
        self.metricsService = metricsService
        self.smartGuessService = smartGuessService
        self.timeService = timeService
        self.categoryProvider = DefaultCategoryProvider(timeSlotService: timeSlotService)
        
        updateStartDateSubject.asObservable().subscribe(onNext: { [unowned self] (date) in
            self.startDate = date
        }).addDisposableTo(disposeBag)
        
        let newTimeSlotForThisDate = timeSlotService.timeSlotCreatedObservable
            .filter(belogsToDate)
            .mapTo(())
        
        let updatedTimeSlotsForThisDate = timeSlotService.timeSlotsUpdatedObservable
            .map(timeSlotsBelogToDate)
            .mapTo(())
        
        let movedToForeground = appLifecycleService
            .movedToForegroundObservable
            .mapTo(())
        
        let refreshObservable =
            Observable.of(newTimeSlotForThisDate, updatedTimeSlotsForThisDate, movedToForeground)
                .merge()
                .startWith(()) // This is a hack I can't remove due to something funky with the view controllery lifecycle. We should fix this in the refactor
        
        refreshObservable
            .map(timeSlotsForToday)
            .map(toTimelineItems)
            .map(filterSelectedElement)
            .bindTo(timelineItemVariable)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Public methods
    func updateTimelineItem(_ timelineItem: TimelineItem, withCategory category: Category)
    {
        updateTimeSlot(timelineItem.timeSlots, withCategory: category)
    }
    
    func timeSlot(before timeSlot: TimeSlot) -> TimeSlot?
    {
        guard timeSlot.startTime.ignoreDateComponents() != timeSlot.startTime.ignoreTimeComponents().ignoreDateComponents() else { return nil }
        
        let slots = timeSlotService.getTimeSlots(forDay: timeSlot.startTime.ignoreTimeComponents())
        let slotIndex = slots.map{ $0.startTime }.index(of: timeSlot.startTime) ?? 0
        return slots.safeGetElement(at: slotIndex - 1)
    }
    
    func timeSlot(after timeSlot: TimeSlot) -> TimeSlot?
    {
        guard let endTime = timeSlot.endTime, endTime.ignoreDateComponents() != endTime.ignoreTimeComponents().ignoreDateComponents() else { return nil }
        
        let slots = timeSlotService.getTimeSlots(forDay: timeSlot.startTime.ignoreTimeComponents())
        let slotIndex = slots.map{ $0.startTime }.index(of: timeSlot.startTime) ?? 0
        return slots.safeGetElement(at: slotIndex + 1)
    }
    
    // MARK: - Private methods
    private func belogsToDate(timeSlot: TimeSlot) -> Bool
    {
        return timeSlot.belongs(toDate: startDate)
    }
    
    private func timeSlotsBelogToDate(timeSlots: [TimeSlot]) -> [TimeSlot]
    {
        return timeSlots.belonging(toDate: startDate)
    }
    
    private func timeSlotsForToday() -> [TimeSlot]
    {
        return timeSlotService.getTimeSlots(forDay: startDate)
    }
    
    private func toTimelineItems(fromTimeSlots timeSlots: [TimeSlot]) -> [TimelineItem]
    {
        return timeSlots.toTimelineItems(timeSlotService: timeSlotService, isCurrentDay: isCurrentDay)
    }
    
    private func updateTimeSlot(_ timeSlots: [TimeSlot], withCategory category: Category)
    {
        timeSlotService.update(timeSlots: timeSlots, withCategory: category)
        timeSlots.forEach { (timeSlot) in
            metricsService.log(event: .timeSlotEditing(date: timeService.now, fromCategory: timeSlot.category, toCategory: category, duration: timeSlot.duration))
        }
    }
    
    private func filterSelectedElement(timelineItems: [TimelineItem]) -> TimelineItem?
    {
        if self.isShowingSubSlot
        {
            var timeSlotToShow : TimeSlot!
            var isRunning = false
            
            for timeline in timelineItems
            {
                if let timeSlot = timeline.timeSlots.filter({ $0.startTime == startDate }).first
                {
                    timeSlotToShow = timeSlot
                    let index = timeline.timeSlots.index(where: { $0.startTime == startDate })
                    if index == timeline.timeSlots.endIndex - 1
                    {
                        isRunning = timeline.isRunning
                    }
                    break
                }
            }
            
            guard timeSlotToShow != nil else { return nil }
            
            return TimelineItem(withTimeSlots: [timeSlotToShow],
                                category: timeSlotToShow.category,
                                duration: timeSlotToShow.duration != nil ?
                                    timeSlotToShow.duration! :
                                    self.timeService.now.timeIntervalSince(timeSlotToShow.startTime),
                                isRunning: isRunning)
        }
        else
        {
            return timelineItems.filter({ $0.startTime == startDate }).first
        }
    }
}
