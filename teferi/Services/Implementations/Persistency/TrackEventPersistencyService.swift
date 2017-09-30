import Darwin

class TrackEventPersistencyService : BasePersistencyService<TrackEvent>
{
    private let loggingService : LoggingService
    private let locationPersistencyService : BasePersistencyService<Location>
    
    init(loggingService: LoggingService,
         locationPersistencyService: BasePersistencyService<Location>)
    {
        self.loggingService = loggingService
        self.locationPersistencyService = locationPersistencyService
    }
    
    override func get(withPredicate predicate: Predicate?) -> [TrackEvent]
    {   
        guard let typeName = predicate?.parameters.first as? String else { return [] }
        
        switch typeName
        {
            case String(describing: Location.self):
                return locationPersistencyService.get().map(Location.asTrackEvent)
            default:
                return []
        }
    }
    
    override func create(_ element: TrackEvent) -> Bool
    {
        switch element
        {
            case .newLocation(let location):
                return locationPersistencyService.create(location)
        }
    }
    
    override func delete(withPredicate predicate: Predicate?) -> Bool
    {
        let deleted = locationPersistencyService.delete(withPredicate: predicate)
        return deleted
    }
}
