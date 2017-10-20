import Foundation

class DefaultSmartGuessService : SmartGuessService
{
    typealias KNNInstance = (location: Location, timeStamp: Date, category: Category, timeSlot: TimeSlot?)
    
    //MARK: Private Properties
    private let distanceThreshold = 400.0 //TODO: We have to think about the 400m constant. Might be too low or too high.
    private let kNeighbors = 3
    private let categoriesToSkip : [Category] = [.commute]
    
    private let timeService : TimeService
    private let loggingService: LoggingService
    private let settingsService: SettingsService
    private let timeSlotService : TimeSlotService
    
    //MARK: Initializers
    init(timeService: TimeService,
         loggingService: LoggingService,
         settingsService: SettingsService,
         timeSlotService : TimeSlotService)
    {
        self.timeService = timeService
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
    }
    
    //MARK: Public Methods
    func get(forLocation location: Location) -> TimeSlot?
    {
        let bestMatches = timeSlotService.getTimeSlots(betweenDate: timeService.now.add(days: -15), andDate: timeService.now)
            .filter(isNotcommuteSlot)
            .filter(hasLocation)
            .filter(isWithinDistanceThreshold(from: location))
        
        guard bestMatches.count > 0 else { return nil }
        
        let knnInstances = bestMatches.map { (location: $0.location!, timeStamp: $0.location!.timestamp, category: $0.category, timeSlot: Optional($0)) }
        
        let startTimeForKNN = Date()
        
        let bestKnnMatch = KNN<KNNInstance, Category>
            .prediction(
                for: (location: location, timeStamp: location.timestamp, category: Category.unknown, timeSlot: nil),
                usingK: knnInstances.count >= kNeighbors ? kNeighbors : knnInstances.count,
                with: knnInstances,
                decisionType: .maxScoreSum,
                customDistance: distance,
                labelAction: { $0.category })
        
        loggingService.log(withLogLevel: .debug, message: "KNN executed in \(Date().timeIntervalSince(startTimeForKNN)) with k = \(knnInstances.count >= kNeighbors ? kNeighbors : knnInstances.count) on a dataset of \(knnInstances.count)")
        
        guard let bestMatch = bestKnnMatch?.timeSlot else { return nil }
        
        loggingService.log(withLogLevel: .debug, message: "TimeSlot found for location: \(location.latitude),\(location.longitude) -> \(bestMatch.category)")
        return bestMatch
    }
    
    //MARK: Private Methods
    
    private func isWithinDistanceThreshold(from location: Location) -> (TimeSlot) -> Bool
    {
        return { timeSlot in
            guard let location = timeSlot.location else { return false }
            return location.distance(from: location) <= self.distanceThreshold
        }
    }
    
    private func distance(instance1: KNNInstance, instance2: KNNInstance) -> Double
    {
        var accumulator = 0.0

        let locationDifference = instance1.location.distance(from: instance2.location) / distanceThreshold
        accumulator += pow(locationDifference, 2)
        
        return sqrt(accumulator)
    }
    
    private func isNotcommuteSlot(_ timeSlot: TimeSlot) -> Bool
    {
        return timeSlot.category != .commute
    }
    
    private func hasLocation(_ timeSlot: TimeSlot) -> Bool
    {
        return timeSlot.location != nil
    }
}
