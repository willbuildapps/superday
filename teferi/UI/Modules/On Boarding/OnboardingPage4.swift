import UIKit
import RxSwift

class OnboardingPage4 : OnboardingPage
{
    private var disposeBag : DisposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: nil)
    }
    
    override func startAnimations()
    {
        viewModel.requestCoreMotionAuthorization()
        
        viewModel.motionAuthorizationChangedObservable
            .subscribe(onNext: finish)
            .addDisposableTo(disposeBag)
    }
}
