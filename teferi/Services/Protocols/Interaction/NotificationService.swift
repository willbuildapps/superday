import Foundation
import UserNotificationsUI

protocol NotificationService
{
    func requestNotificationPermission(completed: @escaping () -> ())
    
    func scheduleNormalNotification(date: Date, message: String)
    func clearAndScheduleWeeklyNotifications()
    func clearAndScheduleGoalNotifications()
}
