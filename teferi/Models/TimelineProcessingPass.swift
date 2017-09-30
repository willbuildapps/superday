import Foundation

typealias Seconds = TimeInterval

enum TimelineProcessingPassType
{
    case merge(maximumDuration: Seconds)
    case filter(minimumDuration: Seconds)
}

struct TimelineProcessingPass: Equatable, CustomStringConvertible
{
    let passType: TimelineProcessingPassType
    let eventTypes: [MotionEventType]?
    
    var description: String {
        
        let eventTypesString = eventTypes == nil ? "all" : eventTypes!.map({ $0.rawValue }).joined(separator: ",")
        switch passType {
        case .merge(let maximumDuration):
            return "Merge [\(eventTypesString)] < \(Int(maximumDuration / 60))"
        case .filter(let minimumDuration):
            return "Filter [\(eventTypesString)] < \(Int(minimumDuration / 60))"
        }
    }
    
    static func mergePass(types: [MotionEventType]?, maxDuration: Seconds = 0) -> TimelineProcessingPass
    {
        return TimelineProcessingPass(passType: .merge(maximumDuration: maxDuration), eventTypes: types)
    }
    
    static func filterPass(types: [MotionEventType]?, minDuration: Seconds = 60*60*24) -> TimelineProcessingPass
    {
        return TimelineProcessingPass(passType: .filter(minimumDuration: minDuration), eventTypes: types)
    }
}

func == (lhs: TimelineProcessingPass, rhs: TimelineProcessingPass) -> Bool
{
    guard (lhs.eventTypes == nil && rhs.eventTypes == nil) || lhs.eventTypes! == rhs.eventTypes! else {
        return false
    }
    
    switch (lhs.passType, rhs.passType) {
    case (let .merge(lhsMax), let .merge(rhsMax)):
        return lhsMax == rhsMax
    case (let .filter(lhsMin), let .filter(rhsMin)):
        return lhsMin == rhsMin
    default:
        return false
    }
}

