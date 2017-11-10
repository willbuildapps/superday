import Foundation

struct Goal
{
    let date: Date
    let category: Category
    let targetTime: Seconds
    let timeSoFar: Seconds // This is not stored to core data but calculated at runtime
    
    var percentageCompleted: Float
    {
        guard targetTime > 0, timeSoFar > 0 else { return 0.0 }
        return Float(timeSoFar / targetTime)
    }
    
    init(date: Date, category: Category, targetTime: Seconds, timeSoFar: Seconds = 0)
    {
        self.date = date
        self.category = category
        self.targetTime = targetTime
        self.timeSoFar = timeSoFar
    }
}

extension Goal
{
    func with(category: Category? = nil, targetTime: Seconds? = nil, timeSoFar: Seconds? = nil) -> Goal
    {
        return Goal(date: self.date, category: category ?? self.category, targetTime: targetTime ?? self.targetTime, timeSoFar: timeSoFar ?? self.timeSoFar)
    }
}
