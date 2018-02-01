import RxSwift

class DefaultEditStateService : EditStateService
{
    let isEditingObservable : Observable<Bool>
    let beganEditingObservable : Observable<(CGPoint, SlotTimelineItem)>

    private let isEditingSubject = PublishSubject<Bool>()
    private let beganEditingSubject = PublishSubject<(CGPoint, SlotTimelineItem)>()
    
    //MARK: Initializers
    init(timeService: TimeService)
    {
        isEditingObservable = isEditingSubject.asObservable()
        beganEditingObservable = beganEditingSubject.asObservable()
    }
    
    func notifyEditingBegan(point: CGPoint, slotTimelineItem: SlotTimelineItem)
    {
        isEditingSubject.on(.next(true))
        beganEditingSubject.on(.next((point, slotTimelineItem)))
    }
    
    func notifyEditingEnded()
    {
        isEditingSubject.on(.next(false))
    }
}
