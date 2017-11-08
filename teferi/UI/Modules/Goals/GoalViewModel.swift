import Foundation
import RxSwift

class GoalViewModel
{
    //MARK: Public Properties
    var goalsObservable : Observable<[Goal]> { return self.goals.asObservable() }
    
    //MARK: Private Properties
    private let disposeBag = DisposeBag()
    private var goals : Variable<[Goal]> = Variable([])
    
    private let timeService : TimeService
    private let timeSlotService : TimeSlotService
    private let goalService : GoalService
    private let appLifecycleService : AppLifecycleService
    
    //MARK: Initializers
    init(timeService: TimeService,
         timeSlotService: TimeSlotService,
         goalService: GoalService,
         appLifecycleService: AppLifecycleService)
    {
        self.timeService = timeService
        self.timeSlotService = timeSlotService
        self.goalService = goalService
        self.appLifecycleService = appLifecycleService
        
        let newGoalForThisDate = goalService.goalCreatedObservable
            .mapTo(())
        
        let updatedGoalsForThisDate = goalService.goalsUpdatedObservable
            .mapTo(())
        
        let newTimeSlotForThisDate = timeSlotService
            .timeSlotCreatedObservable
            .filter(timeSlotBelongsToThisDate)
            .mapTo(())
        
        let updatedTimeSlotsForThisDate = timeSlotService.timeSlotsUpdatedObservable
            .mapTo(belongsToThisDate)
            .mapTo(())
        
        let movedToForeground = appLifecycleService
            .movedToForegroundObservable
            .mapTo(())
        
        let refreshObservable =
            Observable.of(newGoalForThisDate, updatedGoalsForThisDate, movedToForeground, newTimeSlotForThisDate, updatedTimeSlotsForThisDate)
                .merge()
                .startWith(())
        
        refreshObservable
            .map(getGoals)
            .map(withMissingDateGoals)
            .bindTo(goals)
            .addDisposableTo(disposeBag)
        
    }
    
    func isCurrentGoal(_ goal: Goal?) -> Bool
    {
        guard let goal = goal else { return false }
        return goal.date.ignoreTimeComponents() == timeService.now.ignoreTimeComponents()
    }
    
    //MARK: Private Methods
    
    /// Adds placeholder goals to the given goals array to fill the dates that did not have any goal.
    /// The placeholder goals have the date of the days that do not have any goal and a category of .unknown
    ///
    /// - Parameter goals: Goals that were set by the user already
    /// - Returns: Goals that have extra placeholder goals for the date that the user did not set a goal
    private func withMissingDateGoals(_ goals: [Goal]) -> [Goal]
    {
        var goalsToReturn = [Goal]()
        
        for (goal1, goal2) in zip(goals, goals.dropFirst())
        {
            if goalsToReturn.last != goal1
            {
                goalsToReturn.append(goal1)
            }
            
            guard goal2.date.differenceInDays(toDate: goal1.date) != 1 else { continue }
            
            var date = goal1.date.add(days: -1)
            
            while goal2.date.differenceInDays(toDate: date) >= 1
            {
                goalsToReturn.append(Goal(date: date, category: .unknown, value: 0))
                date = date.add(days: -1)
            }
            
            goalsToReturn.append(goal2)
        }
        
        return goalsToReturn
    }
    
    private func getGoals() -> [Goal]
    {
        return goalService.getGoals(sinceDaysAgo: 15)
    }
    
    private func timeSlotBelongsToThisDate(_ timeSlot: TimeSlot) -> Bool
    {
        return timeSlot.startTime.ignoreTimeComponents() == timeService.now.ignoreTimeComponents()
    }
    
    private func belongsToThisDate(_ timeSlots: [TimeSlot]) -> [TimeSlot]
    {
        return timeSlots.filter(timeSlotBelongsToThisDate(_:))
    }
}
