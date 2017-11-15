import UIKit
import RxSwift
import MessageUI
import CoreMotion
import CoreGraphics
import QuartzCore
import SnapKit

class MainViewController : UIViewController, MFMailComposeViewControllerDelegate
{
    // MARK: Private Properties
    private var viewModel : MainViewModel!
    private var presenter : MainPresenter!

    private var pagerViewController : PagerViewController!
    
    private let disposeBag = DisposeBag()
    
    private var addButton : AddTimeSlotView!
    private var calendarButton : UIButton!
    
    @IBOutlet private weak var welcomeMessageView: WelcomeView!
    
    func inject(presenter:MainPresenter, viewModel: MainViewModel)
    {
        self.presenter = presenter
        self.viewModel = viewModel
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        pagerViewController = presenter.setupPagerViewController(vc: self.childViewControllers.firstOfType())
        
        //Add button
        addButton = (Bundle.main.loadNibNamed("AddTimeSlotView", owner: self, options: nil)?.first) as? AddTimeSlotView
        addButton.categoryProvider = viewModel.categoryProvider
        view.addSubview(addButton)
        addButton.constrainEdges(to: view)
        
        //Add fade overlay at bottom of timeline
        let bottomFadeOverlay = fadeOverlay(startColor: UIColor.white,
                                                 endColor: UIColor.white.withAlphaComponent(0.0))
        
        let fadeView = AutoResizingLayerView(layer: bottomFadeOverlay)
        fadeView.isUserInteractionEnabled = false
        view.insertSubview(fadeView, belowSubview: addButton)
        fadeView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(view)
            make.height.equalTo(100)
        }
        
        calendarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        calendarButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        calendarButton.setBackgroundImage(Image(asset: Asset.icCalendar), for: .normal)
        calendarButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.presenter.toggleCalendar()
            })
            .addDisposableTo(disposeBag)
        
        setupNavigationBar()
        
        createBindings()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        viewModel.active = true
        
        if viewModel.shouldShowCMAccessForExistingUsers
        {
            presenter.showCMAccessForExistingUsers()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        viewModel.active = false
    }
    
    // MARK: Private Methods
    
    private func createBindings()
    {
        //Category creation
        addButton
            .categoryObservable
            .subscribe(onNext: viewModel.addNewSlot)
            .addDisposableTo(disposeBag)
        
        viewModel
            .dateObservable
            .subscribe(onNext: onDateChanged)
            .addDisposableTo(disposeBag)
        
        viewModel.showPermissionControllerObservable
            .subscribe(onNext: presenter.showPermissionController)
            .addDisposableTo(disposeBag)
        
        viewModel.welcomeMessageHiddenObservable
            .bindTo(welcomeMessageView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        viewModel.moveToForegroundObservable
            .subscribe(onNext: onBecomeActive)
            .addDisposableTo(disposeBag)
        
        viewModel.locating
            .bindTo(LoadingView.locating.rx.isActive)
            .addDisposableTo(disposeBag)
        
        viewModel.generating
            .bindTo(LoadingView.generating.rx.isActive)
            .addDisposableTo(disposeBag)
        
        viewModel.calendarDay
            .bindTo(calendarButton.rx.title(for: .normal))
            .addDisposableTo(disposeBag)
    }
    
    private func onBecomeActive()
    {
        if viewModel.shouldShowWeeklyRatingUI
        {
            presenter.showWeeklyRating(fromDate: viewModel.weeklyRatingStartDate, toDate: viewModel.weeklyRatingEndDate)
        }
    }
    
    private func onDateChanged(date: Date)
    {
        let today = viewModel.currentDate
        let isToday = today.ignoreTimeComponents() == date.ignoreTimeComponents()
        let alpha = CGFloat(isToday ? 1 : 0)
        
        UIView.animate(withDuration: 0.3)
        {
            self.addButton.alpha = alpha
        }
        
        addButton.close()
        addButton.isUserInteractionEnabled = isToday
    }
    
    private func fadeOverlay(startColor: UIColor, endColor: UIColor) -> CAGradientLayer
    {
        let fadeOverlay = CAGradientLayer()
        fadeOverlay.colors = [startColor.cgColor, endColor.cgColor]
        fadeOverlay.locations = [0.1]
        fadeOverlay.startPoint = CGPoint(x: 0.0, y: 1.0)
        fadeOverlay.endPoint = CGPoint(x: 0.0, y: 0.0)
        return fadeOverlay
    }
    
    private func setupNavigationBar()
    {
        let buttonItems = [
            .createFixedSpace(of: 8),
            UIBarButtonItem(customView: calendarButton)
        ]
        
        var rightItems = navigationItem.rightBarButtonItems ?? []
        rightItems.insert(contentsOf: buttonItems, at: 0)
        
        navigationItem.rightBarButtonItems = rightItems
    }
}
