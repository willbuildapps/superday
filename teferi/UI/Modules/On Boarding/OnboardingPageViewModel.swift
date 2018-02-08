import Foundation
import RxSwift

class OnboardingPageViewModel: NSObject
{
    var movedToForegroundObservable: Observable<Void> {
        return appLifecycleService.movedToForegroundObservable
    }
    
    var locationAuthorizationChangedObservable: Observable<Void>
    {
        guard !settingsService.hasLocationPermission else { return Observable.just(()) }
        return locationService.alwaysAuthorizationGranted.mapTo(())
    }
    
    var motionAuthorizationChangedObservable: Observable<Void>
    {
        return motionService.motionAuthorizationGranted.mapTo(())
    }

    private var timeService : TimeService!
    private var timeSlotService : TimeSlotService!
    fileprivate var settingsService : SettingsService!
    private var appLifecycleService : AppLifecycleService!
    private var motionService: MotionService!
    private var locationService : LocationService!
    
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
    
    func slotTimelineItem(forTimeslot timeslot: TimeSlot) -> SlotTimelineItem
    {
        return SlotTimelineItem(timeSlots: [timeslot])
    }
    
    func timeSlot(withCategory category: Category, from: String, to: String) -> TimeSlot
    {
        let startTime = time(from: from)
        let endTime = time(from: to)
        
        let timeSlot = TimeSlot(startTime: startTime,
                                endTime: endTime,
                                category: category)
        
        return timeSlot
    }
    
    func requestCoreMotionAuthorization()
    {
        motionService.askForAuthorization()
    }
    
    func requestLocationAuthorization()
    {
        guard !settingsService.hasLocationPermission else { return }
        locationService.requestAuthorization()
    }
    
    private func time(from timeString: String) -> Date
    {
        guard let hours = Int(timeString.components(separatedBy: ":")[0]),
            let minutes = Int(timeString.components(separatedBy: ":")[1]) else {
                return timeService.now.ignoreTimeComponents()
        }
        
        return timeService.now
            .ignoreTimeComponents()
            .addingTimeInterval(TimeInterval((hours * 60 + minutes) * 60))
    }
}
