import Foundation
import UIKit

class EnableNotificationsViewModel: RxViewModel
{
    private let settingsService: SettingsService
    private let notificationService: NotificationService
    
    init(settingsService: SettingsService, notificationService: NotificationService)
    {
        self.settingsService = settingsService
        self.notificationService = notificationService
        self.settingsService.setDidAlreadyShowRequestForNotificationsInNewGoal()
    }
    
    func getNotificationPermissions()
    {
        if settingsService.userRejectedNotificationPermission {
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(url, options: [:])
        } else {
            notificationService.requestNotificationPermission { [unowned self] authorized in                
                if !authorized {
                    self.settingsService.setUserRejectedNotificationPermission()
                }
            }
        }
    }
}
