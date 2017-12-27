import Foundation
import CoreData

extension TimeSlotEntity: CoreDataDecodable
{
    init(managedObject: NSManagedObject) throws
    {
        guard let startTime = managedObject.value(forKey: "startTime") as? Date,
            let categoryString = managedObject.value(forKey: "category") as? String,
            let category = Category(rawValue: categoryString) else {
                throw PersistencyError.couldntParse
        }
        
        self.startTime = startTime
        self.category = category
        self.categoryWasSetByUser = (managedObject.value(forKey: "categoryWasSetByUser") as? Bool) ?? false
    }
}

extension TimeSlotEntity
{
    static func all(fromDate startDate: Date, toDate endDate: Date) -> CoreDataResource<[TimeSlotEntity]>
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TimeSlot")
        let predicate = Predicate(parameter: "startTime", rangesFromDate: startDate as NSDate, toDate: endDate as NSDate)
        request.predicate = NSPredicate(format: predicate.format, argumentArray: predicate.parameters)
        
        return CoreDataResource<[TimeSlotEntity]>(request: request) {
            managedObjects in
            return try managedObjects.map(TimeSlotEntity.init)
        }
    }
}
