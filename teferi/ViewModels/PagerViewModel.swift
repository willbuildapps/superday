import RxSwift
import Foundation

class PagerViewModel
{
    //MARK: Fields
    private let timeService : TimeService
    private let settingsService : SettingsService
    private var selectedDateService : SelectedDateService
    
    init(timeService: TimeService,
         settingsService: SettingsService,
         selectedDateService: SelectedDateService)
    {
        self.timeService = timeService
        self.settingsService = settingsService
        self.selectedDateService = selectedDateService
        
        self.selectedDate = timeService.now
    }
    
    //MARK: Properties
    private(set) lazy var dateObservable : Observable<DateChange> =
    {
        return self.selectedDateService
            .currentlySelectedDateObservable
            .map(self.toDateChange)
            .filterNil()
    }()
    
    private var selectedDate : Date
    var currentlySelectedDate : Date
    {
        get { return self.selectedDate }
        set(value)
        {
            self.selectedDate = value
            self.selectedDateService.currentlySelectedDate = value
        }
    }
    
    //Methods
    func canScroll(toDate date: Date) -> Bool
    {
        let minDate = self.settingsService.installDate!.ignoreTimeComponents()
        let maxDate = self.timeService.now.ignoreTimeComponents()
        let dateWithNoTime = date.ignoreTimeComponents()
        
        return dateWithNoTime >= minDate && dateWithNoTime <= maxDate
    }
    
    private func toDateChange(_ date: Date) -> DateChange?
    {
        if date != self.currentlySelectedDate
        {
            let dateChange = DateChange(newDate: date, oldDate: self.selectedDate)
            self.selectedDate = date
            
            return dateChange
        }
        
        return nil
    }
}
