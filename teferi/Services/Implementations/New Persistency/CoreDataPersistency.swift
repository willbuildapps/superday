import Foundation
import RxSwift
import CoreData

enum PersistencyError: Error
{
    case noResults
    case couldntParse
    case couldntCreate
}

class CoreDataPersistency
{
    private let managedObjectContext: NSManagedObjectContext
    
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
    
    func create<A: PersistencyModel>(_ model: A) -> Observable<A>
    {
        return Observable.create { [unowned self] observer in
            
            self.managedObjectContext.perform {
                
                let _ = model.encode(using: self.managedObjectContext)
                
                do {
                    try self.managedObjectContext.save()
                    
                    observer.onNext(model)
                    observer.onCompleted()
                } catch {
                    observer.onError(PersistencyError.couldntCreate)
                }
            }
            
            return Disposables.create{ }
        }
    }
}
