import Foundation
@testable import teferi

struct TempTimelineTestData
{
    let startOffset : TimeInterval
    let endOffset : TimeInterval?
    let category : teferi.Category
    let includeLocation : Bool
}

extension TempTimelineTestData
{
    init(startOffset: TimeInterval, endOffset: TimeInterval?)
    {
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.category = .unknown
        self.includeLocation = false
    }
    
    init(startOffset: TimeInterval, endOffset: TimeInterval?, isCommute: Bool)
    {
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.category = isCommute ? .commute : .unknown
        self.includeLocation = false
    }
    
    init(startOffset: TimeInterval,
         endOffset: TimeInterval?,
         _ category: teferi.Category,
         includeSmartGuess: Bool = false,
         includeLocation: Bool = false)
    {
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.category = category
        self.includeLocation = includeLocation
    }
}
