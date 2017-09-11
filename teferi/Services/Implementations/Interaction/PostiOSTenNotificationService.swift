import Foundation
import UIKit
import UserNotifications

@available(iOS 10.0, *)
class PostiOSTenNotificationService : NotificationService
{
    //MARK: Private Properties
    private let timeService : TimeService
    private let loggingService : LoggingService
    private let settingsService : SettingsService
    private let timeSlotService : TimeSlotService
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    //MARK: Initializers
    init(timeService: TimeService,
         loggingService: LoggingService,
         settingsService: SettingsService,
         timeSlotService: TimeSlotService)
    {
        self.timeService = timeService
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
    }
    
    //MARK: Public Methods
    func requestNotificationPermission(completed: @escaping () -> ())
    {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge],
                                                completionHandler: { (granted, error) in completed() })
    }
    
    func scheduleNormalNotification(date: Date, title: String, message: String)
    {
        scheduleNotification(date: date, title: title, message: message, ofType: .normal)
    }
    
    func clearAndScheduleAllDefaultNotifications()
    {
        unscheduleAllNotifications(ofTypes: .repeatWeekly)
        scheduleVotingNotifications()
        scheduleWeeklyRatingNotifications()
    }
    
    func unscheduleAllNotifications(ofTypes types: NotificationType?...)
    {
        let givenTypes = types.flatMap { $0 }
        
        if givenTypes.isEmpty
        {
            notificationCenter.removeAllDeliveredNotifications()
            notificationCenter.removeAllPendingNotificationRequests()
            return
        }
        
        notificationCenter.getDeliveredNotifications { (notifications) in
            notifications.forEach({ (notification) in
                givenTypes.forEach({ (type) in
                    if notification.request.identifier.contains(type.rawValue)
                    {
                        self.notificationCenter.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                    }
                })
            })
        }
        
        notificationCenter.getPendingNotificationRequests { (requests) in
            requests.forEach({ (request) in
                givenTypes.forEach({ (type) in
                    if request.identifier.contains(type.rawValue)
                    {
                        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    }
                })
            })
        }
    }
    
    //MARK: Private Methods
    
    private func scheduleVotingNotifications()
    {
        for i in 2...7
        {
            let date = Date.create(weekday: i, hour: Constants.hourToShowDailyVotingUI, minute: 00, second: 00)
            scheduleNotification(date: date, title: L10n.votingNotificationTittle, message: L10n.votingNotificationMessage, ofType: .repeatWeekly)
        }
    }
    
    private func scheduleWeeklyRatingNotifications()
    {
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
        case .normal:
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
    
    private func notificationContent(title: String, message: String) -> UNMutableNotificationContent
    {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound(named: UILocalNotificationDefaultSoundName)
        return content
    }
}
