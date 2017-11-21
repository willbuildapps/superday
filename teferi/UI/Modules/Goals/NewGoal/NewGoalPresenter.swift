import Foundation

class NewGoalPresenter
{
    private weak var viewController : NewGoalViewController!
    private let viewModelLocator : ViewModelLocator
    
    private init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator, goalToBeEdited: Goal? = nil) -> NewGoalViewController
    {
        let presenter = NewGoalPresenter(viewModelLocator: viewModelLocator)
        let viewModel = viewModelLocator.getNewGoalViewModel(goalToBeEdited: goalToBeEdited)
        
        let viewController = StoryboardScene.Goal.instantiateNewGoal()
        viewController.inject(presenter: presenter, viewModel: viewModel)
        presenter.viewController = viewController
        
        return viewController
    }
    
    func dismiss()
    {
        viewController.dismiss(animated: true)
    }
}
