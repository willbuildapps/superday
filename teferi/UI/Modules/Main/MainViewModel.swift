import Foundation
import RxSwift

///ViewModel for the MainViewController.
class MainViewModel : RxViewModel
{
    // MARK: Public Properties
    let dateObservable : Observable<Date>
    let isEditingObservable : Observable<Bool>
    let beganEditingObservable : Observable<(CGPoint, TimelineItem)>
    let categoryProvider : CategoryProvider
    
    var currentDate : Date { return self.timeService.now }
    
    var showPermissionControllerObservable : Observable<PermissionRequestType>
    {
        return Observable.of(
            self.appLifecycleService.movedToForegroundObservable,
            self.didBecomeActive)
            .merge()
            .map { [unowned self] () -> PermissionRequestType? in
                if self.shouldShowLocationPermissionRequest() {
                    return PermissionRequestType.location
                } else if self.shouldShowHealthKitPermissionRequest() {
                    return PermissionRequestType.health
                }
                
                return nil
            }
            .filterNil()
    }
    
    var welcomeMessageHiddenObservable : Observable<Bool>
    {
        return Observable.of(
            self.appLifecycleService.movedToForegroundObservable.skip(1),
            self.didBecomeActive,
            self.beganEditingObservable.mapTo(()),
            self.timeSlotService.timeSlotCreatedObservable.mapTo(()) )
            .merge()
            .map { [unowned self] () -> Bool in
                guard self.timeService.now.ignoreTimeComponents() == self.settingsService.installDate!.ignoreTimeComponents()
                else {
                    self.settingsService.setWelcomeMessageShown()
                    return true
                }
                
                let value = self.settingsService.didShowWelcomeMessage
                self.settingsService.setWelcomeMessageShown()
                return value
            }
    }
    
    var moveToForegroundObservable : Observable<Void>
    {
        return appLifecycleService.movedToForegroundObservable
    }
    
    var shouldShowWeeklyRatingUI : Bool
    {
        guard let installDate = settingsService.installDate else { return false }
        
        if
            let lastShown = settingsService.lastShownWeeklyRating,
            lastShown.ignoreTimeComponents() == timeService.now.ignoreTimeComponents() || lastShown.ignoreTimeComponents() == timeService.now.add(days: -1).ignoreTimeComponents()
        {
            return false
        }
        
        let itIsSevenOrMoreDaysSinceTheAppInstall = timeService.now.timeIntervalSince(installDate) >= Constants.sevenDaysInSeconds
        let itIsSundayAfterWeeklyRatingHour = (timeService.now.dayOfWeek == 0 ? timeService.now.hour >= Constants.hourToShowWeeklyRatingUI : false)
        let itIsMondayBeforeWeeklyRatingHour = (timeService.now.dayOfWeek == 1 ? timeService.now.hour < Constants.hourToShowWeeklyRatingUI : false)
        let itIsInTheRangeBetweenSundayAfterWeeklyRatingHourAndModayBeforeWeeklyRatingHour = itIsSundayAfterWeeklyRatingHour || itIsMondayBeforeWeeklyRatingHour
        
        let shouldShowRatingUI = itIsSevenOrMoreDaysSinceTheAppInstall && itIsInTheRangeBetweenSundayAfterWeeklyRatingHourAndModayBeforeWeeklyRatingHour
        
        return shouldShowRatingUI
    }
    
    var weeklyRatingStartDate : Date
    {
        return timeService.now.add(days: -6)
    }
    
    var weeklyRatingEndDate : Date
    {
        return timeService.now
    }

    
    // MARK: Private Properties
    private let timeService : TimeService
    private let metricsService : MetricsService
    private let timeSlotService : TimeSlotService
    private let editStateService : EditStateService
    private let smartGuessService : SmartGuessService
    private let settingsService : SettingsService
    private let appLifecycleService : AppLifecycleService
    
    // MARK: Initializer
    init(timeService: TimeService,
         metricsService: MetricsService,
         timeSlotService: TimeSlotService,
         editStateService: EditStateService,
         smartGuessService : SmartGuessService,
         selectedDateService : SelectedDateService,
         settingsService : SettingsService,
         appLifecycleService: AppLifecycleService)
    {
        self.timeService = timeService
        self.metricsService = metricsService
        self.timeSlotService = timeSlotService
        self.editStateService = editStateService
        self.smartGuessService = smartGuessService
        self.settingsService = settingsService
        self.appLifecycleService = appLifecycleService
        
        isEditingObservable = editStateService.isEditingObservable
        dateObservable = selectedDateService.currentlySelectedDateObservable
        beganEditingObservable = editStateService.beganEditingObservable
        
        categoryProvider = DefaultCategoryProvider(timeSlotService: timeSlotService)

    }
    
    //MARK: Public Methods
    func notifyEditingEnded() { editStateService.notifyEditingEnded() }

    func addNewSlot(withCategory category: Category)
    {
        guard let timeSlot =
            timeSlotService.addTimeSlot(withStartTime: timeService.now,
                                             category: category,
                                             categoryWasSetByUser: true,
                                             tryUsingLatestLocation: true)
            else { return }
        
        if let location = timeSlot.location
        {
            smartGuessService.add(withCategory: timeSlot.category, location: location)
        }
        
        metricsService.log(event: .timeSlotManualCreation(date: timeService.now, category: category))
        metricsService.log(event: .timeSlotCreated(date: timeService.now, category: category, duration: nil))
    }
        
    func updateTimelineItem(_ timelineItem: TimelineItem, withCategory category: Category)
    {
        for timeSlot in timelineItem.timeSlots
        {
            updateTimeSlot(timeSlot, withCategory: category)
        }
        
        editStateService.notifyEditingEnded()
    }
    
    private func updateTimeSlot(_ timeSlot: TimeSlot, withCategory category: Category)
    {
        let categoryWasOriginallySetByUser = timeSlot.categoryWasSetByUser

        timeSlotService.update(timeSlot: timeSlot, withCategory: category)
        metricsService.log(event: .timeSlotEditing(date: timeService.now, fromCategory: timeSlot.category, toCategory: category, duration: timeSlot.duration))
        
        let smartGuessId = timeSlot.smartGuessId
        if !categoryWasOriginallySetByUser && smartGuessId != nil
        {
            //Strike the smart guess if it was wrong
            smartGuessService.strike(withId: smartGuessId!)
        }
        else if smartGuessId == nil, let location = timeSlot.location
        {
            smartGuessService.add(withCategory: category, location: location)
        }
    }
    
    //MARK: Private Methods
    
    private func shouldShowLocationPermissionRequest() -> Bool
    {
        if settingsService.hasLocationPermission { return false }
        
        //If user doesn't have permissions and we never showed the overlay, do it
        guard let lastRequestedDate = settingsService.lastAskedForLocationPermission else { return true }
        
        let minimumRequestDate = lastRequestedDate.addingTimeInterval(Constants.timeToWaitBeforeShowingLocationPermissionsAgain)
        
        //If we previously showed the overlay, we must only do it again after timeToWaitBeforeShowingLocationPermissionsAgain
        return minimumRequestDate < timeService.now
    }
    
    private func shouldShowHealthKitPermissionRequest() -> Bool
    {
        guard let installDate = settingsService.installDate else { return false }
        
        return !settingsService.hasHealthKitPermission && installDate.addingTimeInterval(Constants.timeToWaitBeforeShowingHealthKitPermissions - 5) < timeService.now
    }
}
