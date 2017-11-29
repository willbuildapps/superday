import Foundation

class GoalMessageProvider
{
    private let timeService : TimeService
    private let settingsService: SettingsService
    
    private let firstGoalAchived = L10n.firstGoalAchievedMessage
    private let goalAchivedPart1 = [L10n.goalAchievedPart1Message1,
                                    L10n.goalAchievedPart1Message2,
                                    L10n.goalAchievedPart1Message3,
                                    L10n.goalAchievedPart1Message4]
    private let goalAchivedPart2Before5pm = [L10n.goalAchievedPart2Before5pmMessage1,
                                             L10n.goalAchievedPart2Before5pmMessage2,
                                             L10n.goalAchievedPart2Before5pmMessage3,
                                             L10n.goalAchievedPart2Before5pmMessage4,
                                             L10n.goalAchievedPart2Before5pmMessage5,
                                             L10n.goalAchievedPart2Before5pmMessage6]
    private let goalAchivedPart2After5pm = [L10n.goalAchievedPart2After5pmMessage1,
                                            L10n.goalAchievedPart2After5pmMessage2,
                                            L10n.goalAchievedPart2After5pmMessage3,
                                            L10n.goalAchievedPart2After5pmMessage4,
                                            L10n.goalAchievedPart2After5pmMessage5,
                                            L10n.goalAchievedPart2After5pmMessage6,
                                            L10n.goalAchievedPart2After5pmMessage7]
    private let goalOverAchiever = [L10n.goalOverAchieved1,
                                    L10n.goalOverAchieved2,
                                    L10n.goalOverAchieved3,
                                    L10n.goalOverAchieved4,
                                    L10n.goalOverAchieved5]
    private let goalFailed10PercentOrLess = [L10n.goalFailed10PercentOrLess1,
                                             L10n.goalFailed10PercentOrLess2,
                                             L10n.goalFailed10PercentOrLess3]
    private let goalFailed10PercentOrMore = [L10n.goalFailed10PercentOrMore1,
                                             L10n.goalFailed10PercentOrMore2]
    private let goalFailed0Percent = [L10n.goalFailed0Percent1,
                                      L10n.goalFailed0Percent2,
                                      L10n.goalFailed0Percent3,
                                      L10n.goalFailed0Percent4,
                                      L10n.goalFailed0Percent5]
    
    private var newGoalMessage : String
    {
        return L10n.goalHeaderDefaultMessage
    }
    
    init(timeService: TimeService, settingsService: SettingsService)
    {
        self.timeService = timeService
        self.settingsService = settingsService
    }
    
    func message(forGoal goal: Goal?) -> (message: String?, categoryVisible: Bool, newGoalButtonVisible: Bool)
    {
        guard let goal = goal else { return (newGoalMessage, false, true) }

        switch (goal.date.differenceInDays(toDate: timeService.now), goal.percentageCompleted) {
        case (0, ..<1.0):
            return (defaultMessageForCurrentGoal(forGoal: goal), true, false)
        case (0, 1.0...):
            return (positiveMessage(forGoal: goal), true, false)
        case (1, ..<1.0):
            return (negativeMessage(forGoal: goal), false, true)
        default:
            return (newGoalMessage, false, true)
        }
    }
    
    private func defaultMessageForCurrentGoal(forGoal goal: Goal) -> String
    {
        let components = elapsedTimeComponents(for: goal.targetTime)
        if let hours = components.hour, hours > 0
        {
            return L10n.goalHeaderTodayIWantToSpendHours(String(components.hour!))
        }
        else
        {
            return L10n.goalHeaderTodayIWantToSpendMinutes(String(components.minute!))
        }
    }
    
    private func negativeMessage(forGoal goal: Goal) -> String?
    {
        if goal.percentageCompleted == 0.0
        {
            return goalFailed0Percent.randomItem
        }
        else if goal.percentageCompleted > 0.9
        {
            return goalFailed10PercentOrLess.randomItem
        }
        else
        {
            return goalFailed10PercentOrMore.randomItem!(Int(goal.percentageCompleted * 100))
        }
    }
    
    private func positiveMessage(forGoal goal: Goal) -> String?
    {
        guard goal.percentageCompleted >= 1.0 else { return nil }
        
        guard let lastUsedMessageAndDate = settingsService.lastUsedGoalAchivedMessageAndDate
            else
        {
            let dict = [timeService.now: firstGoalAchived]
            settingsService.setLastUsedGoalAchivedMessageAndDate(dict)
            return firstGoalAchived
        }
        
        if let date = lastUsedMessageAndDate.keys.first,
            date.ignoreTimeComponents() == timeService.now.ignoreTimeComponents()
        {
            return lastUsedMessageAndDate[date]!
        }
        
        guard goal.percentageCompleted < 2.0 else { return goalOverAchiever.randomItem! }
        
        var message: String!
        
        if timeService.now.hour < 17
        {
            message = goalAchivedPart1.randomItem! + "\n" + goalAchivedPart2Before5pm.randomItem!
        }
        else
        {
            message = goalAchivedPart1.randomItem! + "\n" + goalAchivedPart2After5pm.randomItem!
        }
        
        settingsService.setLastUsedGoalAchivedMessageAndDate([timeService.now: message])
        return message
    }
}
