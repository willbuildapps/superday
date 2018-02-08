import Foundation
import RxSwift
import RxCocoa

class TimelineViewModel: RxViewModel
{
    //MARK: Public Properties
    let date : Date
    var timelineItems : Driver<[TimelineItem]>!
    
    //MARK: Private Properties
    private let isCurrentDay : Bool
    private let disposeBag = DisposeBag()
    
    private let timeService : TimeService
    private let timeSlotService : TimeSlotService
    private let editStateService : EditStateService
    private let appLifecycleService : AppLifecycleService
    private let loggingService : LoggingService
    private let settingsService : SettingsService
    private let metricsService : MetricsService
    
    private var dateInsideExpandedTimeline: Date? = nil
    
    private var refreshLayoutSubject = PublishSubject<Void>()
    private var refreshLayout: Observable<Void> {
        return refreshLayoutSubject.asObservable().startWith(())
    }

    var dailyVotingNotificationObservable : Observable<Date>
    {
        return self.appLifecycleService.startedOnDailyVotingNotificationDateObservable
    }
    
    var didBecomeActiveObservable : Observable<Void>
    {
        return self.appLifecycleService.movedToForegroundObservable
    }
    
    //MARK: Initializers
    init(date completeDate: Date,
         timeService: TimeService,
         timeSlotService: TimeSlotService,
         editStateService: EditStateService,
         appLifecycleService: AppLifecycleService,
         loggingService: LoggingService,
         settingsService: SettingsService,
         metricsService: MetricsService)
    {
        self.timeService = timeService
        self.timeSlotService = timeSlotService
        self.editStateService = editStateService
        self.appLifecycleService = appLifecycleService
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.metricsService = metricsService
        self.date = completeDate.ignoreTimeComponents()
        
        self.isCurrentDay = timeService.now.ignoreTimeComponents() == date
        
        super.init()
        
        let todaysTimeSlots = didBecomeActive
            .flatMapLatest { [unowned self] _ in
                self.timeSlotsForToday()
                    .takeUntil(self.didBecomeInactive)
            }

        timelineItems = Observable.combineLatest(todaysTimeSlots, refreshLayout) { ts, _ in ts }
            .map(self.toTimelineItems)
            .asDriver(onErrorJustReturn: [])
    }
    
    //MARK: Public methods
    
    func notifyEditingBegan(point: CGPoint, item: SlotTimelineItem? = nil)
    {
        guard let slotTimelineItem = item else { return }
        
        editStateService
            .notifyEditingBegan(point: point,
                                slotTimelineItem: slotTimelineItem)
    }
    
    func collapseSlots()
    {
        dateInsideExpandedTimeline = nil
        refreshLayoutSubject.onNext(())
    }
    
    func expandSlots(item: SlotTimelineItem)
    {
        dateInsideExpandedTimeline = item.timeSlots.first?.startTime
        refreshLayoutSubject.onNext(())
    }
    
    func calculateDuration(ofTimeSlot timeSlot: TimeSlot) -> TimeInterval
    {
        return timeSlotService.calculateDuration(ofTimeSlot: timeSlot)
    }
    
    func canShowVotingUI() -> Bool
    {
        return canShowVotingView(forDate: date)
    }
    
    func setVote(vote: Bool)
    {
        settingsService.setVote(forDate: date)
        metricsService.log(event: .timelineVote(date: timeService.now, voteDate: date, vote: vote))
    }
    
    //MARK: Private Methods
    private func canShowVotingView(forDate date: Date) -> Bool
    {
        guard
            let installDate = settingsService.installDate,
            timeService.now.timeIntervalSince(date) < Constants.sevenDaysInSeconds &&
            ( timeService.now.ignoreTimeComponents() == date.ignoreTimeComponents() ? timeService.now.hour >= Constants.hourToShowDailyVotingUI : true ) &&
            installDate.ignoreTimeComponents() != date.ignoreTimeComponents()
        else { return false }
        
        let alreadyVoted = !settingsService.lastSevenDaysOfVotingHistory().contains(date.ignoreTimeComponents())
        
        return alreadyVoted
    }
    
    private func timeSlotsForToday() -> Observable<[TimeSlot]>
    {
        let getTimeSlotsForDate = InteractorFactory.shared.createGetTimeSlotsForDateInteractor(date: self.date)
        return getTimeSlotsForDate.execute()
    }
    
    private func toTimelineItems(fromTimeSlots timeSlots: [TimeSlot]) -> [TimelineItem]
    {
        let timelineItems = timeSlots
            .splitBy { $0.category }
            .flatMap { groupedTimeSlots -> [TimelineItem] in
                if groupedTimeSlots.count > 1 && areExpanded(groupedTimeSlots)
                {
                    return expandedTimelineItems(fromTimeSlots: groupedTimeSlots)
                }
                else
                {
                    let slotTimelineItem = SlotTimelineItem(timeSlots: groupedTimeSlots)
                    
                    let timelineItem = slotTimelineItem.category == .commute ?
                        TimelineItem.commuteSlot(item: slotTimelineItem) :
                        TimelineItem.slot(item: slotTimelineItem)
                    
                    return [ timelineItem ]
                }
            }
        
        // Add isLastInPastDay or isRunning to last timeslot of timeline
        if let lastTimelineItem = timelineItems.last, case TimelineItem.slot(let slotTimelineItem) = lastTimelineItem
        {
            let lastSlotItem = slotTimelineItem.withLastTimeSlotFlag(isCurrentDay: isCurrentDay)
            return Array(timelineItems.dropLast()) + [TimelineItem.slot(item: lastSlotItem)]
        }
        else
        {
            return timelineItems
        }
    }
    
    private func expandedTimelineItems(fromTimeSlots timeSlots: [TimeSlot]) -> [TimelineItem]
    {
        guard let first = timeSlots.first, let last = timeSlots.last, first.startTime != last.startTime else { return [] }
        let category = first.category
        
        let slotTimelineItem = SlotTimelineItem(timeSlots: timeSlots)
        
        let titleItem = category == .commute ?
            TimelineItem.expandedCommuteTitle(item: slotTimelineItem) :
            TimelineItem.expandedTitle(item: slotTimelineItem)
        
        let collapseItem = TimelineItem.collapseButton(color: first.category.color)
        
        let items = timeSlots.map { slot -> TimelineItem in
            let slotTimelineItem = SlotTimelineItem(timeSlots: [slot])
            return TimelineItem.expandedSlot(item: slotTimelineItem, hasSeparator: slot.startTime != last.startTime)
        }
        
        return [titleItem] + items + [collapseItem]
    }
    
    private func isLastInPastDay(_ index: Int, count: Int) -> Bool
    {
        guard !isCurrentDay else { return false }
        
        let isLastEntry = count - 1 == index
        return isLastEntry
    }
    
    private func areExpanded(_ timeSlots:[TimeSlot]) -> Bool
    {
        guard let dateInsideExpandedTimeline = dateInsideExpandedTimeline else { return false }
        
        return timeSlots.index(where: { $0.startTime == dateInsideExpandedTimeline }) != nil
    }
}

