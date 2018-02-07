import Foundation
import RxSwift
import RxCocoa

///ViewModel for the CalendardViewModel.
class CalendarViewModel
{
    // MARK: Public Properties
    var minValidDate : Date { return settingsService.installDate ?? timeService.now }
    var maxValidDate : Date { return self.timeService.now }
    
    var selectedDate : Driver<Date> {
       return self.selectedDateService.currentlySelectedDateObservable
        .asDriver(onErrorJustReturn: timeService.now)
    }
    
    // MARK: Private Properties
    private let timeService : TimeService
    private let settingsService: SettingsService
    private let timeSlotService : TimeSlotService
    private var selectedDateService : SelectedDateService
    
    // MARK: Initializers
    init(timeService: TimeService,
         settingsService: SettingsService,
         timeSlotService: TimeSlotService,
         selectedDateService: SelectedDateService)
    {
        self.timeService = timeService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.selectedDateService = selectedDateService
    }
    
    // MARK: Public Methods
    
    func getActivities(forDate date: Date?) -> Observable<[Activity]>
    {
        return Observable.create { [unowned self] observer in
        
            guard let date = date else {
                observer.onCompleted()
                return Disposables.create{}
            }
            
            DispatchQueue(label: "background").async {
                let result = self.timeSlotService.getActivities(forDate: date).sorted(by: self.category)
                observer.onNext(result)
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
    }
    
    func setSelectedDate(date: Date)
    {
        self.selectedDateService.currentlySelectedDate = date
    }
    
    // MARK: Private Methods
    private func category(_ element1: Activity, _ element2: Activity) -> Bool
    {
        let allCategories = Category.all
        let index1 = allCategories.index(of: element1.category)!
        let index2 = allCategories.index(of: element2.category)!
        
        return index1 > index2
    }
}
