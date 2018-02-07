import XCTest
@testable import teferi
import CoreData
import RxSwift

class MockCoreDataPersistency: CoreDataPersistency
{
    var fetchCalled: Bool = false
    var valueToReturn: AnyObject? = nil
    var requestFetched: NSFetchRequest<NSFetchRequestResult>? = nil
    
    init()
    {
        super.init(managedObjectContext: NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType))
    }
    
    override func fetch<A>(_ resource: CoreDataResource<A>) -> Observable<A>
    {
        fetchCalled = true
        
        requestFetched = resource.request
        
        if let valueToReturn = valueToReturn {
            return Observable.just(valueToReturn as! A)
        } else {
            return Observable.empty()
        }
    }
}
