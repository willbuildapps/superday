import Foundation
import CoreData

class MockManagedObjectContext: NSManagedObjectContext
{
    var performCalled: Bool = false
    var fetchCalled: Bool = false
    var arrayToReturn : [Any] = []
    
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
        super.perform(block)
    }
    
    override func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any]
    {
        fetchCalled = true
        return arrayToReturn
    }
}
