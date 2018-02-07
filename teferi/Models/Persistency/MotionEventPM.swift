import Foundation
import CoreData

struct MotionEventPM
{
    let startTime: Date
    let motionType: MotionEventType
}

extension MotionEventPM: PersistencyModel
{
    static var entityName: String = "MotionEvent"
    
    init(managedObject: NSManagedObject) throws
    {
        guard let startTime = managedObject.value(forKey: "startTime") as? Date,
            let motionTypeString = managedObject.value(forKey: "motionType") as? String,
            let motionType = MotionEventType(rawValue: motionTypeString) else {
                throw PersistencyError.couldntParse
        }
        
        self.startTime = startTime
        self.motionType = motionType
    }
    
    func encode() -> NSManagedObject
    {
        fatalError("Not implemented")
    }
}


extension MotionEventPM
{
    static func all(fromDate startDate: Date, toDate endDate: Date) -> CoreDataResource<[MotionEventPM]>
    {
        let predicate = Predicate(parameter: "startTime", rangesFromDate: startDate as NSDate, toDate: endDate as NSDate)
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: true)
        return CoreDataResource<[MotionEventPM]>.many(predicate: predicate, sortDescriptor: sortDescriptor)
    }
}

