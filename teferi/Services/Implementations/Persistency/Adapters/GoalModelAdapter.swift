import Foundation
import CoreData

class GoalModelAdapter : CoreDataModelAdapter<Goal>
{
    //MARK: Private Properties
    private let dateKey = "date"
    private let categoryKey = "category"
    private let valueKey = "value"
    
    //MARK: Initializers
    override init()
    {
        super.init()
        
        sortDescriptorsForList = [ NSSortDescriptor(key: dateKey, ascending: false) ]
        sortDescriptorsForLast = sortDescriptorsForList
    }
    
    //MARK: Public Methods
    override func getModel(fromManagedObject managedObject: NSManagedObject) -> Goal
    {
        let date = managedObject.value(forKey: dateKey) as! Date
        let category = Category(rawValue: managedObject.value(forKey: categoryKey) as! String)!
        let value = managedObject.value(forKey: valueKey) as! Seconds
        
        let goal = Goal(date: date, category: category, value: value)
        
        return goal
    }
    
    override func setManagedElementProperties(fromModel model: Goal, managedObject: NSManagedObject)
    {
        managedObject.setValue(model.value, forKey: valueKey)
        managedObject.setValue(model.date, forKey: dateKey)
        managedObject.setValue(model.category.rawValue, forKey: categoryKey)
    }
}
