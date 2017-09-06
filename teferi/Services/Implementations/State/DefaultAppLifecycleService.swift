import RxSwift

class DefaultAppLifecycleService : AppLifecycleService
{
    let lifecycleEventObservable : Observable<LifecycleEvent>
    private let lifecycleSubject = BehaviorSubject<LifecycleEvent?>(value: nil)

    //MARK: Initializers
    init()
    {
        lifecycleEventObservable = lifecycleSubject
                                    .asObservable()
                                    .filterNil()
                                    .distinctUntilChanged()
    }
    
    func publish(_ event: LifecycleEvent)
    {
        lifecycleSubject
            .on(.next(event))
    }
}
