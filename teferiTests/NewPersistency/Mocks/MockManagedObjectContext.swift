import Foundation
import CoreData

class MockManagedObjectContext: NSManagedObjectContext
{
    var performCalled: Bool = false
    var fetchCalled: Bool = false
    
    init()
    {
        super.init(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func perform(_ block: @escaping () -> Void)
    {
        performCalled = true
        //FIX Enable for Swift 4 super.perform(block)
    }
    
    // FIX: Enable for Swift 4
    /*
    override func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult
    {
        fetchCalled = true
        return []
    }
    
    override func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any]
    {
        fetchCalled = true
        return []
    }
    */
}
