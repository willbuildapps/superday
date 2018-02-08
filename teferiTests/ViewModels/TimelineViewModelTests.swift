import Foundation
import XCTest
import RxSwift
import RxTest
import Nimble
@testable import teferi

class TimelineViewModelTests : XCTestCase
{
    private var disposeBag : DisposeBag = DisposeBag()
    private var viewModel : TimelineViewModel!
    
    private var timeService : MockTimeService!
    private var metricsService : MockMetricsService!
    private var locationService : MockLocationService!
    private var timeSlotService : MockTimeSlotService!
    private var editStateService : MockEditStateService!
    private var appLifecycleService : MockAppLifecycleService!
    private var loggingService : MockLoggingService!
    private var settingsService : MockSettingsService!
    
    private var observer: TestableObserver<[TimelineItem]>!
    private var scheduler:TestScheduler!
    
    override func setUp()
    {
        disposeBag = DisposeBag()
        timeService = MockTimeService()
        metricsService = MockMetricsService()
        locationService = MockLocationService()
        editStateService = MockEditStateService()
        appLifecycleService = MockAppLifecycleService()
        timeSlotService = MockTimeSlotService(timeService: timeService,
                                                   locationService: locationService)
        loggingService = MockLoggingService()
        settingsService = MockSettingsService()
        
        viewModel = TimelineViewModel(date: Date(),
                                           timeService: timeService,
                                           timeSlotService: timeSlotService,
                                           editStateService: editStateService,
                                           appLifecycleService: appLifecycleService,
                                           loggingService: loggingService,
                                           settingsService: settingsService,
                                           metricsService: metricsService)
        
        scheduler = TestScheduler(initialClock:0)
        observer = scheduler.createObserver([TimelineItem].self)
        viewModel.timelineItems
            .drive(observer)
            .disposed(by: disposeBag)
    }
    
    override func tearDown()
    {
        disposeBag = DisposeBag()
    }
    
    @discardableResult private func addTimeSlot(minutesAfterNoon: Int = 0, category : teferi.Category = .work) -> TimeSlot
    {
        let noon = Date.noon
        
        return timeSlotService.addTimeSlot(withStartTime: noon.addingTimeInterval(TimeInterval(minutesAfterNoon * 60)),
                                                category: category,
                                                categoryWasSetByUser: false,
                                                tryUsingLatestLocation: false)!
    }
}

extension TimelineItem
{
    var slotTimelineItem: SlotTimelineItem?
    {
        switch self {
        case .slot(let item),
             .commuteSlot(let item),
             .expandedCommuteTitle(let item),
             .expandedTitle(let item),
             .expandedSlot(let item, _):
            return item
        case .collapseButton(_):
            return nil
        }
    }
}
