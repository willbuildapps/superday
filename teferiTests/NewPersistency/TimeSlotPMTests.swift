import XCTest
@testable import teferi
import Nimble
import RxSwift
import RxTest

class TimeSlotPMTests: XCTestCase
{
    private var mockPersistency: MockCoreDataPersistency!
    
    override func setUp()
    {
        super.setUp()
        
        mockPersistency = MockCoreDataPersistency()
    }
    
    func testAllSetsTheCorrectRequest()
    {
        let fromDate = Date.createTime(hour: 9, minute: 0)
        let toDate = Date.createTime(hour: 18, minute: 0)
        
        let resource = TimeSlotPM.all(fromDate: fromDate, toDate: toDate)
        
        _ = mockPersistency.fetch(resource)
            .subscribe()
        
        expect(self.mockPersistency.requestFetched?.entityName).to(equal(TimeSlotPM.entityName))
        
        let predicate = Predicate(parameter: "startTime", rangesFromDate: fromDate as NSDate, toDate: toDate as NSDate)
        let nspredicate = NSPredicate(format: predicate.format, argumentArray: predicate.parameters)
        expect(self.mockPersistency.requestFetched!.predicate!.debugDescription).to(equal(nspredicate.debugDescription))
        
        expect(self.mockPersistency.requestFetched!.sortDescriptors!.first!.ascending).to(beTrue())
        expect(self.mockPersistency.requestFetched!.sortDescriptors!.first!.key!).to(equal("startTime"))
    }
}
