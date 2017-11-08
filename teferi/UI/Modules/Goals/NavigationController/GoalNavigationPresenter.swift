import Foundation

class GoalNavigationPresenter : NSObject
{
    private weak var viewController : GoalNavigationController!
    private let viewModelLocator : ViewModelLocator
    
    private var calendarViewController : CalendarViewController? = nil
    
    private init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator) -> GoalNavigationController
    {
        let presenter = GoalNavigationPresenter(viewModelLocator: viewModelLocator)
        
        let goalViewController = GoalPresenter.create(with: viewModelLocator)
        let viewController = StoryboardScene.Goal.instantiateGoalNavigation() //GoalNavigationController(rootViewController: goalViewController)
        viewController.pushViewController(goalViewController, animated: false)
        
        presenter.viewController = viewController
        
        return viewController
    }
}
