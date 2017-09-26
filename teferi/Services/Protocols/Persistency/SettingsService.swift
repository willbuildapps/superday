import Foundation

protocol SettingsService
{
    //MARK: Properties
    var installDate : Date? { get }
    
    var lastLocation : Location? { get }
    
    var hasLocationPermission : Bool { get }
    
    var hasHealthKitPermission : Bool { get }
    
    var lastAskedForLocationPermission : Date? { get }
        
    var hasNotificationPermission : Bool { get }
    
    var userEverGaveLocationPermission : Bool { get }
    
    var didShowWelcomeMessage : Bool { get }
    
    var lastShownWeeklyRating : Date? { get }
    
    //MARK: Methods
    func lastHealthKitUpdate(for identifier: String) -> Date
    
    func setLastHealthKitUpdate(for identifier: String, date: Date)
    
    func setInstallDate(_ date: Date)
    
    func setLastLocation(_ location: Location)
    
    func setLastAskedForLocationPermission(_ date: Date)
    
    func setUserGaveLocationPermission()
    
    func setUserGaveHealthKitPermission()
        
    func setWelcomeMessageShown()
    
    func setVote(forDate date: Date)
    func lastSevenDaysOfVotingHistory() -> [Date]
    
    func setLastShownWeeklyRating(_ date: Date)
}
