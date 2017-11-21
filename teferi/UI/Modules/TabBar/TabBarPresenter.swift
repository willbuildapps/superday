import UIKit

class TabBarPresenter
{
    private weak var viewController : UITabBarController!
    private let viewModelLocator : ViewModelLocator
    
    private init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator) -> UITabBarController
    {
        let presenter = TabBarPresenter(viewModelLocator: viewModelLocator)
        
        let imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        let tabBarController = UITabBarController()
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.barTintColor = .white
        tabBarController.tabBar.tintColor = UIColor(r: 81, g: 105, b: 229)
        tabBarController.tabBar.unselectedItemTintColor = UIColor(r: 183, g: 185, b: 187)
        
        presenter.viewController = tabBarController
        
        let topline = CALayer()
        topline.frame = CGRect(x: 0, y: 0, width: tabBarController.tabBar.frame.width, height: 0.5)
        topline.backgroundColor = UIColor(r: 240, g: 240, b: 240).cgColor
        tabBarController.tabBar.layer.addSublayer(topline)
        
        let mainViewController = MainPresenter.create(with: viewModelLocator)
        let navigationController = NavigationPresenter.create(with: viewModelLocator, rootViewController: mainViewController)
        navigationController.tabBarItem.image = Asset.home.image
        navigationController.tabBarItem.imageInsets = imageInsets
        
        let goalViewController = GoalPresenter.create(with: viewModelLocator)
        let goalNavigationController = NavigationPresenter.create(with: viewModelLocator, rootViewController: goalViewController)
        goalNavigationController.tabBarItem.image = Asset.goals.image
        goalNavigationController.tabBarItem.imageInsets = imageInsets
        
        let weeklySummaryViewController = WeeklySummaryPresenter.create(with: viewModelLocator)
        let weeklySummary = NavigationPresenter.create(with: viewModelLocator, rootViewController: weeklySummaryViewController)
        weeklySummary.tabBarItem.image = Asset.icChart.image
        weeklySummary.tabBarItem.imageInsets = imageInsets
        
        let settingsViewController = SettingsPresenter.create(with: viewModelLocator)
        let settingsNavigationController = NavigationPresenter.create(with: viewModelLocator, rootViewController: settingsViewController)
        settingsNavigationController.tabBarItem.image = Asset.icSettings.image
        settingsNavigationController.tabBarItem.imageInsets = imageInsets
        
        tabBarController.viewControllers = [navigationController,
                                            goalNavigationController,
                                            weeklySummary,
                                            settingsNavigationController]
        
        return tabBarController
    }
}
