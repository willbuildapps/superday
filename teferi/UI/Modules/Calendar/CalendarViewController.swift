import UIKit
import RxSwift

class CalendarViewController : UIViewController
{
    fileprivate var viewModel : CalendarViewModel!
    private var presenter : CalendarPresenter!
    
    private let calendarCell = "CalendarCell"
    
    @IBOutlet weak fileprivate var monthLabel : UILabel!
    @IBOutlet weak fileprivate var leftButton : UIButton!
    @IBOutlet weak fileprivate var rightButton : UIButton!
    @IBOutlet weak fileprivate var dayOfWeekLabels : UIStackView!
    @IBOutlet weak fileprivate var calendarBackgroundView : UIView!
    @IBOutlet weak fileprivate var calendarView : CalendarView!
    @IBOutlet weak private var semiTransparentView: UIView!
    @IBOutlet weak private var calendarHeightConstraint : NSLayoutConstraint!
    
    private lazy var viewsToAnimate : [UIView] =
    {
        [
            self.calendarBackgroundView,
            self.semiTransparentView,
            self.calendarView,
            self.monthLabel,
            self.dayOfWeekLabels,
            self.leftButton,
            self.rightButton
        ]
    }()
    
    private var disposeBag = DisposeBag()
    
    func inject(presenter:CalendarPresenter, viewModel: CalendarViewModel)
    {
        self.presenter = presenter
        self.viewModel = viewModel
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        calendarView.setup(startDate: viewModel.minValidDate, endDate: viewModel.maxValidDate, viewModel: viewModel)
        calendarView.calendarDelegate = self
        
        leftButton.rx.tap
            .subscribe(onNext: calendarView.goToPreviousMonth)
            .disposed(by: disposeBag)
        
        rightButton.rx.tap
            .subscribe(onNext: calendarView.goToNextMonth)
            .disposed(by: disposeBag)
        
        viewModel.selectedDate
            .drive(onNext: calendarView.setSelectedDate)
            .disposed(by: disposeBag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CalendarViewController.backgroundTapped))
        semiTransparentView.addGestureRecognizer(tap)
    }
    
    @objc
    private func backgroundTapped()
    {
        hide()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        viewsToAnimate.forEach { v in
            v.alpha = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        show()
    }
    
    func hide()
    {
        UIView.animate(
            withDuration: 0.225,
            animations: {
                self.viewsToAnimate.forEach { v in
                    v.alpha = 0
                    v.transform = CGAffineTransform(translationX: 0, y: -20)
                }
            },
            completion: { _ in
                self.presenter.dismiss()
            }
        )
    }

    
    private func show()
    {
        self.viewsToAnimate.forEach { v in
            v.transform = CGAffineTransform(translationX: 0, y: -20)
        }
        
        UIView.animate(withDuration: 0.225)
        {
            self.viewsToAnimate.forEach { v in
                v.alpha = 1
                v.transform = CGAffineTransform.identity
            }
        }
    }
 
    fileprivate func setCalendarHeight(forDate date: Date)
    {
        let startDay = (date.dayOfWeek + 6) % 7
        let daysInMonth = date.daysInMonth
        var numberOfRows = (startDay + daysInMonth) / 7
        
        if (startDay + daysInMonth) % 7 != 0 { numberOfRows += 1 }
        
        let cellHeight = calendarView.bounds.height / 6
                
        let calendarHeight = calendarView.frame.origin.y + cellHeight * CGFloat(numberOfRows)
        
        calendarHeightConstraint.constant = calendarHeight
        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func setHeader(forDate date: Date)
    {
        let monthName = DateFormatter().monthSymbols[(date.month - 1) % 12]

        let string = NSMutableAttributedString(string: "\(monthName) ",
            attributes: [ NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14) ])
        string.append(NSAttributedString(string: String(date.year),
                                         attributes: [ NSAttributedStringKey.foregroundColor: Style.Color.offBlackTransparent, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14) ]))
        monthLabel.attributedText = string
    }
    
    fileprivate func setButtonStatus(forDate date: Date)
    {
        leftButton.isEnabled = date.month != viewModel.minValidDate.month
        rightButton.isEnabled =  date.month != viewModel.maxValidDate.month
    }
}

extension CalendarViewController: CalendarDelegate
{
    func didChange(month date: Date)
    {
        setHeader(forDate: date)
        setCalendarHeight(forDate: date)
        setButtonStatus(forDate: date)
    }
    
    func didSelect(day: Date)
    {
        viewModel.setSelectedDate(date: day)
        hide()
    }
}
