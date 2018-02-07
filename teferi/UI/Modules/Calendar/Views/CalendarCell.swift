import UIKit
import RxSwift

class CalendarCell : UICollectionViewCell
{
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var activity : CalendarDailyActivityView!
    @IBOutlet weak var customBackground: UIView!
    
    private let fontSize = CGFloat(14.0)
    
    private var disposeBag = DisposeBag()
    
    override var isSelected: Bool {
        didSet {
            
            //These two lines are here so they don't mess with the animation when showing the cell for the first time 
            customBackground.layer.cornerRadius = 14
            customBackground.backgroundColor = Style.Color.gray
            
            customBackground.alpha = isSelected ? 0.24 : 0
            dateLabel.font = isSelected ? UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium) : UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        customBackground.alpha = 0.0
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        isSelected = false
        disposeBag = DisposeBag()
    }
    
    func configure(date: Date?, enabled: Bool, activities: Observable<[Activity]>)
    {
        guard let date = date else {
            self.isHidden = true
            return
        }
        
        self.isHidden = false
        
        dateLabel.text = String(date.day)
        dateLabel.textColor = UIColor.black
        
        contentView.alpha = enabled ? 1.0 : 0.6
        isUserInteractionEnabled = enabled
        
        activities
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: activity.update)
            .disposed(by: disposeBag)
    }
}
