import Foundation
@testable import teferi

class MockSmartGuessService : SmartGuessService
{
    //MARK: Properties
    private var smartGuessId = 0
    
    var addShouldWork = true
    var smartGuessToReturn : TimeSlot? = nil
    var locationsAskedFor = [Location]()
    var guesses = [TimeSlot]()
    
    func get(forLocation location: Location) -> TimeSlot?
    {
        locationsAskedFor.append(location)
        return smartGuessToReturn
    }
}
