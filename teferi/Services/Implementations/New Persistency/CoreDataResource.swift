import Foundation
import CoreData

struct CoreDataResource<A>
{
    let request: NSFetchRequest<NSFetchRequestResult>
    let parser: ([NSManagedObject]) throws -> A
}

extension CoreDataResource
{
    static func many<B: PersistencyModel>(predicate: Predicate, sortDescriptor: NSSortDescriptor? = nil) -> CoreDataResource<[B]>
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: B.entityName)
        request.predicate = NSPredicate(format: predicate.format, argumentArray: predicate.parameters)
        if let sortDescriptor = sortDescriptor {
            request.sortDescriptors = [sortDescriptor]
        }
        
        return CoreDataResource<[B]>(request: request) {
            managedObjects in
            return try managedObjects.map(B.init)
        }
    }
}
