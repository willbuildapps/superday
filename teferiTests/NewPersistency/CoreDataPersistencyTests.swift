import XCTest
@testable import teferi
import Nimble
import RxSwift
import RxTest
import CoreData

class CoreDataPersistencyTests: XCTestCase
{
    private var coreDataPersistency: CoreDataPersistency!
    private var managedObjectContext: MockManagedObjectContext!
    
    override func setUp()
    {
        super.setUp()
    
        managedObjectContext = MockManagedObjectContext()
        coreDataPersistency = CoreDataPersistency(managedObjectContext: managedObjectContext)
    }
    
    func testFetchingCallsPerformOnManagedObjectContext()
    {
        expect(self.managedObjectContext.performCalled).to(beFalse())
        
        let mockResource = CoreDataResource<Void>(
            request: NSFetchRequest(entityName: "Mock"),
            parser: { _ in return }
        )
        
        _ = coreDataPersistency.fetch(mockResource)
            .subscribe()
        
        expect(self.managedObjectContext.performCalled).to(beTrue())
    }
    

    func testFetchingCallsFetchOnManagedObjectContext()
    {
        expect(self.managedObjectContext.fetchCalled).to(beFalse())
        
        let mockResource = CoreDataResource<Void>(
            request: NSFetchRequest(entityName: "Mock"),
            parser: { _ in return }
        )
        
        _ = coreDataPersistency.fetch(mockResource)
            .subscribe()
        
        expect(self.managedObjectContext.fetchCalled).toEventually(beTrue())
    }
    
    func testFetchingCallsTheResourceParser()
    {
        var parserCalled = false
        
        let mockResource = CoreDataResource<Void>(
            request: NSFetchRequest(entityName: "Mock"),
            parser: { _ in
                parserCalled = true
                return
        }
        )
        
        _ = coreDataPersistency.fetch(mockResource)
            .subscribe()
        
        expect(parserCalled).toEventually(beTrue())
    }
}
