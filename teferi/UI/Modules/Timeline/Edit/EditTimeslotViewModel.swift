import Foundation
import RxSwift

class EditTimeslotViewModel
{
    var timelineItemObservable: Observable<TimelineItem?>
    {
        return timelineItemVariable.asObservable()
    }
    let timelineItemsObservable: Observable<[TimelineItem]>

    let categoryProvider : CategoryProvider
    let timeService: TimeService
    var isShowingSubSlot : Bool
    
    private let timeSlotService: TimeSlotService
    private let metricsService: MetricsService
    private let smartGuessService: SmartGuessService
    private let startDate: Date
    
    private let timelineItemVariable = Variable<TimelineItem?>(nil)
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(startDate: Date,
         isShowingSubSlot: Bool = false,
         timelineItemsObservable: Observable<[TimelineItem]>,
         timeSlotService: TimeSlotService,
         metricsService: MetricsService,
         smartGuessService: SmartGuessService,
         timeService: TimeService)
    {
        self.startDate = startDate
        self.timelineItemsObservable = timelineItemsObservable
        self.isShowingSubSlot = isShowingSubSlot
        self.timeSlotService = timeSlotService
        self.metricsService = metricsService
        self.smartGuessService = smartGuessService
        self.timeService = timeService
        self.categoryProvider = DefaultCategoryProvider(timeSlotService: timeSlotService)
        
        timelineItemsObservable
            .map(filterSelectedElement(for: startDate))
            .bindTo(timelineItemVariable)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Public methods
    func updateTimelineItem(_ timelineItem: TimelineItem, withCategory category: Category)
    {
        updateTimeSlot(timelineItem.timeSlots, withCategory: category)
    }
    
    // MARK: - Private methods
    private func updateTimeSlot(_ timeSlots: [TimeSlot], withCategory category: Category)
    {
        timeSlotService.update(timeSlots: timeSlots, withCategory: category)
        timeSlots.forEach { (timeSlot) in
            metricsService.log(event: .timeSlotEditing(date: timeService.now, fromCategory: timeSlot.category, toCategory: category, duration: timeSlot.duration))
        }
    }
    
    private func filterSelectedElement(for date: Date) -> ([TimelineItem]) -> TimelineItem?
    {
        return { timelineItems in
            if self.isShowingSubSlot
            {
                var timeSlotToShow : TimeSlot!
                var isRunning = false
                
                for timeline in timelineItems
                {
                    if let timeSlot = timeline.timeSlots.filter({ $0.startTime == date }).first
                    {
                        timeSlotToShow = timeSlot
                        let index = timeline.timeSlots.index(where: { $0.startTime == date })
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
                return timelineItems.filter({ $0.startTime == date }).first
            }
        }
    }
}
