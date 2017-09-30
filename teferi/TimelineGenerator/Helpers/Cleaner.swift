import Foundation

class Cleaner
{
    private let settingsService: SettingsService
    private let trackEventService: TrackEventService
    private let timeService: TimeService
    
    init(settingsService: SettingsService, trackEventService: TrackEventService, timeService: TimeService)
    {
        self.settingsService = settingsService
        self.trackEventService = trackEventService
        self.timeService = timeService
    }
    
    func cleanUp(slots: [TemporaryTimeSlot])
    {
        if let lastLocation = slots.last?.location {
            settingsService.setLastLocation(lastLocation)
        }
        settingsService.setLastTimelineGenerationDate(timeService.now)
        trackEventService.clearAllData()
    }
}
