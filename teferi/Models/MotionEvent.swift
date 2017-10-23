import Foundation

enum MotionEventType: String
{
    case walk
    case run
    case cycling
    case auto
    case other
    case still
    
    var name : String
    {
        guard self != .auto else { return L10n.transport }
        return self.rawValue.capitalized
    }
}

struct MotionEvent: Equatable
{
    let start: Date
    let end: Date
    let type: MotionEventType
    
    var duration: TimeInterval
    {
        return end.timeIntervalSince(start)
    }
    
    func with(end: Date? = nil, start: Date? = nil, type: MotionEventType? = nil) -> MotionEvent
    {
        return MotionEvent(start: start ?? self.start,
                           end: end ?? self.end,
                           type: type ?? self.type)
    }
}

func == (lhs: MotionEvent, rhs: MotionEvent) -> Bool
{
    return lhs.start == rhs.start && lhs.end == rhs.end && lhs.type == rhs.type
}

extension MotionEvent: CustomStringConvertible
{
    var description: String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let timeInterval = end.timeIntervalSince(start)
        let minutes = floor(timeInterval / 60)
        let seconds = timeInterval - minutes * 60
        
        return "\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end)) : \(type) \(Int(minutes))m \(Int(seconds))s"
    }
}

