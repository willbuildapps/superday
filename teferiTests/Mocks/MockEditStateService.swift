import RxSwift
@testable import teferi

class MockEditStateService : EditStateService
{
    //MARK: Fields
    private let isEditingSubject = PublishSubject<Bool>()
    private let beganEditingSubject = PublishSubject<(CGPoint, SlotTimelineItem)>()
    
    //MARK: Initializers
    init()
    {
        isEditingObservable = isEditingSubject.asObservable()
        beganEditingObservable = beganEditingSubject.asObservable()
    }
    
    //MARK: EditStateService implementation
    let isEditingObservable : Observable<Bool>
    let beganEditingObservable : Observable<(CGPoint, SlotTimelineItem)>
    
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
