import XCTest
import Nimble
import RxSwift
import RxTest
@testable import teferi

class CalendarViewModelTests: XCTestCase
{
    private var viewModel : CalendarViewModel!
    private var disposeBag : DisposeBag = DisposeBag()
    
    private var timeService : MockTimeService!
    private var settingsService : MockSettingsService!
    private var timeSlotService : SimpleMockTimeSlotService!
    private var selectedDateService : MockSelectedDateService!
    
    private var scheduler: TestScheduler!
    
    override func setUp()
    {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock:0)

        timeService = MockTimeService()
        settingsService = MockSettingsService()
        selectedDateService = MockSelectedDateService()
        timeSlotService = SimpleMockTimeSlotService()
        
        viewModel = CalendarViewModel(timeService: timeService,
                                      settingsService: settingsService,
                                      timeSlotService: timeSlotService,
                                      selectedDateService: selectedDateService)
    }
    
    func testSelectedDateForwardsToService()
    {
        let observer:TestableObserver<Date> = scheduler.createObserver(Date.self)
        selectedDateService.currentlySelectedDateObservable
            .skip(1)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        let dates = [Date().addingTimeInterval(2*24*60*60), Date().addingTimeInterval(3*24*60*60)]
        viewModel.setSelectedDate(date: dates[0])
        viewModel.setSelectedDate(date: dates[1])

        expect(observer.events.count).to(equal(2))
        expect(observer.values).to(equal(dates))
    }
    
    func testMaxValidDateReturnsCurrentDateAlways()
    {
        let now = Date()
        
        timeService.mockDate = now
        expect(self.viewModel.maxValidDate).to(equal(now))
        
        timeService.mockDate = now.addingTimeInterval(3*24*60*60)
        expect(self.viewModel.maxValidDate).to(equal(now.addingTimeInterval(3*24*60*60)))
    }
    
    func testGetActivitiesReturnsEmptyForInvalidDate()
    {
        let currentDate = Date()
        let dateRequested = currentDate.addingTimeInterval(3*24*60*60)
        
        timeService.mockDate = currentDate
        
        timeSlotService.timeSlotsToReturn = [
            TimeSlot(withStartTime: Date(), category: .food),
            TimeSlot(withStartTime: Date(), category: .work),
            TimeSlot(withStartTime: Date(), category: .leisure)
        ]
        
        let observer:TestableObserver<[Activity]> = scheduler.createObserver([Activity].self)

        viewModel.getActivities(forDate: dateRequested)
            .observeOn(MainScheduler.instance)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        expect(observer.events.count).to(equal(0))

    }
}
