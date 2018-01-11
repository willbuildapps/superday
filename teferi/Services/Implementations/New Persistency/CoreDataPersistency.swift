import Foundation
import RxSwift
import CoreData

enum PersistencyError: Error
{
    case noResults
    case couldntParse
}

class CoreDataPersistency
{
    let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext)
    {
        self.managedObjectContext = managedObjectContext
    }
    
    func fetch<A>(_ resource: CoreDataResource<A>) -> Observable<A>
    {
        return Observable.create {
            [unowned self] observer in
            
            self.managedObjectContext.perform {
                do {
                    let result = try self.managedObjectContext.fetch(resource.request) as! [NSManagedObject]
                    let entities = try resource.parser(result)
                    observer.onNext(entities)
                    observer.onCompleted()
                } catch let error as PersistencyError {
                    observer.onError(error)
                } catch {
                    observer.onError(PersistencyError.noResults)
                }
            }
            
            return Disposables.create{ }
        }
    }
}
