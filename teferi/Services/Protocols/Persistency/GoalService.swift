import Foundation
import RxSwift

protocol GoalService
{
    var goalCreatedObservable : Observable<Goal> { get }
    var goalUpdatedObservable : Observable<Goal> { get }
    
    @discardableResult func addGoal(forDate date: Date, category: Category, targetTime: Seconds) -> Goal?
    
    func getGoals(sinceDaysAgo days: Int) -> [Goal]

    func update(goal: Goal, withCategory category: Category?, withTargetTime targetTime: Seconds?)
}
