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
        let imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        let tabBarController = UITabBarController()
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.barTintColor = .white
        
        let topline = CALayer()
        topline.frame = CGRect(x: 0, y: 0, width: tabBarController.tabBar.frame.width, height: 0.5)
        topline.backgroundColor = UIColor(r: 240, g: 240, b: 240).cgColor
        tabBarController.tabBar.layer.addSublayer(topline)
        
        tabBarController.transitioningDelegate = self
        
        let navigationController = NavigationPresenter.create(with: viewModelLocator)
        navigationController.tabBarItem.image = Asset.home.image
        navigationController.tabBarItem.imageInsets = imageInsets
        
        let goalNavigationController = GoalNavigationPresenter.create(with: viewModelLocator)
        goalNavigationController.tabBarItem.image = Asset.goals.image
        goalNavigationController.tabBarItem.imageInsets = imageInsets
        
        let weeklySummary = WeeklySummaryPresenter.create(with: viewModelLocator)
        weeklySummary.tabBarItem.image = Asset.icChart.image
        weeklySummary.tabBarItem.imageInsets = imageInsets
        
        tabBarController.viewControllers = [goalNavigationController, navigationController, weeklySummary]

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
