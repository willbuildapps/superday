import Foundation
import UIKit

class OnboardingPresenter
{
    //MARK: Private Properties
    private weak var viewController : OnboardingViewController!
    private let viewModelLocator : ViewModelLocator
    
    //MARK: Initializer
    private init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator) -> OnboardingViewController
    {
        let presenter = OnboardingPresenter(viewModelLocator: viewModelLocator)
        
        let viewController = StoryboardScene.Onboarding.instantiateOnboarding()
        viewController.inject(presenter: presenter, viewModel: viewModelLocator.getOnboardingViewModel())
        
        presenter.viewController = viewController
        
        return viewController
    }
    
    //MARK: Public Methods
    func showMain()
    {
        let imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        let tabBarController = UITabBarController()
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.barTintColor = .white
        
        let topline = CALayer()
        topline.frame = CGRect(x: 0, y: 0, width: tabBarController.tabBar.frame.width, height: 0.5)
        topline.backgroundColor = UIColor(r: 240, g: 240, b: 240).cgColor
        tabBarController.tabBar.layer.addSublayer(topline)
        
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
