import UIKit

class ShortTimelineCell: UITableViewCell
{
    static let cellIdentifier = "shortTimelineCell"
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var activityTag: ActivityTagView!
    
    var timelineItem: TimelineItem? = nil {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        startLabel.textColor = UIColor.normalGray
    }
    
    private func configure()
    {
        guard let timelineItem = timelineItem else { return }
        
        startLabel.text = timelineItem.slotTimeText
        durationLabel.text = timelineItem.elapsedTimeText
        durationLabel.textColor = timelineItem.category.color
        
        activityTag.configure(name: timelineItem.activityTagText ?? L10n.movement, amount: timelineItem.timeSlots.count)
    }
}
