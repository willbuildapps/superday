import Foundation

struct GoalTime: Equatable
{
    typealias Seconds = TimeInterval
    
    let goalTime: Seconds
    let durationString: String
    let unitString: String
    
    init(goalTime: Seconds)
    {
        self.goalTime = goalTime
        
        let timeTextArray = formatedElapsedTimeLongText(for: self.goalTime).components(separatedBy: " ")
        durationString = timeTextArray[0]
        unitString = timeTextArray[1]
    }
    
    static func == (lhs:GoalTime, rhs:GoalTime) -> Bool
    {
        return lhs.goalTime == rhs.goalTime
    }
}
