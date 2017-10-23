import Foundation
import RxSwift

class SmartGuesser
{
    private let smartGuessService : SmartGuessService
    
    init(smartGuessService: SmartGuessService)
    {
        self.smartGuessService = smartGuessService
    }
    
    func run(timeline: [TemporaryTimeSlot]) -> [TemporaryTimeSlot]
    {
        return timeline
            .map(guessCategory)
    }
    
    private func guessCategory(timeSlot: TemporaryTimeSlot) -> TemporaryTimeSlot
    {
        guard timeSlot.category == .unknown, let smartGuess = smartGuessService.get(forLocation: timeSlot.location) else {
            return timeSlot
        }
        
        return timeSlot.with(newCategory: smartGuess.category)
    }
}

extension TemporaryTimeSlot
{
    func with(newCategory: Category) -> TemporaryTimeSlot
    {
        return TemporaryTimeSlot(
            start: start,
            end: end,
            category: newCategory,
            location: location,
            activity: activity
        )
    }
}

