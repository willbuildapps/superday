import Foundation

struct Goal
{
    let date: Date
    let category: Category
    let value: Seconds
    let completed: Seconds // This is not stored to core data but calculated at runtime
    
    init(date: Date, category: Category, value: Seconds, completed: Seconds = 0)
    {
        self.date = date
        self.category = category
        self.value = value
        self.completed = completed
    }
}

extension Goal
{
    func with(category: Category? = nil, value: Seconds? = nil, completed: Seconds? = nil) -> Goal
    {
        return Goal(date: self.date, category: category ?? self.category, value: value ?? self.value, completed: completed ?? self.completed)
    }
}
