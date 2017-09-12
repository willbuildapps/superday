import Foundation

class RatingViewModel
{
    private let timeSlotService : TimeSlotService
    private let metricsService : MetricsService
    private let settingsService : SettingsService
    private let timeService : TimeService
    
    let startDate : Date
    let endDate : Date
    lazy var activities : [Activity] =
    {
        return self.timeSlotService
            .getActivities(fromDate: self.startDate, untilDate: self.endDate)
            .sorted(by: self.duration)
    }()
    
    // MARK: - Init
    init(startDate: Date,
         endDate: Date,
         timeSlotService: TimeSlotService,
         metricsService: MetricsService,
         settingsService: SettingsService,
         timeService: TimeService)
    {
        self.startDate = startDate
        self.endDate = endDate
        self.timeSlotService = timeSlotService
        self.metricsService = metricsService
        self.settingsService = settingsService
        self.timeService = timeService
    }
    
    // MARK: - Helper
    
    private func duration(_ element1: Activity, _ element2: Activity) -> Bool
    {
        return element1.duration > element2.duration
    }
    
    // MARK: - Methods
    
    func setRating(_ rating: Int)
    {
        metricsService.log(event: CustomEvent.timelineWeeklyReview(date: startDate, rating: rating))
    }
    
    func didShowRating()
    {
        settingsService.setLastShownWeeklyRating(timeService.now)
    }
}
