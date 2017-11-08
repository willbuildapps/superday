import Foundation
import RxSwift

protocol GoalService
{
    var goalCreatedObservable : Observable<Goal> { get }
    var goalsUpdatedObservable : Observable<[Goal]> { get }
    
    @discardableResult func addGoal(forDate date: Date, category: Category, value: Seconds) -> Goal?
    
    func getGoals(sinceDaysAgo days: Int) -> [Goal]

    func update(goals: [Goal], withCategory category: Category?, withValue value: Seconds?)
}
