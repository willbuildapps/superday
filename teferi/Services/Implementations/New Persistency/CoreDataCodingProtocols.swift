import Foundation
import CoreData

protocol CoreDataDecodable
{
    init(managedObject: NSManagedObject) throws
}
