import Foundation
import CoreData

class TimeSlotModelAdapter : CoreDataModelAdapter<TimeSlot>
{
    //MARK: Private Properties
    private let endTimeKey = "endTime"
    private let categoryKey = "category"
    private let startTimeKey = "startTime"
    private let locationTimeKey = "locationTime"
    private let locationLatitudeKey = "locationLatitude"
    private let locationLongitudeKey = "locationLongitude"
    private let categoryWasSetByUserKey = "categoryWasSetByUser"
    private let activityKey = "activity"
    
    //MARK: Initializers
    override init()
    {
        super.init()
        
        sortDescriptors = [ NSSortDescriptor(key: startTimeKey, ascending: false) ]
    }
    
    //MARK: Public Methods
    override func getModel(fromManagedObject managedObject: NSManagedObject) -> TimeSlot
    {
        let startTime = managedObject.value(forKey: startTimeKey) as! Date
        let endTime = managedObject.value(forKey: endTimeKey) as? Date
        let category = Category(rawValue: managedObject.value(forKey: categoryKey) as! String)!
        let categoryWasSetByUser = managedObject.value(forKey: categoryWasSetByUserKey) as? Bool ?? false
        
        var activity: MotionEventType? = nil
        if let activityString = managedObject.value(forKey: activityKey) as? String {
            activity = MotionEventType(rawValue: activityString)
        }
        
        let location = super.getLocation(managedObject,
                                         timeKey: locationTimeKey,
                                         latKey: locationLatitudeKey,
                                         lngKey: locationLongitudeKey)
        
        let timeSlot = TimeSlot(startTime: startTime,
                                endTime: endTime,
                                category: category,
                                smartGuessId: nil,
                                location: location,
                                categoryWasSetByUser: categoryWasSetByUser,
                                activity: activity)
        
        return timeSlot
    }
    
    override func setManagedElementProperties(fromModel model: TimeSlot, managedObject: NSManagedObject)
    {
        managedObject.setValue(model.endTime, forKey: endTimeKey)
        managedObject.setValue(model.startTime, forKey: startTimeKey)
        managedObject.setValue(model.category.rawValue, forKey: categoryKey)
        managedObject.setValue(model.categoryWasSetByUser, forKey: categoryWasSetByUserKey)
        
        managedObject.setValue(model.location?.timestamp, forKey: locationTimeKey)
        managedObject.setValue(model.location?.latitude, forKey: locationLatitudeKey)
        managedObject.setValue(model.location?.longitude, forKey: locationLongitudeKey)
        
        managedObject.setValue(model.activity?.rawValue, forKey: activityKey)
    }
}
