import Foundation

struct TimeSlot
{
    // MARK: Properties
    let startTime: Date
    let endTime: Date?
    let category: Category
    let location: Location?
    let categoryWasSetByUser: Bool
    let categoryWasSmartGuessed: Bool
    let activity: MotionEventType?
}

extension TimeSlot
{
    init(startTime: Date, endTime: Date? = nil, category: Category, categoryWasSetByUser: Bool = false, categoryWasSmartGuessed: Bool = false, location: Location? = nil)
    {
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.location = location
        self.categoryWasSetByUser = categoryWasSetByUser
        self.categoryWasSmartGuessed = categoryWasSmartGuessed
        self.activity = nil
    }
}

extension TimeSlot
{
    func withCategory(_ category: Category, setByUser: Bool? = nil) -> TimeSlot
    {
        return TimeSlot(startTime: self.startTime,
                        endTime: self.endTime,
                        category: category,
                        location: self.location,
                        categoryWasSetByUser: setByUser ?? self.categoryWasSetByUser,
                        categoryWasSmartGuessed: false,
                        activity: self.activity)
    }
    
    func withEndDate( _ endDate: Date) -> TimeSlot
    {
        return TimeSlot(
            startTime: self.startTime,
            endTime: endDate,
            category: self.category,
            location: self.location,
            categoryWasSetByUser: self.categoryWasSetByUser,
            categoryWasSmartGuessed: false,
            activity: self.activity)
    }
    
    func withStartTime(_ startTime: Date, endTime: Date? = nil) -> TimeSlot
    {
        return TimeSlot(
            startTime: startTime,
            endTime: endTime ?? self.endTime,
            category: self.category,
            location: self.location,
            categoryWasSetByUser: self.categoryWasSetByUser,
            categoryWasSmartGuessed: self.categoryWasSmartGuessed,
            activity: self.activity)
    }
}

extension TimeSlot
{
    var duration: Double?
    {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    func belongs(toDate date: Date) -> Bool
    {
        return startTime.ignoreTimeComponents() == date
    }
}
