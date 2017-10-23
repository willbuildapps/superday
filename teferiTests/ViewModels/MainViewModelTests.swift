import RxSwift
import XCTest
import Nimble
@testable import teferi

class MainViewModelTests : XCTestCase
{
    private var viewModel : MainViewModel!
    private var disposable : Disposable? = nil
    
    private var loggingService: MockLoggingService!
    private var timeService : MockTimeService!
    private var metricsService : MockMetricsService!
    private var feedbackService : MockFeedbackService!
    private var locationService : MockLocationService!
    private var settingsService : MockSettingsService!
    private var timeSlotService : MockTimeSlotService!
    private var editStateService : MockEditStateService!
    private var smartGuessService : MockSmartGuessService!
    private var appLifecycleService : MockAppLifecycleService!
    private var selectedDateService : MockSelectedDateService!
    private var trackEventService: MockTrackEventService!
    private var motionService: MockMotionService!
    
    override func setUp()
    {
        loggingService = MockLoggingService()
        timeService = MockTimeService()
        metricsService = MockMetricsService()
        locationService = MockLocationService()
        settingsService = MockSettingsService()
        feedbackService = MockFeedbackService()
        editStateService = MockEditStateService()
        smartGuessService = MockSmartGuessService()
        appLifecycleService = MockAppLifecycleService()
        selectedDateService = MockSelectedDateService()
        timeSlotService = MockTimeSlotService(timeService: timeService,
                                                   locationService: locationService)
        trackEventService = MockTrackEventService()
        motionService = MockMotionService()
        
        viewModel = MainViewModel(loggingService: loggingService,
                                  timeService: timeService,
                                  metricsService: metricsService,
                                  timeSlotService: timeSlotService,
                                  editStateService: editStateService,
                                  smartGuessService: smartGuessService,
                                  selectedDateService: selectedDateService,
                                  settingsService: settingsService,
                                  appLifecycleService: appLifecycleService,
                                  locationService: locationService,
                                  trackEventService: trackEventService,
                                  motionService: motionService)
        
    }
    
    override func tearDown()
    {
        disposable?.dispose()
    }
    
    func testTheAddNewSlotsMethodAddsANewSlot()
    {
        var didAdd = false
        
        disposable = timeSlotService.timeSlotCreatedObservable.subscribe(onNext: { _ in didAdd = true })
        viewModel.addNewSlot(withCategory: .commute)
        
        expect(didAdd).to(beTrue())
    }
    
    func testTheAddNewSlotMethodCallsTheMetricsService()
    {
        viewModel.addNewSlot(withCategory: .commute)
        expect(self.metricsService.didLog(event: .timeSlotManualCreation(date: self.timeService.now, category: .commute))).to(beTrue())
    }
    
    func testLocationPermissionShouldNotBeShownIfTheUserHasAlreadyAuthorized()
    {
        settingsService.hasLocationPermission = true
        
        var wouldShow = false
        disposable = viewModel.showPermissionControllerObservable
            .subscribe(onNext:  { _ in wouldShow = true })
        
        expect(wouldShow).to(beFalse())
    }
    
    func testIfLocationPermissionWasNeverShownItNeedsToBeShown()
    {
        settingsService.hasLocationPermission = false
        
        var wouldShow = false
        disposable = viewModel.showPermissionControllerObservable
            .subscribe(onNext: { type in wouldShow = type == .location })
        
        appLifecycleService.publish(.movedToForeground(withDailyVotingNotificationDate: nil))
        
        expect(wouldShow).to(beTrue())
    }
    
    private func addTimeSlot(withCategory category: teferi.Category) -> TimeSlot
    {
        return timeSlotService.addTimeSlot(withStartTime: Date(),
                                                category: category,
                                                categoryWasSetByUser: false,
                                                tryUsingLatestLocation: false)!
    }
}
