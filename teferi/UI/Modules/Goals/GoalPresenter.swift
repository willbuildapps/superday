import Foundation

class GoalPresenter
{
    private weak var viewController : GoalViewController!
    private let viewModelLocator : ViewModelLocator
    
    private init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator) -> GoalViewController
    {
        let presenter = GoalPresenter(viewModelLocator: viewModelLocator)
        let viewModel = viewModelLocator.getGoalViewModel()
        
        let viewController = StoryboardScene.Goal.instantiateGoal()
        viewController.inject(presenter: presenter, viewModel: viewModel)
        presenter.viewController = viewController
        
        return viewController
    }
}
