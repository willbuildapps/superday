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
    
    func addGoal(forDate date: Date, category: Category, targetTime: Seconds) -> Goal?
    {
        let goal = Goal(date: date, category: category, targetTime: targetTime)
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
    
    func update(goals: [Goal], withCategory category: Category?, withTargetTime targetTime: Seconds?)
    {
        let predicate = Predicate(parameter: "date", in: goals.map({ $0.date }) as [AnyObject])
        let editFunction = { (goal: Goal) -> (Goal) in
            return goal.with(category: category, targetTime: targetTime)
        }
        
        if let updatedGoals = persistencyService.batchUpdate(withPredicate: predicate, updateFunction: editFunction)
        {
            goalsUpdatedSubject.on(.next(updatedGoals))
        }
        else
        {
            goals.forEach({ (goal) in
                if let category = category, let targetTime = targetTime
                {
                    loggingService.log(withLogLevel: .warning, message: "Error updating category or value of Goal created on \(goal.date). Category from \(goal.category) to \(category) or targetTime from \(goal.targetTime) to \(targetTime)")
                }
                else if let category = category
                {
                    loggingService.log(withLogLevel: .warning, message: "Error updating category of Goal created on \(goal.date). Category from \(goal.category) to \(category)")
                }
                else if let targetTime = targetTime
                {
                    loggingService.log(withLogLevel: .warning, message: "Error updating value of Goal created on \(goal.date). Value from from \(goal.targetTime) to \(targetTime)")
                }
            })
        }
    }
    
    // MARK: Private Methods
    private func withCompletedTimes(_ goal: Goal) -> Goal
    {
        let slotsFromSameCateoryAndDay = timeSlotService.getTimeSlots(forDay: goal.date, category: goal.category)
        
        let sumOfDurations = slotsFromSameCateoryAndDay
            .map({ timeSlotService.calculateDuration(ofTimeSlot: $0) })
            .reduce(0, +)
        
        return goal.with(timeSoFar: sumOfDurations)
    }
    
    private func tryAdd(goal: Goal) -> Goal?
    {
        guard persistencyService.create(goal) else
        {
            loggingService.log(withLogLevel: .warning, message: "Failed to create new Goal")
            return nil
        }
        
        loggingService.log(withLogLevel: .info, message: "New Goal with category \"\(goal.category)\" value \"\(goal.targetTime)\" created")
        
        goalCreatedSubject.on(.next(goal))
        
        return goal
    }
}
