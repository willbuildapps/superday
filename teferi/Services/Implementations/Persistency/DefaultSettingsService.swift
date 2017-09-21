import CoreData
import UIKit
import CoreLocation

class DefaultSettingsService : SettingsService
{
    //MARK: Public Properties
    
    var installDate : Date?
    {
        return get(forKey: installDateKey)
    }
    
    var lastLocation : Location?
    {
        var location : Location? = nil
        
        let possibleTime = get(forKey: lastLocationDateKey) as Date?
        
        if let time = possibleTime
        {
            let latitude = getDouble(forKey: lastLocationLatKey)
            let longitude = getDouble(forKey: lastLocationLngKey)
            let horizontalAccuracy = get(forKey: lastLocationHorizontalAccuracyKey) as Double? ?? 0.0
            
            location = Location(timestamp: time,
                                latitude: latitude, longitude: longitude,
                                accuracy: horizontalAccuracy)
        }
        
        return location
    }
    
    var hasLocationPermission : Bool
    {
        guard CLLocationManager.locationServicesEnabled() else { return false }
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    var hasHealthKitPermission : Bool
    {
        return getBool(forKey: healthKitPermissionKey)
    }
    
    var hasNotificationPermission : Bool
    {
        let notificationSettings = UIApplication.shared.currentUserNotificationSettings
        return notificationSettings?.types.contains([.alert, .badge]) ?? false
    }
    
    var userEverGaveLocationPermission: Bool
    {
        return getBool(forKey: userGaveLocationPermissionKey)
    }
    
    var didShowWelcomeMessage : Bool
    {
        return getBool(forKey: welcomeMessageShownKey)
    }
    
    var lastShownWeeklyRating : Date?
    {
        return get(forKey: lastShownWeeklyRatingKey)
    }
    
    //MARK: Private Properties
    
    private let timeService : TimeService
    
    private let installDateKey = "installDate"
    private let lastLocationLatKey = "lastLocationLat"
    private let lastLocationLngKey = "lastLocationLng"
    private let lastLocationDateKey = "lastLocationDate"
    private let lastLocationHorizontalAccuracyKey = "lastLocationHorizongalAccuracy"
    private let userGaveLocationPermissionKey = "canIgnoreLocationPermission"
    private let lastHealthKitUpdateKey = "lastHealthKitUpdate"
    private let healthKitPermissionKey = "healthKitPermission"
    private let welcomeMessageShownKey = "welcomeMessageShown"
    private let votingHistoryKey = "votingHistory"
    private let lastShownWeeklyRatingKey = "lastShownWeeklyRating"
    
    //MARK: Initialiazers
    init (timeService : TimeService)
    {
        self.timeService = timeService
    }

    //MARK: Public Methods
    func lastHealthKitUpdate(for identifier: String) -> Date
    {
        let key = lastHealthKitUpdateKey + identifier
        
        guard let lastUpdate : Date = get(forKey: key)
        else
        {
            let initialDate = timeService.now
            setLastHealthKitUpdate(for: identifier, date: initialDate)
            return initialDate
        }
        
        return lastUpdate
    }
    
    func setLastHealthKitUpdate(for identifier: String, date: Date)
    {
        let key = lastHealthKitUpdateKey + identifier
        set(date, forKey: key)
    }
    
    func setInstallDate(_ date: Date)
    {
        guard installDate == nil else { return }
        
        set(date, forKey: installDateKey)
    }
    
    func setLastLocation(_ location: Location)
    {
        set(location.timestamp, forKey: lastLocationDateKey)
        set(location.latitude, forKey: lastLocationLatKey)
        set(location.longitude, forKey: lastLocationLngKey)
        set(location.horizontalAccuracy, forKey: lastLocationHorizontalAccuracyKey)
    }
    
    func setUserGaveLocationPermission()
    {
        set(true, forKey: userGaveLocationPermissionKey)
    }
    
    func setUserGaveHealthKitPermission()
    {
        set(true, forKey: healthKitPermissionKey)
    }
    
    func setWelcomeMessageShown()
    {
        set(true, forKey: welcomeMessageShownKey)
    }
    
    func setVote(forDate date: Date)
    {
        var history = lastSevenDaysOfVotingHistory()
        history.append(date.ignoreTimeComponents())
        UserDefaults.standard.setValue(history, forKey: votingHistoryKey)
    }
    
    func lastSevenDaysOfVotingHistory() -> [Date]
    {
        guard let history = UserDefaults.standard.object(forKey: votingHistoryKey) as? [Date]
        else
        {
            let history = [Date]()
            UserDefaults.standard.setValue(history, forKey: votingHistoryKey)
            return history
        }
        
        let cleanedUpHistory = history.filter { timeService.now.timeIntervalSince($0) < Constants.sevenDaysInSeconds }
        
        UserDefaults.standard.setValue(cleanedUpHistory, forKey: votingHistoryKey)
        
        return cleanedUpHistory
    }
    
    func setLastShownWeeklyRating(_ date: Date)
    {
        set(date, forKey: lastShownWeeklyRatingKey)
    }
    
    // MARK: Private Methods
    private func get<T>(forKey key: String) -> T?
    {
        return UserDefaults.standard.object(forKey: key) as? T
    }
    private func getDouble(forKey key: String) -> Double
    {
        return UserDefaults.standard.double(forKey: key)
    }
    private func getBool(forKey key: String) -> Bool
    {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    private func set(_ value: Date?, forKey key: String)
    {
        UserDefaults.standard.set(value, forKey: key)
    }
    private func set(_ value: Double, forKey key: String)
    {
        UserDefaults.standard.set(value, forKey: key)
    }
    private func set(_ value: Bool, forKey key: String)
    {
        UserDefaults.standard.set(value, forKey: key)
    }
    
}
