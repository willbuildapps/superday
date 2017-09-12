import Foundation
import CoreData

class CoreDataModelAdapter<T>
{
    func getModel(fromManagedObject managedObject: NSManagedObject) -> T
    {
        fatalError("Not implemented")
    }
    
    func setManagedElementProperties(fromModel model: T, managedObject: NSManagedObject)
    {
        fatalError("Not implemented")
    }
    
    var sortDescriptors : [NSSortDescriptor]!
    
    func getLocation(_ managedObject: NSManagedObject, timeKey: String, latKey: String, lngKey: String) -> Location?
    {
        var location : Location? = nil
        
        let possibleTime = managedObject.value(forKey: timeKey) as? Date
        let possibleLatitude = managedObject.value(forKey: latKey) as? Double
        let possibleLongitude = managedObject.value(forKey: lngKey) as? Double
        
        if let time = possibleTime, let latitude = possibleLatitude, let longitude = possibleLongitude
        {
            location = Location(timestamp: time,
                                latitude: latitude, longitude: longitude)
        }
        
        return location
    }
}
