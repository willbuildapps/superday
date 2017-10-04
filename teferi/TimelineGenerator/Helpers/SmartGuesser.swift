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
        
        return timeSlot.with(smartGuess: smartGuess)
    }
}

extension TemporaryTimeSlot
{
    func with(smartGuess: SmartGuess) -> TemporaryTimeSlot
    {
        return TemporaryTimeSlot(
            start: start,
            end: end,
            category: smartGuess.category,
            location: location,
            activity: activity,
            smartGuess: smartGuess
        )
    }
}

