import Foundation
import RxSwift

class NewGoalViewModel
{
    private let timeService: TimeService
    private let goalService: GoalService
    private let categoryProvider: CategoryProvider
    
    var durationSelectedVariable = Variable<Double?>(nil)
    var categorySelectedVariable = Variable<Category?>(nil)
    var categories : [Category]
    {
        return self.categoryProvider.getAll(but: .unknown)
    }
    
    init(timeService: TimeService,
         goalService: GoalService,
         categoryProvider: CategoryProvider)
    {
        self.timeService = timeService
        self.goalService = goalService
        self.categoryProvider = categoryProvider
    }
    
    func createNewGoal()
    {
        goalService.addGoal(forDate: timeService.now, category: categorySelectedVariable.value!, targetTime: durationSelectedVariable.value!)
    }
}
