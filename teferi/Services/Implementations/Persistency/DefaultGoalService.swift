import Foundation
import RxSwift

class DefaultGoalService : GoalService
{
    // MARK: Public Properties
    let goalCreatedObservable : Observable<Goal>
    let goalsUpdatedObservable : Observable<[Goal]>
    
    // MARK: Private Properties
    private let timeService : TimeService
    private let timeSlotService : TimeSlotService
    private let loggingService : LoggingService
    private let persistencyService : BasePersistencyService<Goal>
    
    private let goalCreatedSubject = PublishSubject<Goal>()
    private let goalsUpdatedSubject = PublishSubject<[Goal]>()
    
    init(timeService : TimeService,
         timeSlotService : TimeSlotService,
         loggingService: LoggingService,
         persistencyService: BasePersistencyService<Goal>)
    {
        self.timeService = timeService
        self.timeSlotService = timeSlotService
        self.loggingService = loggingService
        self.persistencyService = persistencyService
        
        goalCreatedObservable = goalCreatedSubject.asObservable()
        goalsUpdatedObservable = goalsUpdatedSubject.asObservable()
    }
    
    func addGoal(forDate date: Date, category: Category, value: Seconds) -> Goal?
    {
        let goal = Goal(date: date, category: category, value: value)
        return tryAdd(goal: goal)
    }
    
    func getGoals(sinceDaysAgo days: Int) -> [Goal]
    {
        let today = timeService.now.ignoreTimeComponents()
        
        let startTime = today.add(days: -days).ignoreTimeComponents() as NSDate
        let endTime = today.tomorrow.ignoreTimeComponents() as NSDate
        let predicate = Predicate(parameter: "date", rangesFromDate: startTime, toDate: endTime)
        
        let goals = persistencyService.get(withPredicate: predicate)
        
        return goals.map(withCompletedTimes)
    }
    
    func update(goals: [Goal], withCategory category: Category?, withValue value: Seconds?)
    {
        let predicate = Predicate(parameter: "date", in: goals.map({ $0.date }) as [AnyObject])
        let editFunction = { (goal: Goal) -> (Goal) in
            return goal.with(category: category, value: value)
        }
        
        if let updatedGoals = persistencyService.batchUpdate(withPredicate: predicate, updateFunction: editFunction)
        {
            goalsUpdatedSubject.on(.next(updatedGoals))
        }
        else
        {
            goals.forEach({ (goal) in
                loggingService.log(withLogLevel: .warning, message: "Error updating category or value of Goal created on \(goal.date). Category from \(goal.category) to \(category) or value from \(goal.value) to \(value)")
            })
        }
    }
    
    // MARK: Private Methods
    private func withCompletedTimes(_ goal: Goal) -> Goal
    {
        let slotsFromSameCateoryAndDay = timeSlotService.getTimeSlots(forDay: goal.date, category: goal.category)
        
        return goal.with(completed: slotsFromSameCateoryAndDay
            .map({ timeSlotService.calculateDuration(ofTimeSlot: $0) })
            .reduce(0, +))
    }
    
    private func tryAdd(goal: Goal) -> Goal?
    {
        guard persistencyService.create(goal) else
        {
            loggingService.log(withLogLevel: .warning, message: "Failed to create new Goal")
            return nil
        }
        
        loggingService.log(withLogLevel: .info, message: "New Goal with category \"\(goal.category)\" value \"\(goal.value)\" created")
        
        goalCreatedSubject.on(.next(goal))
        
        return goal
    }
}
