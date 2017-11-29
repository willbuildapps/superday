import Foundation
import StoreKit

class SettingsViewModel
{
    private let settingsService : SettingsService
    private let feedbackService: FeedbackService
    
    init(settingsService: SettingsService, feedbackService: FeedbackService)
    {
        self.settingsService = settingsService
        self.feedbackService = feedbackService
    }
    
    var fullAppVersion: String
    {
        return "Version \(self.settingsService.versionNumber) (\(self.settingsService.buildNumber))"
    }
    
    func composeFeedback()
    {
        feedbackService.composeFeedback()
    }
    
    func requestReview()
    {
        SKStoreReviewController.requestReview()
    }
}
