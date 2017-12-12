import Foundation

enum CustomEvent
{
    case timeSlotManualCreation(date: Date, category: Category)
    case timeSlotEditing(date: Date, fromCategory: Category, toCategory: Category, duration: Double?)
    case timeSlotCreated(date: Date, category: Category, duration: Double?)
    case timeSlotSmartGuessed(date: Date, category: Category, duration: Double?)
    case timeSlotNotSmartGuessed(date: Date, category: Category, duration: Double?)
    case timelineVote(date: Date, voteDate: Date, vote: Bool)
    case timelineWeeklyReview(date: Date, rating: Int)
    case goalAchieved(goal: Goal)
    case goalFailed(goal: Goal)
    case goalCreation(date: Date, category: Category, duration: Double)
    case goalEditing(date: Date, fromCategory: Category, toCategory: Category, fromDuration: Double, toDuration: Double)
    
    var name : String
    {
        switch self {
        case .timeSlotManualCreation(_):
            return "Manual TimeSlot Creation"
        case .timeSlotEditing(_):
            return "TimeSlot Editing"
        case .timeSlotCreated(_):
            return "TimeSlot Created"
        case .timeSlotSmartGuessed(_):
            return "TimeSlot SmartGuessed"
        case .timeSlotNotSmartGuessed(_):
            return "TimeSlot Not SmartGuessed"
        case .timelineVote(_):
            return "Timeline Vote"
        case .timelineWeeklyReview(_):
            return "Timeline weekly review"
        case .goalAchieved(_):
            return "Goal_Achieved"
        case .goalFailed(_):
            return "Goal_Failed"
        case .goalCreation(_):
            return "Goal_Creation"
        case .goalEditing(_):
            return "Goal_Editing"
        }
    }
    
    var attributes : [String: Any]
    {
        var attributesToReturn : [String: Any] = ["regionCode": Locale.current.regionCode ?? ""]
        
        switch self {
        case .timeSlotManualCreation(let date, let category):

            attributesToReturn["localHour"] = date.hour
            attributesToReturn["localHourString"] = String(date.hour)
            attributesToReturn["dayOfWeek"] = date.dayOfWeek
            attributesToReturn["dayOfWeekString"] = String(date.dayOfWeek)
            attributesToReturn["category"] = category.rawValue
            
        case .timeSlotEditing(let date, let fromCategory, let toCategory, let duration):
            
            attributesToReturn["localHour"] = date.hour
            attributesToReturn["localHourString"] = String(date.hour)
            attributesToReturn["dayOfWeek"] = date.dayOfWeek
            attributesToReturn["dayOfWeekString"] = String(date.dayOfWeek)
            attributesToReturn["fromCategory"] = fromCategory.rawValue
            attributesToReturn["toCategory"] = toCategory.rawValue
            attributesToReturn["duration"] = duration ?? -1
            
        case .timeSlotCreated(let date, let category, let duration),
             .timeSlotSmartGuessed(let date, let category, let duration),
             .timeSlotNotSmartGuessed(let date, let category, let duration):
            
            attributesToReturn["localHour"] = date.hour
            attributesToReturn["localHourString"] = String(date.hour)
            attributesToReturn["dayOfWeek"] = date.dayOfWeek
            attributesToReturn["dayOfWeekString"] = String(date.dayOfWeek)
            attributesToReturn["category"] = category.rawValue
            attributesToReturn["duration"] = duration ?? -1
            
        case .timelineVote(let date, let voteDate, let vote):
            
            attributesToReturn["localHour"] = date.hour
            attributesToReturn["localHourString"] = String(date.hour)
            attributesToReturn["dayOfWeek"] = date.dayOfWeek
            attributesToReturn["dayOfWeekString"] = String(date.dayOfWeek)
            attributesToReturn["voteDate"] = "\(voteDate.month)-\(voteDate.day)"
            attributesToReturn["vote"] = vote ? 1 : -1
            attributesToReturn["voteString"] = vote ? "+" : "-"
            
        case .timelineWeeklyReview(let date, let rating):
            
            attributesToReturn["localHour"] = date.hour
            attributesToReturn["localHourString"] = String(date.hour)
            attributesToReturn["dayOfWeek"] = date.dayOfWeek
            attributesToReturn["dayOfWeekString"] = String(date.dayOfWeek)
            attributesToReturn["weekOfYearRated"] = date.weekOfYear
            attributesToReturn["weekOfYearRatedString"] = String(date.weekOfYear)
            attributesToReturn["rating"] = rating
            attributesToReturn["ratingString"] = String(rating)
            
        case .goalAchieved(let goal), .goalFailed(let goal):
            
            attributesToReturn["dayOfWeek"] = goal.date.dayOfWeek
            attributesToReturn["dayOfWeekString"] = String(goal.date.dayOfWeek)
            attributesToReturn["weekOfYearRated"] = goal.date.weekOfYear
            attributesToReturn["weekOfYearRatedString"] = String(goal.date.weekOfYear)
            attributesToReturn["category"] = goal.category.rawValue
            attributesToReturn["percentageCompleted"] = Int(goal.percentageCompleted * 100)
            attributesToReturn["targetDuration"] = goal.targetTime
            attributesToReturn["timeSoFar"] = goal.timeSoFar

        case .goalCreation(let date, let category, let duration):
            
            attributesToReturn["localHour"] = date.hour
            attributesToReturn["localHourString"] = String(date.hour)
            attributesToReturn["dayOfWeek"] = date.dayOfWeek
            attributesToReturn["dayOfWeekString"] = String(date.dayOfWeek)
            attributesToReturn["category"] = category.rawValue
            attributesToReturn["duration"] = duration
            
        case .goalEditing(let date, let fromCategory, let toCategory, let fromDuration, let toDuration):
            
            attributesToReturn["localHour"] = date.hour
            attributesToReturn["localHourString"] = String(date.hour)
            attributesToReturn["dayOfWeek"] = date.dayOfWeek
            attributesToReturn["dayOfWeekString"] = String(date.dayOfWeek)
            attributesToReturn["fromCategory"] = fromCategory.rawValue
            attributesToReturn["toCategory"] = toCategory.rawValue
            attributesToReturn["fromDuration"] = fromDuration
            attributesToReturn["toDuration"] = toDuration
            
        }
        
        return attributesToReturn
    }
}
