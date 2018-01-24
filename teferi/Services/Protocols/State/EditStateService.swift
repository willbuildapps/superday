import RxSwift
import CoreGraphics

protocol EditStateService
{
    var isEditingObservable : Observable<Bool> { get }
    
    var beganEditingObservable : Observable<(CGPoint, SlotTimelineItem)> { get }
    
    func notifyEditingBegan(point: CGPoint, slotTimelineItem: SlotTimelineItem)
    
    func notifyEditingEnded()
}
