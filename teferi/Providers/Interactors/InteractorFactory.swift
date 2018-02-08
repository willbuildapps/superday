import Foundation

protocol Interactor
{
    associatedtype ReturnType
    func execute() -> ReturnType
}

class InteractorFactory
{
    var coreDataPersistency: CoreDataPersistency!
    var timeService: TimeService!
    var timeSlotService: TimeSlotService!
    var appLifecycleService: AppLifecycleService!
    
    static var shared: InteractorFactory = InteractorFactory()
    
    private init() {}
    
    func setup(coreDataPersistency: CoreDataPersistency, timeService: TimeService, timeSlotService: TimeSlotService, appLifecycleService: AppLifecycleService)
    {
        self.coreDataPersistency = coreDataPersistency
        self.timeService = timeService
        self.timeSlotService = timeSlotService
        self.appLifecycleService = appLifecycleService
    }
    
    // INTERACTOR CREATORS
    
    func createGetTimeSlotsForDateInteractor(date: Date) -> GetTimeSlotsForDate
    {
        return GetTimeSlotsForDate(persistency: coreDataPersistency, timeService: timeService, timeSlotService: timeSlotService, appLifecycleService: appLifecycleService, date: date)
    }
}
