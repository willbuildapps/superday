import Foundation
import CoreData

protocol CoreDataDecodable
{
    init(managedObject: NSManagedObject) throws
}

protocol CoreDataEncodable
{
    func encode(using moc: NSManagedObjectContext) -> NSManagedObject
}

protocol PersistencyModel: CoreDataDecodable, CoreDataEncodable
{
    static var entityName: String { get }
}
