import CoreData

extension Predicate
{
    func convertToNSPredicate() -> NSPredicate
    {
        let predicate = NSPredicate(format: format, argumentArray: parameters)
        return predicate
    }
}

extension Array where Element == Predicate
{
    func convertToANDNSPredicate() -> NSCompoundPredicate
    {
        return NSCompoundPredicate(andPredicateWithSubpredicates: self.map({ $0.convertToNSPredicate() }))
    }
}
