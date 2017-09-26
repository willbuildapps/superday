import Foundation

class OnboardingViewModel
{
    private(set) var timeService : TimeService
    private(set) var timeSlotService : TimeSlotService
    private(set) var settingsService : SettingsService
    private(set) var appLifecycleService : AppLifecycleService
    private(set) var notificationService : NotificationService
    private let locationService: LocationService
    
    init(timeService: TimeService,
         timeSlotService: TimeSlotService,
         settingsService: SettingsService,
         appLifecycleService: AppLifecycleService,
         notificationService: NotificationService,
         locationService: LocationService)
    {
        self.timeService = timeService
        self.timeSlotService = timeSlotService
        self.settingsService = settingsService
        self.appLifecycleService = appLifecycleService
        self.notificationService = notificationService
        self.locationService = locationService
    }
    
    func pageViewModel() -> OnboardingPageViewModel
    {
        return OnboardingPageViewModel(
            timeService: timeService,
            timeSlotService: timeSlotService,
            settingsService: settingsService,
            appLifecycleService: appLifecycleService,
            notificationService: notificationService,
            locationService: locationService)
    }
}
