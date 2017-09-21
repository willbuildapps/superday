import Foundation

class TimelineGenerator
{
    private let pipeline : Pipeline
    
    private let loggingService: LoggingService
    private let trackEventService: TrackEventService
    private let smartGuessService: SmartGuessService
    private let timeService: TimeService
    private let timeSlotService: TimeSlotService
    private let metricsService: MetricsService
    private let settingsService: SettingsService
    
    init(loggingService: LoggingService,
         trackEventService: TrackEventService,
         smartGuessService: SmartGuessService,
         timeService: TimeService,
         timeSlotService: TimeSlotService,
         metricsService: MetricsService,
         settingsService: SettingsService)
    {
        self.loggingService = loggingService
        self.trackEventService = trackEventService
        self.smartGuessService = smartGuessService
        self.timeService = timeService
        self.timeSlotService = timeSlotService
        self.metricsService = metricsService
        self.settingsService = settingsService
        
        let locationPump = LocationPump(trackEventService: trackEventService,
                                        settingsService: settingsService,
                                        timeSlotService: timeSlotService,
                                        loggingService: loggingService,
                                        timeService: timeService)
        
        let healthKitPump = HealthKitPump(trackEventService: trackEventService, loggingService: loggingService)
        
        pipeline = Pipeline.with(loggingService: loggingService, pumps: locationPump, healthKitPump)
            .pipe(to: MergePipe())
            .pipe(to: SmartGuessPipe(smartGuessService: smartGuessService))
            .pipe(to: MergeMiniCommuteTimeSlotsPipe(timeService: timeService))
            .pipe(to: MergeShortTimeSlotsPipe())
            .pipe(to: CapMidnightPipe(timeService: timeService))
            .pipe(to: FirstTimeSlotOfDayPipe(timeService: timeService, timeSlotService: timeSlotService))
            .sink(PersistencySink(settingsService: settingsService,
                                  timeSlotService: timeSlotService,
                                  smartGuessService: smartGuessService,
                                  trackEventService: trackEventService,
                                  timeService: timeService,
                                  metricsService: metricsService))
    }
    
    func execute()
    {
        pipeline.run()
    }
}
