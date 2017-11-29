import UIKit

class NavigationPresenter : NSObject
{
    private weak var viewController : NavigationController!
    private let viewModelLocator : ViewModelLocator

    private init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create<T: UIViewController>(with viewModelLocator: ViewModelLocator, rootViewController: T) -> NavigationController
    {
        let presenter = NavigationPresenter(viewModelLocator: viewModelLocator)
        
        let viewController = NavigationController(rootViewController: rootViewController)
        viewController.inject(presenter: presenter, viewModel: viewModelLocator.getNavigationViewModel(forViewController: rootViewController))
        
        presenter.viewController = viewController
        
        return viewController
    }
}
