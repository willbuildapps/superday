import Foundation
import UIKit

class IntroPresenter : NSObject
{
    private weak var viewController : IntroViewController!    
    private let viewModelLocator : ViewModelLocator
    
    private init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator) -> IntroViewController
    {
        let presenter = IntroPresenter(viewModelLocator: viewModelLocator)
        
        let viewController = IntroViewController()
        viewController.inject(presenter: presenter, viewModel: viewModelLocator.getIntroViewModel())
                
        presenter.viewController = viewController
        
        return viewController
    }
    
    func showOnBoarding()
    {
        let vc = OnboardingPresenter.create(with: viewModelLocator)
        vc.transitioningDelegate = self
        viewController.present(vc, animated: true)        
    }
    
    func showMainScreen()
    {
        let tabBarController = TabBarPresenter.create(with: viewModelLocator)
        tabBarController.transitioningDelegate = self
        viewController.present(tabBarController, animated: true)
    }
}

extension IntroPresenter : UIViewControllerTransitioningDelegate
{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return FadeTransition()
    }
}
