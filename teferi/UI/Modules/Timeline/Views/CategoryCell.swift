import UIKit
import RxSwift

class CategoryCell: UITableViewCell
{
    static let cellIdentifier = "CategoryCell"
    
    @IBOutlet private(set) weak var categoryCircle: UIView!
    @IBOutlet private weak var categoryButton : UIButton!
    @IBOutlet private weak var categoryIcon: UIImageView!
    @IBOutlet private weak var categoryLabel: UILabel!
    
    private(set) var slotTimelineItem: SlotTimelineItem?
    
    var editClickObservable : Observable<SlotTimelineItem> {
        return self.categoryButton.rx.tap
            .mapTo(self.slotTimelineItem)
            .filterNil()
            .asObservable()
    }
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func configure(slotTimelineItem: SlotTimelineItem)
    {
        self.slotTimelineItem = slotTimelineItem
        
        categoryCircle.backgroundColor = slotTimelineItem.category.color
        let image = UIImage(asset: slotTimelineItem.category.icon)!
        categoryIcon.image = image
        categoryIcon.contentMode = .scaleAspectFit
        
        categoryLabel.text = slotTimelineItem.category.description
    }
}
