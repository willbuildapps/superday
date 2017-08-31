import RxSwift

protocol AppLifecycleService
{
    var lifecycleEventObservable : Observable<LifecycleEvent> { get }
    
    func publish(_ event: LifecycleEvent)
}

extension AppLifecycleService
{
    var movedToForegroundObservable : Observable<Void>
    {
        return self.lifecycleEventObservable
            .filter {
                guard case .movedToForeground = $0 else { return false }
                return true
            }
            .mapTo(())
    }
    
    var startedOnDailyVotingNotificationDateObservable : Observable<Date>
    {
        return self.lifecycleEventObservable
            .map { (event) -> Date? in
                guard case .movedToForeground(let dailyVotingNotificationDate) = event else { return nil }
                return dailyVotingNotificationDate
            }
            .filterNil()
    }
}
