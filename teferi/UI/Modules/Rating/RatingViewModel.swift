import Foundation

class RatingViewModel
{
    private let timeSlotService : TimeSlotService
    private let metricsService : MetricsService
    
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
         metricsService: MetricsService)
    {
        self.startDate = startDate
        self.endDate = endDate
        self.timeSlotService = timeSlotService
        self.metricsService = metricsService
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
}
