import Foundation
import RxSwift

class TimeslotDetailPresenter: NSObject
{
    private weak var viewController : TimeslotDetailViewController!
    private let viewModelLocator : ViewModelLocator
    fileprivate var padding : ContainerPadding?
    fileprivate let swipeInteractionController = SwipeInteractionController()
    
    init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator, startDate: Date, timelineItemsObservable: Observable<[TimelineItem]>, isShowingSubSlot: Bool = false) -> TimeslotDetailViewController
    {
        let presenter = TimeslotDetailPresenter(viewModelLocator: viewModelLocator)
        let viewModel = viewModelLocator.getTimeslotDetailViewModel(for: startDate, timelineItemsObservable: timelineItemsObservable, isShowingSubSlot: isShowingSubSlot)
        
        let viewController = StoryboardScene.Main.instantiateEditTimeslot()
        viewController.inject(presenter: presenter, viewModel: viewModel)
        presenter.viewController = viewController
        
        return viewController
    }
    
    func showEditSubTimeSlot(with startDate: Date, timelineItemsObservable: Observable<[TimelineItem]>)
    {
        let vc = TimeslotDetailPresenter.create(with: viewModelLocator, startDate: startDate, timelineItemsObservable: timelineItemsObservable, isShowingSubSlot: true)
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        viewController.present(vc, animated: true, completion: nil)
        
        swipeInteractionController.wireToViewController(viewController: vc)
    }
    
    func showEditStartTime(timeSlot: TimeSlot)
    {
        showEditTime(timeSlot: timeSlot, isStart: true)
    }
    
    func showEditEndTime(timeSlot: TimeSlot)
    {
        showEditTime(timeSlot: timeSlot, isStart: false)
    }
    
    func dismiss()
    {
        viewController.dismiss(animated: true)
    }
    
    private func showEditTime(timeSlot: TimeSlot, isStart:Bool)
    {
        padding = ContainerPadding(left: 16, top: 48, right: 16, bottom: 16)
        
        let vc = EditTimesPresenter.create(with: viewModelLocator, slotStartTime: timeSlot.startTime, editingStart: isStart)
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        viewController.present(vc, animated: true, completion: nil)

        swipeInteractionController.wireToViewController(viewController: vc)
    }
}

extension TimeslotDetailPresenter : UIViewControllerTransitioningDelegate
{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting, containerPadding: padding, hasDimmingView: false, hasShadow: false)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return FromBottomTransition(presenting:true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return FromBottomTransition(presenting:false)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        return swipeInteractionController.interactionInProgress ? swipeInteractionController : nil
    }
}
