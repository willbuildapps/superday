import Foundation
import RxSwift
@testable import teferi

class MockGoalService : GoalService
{
    private let timeService : TimeService
    private let goalCreatedSubject = PublishSubject<Goal>()
    private let goalUpdatedSubject = PublishSubject<Goal>()
    
    var goalCreatedObservable: Observable<Goal>
    var goalUpdatedObservable: Observable<Goal>
    
    var goals = [Goal]()
    
    init(timeService: TimeService)
    {
        self.timeService = timeService
        
        goalCreatedObservable = goalCreatedSubject.asObservable()
        goalUpdatedObservable = goalUpdatedSubject.asObservable()
    }
    
    func addGoal(forDate date: Date, category: teferi.Category, targetTime: Seconds) -> Goal?
    {
        goals.append(Goal(date: date, category: category, targetTime: targetTime))
        return goals.last
    }
    
    func getGoals(sinceDaysAgo days: Int) -> [Goal]
    {
        return goals.filter({ (goal) -> Bool in
            return timeService.now.differenceInDays(toDate: goal.date) <= days
        })
    }
    
    func update(goal: Goal, withCategory category: teferi.Category?, withTargetTime targetTime: Seconds?)
    {
        self.goals = self.goals.map({ existingGoal in
            if existingGoal == goal {
                return goal.with(category: category, targetTime: targetTime)
            }
            return existingGoal
        })
    }
}
