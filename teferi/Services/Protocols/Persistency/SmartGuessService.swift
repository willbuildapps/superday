import Foundation

protocol SmartGuessService
{
    func get(forLocation: Location) -> SmartGuess?
    
    @discardableResult func add(withCategory category: Category, location: Location) -> SmartGuess?
    
    func markAsUsed(_ smartGuess: SmartGuess, atTime time: Date)
    
    func strike(withId id: Int)
    
    func purgeEntries(olderThan maxAge: Date)
}
