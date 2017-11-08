import UIKit
import RxSwift

class NewGoalViewController: UIViewController
{
    private let hourInSeconds: Double = 60*60
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var topDescriptionLabel: UILabel!
    @IBOutlet private weak var timeDescriptionLabel: UILabel!
    @IBOutlet private weak var middleDescriptionLabel: UILabel!
    @IBOutlet private weak var newGoalButton: UIButton!
    private var timePicker: HorizontalPicker<TimeInterval>!
    private let timePickerCellSize = CGSize(width: 50.0, height: 30.0)
    private var categoryPicker: HorizontalPicker<Category>!
    private let categoryPickerCellSize = CGSize(width: 52.0, height: 64)
    
    private var viewModel: NewGoalViewModel!
    private var presenter: NewGoalPresenter!
    private let disposeBag = DisposeBag()
    
    func inject(presenter: NewGoalPresenter, viewModel: NewGoalViewModel)
    {
        self.presenter = presenter
        self.viewModel = viewModel
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        titleLabel.text = L10n.newGoalTitle
        topDescriptionLabel.text = L10n.newGoalTopDescription
        middleDescriptionLabel.text = L10n.newGoalMiddleDescription
        newGoalButton.setTitle(L10n.newGoalActionButtonTitle, for: .normal)

        timePicker = HorizontalPicker<TimeInterval>()
        view.addSubview(timePicker)
        timePicker.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topDescriptionLabel.snp.bottom).offset(17)
            make.height.equalTo(timePickerCellSize.height)
        }
        
        let timeGradientOverlay = PickerGradientOverlay(withframe: timePicker.frame, cellSize: timePickerCellSize)
        view.addSubview(timeGradientOverlay)
        timeGradientOverlay.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topDescriptionLabel.snp.bottom).offset(17)
            make.height.equalTo(timePickerCellSize.height)
        }
        
        categoryPicker = HorizontalPicker<Category>()
        view.addSubview(categoryPicker)
        categoryPicker.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(middleDescriptionLabel.snp.bottom).offset(20)
            make.height.equalTo(categoryPickerCellSize.height)
        }
        
        let categoryGradientOverlay = PickerGradientOverlay(withframe: timePicker.frame, cellSize: categoryPickerCellSize)
        view.addSubview(categoryGradientOverlay)
        categoryGradientOverlay.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(middleDescriptionLabel.snp.bottom).offset(20)
            make.height.equalTo(categoryPickerCellSize.height)
        }
        
        createBindings()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        if !timePicker.isAlreadySetup
        {
            let values: [TimeInterval] = [hourInSeconds, 1.5*hourInSeconds, 2*hourInSeconds, 3*hourInSeconds, 4*hourInSeconds, 5*hourInSeconds, 6*hourInSeconds, 7*hourInSeconds, 8*hourInSeconds, 9*hourInSeconds, 10*hourInSeconds, 30*60, 45*60]
            timePicker.setup(withItems: values, viewForItem: viewForTimePickerItem, viewSize: timePickerCellSize, numberOfVisibleViews: 5)
        }
        
        if !categoryPicker.isAlreadySetup
        {
            let values: [Category] = viewModel.categories
            categoryPicker.setup(withItems: values, viewForItem: viewForCategoryPickerItem, viewSize: categoryPickerCellSize, numberOfVisibleViews: 5)
        }
    }
    
    private func createBindings()
    {
        closeButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.presenter.dismiss()
            })
            .addDisposableTo(self.disposeBag)
        
        timePicker.selectionItemObservable
            .subscribe(onNext: { [unowned self] (duration) in
                if duration < self.hourInSeconds
                {
                    self.timeDescriptionLabel.text = L10n.minutes
                }
                else if duration == self.hourInSeconds
                {
                    self.timeDescriptionLabel.text = L10n.hour
                }
                else
                {
                    self.timeDescriptionLabel.text = L10n.hours
                }
            })
            .addDisposableTo(disposeBag)
        
        timePicker.selectionItemObservable
            .bindTo(viewModel.durationSelectedVariable)
            .addDisposableTo(disposeBag)
        
        categoryPicker.selectionItemObservable
            .bindTo(viewModel.categorySelectedVariable)
            .addDisposableTo(disposeBag)
        
        newGoalButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.createNewGoal()
                self.presenter.dismiss()
            })
            .addDisposableTo(disposeBag)
    }
    
    private func viewForTimePickerItem(_ duration: TimeInterval, viewSize: CGSize) -> UIView
    {
        let label = UILabel(frame: CGRect(origin: .zero, size: viewSize))
        
        let value = duration < hourInSeconds ?
            String(format: "%02d", (Int(duration) / 60) % 60) :
            duration == 1.5*hourInSeconds ?
                String(format: "%.1f", (duration / 3600)) :
                String(format: "%.01d", (Int(duration) / 3600))
        
        label.text = value
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightSemibold)
        label.textAlignment = .center
        label.textColor = Color.almostBlack
        return label
    }
    
    private func viewForCategoryPickerItem(_ category: Category, viewSize: CGSize) -> UIView
    {
        let view = CategoryWithNameView.fromNib()
        view.frame = CGRect(origin: .zero, size: viewSize)
        view.category = category
        return view
    }
}
