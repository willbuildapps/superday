import Foundation
import CoreData

struct TimeSlotPM
{
    let startTime: Date
    let category: Category
    let editedByUser: Bool
}

extension TimeSlotPM: PersistencyModel
{
    static var entityName: String = "TimeSlot"
    
    init(managedObject: NSManagedObject) throws
    {
        guard let startTime = managedObject.value(forKey: "startTime") as? Date,
            let categoryString = managedObject.value(forKey: "category") as? String,
            let category = Category(rawValue: categoryString) else {
                throw PersistencyError.couldntParse
        }
        
        self.startTime = startTime
        self.category = category
        self.editedByUser = (managedObject.value(forKey: "categoryWasSetByUser") as? Bool) ?? false
    }
    
    func encode(using moc: NSManagedObjectContext) -> NSManagedObject
    {
        guard let entity = NSEntityDescription.entity(forEntityName: type(of: self).entityName, in: moc) else { fatalError("Can't create entity") }
        
        let managedObject = NSManagedObject(entity: entity, insertInto: moc)
        managedObject.setValue(startTime, forKey: "startTime")
        managedObject.setValue(category.rawValue, forKey: "category")
        managedObject.setValue(editedByUser, forKey: "categoryWasSetByUser")
        
        return managedObject
    }
}

extension TimeSlotPM
{
    static func all(fromDate startDate: Date, toDate endDate: Date) -> CoreDataResource<[TimeSlotPM]>
    {
        let predicate = Predicate(parameter: "startTime", rangesFromDate: startDate as NSDate, toDate: endDate as NSDate)
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: true)
        return CoreDataResource<[TimeSlotPM]>.many(predicate: predicate, sortDescriptor: sortDescriptor)
    }
    
    static func all(forDate date: Date) -> CoreDataResource<[TimeSlotPM]>
    {
        let startDate = date.ignoreTimeComponents()
        let endDate = date.tomorrow.ignoreTimeComponents().addingTimeInterval(-1)
        return all(fromDate: startDate, toDate: endDate)
    }
}
