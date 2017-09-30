import UIKit

struct ContainerPadding
{
    let left : CGFloat
    let top : CGFloat
    let right : CGFloat
    let bottom : CGFloat
}

protocol DesiredHeightProtocol
{
    func height(forWidth width: CGFloat) -> CGFloat
}

class ModalPresentationController: UIPresentationController
{
    private var dimmingView : UIView!
    private var containerPadding : ContainerPadding?
    private var canBeDismissedByUser : Bool
    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         containerPadding: ContainerPadding? = ContainerPadding(left: 16, top: 78, right: 16, bottom: 78),
         canBeDismissedByUser: Bool = true)
    {
        self.containerPadding = containerPadding
        self.canBeDismissedByUser = canBeDismissedByUser
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        setupDimmingView()
    }
    
    private func setupDimmingView()
    {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        dimmingView.alpha = 0.0
        
        if canBeDismissedByUser
        {
            let dismissTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ModalPresentationController.dismiss))
            dimmingView.addGestureRecognizer(dismissTapRecognizer)
        }
    }
    
    @objc private func dismiss()
    {
        presentedViewController.dismiss(animated: true)
    }
    
    override func presentationTransitionWillBegin()
    {
        containerView?.insertSubview(dimmingView, at: 0)
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        guard let coordinator = presentedViewController.transitionCoordinator
        else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin()
    {
        guard let coordinator = presentedViewController.transitionCoordinator
        else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews()
    {
        presentedView?.frame = frameOfPresentedViewInContainerView
        
        presentedViewController.view.layer.cornerRadius = 10.0
        presentedViewController.view.layer.shadowColor = UIColor.black.cgColor
        presentedViewController.view.layer.shadowOpacity = 0.2
        presentedViewController.view.layer.shadowOffset = CGSize.zero
        presentedViewController.view.layer.shadowRadius = 2
        presentedViewController.view.layer.masksToBounds = false
        presentedViewController.view.layer.shadowPath = UIBezierPath(roundedRect: presentedViewController.view.bounds, cornerRadius: 10.0).cgPath
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize
    {
        guard let containerPadding = containerPadding else { return parentSize }
        
        return CGSize(width: parentSize.width - containerPadding.left - containerPadding.right, height: parentSize.height - containerPadding.top - containerPadding.bottom)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect
    {
        guard let containerPadding = containerPadding else { return containerView!.bounds }
        
        let containerSize = containerView!.bounds.size
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerSize)
        
        if let container = presentedViewController as? DesiredHeightProtocol
        {
            let newSize = CGSize(width: frame.size.width, height: container.height(forWidth: frame.size.width))
            frame = CGRect(origin: CGPoint(x: containerPadding.left, y: containerSize.height / 2 - newSize.height / 2),
                           size: newSize)
        }
        else
        {
            frame.origin = CGPoint(x: containerPadding.left, y: containerPadding.top)
        }
        
        return frame
    }
}
