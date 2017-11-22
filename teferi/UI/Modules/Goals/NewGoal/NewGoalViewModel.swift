import Foundation
import RxSwift

class NewGoalViewModel
{
    private let timeService: TimeService
    private let goalService: GoalService
    private let notificationService: NotificationService
    private let categoryProvider: CategoryProvider
    private let goalToBeEdited: Goal?
    
    var durationSelectedVariable = Variable<Double?>(nil)
    var categorySelectedVariable = Variable<Category?>(nil)
    var categories : [Category]
    {
        return self.categoryProvider.getAll(but: .unknown)
    }
    
    typealias Minutes = Double
    var goalTimes:[GoalTime] = {
        let times: [Double] = [30, 45, 60, 1.5 * 60, 2 * 60, 3 * 60, 4 * 60, 5 * 60, 6 * 60, 7 * 60, 8 * 60, 9 * 60, 10 * 60]
        return times
            .map{ 60 * $0 }
            .map(GoalTime.init)
    }()
    
    private(set) var initialCategory: Category?
    private(set) var initialTime: GoalTime?
    private(set) var buttonTitle: String
    
    init(goalToBeEdited: Goal?,
         timeService: TimeService,
         goalService: GoalService,
         notificationService: NotificationService,
         categoryProvider: CategoryProvider)
    {
        self.goalToBeEdited = goalToBeEdited
        self.timeService = timeService
        self.goalService = goalService
        self.notificationService = notificationService
        self.categoryProvider = categoryProvider
        
        if let goalToBeEdited = goalToBeEdited {
            initialCategory = goalToBeEdited.category
            initialTime = GoalTime(goalTime: goalToBeEdited.targetTime)
            buttonTitle = "Done"
        } else {
            buttonTitle = "Set a goal"
        }
    }
    
    func saveGoal()
    {
        if let goalToBeEdited = goalToBeEdited {
            goalService.update(goal: goalToBeEdited, withCategory: categorySelectedVariable.value!, withTargetTime: durationSelectedVariable.value!)
        } else {
            goalService.addGoal(forDate: timeService.now, category: categorySelectedVariable.value!, targetTime: durationSelectedVariable.value!)
        }
        
        if let reminderText = categorySelectedVariable.value?.notificationReminderText, timeService.now.hour < 20 {
            notificationService.scheduleNormalNotification(date: timeService.now.addingTimeInterval(60 * 60 * 3), message: reminderText)
        }
    }
}

fileprivate extension Category
{
    var notificationReminderText: String? {
        switch self {
        case .family:
            return [L10n.familyGoalReminder1, L10n.familyGoalReminder2].randomItem
        case .fitness:
            return [L10n.fitnessGoalReminder1, L10n.fitnessGoalReminder2].randomItem
        case .food:
            return L10n.foodGoalReminder
        case .leisure:
            return L10n.leisureGoalReminder
        case .commute:
            return [L10n.commuteGoalReminder1, L10n.commuteGoalReminder2].randomItem
        case .work:
            return [L10n.workGoalReminder1, L10n.workGoalReminder2].randomItem
        case .shopping:
            return L10n.shoppingGoalReminder
        default:
            return nil
        }
    }
}
