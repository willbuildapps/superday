import Foundation
import RxSwift
@testable import teferi

class MockGoalService : GoalService
{
    private let timeService : TimeService
    private let goalCreatedSubject = PublishSubject<Goal>()
    private let goalssUpdatedSubject = PublishSubject<[Goal]>()
    
    var goalCreatedObservable: Observable<Goal>
    var goalsUpdatedObservable: Observable<[Goal]>
    
    var goals = [Goal]()
    
    init(timeService: TimeService)
    {
        self.timeService = timeService
        
        goalCreatedObservable = goalCreatedSubject.asObservable()
        goalsUpdatedObservable = goalssUpdatedSubject.asObservable()
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
    
    func update(goals: [Goal], withCategory category: teferi.Category?, withTargetTime targetTime: Seconds?)
    {
        self.goals = self.goals.map({ (goal) in
            var goalToReturn = goal
            goals.forEach({ (innerGoal) in
                if innerGoal == goalToReturn
                {
                    goalToReturn = goalToReturn.with(category: category, targetTime: targetTime)
                }
            })
            return goalToReturn
        })
    }
}
