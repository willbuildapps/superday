import Foundation
import UIKit
import UserNotifications

class DefaultNotificationService : NotificationService
{
    //MARK: Private Properties
    private let timeService : TimeService
    private let loggingService : LoggingService
    private let settingsService : SettingsService
    private let goalService: GoalService
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    //MARK: Initializers
    init(timeService: TimeService,
         loggingService: LoggingService,
         settingsService: SettingsService,
         goalService: GoalService)
    {
        self.timeService = timeService
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.goalService = goalService
    }
    
    //MARK: Public Methods
    func requestNotificationPermission(completed: @escaping (_ authorized: Bool) -> ())
    {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge],
                                                completionHandler: { (granted, error) in
                                                    DispatchQueue.main.async {
                                                        completed(granted)
                                                    }
                                                })
    }
    
    func scheduleNormalNotification(date: Date, message: String)
    {
        scheduleNotification(date: date, title: "", message: message, ofType: .normal)
    }
    
    func clearAndScheduleWeeklyNotifications()
    {
        unscheduleAllNotifications(ofTypes: [.repeatWeekly]) { [unowned self] in
            self.scheduleVotingNotifications()
            self.scheduleWeeklyRatingNotifications()
        }
    }
    
    func clearAndScheduleGoalNotifications()
    {
        unscheduleAllNotifications(ofTypes: [.goal], completion: scheduleGoalNotifications)
    }
    
    //MARK: Private Methods
    
    private func unscheduleAllNotifications(ofTypes notificationTypes: [NotificationType], completion: (() -> Void)?)
    {
        if notificationTypes.isEmpty
        {
            notificationCenter.removeAllDeliveredNotifications()
            notificationCenter.removeAllPendingNotificationRequests()
            completion?()
            return
        }
        
        notificationCenter.getDeliveredNotifications { (notifications) in
            
            let notificationIdentifiers = notifications
                .map({ $0.request.identifier })
                .filter({ (notificationIdentifier) -> Bool in
                    return notificationTypes.filter({ notificationIdentifier.contains($0.rawValue) }).count > 0
                })
            
            self.notificationCenter.removeDeliveredNotifications(withIdentifiers: notificationIdentifiers)
            
            self.notificationCenter.getPendingNotificationRequests { (requests) in
                
                let requestIdentifiers = requests
                    .map({ $0.identifier })
                    .filter({ (requestIdentifier) -> Bool in
                        return notificationTypes.filter({ requestIdentifier.contains($0.rawValue) }).count > 0
                    })
                
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: requestIdentifiers)
                
                completion?()
            }
        }
    }
    
    private func scheduleVotingNotifications()
    {
        guard let installDate = settingsService.installDate else { return }
        
        for i in 2...7
        {
            if timeService.now.ignoreTimeComponents() == installDate.ignoreTimeComponents(), timeService.now.dayOfWeek == i-1 { continue }
            
            let date = Date.create(weekday: i, hour: Constants.hourToShowDailyVotingUI, minute: 00, second: 00)
            scheduleNotification(date: date, title: L10n.votingNotificationTittle, message: L10n.votingNotificationMessage, ofType: .repeatWeekly)
        }
    }
    
    private func scheduleWeeklyRatingNotifications()
    {
        guard
            let installDate = settingsService.installDate,
            timeService.now.timeIntervalSince(installDate) >= Constants.sevenDaysInSeconds
        else { return }

        let date = Date.create(weekday: 1, hour: Constants.hourToShowWeeklyRatingUI, minute: 00, second: 00)
        scheduleNotification(date: date, title: L10n.ratingNotificationTitle, message: L10n.ratingNotificationMessage, ofType: .repeatWeekly)
    }
    
    private func scheduleNotification(date: Date, title: String, message: String, ofType type: NotificationType)
    {
        loggingService.log(withLogLevel: .info, message: "Scheduling message for date: \(date)")
        
        let content = notificationContent(title: title, message: message)
        let identifier = type.rawValue + "\(date.dayOfWeek)\(date.hour)\(date.minute)\(date.second)"
        var trigger : UNNotificationTrigger! = nil
        
        switch type {
        case .goal, .normal:
            let fireTime = date.timeIntervalSinceNow
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: fireTime, repeats: false)
        case .repeatWeekly:
            let triggerWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
        }
        
        content.userInfo["id"] = identifier
        content.userInfo["notificationType"] = type.rawValue
        
        let request  = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { [unowned self] (error) in
            if let error = error
            {
                self.loggingService.log(withLogLevel: .warning, message: "Tried to schedule notifications, but could't. Got error: \(error)")
            }
        }
    }
    
    private func scheduleGoalNotifications()
    {
        guard let goal = goalService.getGoals(sinceDaysAgo: 1).first,
            goal.date.ignoreTimeComponents() == timeService.now.ignoreTimeComponents()
            else { return }
        
        let tomorrowAt11 = timeService.now.tomorrow.setHour(11)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        let todayDateString = dateFormatter.string(from: timeService.now)
        

        let message = L10n.resultsNotificationMessage(todayDateString)
        scheduleNotification(date: tomorrowAt11, title: "", message: message, ofType: .goal)
    }
    
    private func notificationContent(title: String, message: String) -> UNMutableNotificationContent
    {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default()
        return content
    }
}
