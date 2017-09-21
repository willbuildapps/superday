import Foundation
@testable import teferi

class MockSettingsService : SettingsService
{
    //MARK: Properties
    var nextSmartGuessId = 0
    var installDate : Date? = Date()
    var lastInactiveDate : Date? = nil
    var lastLocation : Location? = nil
    var userEverGaveLocationPermission : Bool = false
    var didShowWelcomeMessage : Bool = true
    var lastShownWeeklyRating : Date? = Date()
    

    var hasLocationPermission = true
    var hasHealthKitPermission = true
    var hasNotificationPermission = true
    
    var healthKitUpdates = [String: Date]()
    
    //MARK: Methods
    func lastHealthKitUpdate(for identifier: String) -> Date
    {
        guard let dateToReturn = healthKitUpdates[identifier]
        else
        {
            return lastInactiveDate!
        }
        
        return dateToReturn
    }
    
    func setLastHealthKitUpdate(for identifier: String, date: Date)
    {
        healthKitUpdates[identifier] = date
    }
    
    func setInstallDate(_ date: Date)
    {
        installDate = date
    }
    
    func setLastLocation(_ location: Location)
    {
        lastLocation = location
    }
    
    func getNextSmartGuessId() -> Int
    {
        return nextSmartGuessId
    }
    
    func incrementSmartGuessId()
    {
        nextSmartGuessId += 1
    }
    
    func setUserGaveLocationPermission()
    {
        userEverGaveLocationPermission = true
    }
    
    func setUserGaveHealthKitPermission()
    {
        hasHealthKitPermission = true
    }
    
    func setWelcomeMessageShown()
    {
        didShowWelcomeMessage = true
    }
    
    func setVote(forDate date: Date)
    {
        
    }
    
    func lastSevenDaysOfVotingHistory() -> [Date]
    {
        return []
    }
    
    func setLastShownWeeklyRating(_ date: Date)
    {
        lastShownWeeklyRating = date
    }
}
