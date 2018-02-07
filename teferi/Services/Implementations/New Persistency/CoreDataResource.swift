import Foundation
import CoreData

struct CoreDataResource<A>
{
    let request: NSFetchRequest<NSFetchRequestResult>
    let parser: ([NSManagedObject]) throws -> A
}

extension CoreDataResource
{
    static func many<B: PersistencyModel>(predicate: Predicate? = nil, sortDescriptor: NSSortDescriptor? = nil) -> CoreDataResource<[B]>
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: B.entityName)
        if let predicate = predicate {
            request.predicate = NSPredicate(format: predicate.format, argumentArray: predicate.parameters)
        }
        if let sortDescriptor = sortDescriptor {
            request.sortDescriptors = [sortDescriptor]
        }
        
        return CoreDataResource<[B]>(request: request) {
            managedObjects in
            return try managedObjects.map(B.init)
        }
    }
    
    static func single<B: PersistencyModel>(predicate: Predicate? = nil, sortDescriptor: NSSortDescriptor? = nil) -> CoreDataResource<B>
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: B.entityName)
        if let predicate = predicate {
            request.predicate = NSPredicate(format: predicate.format, argumentArray: predicate.parameters)
        }
        if let sortDescriptor = sortDescriptor {
            request.sortDescriptors = [sortDescriptor]
        }
        
        return CoreDataResource<B>(request: request) {
            managedObjects in
            guard let first = managedObjects.first else {
                throw PersistencyError.couldntParse
            }
            return try B.init(managedObject: first)
        }
    }
}
