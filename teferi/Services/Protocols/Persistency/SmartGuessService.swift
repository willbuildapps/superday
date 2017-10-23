import Foundation

protocol SmartGuessService
{
    func get(forLocation: Location) -> TimeSlot?
}
