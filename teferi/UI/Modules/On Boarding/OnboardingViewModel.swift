import Foundation

class OnboardingViewModel
{
    private(set) var timeService : TimeService
    private(set) var timeSlotService : TimeSlotService
    private(set) var settingsService : SettingsService
    private(set) var appLifecycleService : AppLifecycleService
    private let motionService: MotionService
    private let locationService: LocationService
    
    init(timeService: TimeService,
         timeSlotService: TimeSlotService,
         settingsService: SettingsService,
         appLifecycleService: AppLifecycleService,
         motionService: MotionService,
         locationService: LocationService)
    {
        self.timeService = timeService
        self.timeSlotService = timeSlotService
        self.settingsService = settingsService
        self.appLifecycleService = appLifecycleService
        self.motionService = motionService
        self.locationService = locationService
    }
    
    func pageViewModel() -> OnboardingPageViewModel
    {
        return OnboardingPageViewModel(
            timeService: timeService,
            timeSlotService: timeSlotService,
            settingsService: settingsService,
            appLifecycleService: appLifecycleService,
            motionService: motionService,
            locationService: locationService)
    }
}
