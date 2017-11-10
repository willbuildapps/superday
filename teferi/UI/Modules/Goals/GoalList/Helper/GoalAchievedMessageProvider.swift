import Foundation

class GoalAchievedMessageProvider
{
    private let timeService : TimeService
    private let settingsService: SettingsService
    
    private let firstGoalAchived = L10n.firstGoalAchievedMessage
    private let part1 = [L10n.goalAchievedPart1Message1,
                         L10n.goalAchievedPart1Message2,
                         L10n.goalAchievedPart1Message3,
                         L10n.goalAchievedPart1Message4]
    private let part2Before5pm = [L10n.goalAchievedPart2Before5pmMessage1,
                                  L10n.goalAchievedPart2Before5pmMessage2,
                                  L10n.goalAchievedPart2Before5pmMessage3,
                                  L10n.goalAchievedPart2Before5pmMessage4,
                                  L10n.goalAchievedPart2Before5pmMessage5,
                                  L10n.goalAchievedPart2Before5pmMessage6]
    private let part2After5pm = [L10n.goalAchievedPart2After5pmMessage1,
                                 L10n.goalAchievedPart2After5pmMessage2,
                                 L10n.goalAchievedPart2After5pmMessage3,
                                 L10n.goalAchievedPart2After5pmMessage4,
                                 L10n.goalAchievedPart2After5pmMessage5,
                                 L10n.goalAchievedPart2After5pmMessage6,
                                 L10n.goalAchievedPart2After5pmMessage7]
    private let overAchiever = [L10n.goalOverAchieved1,
                                L10n.goalOverAchieved2,
                                L10n.goalOverAchieved3,
                                L10n.goalOverAchieved4,
                                L10n.goalOverAchieved5]
    
    init(timeService: TimeService,
         settingsService: SettingsService)
    {
        self.timeService = timeService
        self.settingsService = settingsService
    }
    
    func message(forGoal goal: Goal) -> String?
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
        
        guard goal.percentageCompleted < 2.0 else { return overAchiever.randomItem! }

        var message: String!

        if timeService.now.hour < 17
        {
            message = part1.randomItem! + "\n" + part2Before5pm.randomItem!
        }
        else
        {
            message = part1.randomItem! + "\n" + part2After5pm.randomItem!
        }
        
        settingsService.setLastUsedGoalAchivedMessageAndDate([timeService.now: message])
        return message
    }
}
