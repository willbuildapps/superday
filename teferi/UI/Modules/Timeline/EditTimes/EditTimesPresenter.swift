import Foundation

class EditTimesPresenter
{
    private weak var viewController : EditTimesViewController!
    private let viewModelLocator : ViewModelLocator

    private init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator, slotStartTime: Date, editingStart: Bool) -> EditTimesViewController
    {
        let presenter = EditTimesPresenter(viewModelLocator: viewModelLocator)
        let viewModel = viewModelLocator.getEditTimesViewModel(for: slotStartTime, editingStart: editingStart)
        
        let viewController = StoryboardScene.Main.instantiateEditTimes()
        viewController.inject(presenter: presenter, viewModel: viewModel)
        presenter.viewController = viewController
        
        return viewController
    }
    
    func dismiss()
    {
        viewController.dismiss(animated: true, completion: nil)
    }
}
