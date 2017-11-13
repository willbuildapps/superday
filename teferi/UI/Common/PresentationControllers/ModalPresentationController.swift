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
    private var dimmingView : UIView?
    private var containerPadding : ContainerPadding?
    private var canBeDismissedByUser : Bool
    private var hasDimmingView : Bool
    private var hasShadow : Bool
    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         containerPadding: ContainerPadding? = ContainerPadding(left: 16, top: 78, right: 16, bottom: 78),
         canBeDismissedByUser: Bool = true,
         hasDimmingView: Bool = true,
         hasShadow: Bool = true)
    {
        self.containerPadding = containerPadding
        self.canBeDismissedByUser = canBeDismissedByUser
        self.hasDimmingView = hasDimmingView
        self.hasShadow = hasShadow
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        if hasDimmingView {
            setupDimmingView()
        }
    }
    
    private func setupDimmingView()
    {
        dimmingView = UIView()
        dimmingView!.translatesAutoresizingMaskIntoConstraints = false
        dimmingView!.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        dimmingView!.alpha = 0.0
        
        if canBeDismissedByUser
        {
            let dismissTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ModalPresentationController.dismiss))
            dimmingView!.addGestureRecognizer(dismissTapRecognizer)
        }
    }
    
    @objc private func dismiss()
    {
        presentedViewController.dismiss(animated: true)
    }
    
    override func presentationTransitionWillBegin()
    {
        guard let dimmingView = dimmingView else { return }
        
        containerView!.insertSubview(dimmingView, at: 0)
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        changeDimmingViewAlpha(alpha: 1)
    }
    
    override func dismissalTransitionWillBegin()
    {
        changeDimmingViewAlpha(alpha: 0)
    }
    
    override func containerViewWillLayoutSubviews()
    {
        presentedView?.frame = frameOfPresentedViewInContainerView
        
        presentedViewController.view.layer.cornerRadius = 10.0
        
        if hasShadow {
            presentedViewController.view.layer.shadowColor = UIColor.black.cgColor
            presentedViewController.view.layer.shadowOpacity = 0.2
            presentedViewController.view.layer.shadowOffset = CGSize.zero
            presentedViewController.view.layer.shadowRadius = 2
            presentedViewController.view.layer.masksToBounds = false
            presentedViewController.view.layer.shadowPath = UIBezierPath(roundedRect: presentedViewController.view.bounds, cornerRadius: 10.0).cgPath
        }
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
    
    private func changeDimmingViewAlpha(alpha: CGFloat)
    {
        guard let dimmingView = dimmingView else { return }

        guard let coordinator = presentedViewController.transitionCoordinator
            else {
                dimmingView.alpha = alpha
                return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            dimmingView.alpha = alpha
        })
    }
}
